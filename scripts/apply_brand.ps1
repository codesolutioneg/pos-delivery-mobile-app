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

$config = Get-Content $Defines -Raw | ConvertFrom-Json
$brandName = $config.BRAND_NAME
$appId = $config.APP_ID

Write-Host "Applying brand: $Brand ($brandName)"

$manifest = Join-Path $Root "android\app\src\main\AndroidManifest.xml"
(Get-Content $manifest -Raw) -replace 'android:label="[^"]*"', "android:label=`"$brandName`"" |
    Set-Content $manifest -NoNewline

$gradle = Join-Path $Root "android\app\build.gradle.kts"
(Get-Content $gradle -Raw) -replace 'applicationId = "[^"]*"', "applicationId = `"$appId`"" |
    Set-Content $gradle -NoNewline

$plist = Join-Path $Root "ios\Runner\Info.plist"
if (Test-Path $plist) {
    (Get-Content $plist -Raw) -replace '(?<=<key>CFBundleDisplayName</key>\s*<string>)[^<]*', $brandName |
        Set-Content $plist -NoNewline
}

$configDir = Join-Path $Root "deploy_configs\$Brand"
$active = Join-Path $Root "brand_assets\active"
New-Item -ItemType Directory -Force -Path $active | Out-Null

$iconSrc = Join-Path $configDir "icon.png"
if (Test-Path $iconSrc) {
    Copy-Item $iconSrc (Join-Path $active "icon.png") -Force
    Write-Host "Icon copied from deploy_configs/$Brand/icon.png"
} else {
    Write-Host "No deploy_configs/$Brand/icon.png - keeping current brand_assets/active/icon.png"
}

$splashSrc = Join-Path $configDir "splash.png"
if (Test-Path $splashSrc) {
    Copy-Item $splashSrc (Join-Path $active "splash.png") -Force
} elseif (Test-Path (Join-Path $active "icon.png")) {
    Copy-Item (Join-Path $active "icon.png") (Join-Path $active "splash.png") -Force
}

$gs = Join-Path $configDir "google-services.json"
if (Test-Path $gs) {
    Copy-Item $gs (Join-Path $Root "android\app\google-services.json") -Force
    Write-Host "Copied google-services.json"
}

Set-Location $Root
flutter pub get
if (Test-Path (Join-Path $active "icon.png")) {
    dart run flutter_launcher_icons
}
if (Test-Path (Join-Path $active "splash.png")) {
    dart run flutter_native_splash:create
}

Write-Host "Brand applied. Run: flutter run --dart-define-from-file=deploy_configs/${Brand}/defines.json"
