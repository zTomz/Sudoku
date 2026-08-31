# Contributing

Use Flutter 3.47.0 or newer with Dart 3.13. Keep changes focused, preserve the feature-first structure and reuse Rudi components. Use primary constructors for new Dart classes. Do not add packages without a concrete need.

```shell
flutter pub get
flutter gen-l10n
dart format lib test .github/prepare_web.dart
dart analyze --fatal-infos
dart analyze --fatal-infos .github/prepare_web.dart
flutter test
```

Edit both ARB files for visible text. Never edit generated localization files manually. Commit generated localization output and pubspec.lock so CI can check synchronization. Keep daily generator v1 deterministic across VM and web; free games use v2. The daily fingerprint is covered by `test/game_test.dart`. Run `flutter test test/game_test.dart` when touching the generator.

Use issues/PRs for changes; no server credentials are needed. Never commit local path overrides, signing keys, Play credentials, build artifacts or private user saves.
