# Architecture

Flutter 3.47 / Dart 3.13. New application code uses primary constructors, declaring parameters, pattern matching, exhaustive switches and immutable collection snapshots. No experimental language flags.

- `lib/app`: composition, lifecycle, session coordination and theme.
- `lib/features/game/domain`: pure Dart puzzle generator, independent uniqueness and logical solvers, immutable game state and reversible moves.
- `lib/features/game/data`: versioned JSON snapshots and a small storage boundary.
- `lib/features/*/presentation`: Rudi views for play, calendar, statistics and preferences.
- `lib/features/settings/domain`: immutable settings.
- `lib/common/presentation`: shared labels, layout, accent colors and the Solar icon adapter.
- `lib/l10n`: English/German ARB sources and generated localization classes.

Application state uses Riverpod's generated Notifier with immutable `SudokuState` snapshots. `SudokuController`, repository and generator providers are intentionally kept alive for the application scope; disposal stops timers and physically cancels pending generation. Widgets observe provider state and invoke notifier commands. Transient navigation state stays local. The hint provider auto-disposes with the sheet and only recalculates when puzzle identity or board values change, not on timer ticks or note edits. All project-owned providers use `@riverpod` or `@Riverpod`; run `dart run build_runner build` after changing their inputs. Business rules live outside widgets; persistence and generation are overridden independently in tests.

## Puzzle IDs and difficulty

Generators use a stable integer PRNG so a versioned puzzle ID matches across Dart VM and JavaScript. Daily seeds derive from the local calendar date. Timezone changes therefore change which day is shown, not the contents of a given date and generator version. There is no trusted server clock, leaderboard or anti-cheat claim.

Every removed clue is accepted only when the solver proves one solution. Solver budget exhaustion rejects the removal. Generator identifiers document deterministic puzzle identity; they do not select compatibility implementations.

Free-play IDs use v3 and daily IDs use v2, both through the same technique-graded generation path. Randomized MRV backtracking builds full solutions from an empty grid with shuffled cell tie-breaking and candidate order. This is not uniform sampling over all valid Sudoku boards. There are no legacy generators, generator-version selectors, old-settings fallbacks or save migrations. Current daily sessions reopen their stored puzzle instead of regenerating it.

`LogicalSolver` applies the easiest available technique first, records immutable placement/elimination evidence and never guesses, reads a stored solution or assumes uniqueness. Easy uses naked/hidden singles. Medium adds locked candidates (pointing/claiming) and naked/hidden pairs. Hard adds naked/hidden triples, X-Wing and XY-Wing. Stuck or invalid boards receive no difficulty rating. A successful logical solve is checked separately with the original bounded uniqueness solver. Medium and hard must also leave the next simpler technique set stuck. These are deterministic technique tiers, not a universal difficulty score or a proof that every human must use the same path.

Generation removes rotationally paired clues first, then tries single removals if necessary. A removal is retained only if the board remains uniquely solvable within the requested techniques. Clue ceilings (40 easy, 36 medium/hard) prevent overly filled boards; they do not determine the rating. At most 256 solution grids are attempted, with bounded solution searches; failure uses the existing retry UI, never an easier fallback. Scheduling yields remain inside the engine but application calls run in a separate native isolate or a dedicated Web Worker, not on the UI thread. One cancellable job owns each worker, terminates it on completion/error/disposal and imposes a two-minute safety timeout. Worker failures are surfaced; there is no silent main-thread fallback. App suspension pauses any puzzle that finishes generating in the background. Clock time changes scheduling or causes an explicit failure, never puzzle selection.

Each accepted puzzle also stores a versioned `DifficultyRating`: technique cost, search cost, bottleneck count and total logical steps. Technique weights are 1/3/8/12/16/24/30/40/50 in enum order; every occurrence contributes. Before each step with more than twelve empty cells, count distinct immediate naked/hidden-single placements. Search cost adds `12 ~/ (choices + 1)` and zero or one choice counts as a bottleneck. The completed tail contributes no search cost. This is a reproducible scarcity proxy, not enumeration of every advanced alternative or a calibrated human solve-time model. Compare the effort score within the existing technique tier; it does not relabel tiers or change puzzle fingerprints. Expensive assessment is skipped during trial removals and performed once for the accepted puzzle.

