# Verification — Sudoku 0.2.0, 2026-08-31

- Flutter 3.47.0 stable / Dart 3.13.0 on Windows x64.
- Sudoku: formatter and static analysis passed; 21 tests passed.
- Puzzle coverage includes 36 unique-solution samples and eight v2 solution-diversity samples.
- Daily v1 fingerprint retained and matched between Dart VM and compiled JavaScript.
- Localization regenerated with identical generated-file hashes.
- UI regression coverage: 320×568, 390×844, 844×390 and 1200×900; 200% text at 320×568; rapid navigation, settings sheet selection, save compatibility and pixel comparison of thick grid boundaries across selections/palettes.
- Rudi UI: static analysis, formatter, import-boundary guard and 22 tests passed.
- Rudi example: analysis and 1 test passed. Preview: analysis and 3 tests passed after refreshing dependency metadata.
- Loop: analysis and 10 affected tests passed against modified Rudi in an isolated copy. Original staged changes were not touched.
- Android optimized test-signed APK, Windows release and Web release rebuilt. Android com.tomvogel.sudoku, version 0.2.0+2, minSdk24, targetSdk36, no Internet permission.
- Web: 24-resource offline cache generated, 3 Node routing/cache tests passed, JavaScript syntax checked.
- Full Windows Release directory and prepared Web directory packaged; APK copied without modification.
- No new AAB, iOS/macOS builds, Store signing, publishing, GitHub Actions run or deployment. Local release signing is for testing only.
- Interactive/device/visual/accessibility acceptance is intentionally left to the user.

Rudi 0.2 changes are not published. This development build uses an ignored local path override. A clean public Sudoku checkout/remote CI requires publishing Rudi and updating the public Git pin first. Source bundle includes both current checkouts and a relative override.

Flutter web icon tree shaking emits the existing expected Material/Cupertino font-family warning. The app uses painted icons and bundled Google Sans. Compilation succeeds; no missing icon font is introduced by this change.

Difficulty remains a clue-count heuristic (42/34/28 targets), not a human-technique rating. Randomized search is not claimed to uniformly sample all Sudoku grids. Storage remains best-effort shared_preferences with no cloud backup.

## 0.2.1 follow-up

- New compact home, weekly daily-puzzle shortcuts, resume progress, direct difficulty controls and gradient/dot texture.
- Shared accent and fully colored selection with contrasting digits/notes.
- Bundled Solar Outline icons and license attribution; optional Rudi bottom-sheet closeIcon slot.
- Sudoku formatting/static analysis and 23 tests passed, including cancel-before-replacement protection and selection contrast.
- Rudi analysis, its import-boundary guard and 8 affected component tests passed.
- No generator/storage format changes. No interactive device testing or publication performed.
- Loop compatibility analysis and 10 affected tests passed in the isolated copy; original Loop checkout unchanged.
- Final Android 0.2.1+3 and Windows release built with bundled Solar Outline font (8,084 bytes after Android font subsetting).
- Final Web build includes Solar icon fonts and attribution in its 28-resource offline cache; 3 Node cache tests passed.

## 0.2.2 follow-up

- Compact white/filled navigation, standard Solar settings gear, filled resume play icon, lighter settings values and reduced padding.
- Rudi pressable now provides opt-in clipped ink feedback; settings tiles enable it. Nullable closeIcon removes the app sheet close button without removing drag/barrier/back dismissal.
- Existing pub.dev solar_icons dependency retained; no dependency or license change.
- Sudoku: formatting, static analysis and 23 tests passed. Localization regenerated and hashes matched on a second generation.
- Rudi: formatting, static analysis, import-boundary guard and 25 tests passed. New tests cover ink painting/cancellation/settling, reduced motion, and barrier/back dismissal without the close button.
- Loop: static analysis and 25 affected settings/theme/sheet tests passed in the isolated compatibility copy; original checkout unchanged.
- Android optimized test-signed APK 0.2.2+4 built successfully. Solar Bold and Outline fonts bundled; package id, version code and absence of Internet permission verified.
- Windows release and Web release built successfully. Web offline cache contains 28 resources; all 3 Node cache tests passed. The existing Material/Cupertino font-family warning remains; all used Solar fonts are present.
- No gameplay, generator or storage format changes. No interactive/device testing, store signing, publishing, commit or push performed.

