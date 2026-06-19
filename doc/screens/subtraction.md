# Screen: Subtraction

**File:** `lib/features/math_operations/subtraction_screen.dart`  
**Route:** `/subtraction`

## Current purpose

8 rounds: learn subtraction by removing objects from a group.

## Existing functionality

- Shared math operation widgets and themes
- TTS prompts, celebration overlay, RouteAware music
- `RewardModuleIds.subtraction` completion

## Priority: P2 | Complexity: Medium

## Development tasks

Same pattern as [addition.md](./addition.md):

- [ ] Drag/touch targets on small screens
- [ ] Equation display (e.g. `5 − 2 = ?`)
- [ ] TTS reads equation
- [ ] Optional tap helper after failed drags
- [ ] Music lifecycle regression

## Acceptance criteria

8 rounds completable; progress recorded; responsive layout.
