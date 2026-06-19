# Screen: Sequencing

**File:** `lib/features/sequencing/sequencing_screen.dart`  
**Route:** `/sequencing`
**Status:** Implemented with responsive/tap polish (2026-06-19)

## Current purpose

8 rounds: fill missing number in forward/backward sequences.

## Existing functionality

- Drag number into gap
- Hint after 2 wrong attempts
- Shared math op theme/widgets
- RouteAware music

## Current issues

- Drag-only — no tap fallback
- Sequence boxes may clip on narrow screens

## Priority: P2 | Complexity: Medium

## Development tasks

### UI
- [x] Responsive wrapped layout for long sequences

### Existing functionality
- [x] Tap option to fill gap (alternative to drag)
- [x] Round progress header

### Kids experience
- [x] TTS reads sequence pattern

### Responsiveness
- [x] Sequence row on 320dp width

## Notes

- Sequence row now wraps inside the visible area instead of scrolling off-screen.
- Prompt speech now reads the actual pattern with a spoken blank.
- Option tray wraps on narrow screens so tap targets stay usable.

## Assets

- **Reuse:** math op widgets, audio
- **New:** No

## Acceptance criteria

8 rounds completable; tap or drag works; progress saved.
