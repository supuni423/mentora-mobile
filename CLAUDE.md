# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Mentora is a Flutter student-side client (Dart SDK ^3.13.1) for the Mentora tutoring platform, consuming an existing Node/Express + PostgreSQL backend at `C:\Users\User\Desktop\Mentora\backend` (see that repo's own `CLAUDE.md` for backend internals and known quirks). Current scope is the "core loop": auth, course browsing, student profile, and enrollment (booking) requests. Tutor/admin features, the communities/feed module, and Socket.io real-time updates are not implemented here.

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run -d <device>` — pass `--dart-define=API_BASE_URL=http://<host>:5000` to point at a non-default backend (e.g. `http://10.0.2.2:5000` for an Android emulator, or a LAN IP for a physical device). Windows desktop builds need Developer Mode enabled (`start ms-settings:developers`) because plugin builds require symlink support; Chrome/web works without it.
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/<file>.dart`
- Static analysis / lint: `flutter analyze`
- Format code: `dart format .`
- Build for a platform: `flutter build <apk|ios|windows|web|...>`

The backend must be running locally (`npm run dev` in the backend repo, default `http://localhost:5000`) for most of the test suite — see Testing below.

Configured platforms: android, ios, linux, macos, web, windows.

## Architecture

Provider-based, feature-sliced. Each feature is a `service` (thin HTTP wrapper) + `provider` (ChangeNotifier state) pair; screens consume the provider via `context.watch`/`context.read`. All are constructed once in `main()` and injected via `MultiProvider.value` in `MyApp` — no `ProxyProvider` indirection.

- **`lib/config/app_config.dart`** — resolves the API base URL (per-platform default, overridable via `--dart-define=API_BASE_URL`).
- **`lib/services/api_client.dart`** — the single HTTP transport. Every feature service takes this in its constructor rather than reimplementing headers/error handling. Auto-attaches `Authorization: Bearer <token>` from `TokenStorage`. Non-2xx responses throw `ApiException(statusCode, message)`. On a 401 *while a token is set* (i.e. an active session was rejected — a 401 with no token, like a bad-password login attempt, is excluded and surfaces inline instead), it clears the token and calls `onUnauthorized`, which `AuthProvider` wires to itself in `main()`. There's no refresh-token flow on the backend, so this is the only recovery path.
- **`lib/services/token_storage.dart`** — `flutter_secure_storage`-backed singleton (`TokenStorage.instance`) caching the JWT and a small `User` record in memory after first `load()`, so `ApiClient` never awaits disk I/O per request. Has a `@visibleForTesting debugSetSession()` escape hatch used by the live integration tests (see below) to set a session without touching the platform channel.
- **`lib/providers/auth_provider.dart`** — owns `AuthStatus` (`authenticated`/`unauthenticated`) and the current `User`. Note: the app root (`HomeShell`) does **not** switch on auth status — it's always shown so course browsing stays public. Auth screens (Login/Register/Forgot/Reset) are pushed on top and `Navigator.popUntil((r) => r.isFirst)` back to it on success; gated tabs (Enrollments, Profile) show `widgets/auth_gate.dart` instead of their real content when logged out.
- **Course / Profile / Enrollment** each follow the same `models/*.dart` (defensive `fromJson`, matched against real live backend responses — see the field-shape notes below) → `services/*_service.dart` → `providers/*_provider.dart` → `screens/*/` pattern.

### Backend response shapes worth knowing before touching a service/model

Confirmed against the live backend (not assumed from route names) — several are non-obvious and easy to get wrong from PowerShell testing alone:

- `GET /api/courses/:id/reviews`, `GET /api/enrollments/me`, `GET /api/enrollments/schedule` all return a **plain JSON array**, not `{data: [...]}` or similar. (`Invoke-RestMethod | ConvertTo-Json` in PowerShell renders a raw JSON array as a fake-looking `{value: [...], Count: n}` object — that's a PowerShell display quirk, not a real API envelope. Verify response shapes against the actual Dart `http` client or raw `Invoke-WebRequest .Content`, not `ConvertTo-Json` output.)
- `POST /api/enrollments` and `PUT /api/enrollments/:id` return `{message, enrollment: {...}}` (see `Enrollment.fromWrapped`).
- `PUT /api/enrollments/:id` requires the **full field set** on every call (same shape as `POST`), not a partial patch — sending only the changed field(s) returns 400.
- `GET /api/students/profile` uses different field names (`name`, `grade`) than registration (`fullName`, `gradeLevel`) — kept as distinct types (`StudentProfile` vs. the register form fields), not unified.
- Login with bad credentials returns **400**, not 401 — `ApiClient`'s forced-logout path only triggers on 401 (an already-issued token being rejected), so this is intentionally inert for login failures.
- `PUT /api/students/profile` returns only `{message, profilePicture}`, not the full profile — callers must refetch.

## Testing

Most of the test suite hits the **live backend** (`localhost:5000`), not mocks — there's no backend test suite to develop against, so integration tests against real responses are the primary way this app's assumptions get checked. Start the backend first (`npm run dev` in the backend repo). Test student account: `testboy@gmail.com` / `testboy@123`.

Tests that call protected endpoints run under `TestWidgetsFlutterBinding` and need two things set up (see `test/student_service_smoke_test.dart` or `test/enrollment_service_smoke_test.dart` for the pattern):
1. `HttpOverrides.global = null;` — `TestWidgetsFlutterBinding` otherwise fakes every HTTP request as a 400.
2. A mock handler on the `plugins.it_nomads.com/flutter_secure_storage` method channel (no real platform channel exists in a test run) — set it in `setUp`, clear it in `tearDown`, and use `TokenStorage.instance.debugSetSession(...)` instead of `save()` to set the session in-memory only.

`test/widget_test.dart` is a plain widget smoke test (no live backend needed) confirming the public course list renders when logged out.

## Linting

Lint rules come from `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`). The `build/`, `android/`, `ios/`, `web/`, `windows/`, `macos/`, and `linux/` directories are excluded from analysis.