## First-commit preparation (source 0.1.0+1, preview build 5)

- Pause now uses RudiDialog over the dimmed board; the grid remains in place while values/notes are concealed and background input is excluded.
- System back resumes the same game. Keyboard focus and entry work after resuming; the timer remains stopped while paused.
- Proportional optical numeral alignment covers both values and notes. Raster regression with the bundled Google Sans verifies given-digit ink centers within 1.2 logical pixels of cell centers.
- Sudoku formatting, static analysis and all 25 tests passed; Rudi analysis, formatting, boundary guard and 25 tests passed. Localization regeneration was stable.
- Android, Windows and Web release previews built with build number 5. Source remains at the user's 0.1.0+1. Android version/package and lack of Internet permission checked; web cache has 28 resources and all 3 Node tests passed.
- CI-required scripts now live in scripts/ so the user-owned tool/ ignore rule is preserved. Public builds enforce the lockfile. Commit gate correctly fails on the current local Rudi path lock; docs/FIRST_COMMIT.md documents the public Rudi commit prerequisite.
- Staged-path/credential-pattern checks found no signing keys or matching credential patterns. Existing staged changes were not reset or restaged. Whitespace cleanup preserves license wording.
- Public dependency validation without the override and remote GitHub Actions remain pending until Rudi 0.2 changes are published and pinned. No commits, pushes, deployments or manual device testing were performed.

## UI follow-up (preview build 6)

- All Play/Pause icons use the Solar Bold variant, including daily actions. The pause dialog explicitly uses foreground text color. Navigation uses the plain Solar calendar outline, with its Bold counterpart when selected. English settings heading is now Game.
- Numerals now align using the bundled font's visible outline centers, separately for regular and medium weight. Text layout is cached per digit and disposed with its widget; selection animations do not repeatedly lay out unchanged text.
- Raster tests include clues and player entries at 320×568, 390×844 and 1200×900. Visible ink centers pass a 0.5 logical-pixel tolerance on both axes. These metrics belong to the bundled Google Sans and must be checked again if that font changes.
- Formatting, static analysis and all 27 Sudoku tests passed. The public-dependency commit gate remains intentionally blocked on the local Rudi lockfile; no dependency revision was fabricated and no Git index, commit or remote was changed.
- Android, Windows and Web release previews built successfully with build number 6. Android version metadata and bundled Solar fonts checked; all 3 Node web-cache tests passed against the generated 28-resource cache. The existing unused Material/Cupertino font-family warning remains unchanged.

## Public Rudi dependency and first-commit readiness

- Rudi UI 0.2.0 is published at 46057ebd56464e45b22080ae7447a04d63a208c5. Both the manifest and lockfile pin this public Git commit.
- The ignored local override was backed up outside the repository. Dependency resolution with --enforce-lockfile passed without it.
- Localization regeneration produced identical output. Formatting, static analysis, all 27 Sudoku tests and the commit dependency gate passed.
- Android release app bundle, Windows release and Web release built against public Rudi. The Android bundle is unsigned; store signing remains separate.
- The Web offline cache contains 28 resources and all 3 Node cache tests passed. The existing unused Material/Cupertino font-family warning remains; used Solar fonts are bundled.
- Source version remains 0.1.0+1. No gameplay, persistence or generator changes were made during this dependency update.
- Manual device acceptance, remote GitHub Actions and publishing are not performed by these local checks. No commit or push was performed.
- An independent export of the staged source resolved the enforced lockfile unchanged and passed static analysis and all 27 tests, without local overrides or a sibling Rudi checkout.

## Optical numeral follow-up (preview build 7)

- Added a downward optical adjustment of 0.045 em to board numerals, about one logical pixel at phone sizes. Horizontal outline centering is unchanged; small candidate notes receive the same proportional adjustment.
- Existing raster checks now verify the intentional optical target for clues and player entries on three viewport sizes, retaining the 0.5 logical-pixel tolerance.
- Formatting, static analysis and all 27 Sudoku tests passed. Manual judgment of the new position remains with the user.
- No dependency, Rudi API, localization or storage changes; no generation was required. Windows/Web builds were not repeated for this small paint-offset change.
- Android release APK built successfully with the existing local test-signing key and build number 7; source version remains 0.1.0+1. No commit or push performed.

