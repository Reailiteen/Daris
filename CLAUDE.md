# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/simulator
flutter analyze          # Run linter
flutter format lib/      # Format code
flutter build ios        # Build iOS (primary platform)
flutter build apk        # Build Android
```

## Environment Setup

Create a `.env` file in the project root before running:
```
SUPABASE_URL=<your_supabase_url>
SUPABASE_ANON_KEY=<your_anon_key>
```

## Architecture

**State management:** GetX — controllers extend `GetxController`, use `Rx*` observables, views use `Obx()` for reactive rebuilds.

**Routing:** GetX named routes defined in `main.dart`. Two routes: `/onboarding` → `OnboardingView` and `/home` → `HomeView`.

**Dependency injection:** GetX Bindings. `AuthorizationBinding` loads only `AuthorizationController`. `HomeBinding` lazy-loads all 6 feature controllers. Services registered via `Get.putAsync` at startup.

**Feature structure:** Each feature lives in `lib/features/<name>/` with `controller/`, `view/`, `widgets/`, and `bindings/` subdirectories. Features are self-contained.

**Services:**
- `SupabaseService` (`lib/data/services/supabase_service.dart`) — Supabase backend, authentication, and data operations
- `FocusFlowService` (`lib/data/services/focus_flow_service.dart`) — iOS/macOS platform channel (`com.focusflow/channel`) for Screen Time FamilyControls, app selection, website blocking

**Core platform:** iOS is the primary target (Screen Time FamilyControls API). Platform channel methods handle authorization, app picker, website blocking, and session management.

## Key Patterns

- Reactive state: `RxBool`, `RxString`, `RxList`, `Rxn<T>` (nullable)
- Services are singletons registered with `Get.putAsync` in `main.dart`
- `HomeBinding` is the DI hub for the main app — all feature controllers are registered there
- Authorization can be skipped via static flag `AuthorizationController._authorizationSkipped` (development only)
- Constants (channel name, storage keys, app group ID) in `lib/core/constants/app_constants.dart`
- Theme configured for Material 3 with Outfit font; primary color purple `#5856D6`

## Data Models

- `lib/data/models/focus_session.dart` — session with UUID, duration, timer/progress logic
- `lib/data/models/blocked_website.dart` — domain blocking with category and toggle
- `lib/data/models/core_models.dart` — Sport, ActivitySession, FocusCycle, ScreenBudget (Supabase-backed)
- `lib/data/models/session_statistic.dart` — completed session tracking
