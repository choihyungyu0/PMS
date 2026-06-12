param(
    [int]$BackendPort = 8000,
    [switch]$SkipPubGet,
    [switch]$RestartTunnel,
    [switch]$RestartBackend
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ProjectRoot
$BackendRoot = Join-Path $RepoRoot "backend"
$ToolsDir = Join-Path $RepoRoot ".tools"
$CloudflaredPath = Join-Path $ToolsDir "cloudflared.exe"
$BackendPidFile = Join-Path $ToolsDir "more-cycle-backend.pid"
$TunnelPidFile = Join-Path $ToolsDir "more-cycle-cloudflared.pid"
$PublicUrlFile = Join-Path $ToolsDir "more-cycle-public-url.txt"
$BackendLog = Join-Path $BackendRoot "uvicorn-public.log"
$BackendErr = Join-Path $BackendRoot "uvicorn-public.err"
$TunnelLog = Join-Path $ToolsDir "cloudflared-more-cycle.log"
$TunnelErr = Join-Path $ToolsDir "cloudflared-more-cycle.err"

New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

function Get-ProcessFromPidFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    $ProcessId = (Get-Content $Path -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace($ProcessId)) {
        return $null
    }

    return Get-Process -Id ([int]$ProcessId) -ErrorAction SilentlyContinue
}

function Stop-ProcessFromPidFile {
    param([string]$Path)

    $Process = Get-ProcessFromPidFile -Path $Path
    if ($null -ne $Process) {
        Stop-Process -Id $Process.Id -Force
    }
    if (Test-Path $Path) {
        Remove-Item -LiteralPath $Path -Force
    }
}

function Test-BackendHealth {
    param([string]$BaseUrl)

    try {
        $Response = Invoke-WebRequest -Uri "$BaseUrl/api/health" -UseBasicParsing -TimeoutSec 5
        return $Response.StatusCode -ge 200 -and $Response.StatusCode -lt 300
    } catch {
        return $false
    }
}

function Wait-BackendHealth {
    param(
        [string]$BaseUrl,
        [int]$TimeoutSeconds = 45
    )

    $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $Deadline) {
        if (Test-BackendHealth -BaseUrl $BaseUrl) {
            return
        }
        Start-Sleep -Seconds 1
    }

    throw "Backend did not become healthy at $BaseUrl. Check $BackendLog and $BackendErr."
}

function Get-PythonExecutable {
    $VenvPython = Join-Path $BackendRoot ".venv\Scripts\python.exe"
    if (Test-Path $VenvPython) {
        return $VenvPython
    }
    return "python"
}

function Ensure-Cloudflared {
    if (Test-Path $CloudflaredPath) {
        return
    }

    $DownloadUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"
    Write-Host "Downloading cloudflared to $CloudflaredPath"
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $CloudflaredPath
}

function Read-TunnelUrlFromLogs {
    $Combined = ""
    if (Test-Path $TunnelLog) {
        $Combined += Get-Content $TunnelLog -Raw
    }
    if (Test-Path $TunnelErr) {
        $Combined += Get-Content $TunnelErr -Raw
    }

    $Match = [regex]::Match($Combined, "https://[a-zA-Z0-9-]+\.trycloudflare\.com")
    if ($Match.Success) {
        return $Match.Value
    }

    return $null
}

function Ensure-Backend {
    $LocalBaseUrl = "http://127.0.0.1:$BackendPort"
    if (-not $RestartBackend -and (Test-BackendHealth -BaseUrl $LocalBaseUrl)) {
        Write-Host "Backend already healthy at $LocalBaseUrl"
        return $LocalBaseUrl
    }

    if ($RestartBackend) {
        Stop-ProcessFromPidFile -Path $BackendPidFile
    }

    Write-Host "Starting FastAPI backend at $LocalBaseUrl"
    $Python = Get-PythonExecutable
    $Process = Start-Process `
        -FilePath $Python `
        -ArgumentList @("-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", $BackendPort.ToString()) `
        -WorkingDirectory $BackendRoot `
        -WindowStyle Hidden `
        -RedirectStandardOutput $BackendLog `
        -RedirectStandardError $BackendErr `
        -PassThru
    Set-Content -Path $BackendPidFile -Value $Process.Id
    Wait-BackendHealth -BaseUrl $LocalBaseUrl
    return $LocalBaseUrl
}

function Ensure-Tunnel {
    param([string]$LocalBaseUrl)

    if ($RestartTunnel) {
        Stop-ProcessFromPidFile -Path $TunnelPidFile
        if (Test-Path $PublicUrlFile) {
            Remove-Item -LiteralPath $PublicUrlFile -Force
        }
    }

    $ExistingTunnelProcess = Get-ProcessFromPidFile -Path $TunnelPidFile
    if ($null -ne $ExistingTunnelProcess -and (Test-Path $PublicUrlFile)) {
        $ExistingUrl = (Get-Content $PublicUrlFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($ExistingUrl) -and (Test-BackendHealth -BaseUrl $ExistingUrl)) {
            Write-Host "Reusing public tunnel $ExistingUrl"
            return $ExistingUrl
        }
    }

    Ensure-Cloudflared

    Remove-Item -LiteralPath $TunnelLog, $TunnelErr -Force -ErrorAction SilentlyContinue
    Write-Host "Starting Cloudflare Tunnel for $LocalBaseUrl"
    $Process = Start-Process `
        -FilePath $CloudflaredPath `
        -ArgumentList @("tunnel", "--url", $LocalBaseUrl, "--loglevel", "info") `
        -WindowStyle Hidden `
        -RedirectStandardOutput $TunnelLog `
        -RedirectStandardError $TunnelErr `
        -PassThru
    Set-Content -Path $TunnelPidFile -Value $Process.Id

    $Deadline = (Get-Date).AddSeconds(60)
    while ((Get-Date) -lt $Deadline) {
        $PublicUrl = Read-TunnelUrlFromLogs
        if (-not [string]::IsNullOrWhiteSpace($PublicUrl)) {
            Set-Content -Path $PublicUrlFile -Value $PublicUrl
            Wait-BackendHealth -BaseUrl $PublicUrl -TimeoutSeconds 30
            return $PublicUrl
        }
        Start-Sleep -Seconds 1
    }

    throw "Cloudflare Tunnel did not publish a URL. Check $TunnelLog and $TunnelErr."
}

$LocalBaseUrl = Ensure-Backend
$PublicBaseUrl = Ensure-Tunnel -LocalBaseUrl $LocalBaseUrl

Set-Location $ProjectRoot
Write-Host "Building MORE Cycle public APK with API_BASE_URL=$PublicBaseUrl"

if (-not $SkipPubGet) {
    flutter pub get
}

flutter build apk --release "--dart-define=API_BASE_URL=$PublicBaseUrl"

$ApkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "Public backend URL: $PublicBaseUrl"
Write-Host "APK ready: $ApkPath"
Write-Host "Keep this PC, the backend, and the Cloudflare Tunnel running while testers use the APK."
