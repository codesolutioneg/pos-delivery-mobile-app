# AGENTS.md — Operating manual for any AI working in the **driver app**

Read this file **before** touching code. It is the same contract every agent
(Claude Code, Cursor, Continue, or a human) works under.
`docs/STATE.md` is the *current facts*; this file is the *method*.

Scope: `E:\app_flutter\code-solution\delivery` (`dishflow_delivery`) — the
white-label **driver** app. The POS is `../pos_test` and the customer app is
`../dishflow-kingdom-multiresturant-mobile`; both have their own conventions.
Do not edit them unless asked — but **do** read them, because this app
deliberately copies the customer app's branding mechanism.

---

## 0. The loop (never skip a step)

1. **Read `docs/STATE.md` first.** Snapshot, architecture facts, Decisions log.
   If a decision there contradicts your idea, the decision wins — or you argue
   it explicitly and append a new dated line.
2. **Locate before editing.** Search the real code and read the whole function
   you are about to change. Never patch from memory or from a filename guess.
   Every method, field, and package version in this repo is checkable.
3. **Smallest change that fixes the root cause.** No drive-by refactors, no
   renames, no reformatting of untouched lines.
4. **Verify, and say what you ran:**
   - `flutter analyze` — must be **0 issues**. This repo is currently clean, so
     any new warning is yours. Do not accept "pre-existing lints" as an excuse.
   - `flutter test` — must stay green (6 tests today).
   - Touched native config, assets, or `pubspec.yaml`? Also
     `flutter build apk --debug --dart-define-from-file=deploy_configs/dev/defines.json`.
5. **Report honestly.** If something is half-done, say half-done. A wrong ✅ is
   worse than an honest 🟡. If you never ran it on a device, say so.
6. **Update `docs/STATE.md` last**, before saying "done": append to the Board and
   the Decisions log. Append-only — strike through (`~~…~~`) with a dated line
   instead of deleting history.

---

## 1. Hard rules — ⛔ never

- **Never claim a commit.** This repo has **no git** (no `.git`, no history). You
  cannot commit, diff, branch, or revert. State = what is on disk, which is
  exactly why `docs/STATE.md` must be accurate.
- **Never overwrite `brand_assets/active/*` by hand.** It is generated output —
  edit `deploy_configs/<brand>/icon.png` and run `scripts/apply_brand.ps1`.
- **Never hardcode a brand.** Brand name, colour, API base, restaurant key all
  come from `AppConfig` (dart-defines). The logo comes from `AppAssets.brandLogo`.
- **Never add a package without asking.** Two recent features (painted map
  markers, polyline decoding) were built without new dependencies on purpose.
- **Never remove the reroute throttle** in `DeliveryMapView` (≥150 m or ≥45 s).
  Every recompute is a billed Google request.
- **Never present an estimate as a real route.** `DeliveryRoute.isEstimate` must
  stay visible in the UI (dashed line + "approx." tag).
- **Never go back to the legacy Directions API.** It is disabled on this Google
  Cloud project — see the 2026-08-11 Decisions entry. Routes API only.
- **Never inline Arabic/English UI strings.** Add a key to both
  `lib/l10n/app_en.arb` and `app_ar.arb`, then run `flutter gen-l10n`.
- **Never truncate code** in an answer (`// ... rest of file`). Return complete,
  compilable blocks.
- **Never treat the map's GPS stream as the tracker.** `TrackingRepository` is
  still a stub; writing driver locations to RTDB is unbuilt work, not a bug to
  patch inside the map widget.

---

## 2. What this product is

Flutter **driver** app for the DishFlow POS system. One codebase, one brand per
build. The driver logs in with the username/password created for them in the
POS, then sees assigned orders, a map to the customer, and pickup/deliver flows.

- **Backend:** Firebase (Firestore for orders/drivers, per-branch project) +
  the DishFlow REST API via `DioClient` (`AppConfig.baseUrl` + `/v1`, with
  `X-Restaurant-Key`).
- **Each branch (فرع) is its own Firebase project** — 14 configs in
  `lib/firebase_configs/`. Debug picks one at launch (`_dev_firebase_client` in
  SharedPreferences); release uses the baked `lib/firebase_options.dart`.
- **Auth is TEMP and insecure by decision**: plaintext passwords in Firestore
  `drivers` + Firebase **Anonymous** sign-in. Documented in `README.md`. Don't
  "discover" it as a bug — it's on the Next-up list.

