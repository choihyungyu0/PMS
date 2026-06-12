param(
    [string]$BackendHost = "",
    [int]$BackendPort = 8000,
    [switch]$SkipPubGet
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

if ([string]::IsNullOrWhiteSpace($BackendHost)) {
    $DefaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
        Sort-Object RouteMetric, InterfaceMetric |
        Select-Object -First 1

    if ($null -ne $DefaultRoute) {
        $BackendHost = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $DefaultRoute.InterfaceIndex |
            Where-Object {
                $_.IPAddress -notlike "127.*" -and
                $_.IPAddress -notlike "169.254.*" -and
                $_.AddressState -eq "Preferred"
            } |
            Select-Object -ExpandProperty IPAddress -First 1
    }
}

if ([string]::IsNullOrWhiteSpace($BackendHost)) {
    $BackendHost = Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*" -and
            $_.AddressState -eq "Preferred" -and
            $_.PrefixOrigin -ne "Manual"
        } |
        Select-Object -ExpandProperty IPAddress -First 1
}

if ([string]::IsNullOrWhiteSpace($BackendHost)) {
    throw "No local IPv4 address was found. Pass -BackendHost manually, for example: .\scripts\build-release-apk.ps1 -BackendHost 192.168.0.12"
}

$ApiBaseUrl = "http://${BackendHost}:$BackendPort"
Write-Host "Building MORE Cycle release APK with API_BASE_URL=$ApiBaseUrl"

if (-not $SkipPubGet) {
    flutter pub get
}

flutter build apk --release "--dart-define=API_BASE_URL=$ApiBaseUrl"

$ApkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "APK ready: $ApkPath"
