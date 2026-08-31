# First GitHub commit

The source version is 0.1.0+1. Earlier 0.2.x files were local UI previews, not published releases. Historical installation previews used higher build numbers; create new previews only when explicitly requested.

## Public dependency resolved

Rudi UI 0.2.0 has been published on GitHub at `eff9e33e4797e8bbee9c24395b00757ca1e48380`. Sudoku's manifest and lockfile now resolve that public Git revision. The local override has been removed from the repository and backed up outside it. No sibling Rudi checkout is required.

1. Run the checks below without a local override; confirm Rudi resolves through Git at the pinned hash and version 0.2.0.
2. Review the complete staged source, workflows, generated localization and public lockfile together with `git diff --cached`.
3. Create the first Sudoku commit when ready. Creating a GitHub repository, setting its remote and pushing are separate actions; none have been performed here.

```shell
flutter pub get --enforce-lockfile
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test .github/prepare_web.dart
dart analyze --fatal-infos
dart analyze --fatal-infos .github/prepare_web.dart
flutter test
```

Verify generated localization has no diff after regeneration and ensure pubspec.lock uses public dependencies rather than local paths. Platform builds and the Web cache checks are documented in RELEASING.md; run local artifact builds only when requested.

The only custom build helper is `.github/prepare_web.dart`, which generates the browser offline cache. Other checks use standard Flutter/Dart commands. `AGENTS.md` remains an ignored local assistant guide. Never stage Android signing keys, `key.properties`, `local.properties`, `pubspec_overrides.yaml`, build output, or private saves. The prepared source changes can be staged together once verification passes; no commit or push is performed automatically.

Suggested commit subjects:

- Rudi: `feat: add grouped settings, floating navigation and modal controls`
- Sudoku: `feat: introduce offline Sudoku with daily puzzles and Rudi UI`

Pages deployment is manual. CI builds unsigned Android bundles and portable Windows/Web artifacts; those are not signed Store releases. The interactive device acceptance test remains with the maintainer.