## Standard Flutter numeral layout

- Removed per-digit font-outline tables, the optical offset and the custom stateful TextPainter implementation.
- Board values and notes now use ordinary Text inside the existing Center widgets. TextHeightBehavior distributes leading evenly; Flutter owns font shaping and metrics. Existing cell-relative font sizes, colors, weights and note slots remain unchanged.
- Replaced font-specific raster-position expectations with centered text-layout and cell-containment checks for clues and entered values on three screen sizes. This verifies layout, not subjective optical centering of each glyph outline.
- Formatting, static analysis and all 14 UI tests passed. No localization generation was needed. No APK or other platform builds were run, as requested; device debugging and visual acceptance remain with the user.

## Helper cleanup and current assistant guidance

- Removed the general-purpose helper files from scripts/ and tool/. The one required browser-cache generator is now .github/prepare_web.dart; CI, Pages, README and contributor/release instructions use that path.
- Removed the custom commit-check command and redundant build wrapper/fingerprint diagnostic. Standard Flutter/Dart checks and enforced public lockfile resolution remain; the daily fingerprint remains covered by test/game_test.dart.
- Updated the ignored local AGENTS.md with the current stack, UI behavior, data compatibility, Rudi workflow and the user's preference for no unsolicited builds or device testing. Android launcher edits were left untouched.
- Static analysis, the relocated helper's formatting/analysis, all 27 Flutter tests and all 3 Web cache tests passed. Cache generation was verified against an existing Web build; no fresh platform build, remote CI run, commit or push was performed.
- The environment rejected directory-removal commands. All eight inspected helper files were removed, but empty local scripts/ and tool/ directories remain; Git does not track empty directories. Earlier sections above describe historical states, not current commands.

## Technique-graded generator — 2026-08-31

- Final verification: all 47 Flutter tests passed. Dart formatting, Flutter static analysis and Git whitespace checks passed; a second localization generation produced identical hashes.
- Free generation is now v3; newly generated daily puzzles are v2. Both have independently checked unique solutions and complete no-guess logical paths. Medium and hard must leave the simpler technique set stuck. Frozen daily v1 remains callable and its original fingerprint is unchanged; saved v1/v2 puzzles retain their embedded grids and original ratings.
- Nine techniques are covered: naked/hidden singles, pointing/claiming locked candidates, naked/hidden pairs and triples, X-Wing and XY-Wing. Tests replay every generated path and verify candidate removals against the known solution, with independent set-based solution counting, fixed technique fixtures and transposed/rotated/digit-renamed variants.
- Stress run: `flutter test --no-pub test/generator_quality_test.dart --dart-define=SUDOKU_SAMPLES=400` passed for 1,200 puzzles (seeds 0–399 at each difficulty), without generation failure or duplicate puzzles within each tier. All requested grades matched. This is a sampled regression check, not a proof of success for every seed or uniform random sampling.
- Local Windows Flutter-test generation timings for that run: easy median 1.7 ms / p95 2.3 ms / max 18.5 ms; medium 27.7 / 113.5 / 296.5 ms; hard 118.1 / 581.0 / 1,365.6 ms. Times exclude the subsequent independent oracle and trace checks. These are host-specific development measurements, not mobile/browser performance guarantees.
- The pure-Dart portability test compares complete puzzle snapshots and logical steps across the VM and compiled JavaScript for 16 cases, including free-play tiers, boundary seeds, both daily versions and a leap day. Compilation is confined to a temporary test output, not an application/release build.
- English/German difficulty explanations and README/architecture documentation describe the new grading and legacy behavior. No new dependencies, storage schema changes, launcher edits or app version changes.
- No emulator/device launch, interactive acceptance, APK/Web/Windows application build, deployment, commit or push. Manual speed and solving-experience acceptance on target devices remains with the user.

## Targeted errors, current-only engine and automatic Pages — 2026-08-31

