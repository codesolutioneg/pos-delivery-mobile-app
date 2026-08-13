# Delivery app work state

Daily log for `delevary-app-dishflow`. The handoff map is still [`docs/STATE.md`](docs/STATE.md) — update that file too. No secrets.

## 2026-08-13

- Confirmed driver auth is DishFlow backend: `POST /api/v1/drivers/login`, `GET /drivers/me`. Logout now calls `POST /drivers/logout` with the stored refresh token, then clears local session. Live Flutter route test: login / me / logout 200; wrong restaurant key 401.

## 2026-08-12

- GPS writer: `FirestoreTrackingRepository` writes `driver_locations/{driverUid}` (`lat`, `lng`, `heading`, `updatedAt`). Wired in DI (replaces the stub).
- Login is `POST /drivers/login` (DishFlow JWT). Firebase Anonymous Auth is still required so `drivers/{firebaseDriverId}/orders` works. Session stores the JWT; `DriverEntity.id` is the Firestore driver doc id (`firebaseDriverId`).
