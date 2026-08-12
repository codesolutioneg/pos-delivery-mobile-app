# Delivery app work state

Daily log for `delevary-app-dishflow`. The handoff map is still [`docs/STATE.md`](docs/STATE.md) — update that file too. No secrets.

## 2026-08-12

- GPS writer: `FirestoreTrackingRepository` writes `driver_locations/{driverUid}` (`lat`, `lng`, `heading`, `updatedAt`). Wired in DI (replaces the stub).
- Login is `POST /drivers/login` (DishFlow JWT). Firebase Anonymous Auth is still required so `drivers/{firebaseDriverId}/orders` works. Session stores the JWT; `DriverEntity.id` is the Firestore driver doc id (`firebaseDriverId`).