- Solution checking is now the default. Error color, underline and accessibility annotations apply only to incorrect editable entries. Correct givens and correct entries remain unmarked even when another entry repeats their digit. Conflict-only mode additionally requires a rule conflict; off mode remains silent. Domain and widget tests cover placement order, selection, correction, undo/redo, non-conflicting mistakes and notes.
- Removed the legacy daily generator, version-selection API, old-settings fallback and compatibility-only tests, as explicitly requested. The current technique-graded generator, deterministic IDs, snapshot validation and current-session restoration remain. No data migrations or storage deletions were added. This supersedes the legacy-support statements in the previous verification entry.
- Updated the existing Pages workflow to publish automatically on pushes to `main`, with manual runs restricted to `main`. It checks localization, formatting, static analysis, tests and VM/JavaScript determinism; builds for the configured Pages path; prepares/tests offline caching; and deploys with write/OIDC permissions confined to the deployment job. No duplicate Pages workflow was introduced.
- Verification: all 51 Flutter tests passed; full Dart formatting and Flutter analysis passed; regenerated localization hashes remained identical. All 14 current portability cases matched between Dart VM and compiled JavaScript, including complete logical traces.
- actionlint 1.7.12 passed for both workflows. The tool archive was checked against the publisher's SHA-256 checksum. All 3 existing offline-cache tests passed against the already-present Web output; this does not validate a fresh release build.
- No emulator, fresh application build, hosted GitHub Actions run, repository-setting change, commit, push or deployment. Enable GitHub Pages with GitHub Actions as the source once, then push the workflow/source to `main` to run the actual deployment. README and release/architecture documentation were updated; Rudi, Loop, dependency pins and launcher assets were not changed.

## Generated Riverpod, background workers, effort ratings and hints — 2026-08-31

- Replaced ChangeNotifier/ListenableBuilder with generated Riverpod providers and immutable application-state snapshots. Provider disposal owns timers and worker cancellation; repository/generator overrides keep controller tests isolated. Updated the ignored local assistant guide and contributor/architecture documentation to require generator syntax for application state management.
- Native generation runs in a cancellable isolate; Web generation runs in a dedicated compiled worker. Startup races, error propagation, timeout cleanup, concurrent-request suppression and background completion while lifecycle-paused have regression tests. The release helper compiles the worker and includes it in offline caching without publishing its dependency metadata. Debug Web compilation is documented in README.
- The accepted puzzle stores deterministic effort metrics covering every technique occurrence and scarcity of immediate single-placement choices. Technique tiers and existing puzzle fingerprints are unchanged. The score is explicitly documented as a heuristic within a tier, not calibrated human difficulty. Current snapshots include the rating; no migrations or legacy-reading paths were added.
- English/German hints explain all supported techniques using candidate evidence and elimination chains through the next placement. They ignore player notes, reject incorrect entries, never guess or apply moves automatically, and disappear while paused. Widget tests cover both languages at enlarged text scale; domain tests cover immutability, missing hints, completion and board-sensitive provider invalidation.
- Follow-up: nine placements now disable a digit rather than leaving its checkmark actionable. The domain rejects further placements/notes, keyboard and number-first input cannot bypass the limit, and exhausted number-first selections clear. Givens count and notes do not. Undo/erase restore availability, redo disables it again; both entry modes have widget regressions.
- Verification: all 63 Flutter tests passed; Flutter analysis and helper analysis passed; Dart formatting and Git whitespace checks passed. Enforced public lockfile resolution passed without a local override. Regenerated Riverpod and localization outputs were hash-stable. actionlint 1.7.12 accepted both workflows.
- All 14 VM/JavaScript comparison cases matched in full puzzle snapshots, effort metrics and candidate/solution traces (Windows stdout line endings were normalized for comparison). The real compiled worker additionally matched VM references for all three tiers and a daily puzzle. Five Node worker/offline-cache tests passed; the refreshed existing Web output caches 29 resources including the worker at root and repository subpaths.
- No fresh Flutter application/release build, emulator, interactive browser/device acceptance, hosted Actions run, commit, push or deployment. Only pure-Dart worker/test JavaScript was compiled, and offline preparation was checked against already-existing Web application output. Rudi, Loop, launcher artwork and source version 0.1.0+1 remain unchanged. The earlier 1,200-puzzle stress run was not repeated in this follow-up.
