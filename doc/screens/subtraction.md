# Screen: Subtraction

**File:** `lib/features/math_operations/subtraction_screen.dart`  
**Route:** `/subtraction`
**Status:** Implemented with shared math-op polish applied (2026-06-19)

## Current purpose

8 rounds: learn subtraction by removing objects from a group.

## Existing functionality

- Shared math operation widgets and themes
- TTS prompts, celebration overlay, RouteAware music
- `RewardModuleIds.subtraction` completion

## Priority: P2 | Complexity: Medium

## Development tasks

Same pattern as [addition.md](./addition.md):

- [x] Drag/touch targets on small screens
- [x] Equation display (e.g. `5 − 2 = ?`)
- [x] TTS reads equation
- [x] Optional tap helper after failed drags
- [x] Music lifecycle regression

## Notes

- Objects now support both drag and tap removal.
- Repeated failed drags show a helper CTA so kids can still finish the round.
- Object sizing was tightened for smaller layouts to avoid clipping.

## Acceptance criteria

8 rounds completable; progress recorded; responsive layout.
