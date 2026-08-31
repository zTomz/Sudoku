# Contributing

Use Flutter 3.47.0 or newer with Dart 3.13. Keep changes focused, preserve the feature-first structure and reuse Rudi components. Use primary constructors for new Dart classes. Do not add packages without a concrete need.

```shell
flutter pub get
flutter gen-l10n
dart run build_runner build
dart format lib test .github/prepare_web.dart
dart analyze --fatal-infos
dart analyze --fatal-infos .github/prepare_web.dart
flutter test
```

Edit both ARB files for visible text. Never edit generated localization or Riverpod files manually. Commit generated output and pubspec.lock so CI can check synchronization. Prefer Riverpod for application state management and always use generator syntax (`@riverpod` / `@Riverpod`), not manual providers or ChangeNotifier wrappers. Keep transient widget-only state local.

The current generator uses free v3 / daily v2 identities. Do not introduce legacy generators or save migrations. Keep fingerprints deterministic across VM and JavaScript; run the game, generator-quality and engine-feature tests after engine changes. See README for the worker compilation required before Web debug runs; release preparation compiles the worker automatically.

Use issues/PRs for changes; no server credentials are needed. Never commit local path overrides, signing keys, Play credentials, build artifacts or private user saves.
