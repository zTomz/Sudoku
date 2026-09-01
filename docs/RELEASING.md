# Builds and publication

## Dependencies

Sudoku uses Rudi UI 0.2.0 from the pinned public Git commit `46057ebd56464e45b22080ae7447a04d63a208c5`. Release and CI builds need no local Rudi checkout. Run `flutter pub get --enforce-lockfile`; do not enable a development override for release verification. See FIRST_COMMIT.md for the verification checklist.

Run `dart run build_runner build` after provider changes and `flutter gen-l10n` after translation changes. CI regenerates both and rejects out-of-sync checked-in output.

## Android

App name: **Sudoku**. Application ID and namespace: **com.tomvogel.sudoku**.

For an installable local test build in PowerShell:

```powershell
$env:SUDOKU_TEST_SIGNING = 'true'
flutter build apk --release
Remove-Item Env:\SUDOKU_TEST_SIGNING
```

This is optimized release code signed with the machine's Android **debug key**, strictly for testing. It is not a Play Store upload. A later differently signed Store install may require uninstalling the test version, which removes local saves.

For Store releases, create and securely retain your own upload key using the official Flutter signing guide. Copy `android/key.properties.example` to `android/key.properties` and supply real local values. Those files and keystores are ignored by Git. Do not use SUDOKU_TEST_SIGNING for publication.

```shell
flutter build appbundle --release
```

Without a local signing configuration the bundle is intentionally **unsigned**; CI validates packaging but does not produce a Store-ready signed release. Upload keys, Play Console setup, listing, screenshots, content rating, Data safety declarations, policy review and testing tracks still need to be completed before publication. No account, application listing or release was created by this scaffold.

Android release manifest requests no Internet permission. Debug/profile builds use Flutter's development permission. Android automatic backup is disabled for the local-only initial app.

Reference: https://docs.flutter.dev/deployment/android

## Web / GitHub Pages

Run these commands from the repository root. For root hosting, use `--base-href /` instead of `/Sudoku/`. Repository paths are case-sensitive.

```shell
flutter build web --release --no-web-resources-cdn --base-href /Sudoku/
dart run .github/prepare_web.dart
node --test test/web_cache_test.cjs
node --test test/background_worker_test.cjs
```

Publish **build/web**, not the source `web` directory. Local fonts and CanvasKit are bundled; bootstrap configuration keeps renderer and fallback-font requests on the same origin. Build preparation compiles the dedicated puzzle worker, then generates the content-versioned offline service worker and its registration. Both workers support repository subpaths. Do not omit preparation: puzzle generation requires `sudoku_worker.js` and does not fall back to blocking the UI thread. For Web debug runs, compile `lib/features/game/data/puzzle_worker.dart` to `web/sudoku_worker.js` with `dart compile js -O2` before starting Flutter.

The first visit requires a connection and enough time to cache all resources. Subsequent launches can work offline after caching has succeeded. Browser eviction/private mode/storage policies can still remove the cache. HTTPS or localhost is required for service workers. New versions activate after all tabs using the previous version are closed; don't force-reload an in-progress game just to update.

The `Publish GitHub Pages` workflow runs automatically on pushes to `main`, or manually with `main` selected. Enable **Settings → Pages → Build and deployment → Source → GitHub Actions** once in the repository. No personal access token is required. Protect the `github-pages` environment to allow deployments from `main` only; manual runs on other branches are skipped by the workflow.

Before deployment, the workflow enforces the dependency lockfile, verifies localization and formatting, runs Flutter analysis/tests and compares generated puzzles and complete logical traces between Dart VM and JavaScript. It then reads the configured Pages base path with `actions/configure-pages`, builds the app, prepares the offline cache and runs its tests before uploading `build/web`. This supports repository subpaths (including case), root sites and configured custom domains without hard-coded URLs. Only the deployment job receives Pages-write and OIDC permissions; concurrent deployments are serialized.

Creating or changing this workflow does not publish local uncommitted changes. Commit and push to `main` to trigger it, then check the workflow's deployment URL. GitHub repository settings and a successful hosted run cannot be verified by local tests alone.

Alternative: create a Cloudflare Pages project and upload the prepared `build/web` output. The supplied `_headers` file configures entrypoint/worker revalidation. No Cloudflare account or project was created.

References:
- https://docs.flutter.dev/deployment/web
- https://docs.flutter.dev/platform-integration/web/initialization
- https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages

## Windows

```shell
flutter build windows --release
```

Distribute the **entire** `build/windows/x64/runner/Release` directory, including `data` and all DLLs, not just sudoku.exe. The test package is a portable ZIP, not an installer or code-signed release. The Microsoft Visual C++ runtime may be needed on another PC. SmartScreen may warn about unsigned software.

## Apple platforms

This initial project generates Android, Web and Windows targets. iOS/macOS platform runners, signing and native builds are not configured or verified. Add them on a Mac with Xcode when those targets become part of the release scope.
