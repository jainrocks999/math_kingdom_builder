# Screen: Mini Quiz

**File:** `lib/features/mini_quiz/mini_quiz_screen.dart`  
**Route:** `/mini-quiz`
**Status:** Implemented with shared completion card (2026-06-20)

## Current purpose

9 mixed rounds: tap number, drag match, write number via keypad.

## Existing functionality

- Five quiz modes rotated
- Drag-and-drop and keypad write mode
- Celebration, RouteAware music
- Highest star reward (5★)
- Resume from the last unfinished quiz step

## Current issues

- Celebration modal now reuses a shared completion card

## Priority: P1 | Complexity: High

## Development tasks

### Bug fixes
- [x] Drag drop hit testing on various DPIs

### UI
- [x] Mode badge: Tap / Drag / Type with emoji
- [x] Keypad buttons min 48dp

### Existing functionality
- [x] Shared celebration overlay
- [x] Resume from last unfinished step
- [x] Expand quiz flow to 35 steps

### New (optional)
- [x] First-time drag hint overlay
- [x] Add count-based extra modes: Missing Number, Compare Groups

### Kids experience
- [x] Extra praise TTS on complete

### Responsiveness
- [x] Scroll for drag overflow; large write display

## Deferred


## Assets

- **Reuse:** counting assets
- **New:** No

## Acceptance criteria

All three modes work; drag OK on Android; 5★ on complete; next nav works.
