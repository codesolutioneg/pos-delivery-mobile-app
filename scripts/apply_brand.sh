#!/usr/bin/env bash
# Applies white-label native + asset config for one brand of the driver app.
set -euo pipefail

BRAND="${1:?Usage: apply_brand.sh <brand>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$ROOT/deploy_configs/$BRAND"
DEFINES="$CONFIG_DIR/defines.json"

if [[ ! -f "$DEFINES" ]]; then
  echo "Missing $DEFINES" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

BRAND_NAME="$(jq -r '.BRAND_NAME' "$DEFINES")"
APP_ID="$(jq -r '.APP_ID' "$DEFINES")"

echo "Applying brand: $BRAND ($BRAND_NAME)"

MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"
sed -i.bak "s/android:label=\"[^\"]*\"/android:label=\"$BRAND_NAME\"/" "$MANIFEST"
rm -f "$MANIFEST.bak"

GRADLE="$ROOT/android/app/build.gradle.kts"
sed -i.bak "s/applicationId = \"[^\"]*\"/applicationId = \"$APP_ID\"/" "$GRADLE"
rm -f "$GRADLE.bak"

PLIST="$ROOT/ios/Runner/Info.plist"
if [[ -f "$PLIST" ]]; then
  # Replaces the <string> right after CFBundleDisplayName.
  perl -0pi -e "s|(<key>CFBundleDisplayName</key>\s*<string>)[^<]*|\${1}$BRAND_NAME|" "$PLIST"
fi

# iOS product bundle identifier (Runner target only — skip RunnerTests)
PBXPROJ="$ROOT/ios/Runner.xcodeproj/project.pbxproj"
if [[ -f "$PBXPROJ" ]]; then
  python3 - <<PY
from pathlib import Path
path = Path(r"""$PBXPROJ""")
lines = []
for line in path.read_text().splitlines(True):
    if "PRODUCT_BUNDLE_IDENTIFIER" in line and "RunnerTests" not in line:
        indent = line[: len(line) - len(line.lstrip())]
        lines.append(f"{indent}PRODUCT_BUNDLE_IDENTIFIER = $APP_ID;\n")
    else:
        lines.append(line)
path.write_text("".join(lines))
print(f"iOS bundle id set to $APP_ID")
PY
fi

ACTIVE="$ROOT/brand_assets/active"
mkdir -p "$ACTIVE"

if [[ -f "$CONFIG_DIR/icon.png" ]]; then
  cp "$CONFIG_DIR/icon.png" "$ACTIVE/icon.png"
  echo "Icon copied from deploy_configs/$BRAND/icon.png"
else
  echo "No deploy_configs/$BRAND/icon.png - keeping current brand_assets/active/icon.png"
fi

if [[ -f "$CONFIG_DIR/splash.png" ]]; then
  cp "$CONFIG_DIR/splash.png" "$ACTIVE/splash.png"
elif [[ -f "$ACTIVE/icon.png" ]]; then
  cp "$ACTIVE/icon.png" "$ACTIVE/splash.png"
fi

if [[ -f "$CONFIG_DIR/google-services.json" ]]; then
  cp "$CONFIG_DIR/google-services.json" "$ROOT/android/app/google-services.json"
  echo "Copied google-services.json"
fi

cd "$ROOT"
flutter pub get
[[ -f "$ACTIVE/icon.png" ]] && dart run flutter_launcher_icons
[[ -f "$ACTIVE/splash.png" ]] && dart run flutter_native_splash:create

# Keep the native launch image fully visible (not clipped) on every iPhone size.
STORYBOARD="$ROOT/ios/Runner/Base.lproj/LaunchScreen.storyboard"
if [[ -f "$STORYBOARD" ]]; then
  perl -pi -e 's/contentMode="center"/contentMode="scaleAspectFit"/g' "$STORYBOARD"
fi

echo "Brand applied. Run: flutter run --dart-define-from-file=deploy_configs/$BRAND/defines.json"
