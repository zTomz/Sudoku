# Architecture

Flutter 3.47 / Dart 3.13. New application code uses primary constructors, declaring parameters, pattern matching, exhaustive switches and immutable collection snapshots. No experimental language flags.

- `lib/app`: composition, lifecycle, session coordination and theme.
- `lib/features/game/domain`: pure Dart puzzle generator, uniqueness solver, immutable game state and reversible moves.
- `lib/features/game/data`: versioned JSON snapshots and a small storage boundary.
- `lib/features/*/presentation`: Rudi views for play, calendar, statistics and preferences.
- `lib/features/settings/domain`: immutable settings.
- `lib/common/presentation`: shared labels, layout, accent colors and the Solar icon adapter.
- `lib/l10n`: English/German ARB sources and generated localization classes.

State uses a single injected ChangeNotifier for this initial, local application. No Riverpod or hooks dependency is required. If Riverpod is introduced later, use generated providers per the project's instructions. Business rules live outside widgets; persistence is injected and tested independently.

## Puzzle IDs and difficulty

The v1 generator has its own documented integer PRNG, so daily puzzles match across Dart VM and JavaScript. Daily seeds derive from the local calendar date. Timezone changes therefore change which day is shown, not the contents of a given date. There is no trusted server clock, leaderboard or anti-cheat claim.

Every removed clue is accepted only when the solver proves one solution. Solver budget exhaustion rejects the removal. A date's generator version and stable PRNG must not be changed in place; introduce a new version and retain the previous version for existing daily IDs.

Free-play IDs now use v2. A randomized backtracking search builds complete solutions from an empty grid instead of permuting the old cyclic template. This is not a claim of uniform sampling over all valid Sudoku boards. Saved v1 sessions retain their embedded puzzle/solution, and daily generation stays on frozen v1.

Initial easy/medium/hard labels use target clue counts (42/34/28). Uniqueness can stop removal before the target. This is a scaffold heuristic, not human-strategy grading; puzzles are not guaranteed to be solvable without guessing. A technique-aware grader and explanatory hint engine are follow-up work.

## Storage and time

One schema-versioned JSON snapshot contains settings, one free-play session, daily sessions, and compact completion results. Each reversible move stores cell deltas rather than 81-cell history copies. Restoring replays the history and validates it against the board. Invalid or unsupported snapshots are left untouched; the app shows a retry state instead of silently deleting them.

Writes are queued and failures are surfaced with a retry button. Values, notes and undo/redo are saved after moves; time is checkpointed every 15 seconds and on pause/navigation. A monotonic Stopwatch tracks foreground play. Leaving the app pauses the board. No timer, sound, score or animation leaks solution correctness when checking is off.

shared_preferences is appropriate for this small first version but is not a transactional save-game database or backup. The plugin does not guarantee crash-proof disk durability. Browser storage has a quota and may be evicted or cleared. Multi-tab editing is not synchronized: use one game tab. Large long-term daily archives, import/export, migrations beyond schema 1 and more robust native storage remain explicit follow-up work.

## UI boundaries

RudiApp, RudiPage, navigation, buttons, pressables, dialogs, option/settings tiles, feedback, typography, motion and semantic colors come from rudi_ui. Sudoku owns its board and app-specific glyphs. There are no Material or Cupertino components.

Rudi is pinned to Git commit 0b00c0727ef6792eeb9d86c892a8d680f1d312a7. The 0.2 development build uses an ignored local override to the modified Rudi 0.2 checkout. Its floating navigation, grouped settings, switch rows, bottom-sheet route and system-bar styling live in the package. Cue 0.3.1 is an application dependency for scene transitions; Rudi retains its SDK-only dependency boundary. Until Rudi is published and the public pin updated, the override is required and standalone remote CI remains pending.

Layout responds to available width and height. Board numerals intentionally fit their cells independently of system text scaling; surrounding UI follows scaling. Every cell has row/column/value/note semantics, selected state, keyboard support and a non-color error indicator. Manual accessibility/device verification remains necessary.


The game header remains at the top and controls at the bottom. The board is centered in the available space; in very short landscape windows only the puzzle area scrolls to keep cells legible. Four palette choices persist independently from app appearance. A single foreground CustomPainter draws block/outer boundaries after cell backgrounds and selection effects, avoiding per-cell border overwrites. User preferences and platform reduced-motion settings control interaction feedback.

In 0.2.1, AppIcon maps semantic application symbols to bundled Solar Outline font glyphs rather than custom vector paths. The Sudoku board, grid and decorative dot texture remain custom-painted. solar_icons is an application dependency only; Rudi accepts the supplied close icon through its optional widget parameter. App colors share a single accent definition, and the board receives the resolved theme accent explicitly.
