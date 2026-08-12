# Per-brand deploy configs (driver app)

One folder per brand. Same layout as the customer app.

```
deploy_configs/<brand>/
  defines.json          # required — dart-defines + APP_ID
  icon.png              # brand logo (login screen, launcher icon, native splash)
  splash.png            # optional — defaults to icon.png
  google-services.json  # optional — copied to android/app/
```

## Apply a brand, then run

```powershell
.\scripts\apply_brand.ps1 -Brand balkans
flutter run --dart-define-from-file=deploy_configs/balkans/defines.json
```

`apply_brand` sets the Android label/applicationId + iOS display name, copies
`icon.png`/`splash.png` into `brand_assets/active/`, then regenerates the
launcher icons and the native launch screen.

`brand_assets/active/icon.png` is the asset the app reads at runtime
(`AppAssets.brandLogo`) — it is what the login screen and the animated splash
show. It is checked in with the current default brand.

## Release APK

```powershell
.\scripts\build_brand.ps1 -Brand balkans   # → build/artifacts/dishflow-delivery-balkans-release.apk
```

`defines.json` keys map to `AppConfig`: `BASE_URL`, `BRAND_ID`, `BRAND_NAME`,
`RESTAURANT_KEY`, `PRIMARY_COLOR` (decimal ARGB). `APP_ID` is native-only.

> `PRIMARY_COLOR` = `4294933173` (`0xFFFF6B35`) is treated by
> `AppColors.brandPrimary` as "not set" and falls back to the driver blue —
> pick any other value to actually override the brand color.
