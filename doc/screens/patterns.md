# Screen: Patterns

**File:** `lib/features/patterns/patterns_screen.dart`  
**Route:** `/patterns`
**Status:** Implemented with responsive/tap polish (2026-06-19)

## Current purpose

8 rounds: complete AB/ABB color-shape patterns.

## Existing functionality

- Drag pattern piece to complete sequence
- Hint after 2 wrong attempts
- RouteAware music
- Uses colored shapes (no extra image assets)

## Current issues

- Drag-only interaction
- Pattern row may overflow

## Priority: P2 | Complexity: Medium

## Development tasks

### UI
- [x] Wrapped layout for pattern row

### Existing functionality
- [x] Tap-to-place fallback
- [x] TTS describes pattern (“red circle, blue square…”)

### Responsiveness
- [x] Pattern pieces on narrow screens

## Notes

- Pattern row now stays inside the visible area instead of relying on squeeze/overflow.
- Prompt speech now reads the actual pattern with a spoken blank at the end.
- Option tiles are tap-first, with drag starting only on hold for more reliable child interaction.

## Assets

- **Reuse:** `AppColors` for shapes
- **New:** No

## Acceptance criteria

8 rounds completable; hints work; progress saved.
