# AGENTS.md

Flutter e-commerce app (Flutter 3.47 / Dart SDK `^3.13`). Feature-first MVVM:
`data/{models,datasources,repositories}` → `presentation/{view_models,views,widgets}`.
State: `flutter_bloc` Cubit. DI: `get_it`. No codegen / `build_runner`.

## Commands
- `flutter pub get` — after any `pubspec.yaml` change.
- `flutter analyze` — target 0 errors. ~20 pre-existing **info** lints
  (`prefer_initializing_formals`) in `core/responsive/*` are expected; do not treat as regressions.
- `flutter test` — full suite.
- Single file: `flutter test test/core/network/dio_client_test.dart`
- Single test: `flutter test --plain-name "part of test name"`

## Architecture rules (verified — follow these)
- All HTTP goes through `DioClient` (`lib/core/network/dio_client.dart`). Datasources must not
  use raw `Dio`. `DioClient` converts every `DioException` into `ApiException` — catch
  `ApiException` (from `core/network/api_exceptions.dart`), never `DioException`.
- Per-feature flow: `XApiDatasource` → `XRepository` (abstract) + `XRepositoryImpl` →
  `XCubit` + sealed `XState` → view via `BlocProvider`/`BlocBuilder`. Auth uses
  `LoginService`/`AuthRepository`; products use `ProductsApiDatasource`/`ProductsRepository`.
- Endpoints live in `lib/core/network/api_endpoints.dart` (baseUrl `dummyjson.com`).
  `lib/core/constant/endpoind.dart` is a stale duplicate — edit `api_endpoints.dart`.
- DI: `configureDependencies()` in `lib/core/services/service_locator.dart`. `main()` must
  `await` it after `WidgetsFlutterBinding.ensureInitialized()`. Resolve with `getIt<X>()`.
  Repositories/datasources are `lazySingleton`; Cubits are `factory` (fresh state per view).
- `lib/app_steps.dart` is scratch planning notes, not runtime code.

## UI conventions
- Use responsive helpers from `core/responsive/responsive_context.dart`, not raw
  `MediaQuery`/`LayoutBuilder`: `context.responsive(mobile:…, tablet:…, desktop:…)`,
  `context.spacing.*`, `context.textStyles.*`.
- Theme tokens are in `core/theme/` (`app_colors.dart`, `app_spacing.dart` incl. `AppRadius`,
  `app_text_styles.dart`). Reuse shared `core/widgets/` (`AppButton`, `AppTextField`).
- `AppColors` has no `error` token — use `AppColors.discount` for negative/out-of-stock text.

## Auth / tokens
- Tokens are cached in `shared_preferences` via `SharedPrefsTokenStorage` (the registered
  `TokenStorage`). `AuthInterceptor` injects `Bearer` from the cache, refreshes on `401`, and
  writes new tokens back to the cache.
- `requiresAuth` defaults to `true` per request; pass `requiresAuth: false` for public
  endpoints (e.g. login).

## Tests
- `test/core/network/dio_client_test.dart` covers `TokenStorage`, `AuthInterceptor`,
  `DioClient`, and `ApiException`. `MyApp` requires an `isLoggedIn` argument.
- Widget tests build `MyApp` directly and do **not** call `configureDependencies()`. Any widget
  that resolves a `getIt` service (e.g. `LoginView`) needs a configured locator or an injected
  fake, or the test will throw on first use.
