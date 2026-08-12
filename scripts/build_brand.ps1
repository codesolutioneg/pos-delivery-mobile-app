param(
    [Parameter(Mandatory = $true)]
    [string]$Brand
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Defines = Join-Path $Root "deploy_configs\$Brand\defines.json"

if (-not (Test-Path $Defines)) {
    throw "Missing $Defines"
}

& (Join-Path $Root "scripts\apply_brand.ps1") -Brand $Brand

Set-Location $Root
flutter build apk --release --dart-define-from-file=$Defines

$out = Join-Path $Root "build\app\outputs\flutter-apk\app-release.apk"
$destDir = Join-Path $Root "build\artifacts"
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$dest = Join-Path $destDir "dishflow-delivery-$Brand-release.apk"
Copy-Item $out $dest -Force
Write-Host "Built: $dest"