### Layout
```
lib/
  core/       config (AppConfig), constants, di, dev, error, l10n, network,
              router, theme, utils, widgets
  features/<feature>/{data,domain,presentation}   ← auth, orders, tracking,
              shell, splash, wallet, profile
  l10n/       .arb sources + generated AppLocalizations
brand_assets/active/   generated active-brand logo (do not hand-edit)
deploy_configs/<brand>/  per-brand defines.json + icon.png
scripts/      apply_brand / build_brand
docs/STATE.md live state — read first, update last
```
Clean Architecture per feature (`data` → `domain` ← `presentation`), Cubit for
state, `get_it` for DI (`lib/core/di/injection.dart`), `go_router` for routing.
New code goes in the matching `features/<feature>/`; only genuinely
cross-feature helpers belong in `lib/core/`.

---

## 3. Facts you must not re-invent

These bite silently. Full detail in `docs/STATE.md` → *Architecture*.

- **`geocoding` 5.x has no top-level functions.** Use a `Geocoding()` instance,
  created **lazily** (a static initializer runs before plugin registration).
- **`SplashGate.done` latches.** `AuthLoading` fires again on login submit; a
  non-latching gate throws the driver back to the splash mid-login.
- **Subscribe to `AuthCubit.stream` before calling `bootstrap()`**, or the first
  settled state can be missed and the splash never ends.
- **An animated splash cannot be native.** Native (`flutter_native_splash`) is
  the brand frame; the animation is the Dart `SplashPage`. The "Flutter logo"
  splash was Android 12+ using the launcher icon — fixed by regenerating assets,
  not by editing Dart.
- **The manifest Maps key cannot call the Routes API** (Android-restricted →
  `403 API_KEY_ANDROID_APP_BLOCKED`). Real routes need
  `--dart-define=MAPS_API_KEY=<unrestricted key>`.
- **`AppColors.brandPrimary` treats `0xFFFF6B35` as "unset"** and falls back to
  the driver blue — so the Balkans brand renders blue. Known, deliberate.
- **Map marker pins are painted at runtime** (`MapMarkerFactory`), anchored
  `(0.5, 1)` because the tip is at the bottom. `BitmapDescriptor.fromBytes` is
  deprecated — use `.bytes`.

---

## 4. Code style

- Flutter/Dart with `flutter_lints`. Match the file you are in: same naming,
  same widget-splitting habits, same comment density. This codebase comments
  *why*, never *what* — and it uses explicit types on locals in the `orders`
  domain layer. Follow the neighbours, not your defaults.
- `const` constructors where possible; `async/await` over `.then`;
  `unawaited(...)` for deliberate fire-and-forget.
- Async work in a `State`: guard every resume with `if (!mounted) return;`, and
  use a monotonic token (`_resolveToken` / `_routeToken` pattern) so a stale
  response cannot overwrite a newer one. Cancel stream subscriptions in
  `dispose`.
- Errors: fail visibly in driver-facing paths (banner / snackbar), degrade
  quietly with a labelled fallback for network extras like routing.
- Theme tokens only — `AppColors` / `AppTextStyles` / `AppDimensions`, never raw
  hex in a widget.
- Tests: pure logic (decoders, geometry, gates) is unit-testable and should be
  tested. Anything needing Firebase or plugins is not — this repo has no Firebase
  test harness, so extract the pure part instead of mocking the plugin.

---

## 5. Brand / build workflow

```powershell
.\scripts\apply_brand.ps1 -Brand balkans     # native names, icon, splash
flutter run --dart-define-from-file=deploy_configs/balkans/defines.json
.\scripts\build_brand.ps1 -Brand balkans     # → build/artifacts/*.apk
```
Add a brand = new `deploy_configs/<brand>/` with `defines.json` (+ `icon.png`,
optional `splash.png`, `google-services.json`). Keep this identical to the
customer app's mechanism; if you change one, note the drift in `docs/STATE.md`.

---

## 6. Answering style

- The owner writes Arabic → answer in Arabic (Egyptian is fine), but keep code,
  identifiers, and file paths in English.
- Lead with the answer. No preamble.
- Reference code as `path/to/file.dart:42`.
- Report what you verified and what you didn't. "Analyzer clean, tests green,
  not run on a device" is a complete, honest status.
- If you are unsure, say so and go read the file. Do not invent a method name,
  a Firestore field, or a package API — every one of them is checkable.