Hints present the deduction prefix from the current board through its next placement, including prerequisite eliminations, candidate snapshots, affected cells and localized explanations of all nine techniques. They are read-only, never assume the player's notes are correct and never consult the solution for a deduction. The solution is used only to refuse hints based on incorrect entries. Pausing also conceals the hint content. Unsupported positions return an explicit no-hint state rather than guessing.

`lib/features/game/data/puzzle_worker.dart` is a pure-Dart Web Worker entrypoint compiled to `sudoku_worker.js`. Its URL resolves against `document.baseURI`, preserving GitHub Pages subpaths. `.github/prepare_web.dart` compiles the worker before calculating the offline manifest. Debug Web runs require a separate worker compilation into `web/`; that generated file is ignored. The `web` dependency supplies typed browser interop, not a network service.

`test/generator_quality_test.dart` checks independent solution counts, exact grades, step replay, technique fixtures, symmetry transforms and reproducibility. Increase the sample corpus with `flutter test test/generator_quality_test.dart --dart-define=SUDOKU_SAMPLES=400`. `test/generator_portability.dart` is a pure-Dart test entrypoint whose JSON output can be compared between the VM and compiled JavaScript.

## Storage and time

One schema-versioned JSON snapshot contains settings, one free-play session, daily sessions, and compact completion results. Each reversible move stores cell deltas rather than 81-cell history copies. Restoring replays the history and validates it against the board. Invalid or unsupported snapshots are left untouched; the app shows a retry state instead of silently deleting them.

Writes are queued and failures are surfaced with a retry button. Values, notes and undo/redo are saved after moves; time is checkpointed every 15 seconds and on pause/navigation. A monotonic Stopwatch tracks foreground play. Leaving the app pauses the board. No timer, sound, score or animation leaks solution correctness when checking is off.

Solution checking is the default. `GameSession.isIncorrect` identifies nonempty, editable entries that differ from the solution. Both checking modes gate error styling and accessibility labels on that predicate, so correct entries and givens never become erroneous because of another cell. Conflict-only mode additionally requires a repeated digit in a shared unit; it consults the solution only to attribute the conflict. Notes, empty cells, paused boards and checking-off mode have no error marks.

Nine placements exhaust a digit: the number bar shows a disabled checkmark, keyboard and number-first selection cannot bypass the rule, and `GameSession.enter` rejects further entries or notes for that digit. Givens count, notes do not; this depends on placement count, not solution correctness. Number-first selection clears when exhausted. Undo or erasing a placement restores availability below nine; redo restores the disabled state. To correct a misplaced exhausted digit, erase it first.

shared_preferences is appropriate for this small first version but is not a transactional save-game database or backup. The plugin does not guarantee crash-proof disk durability. Browser storage has a quota and may be evicted or cleared. Multi-tab editing is not synchronized: use one game tab. Large long-term daily archives, import/export and more robust native storage remain possible follow-up work. Only the current snapshot format is supported; schema validation does not migrate data.

## UI boundaries

RudiApp, RudiPage, navigation, buttons, pressables, dialogs, option/settings tiles, feedback, typography, motion and semantic colors come from rudi_ui. Sudoku owns its board and app-specific glyphs. There are no Material or Cupertino components.

Rudi UI 0.2.0 is pinned to public Git commit 46057ebd56464e45b22080ae7447a04d63a208c5; no local override is required. Its floating navigation, grouped settings, switch rows, bottom-sheet route and system-bar styling live in the package. Cue 0.3.1 is an application dependency for scene transitions; Rudi retains its SDK-only dependency boundary.

Layout responds to available width and height. Board numerals intentionally fit their cells independently of system text scaling; surrounding UI follows scaling. Every cell has row/column/value/note semantics, selected state, keyboard support and a non-color error indicator. Manual accessibility/device verification remains necessary.


The game header remains at the top and controls at the bottom. The board is centered in the available space; in very short landscape windows only the puzzle area scrolls to keep cells legible. Four palette choices persist independently from app appearance. A single foreground CustomPainter draws block/outer boundaries after cell backgrounds and selection effects, avoiding per-cell border overwrites. User preferences and platform reduced-motion settings control interaction feedback.

In 0.2.1, AppIcon maps semantic application symbols to bundled Solar Outline font glyphs rather than custom vector paths. The Sudoku board, grid and decorative dot texture remain custom-painted. solar_icons is an application dependency only; Rudi accepts the supplied close icon through its optional widget parameter. App colors share a single accent definition, and the board receives the resolved theme accent explicitly.
