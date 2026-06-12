$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = Split-Path -Parent $ProjectRoot
$ToolsDir = Join-Path $RepoRoot ".tools"
$BackendPidFile = Join-Path $ToolsDir "more-cycle-backend.pid"
$TunnelPidFile = Join-Path $ToolsDir "more-cycle-cloudflared.pid"

function Stop-ProcessFromPidFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    $ProcessId = (Get-Content $Path -Raw).Trim()
    if (-not [string]::IsNullOrWhiteSpace($ProcessId)) {
        $Process = Get-Process -Id ([int]$ProcessId) -ErrorAction SilentlyContinue
        if ($null -ne $Process) {
            Stop-Process -Id $Process.Id -Force
            Write-Host "Stopped process $($Process.Id)"
        }
    }

    Remove-Item -LiteralPath $Path -Force
}

Stop-ProcessFromPidFile -Path $TunnelPidFile
Stop-ProcessFromPidFile -Path $BackendPidFile
Write-Host "MORE Cycle public backend processes stopped."
