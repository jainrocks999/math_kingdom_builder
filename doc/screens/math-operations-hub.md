# Screen: Math Operations Hub

**File:** `lib/features/math_operations/math_operations_screen.dart`  
**Route:** `/math-operations`
**Status:** Implemented with audio polish deferred (2026-06-19)

## Current purpose

Lists Addition, Subtraction, Multiplication, Division entry cards.

## Existing functionality

- Four operation cards with navigation
- Back to home, sky background

## Current issues

- Not in Start Learning guided path
- No progress/stars on cards
- No audio

## Priority: P2 | Complexity: Low

## Development tasks

### UI
- [x] Match card style to Start Learning modules

### Existing functionality
- [x] Progress snapshot star badges on cards
- [x] Link back to Start Learning

## Notes

- Hub now loads live operation progress and refreshes when returning from any operation screen.
- Header summary shows math stars earned, played operations, and a direct button back to Start Learning.
- Audio is still deferred because it is not required for core navigation/progress visibility.

## Assets

- **Reuse:** backgrounds, emoji
- **New:** No

## Acceptance criteria

All four ops navigable; progress visible; consistent styling.
