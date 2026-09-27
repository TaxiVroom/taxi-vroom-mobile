# Commands

- After a fresh clone and after any `.env.*` change: `dart run build_runner build --delete-conflicting-outputs`. envied generates `lib/env/*.g.dart` (gitignored); the app does not compile without them.
- Run a flavor: `flutter run --flavor development --target lib/main_development.dart` (same pattern for `staging` / `production`).
- Run a single test file: `very_good test <path>`. `very_good test` never runs `pub get`: run `flutter pub get` first after changing `pubspec.yaml`.
- Bloc lint (run by CI with `very_good_analysis`): `dart run bloc_tools:bloc lint .`

# Environment

- Env files live at the repo root and are gitignored: `.env.dev`, `.env.stg`, `.env.prod` — not `.env.staging`, the names are hardcoded in `lib/env/env_*.dart`. Keys: `API_BASE_URL`, `MAPBOX_ACCESS_TOKEN` (the public `pk.` token only, never a secret one).
- `.env.dev` points to the backend on the dev machine's LAN IP, port 3000. When that IP changes, update it and rerun `build_runner`.
- `main_staging.dart` uses the production Firebase options: no staging Firebase app exists yet.

# Architecture

- Business logic belongs in domain use cases, never in blocs. Existing blocs still contain some (see their `FIXME`s): don't copy that pattern.
- Errors in new code: repositories return `Result<T>` (`lib/core/utils/result.dart`), catching technical exceptions (`DioException`, `FirebaseAuthException`) and returning `Result.error(<Failure>)` (`core/errors/failures.dart`); blocs `switch` on the result instead of using try/catch. Existing try/catch + `e.toString()` code will be migrated later: don't copy it.
- API mapping (see `document_type_model.dart`): datasources return data models built with `fromJson`; the repository calls the model's `toDomain()` and only returns domain entities. Models must not extend domain entities. Older models still do: migrate them when touched.
- No DI container: everything is built in `lib/app/view/app.dart` and passed by constructor through `AuthNavigator` → `PassengerRegistrationNavigator` / `DriverRegistrationNavigator` → bloc. A new use case must be threaded through every level.
- Screen navigation is declarative: each navigator's `FlowBuilder` maps bloc states to a page stack. Never push screens with `Navigator`; it is only used to close modals and bottom sheets.
- Shared registration pages (`lib/features/registration/shared/pages/`) only know the abstract `RegistrationBloc`. Role-specific behavior goes in an abstract method of `RegistrationBloc` implemented by `PassengerRegistrationBloc` and `DriverRegistrationBloc` (see `notifyPermissionGranted()`).
- On failure a bloc emits `RegistrationError` / `AuthError`, then re-emits the previous ready state; the navigator's `BlocListener` shows the toast and keeps the current page stack.
- UI kit is `shadcn_flutter`, not Material: use its `Scaffold` (`headers` / `footers`), `PrimaryButton`, `GhostButton`, `showToast`. Import `package:flutter/material.dart` only with `show` for what shadcn lacks.
- No sibling dependencies within the same architectural layer: lift state up to a common ancestor and pass it down, or push it down and subscribe to it.

# Domain gotchas

- Passenger registration: the last screen is the `notifications` step; leaving it calls `POST /v1/passengers`, which finalizes the registration (`COMPLETE`) and creates the user. A finalized registration skips the registration screens: `AuthBloc` checks `RegistrationFlowEntity.isComplete` and goes home.

# Known issues

- CI (`.github/workflows/main.yaml`) only runs on push / PR to `main` and pins Flutter `3.35.x`, while `pubspec.yaml` requires `flutter: ^3.38.1`.

# Repo conventions

- PR titles must follow Conventional Commits (CI runs a semantic pull request check).
- CI spell-checks every `*.md` file against English dictionaries: add project-specific words to `.github/cspell.json`.
