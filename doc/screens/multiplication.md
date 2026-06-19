# Screen: Multiplication

**File:** `lib/features/math_operations/multiplication_screen.dart`  
**Route:** `/multiplication`
**Status:** Implemented with shared math-op polish applied (2026-06-19)

## Current purpose

8 rounds: build equal groups to understand multiplication.

## Existing functionality

- Shared math operation widgets and themes
- TTS, celebration, RouteAware music
- `RewardModuleIds.multiplication` completion

## Priority: P2 | Complexity: Medium

## Development tasks

Same pattern as [addition.md](./addition.md):

- [x] Clear visual for equal groups
- [x] Equation display (e.g. `2 × 3 = ?`)
- [x] Touch/drag targets sized for kids
- [x] Feedback helper consistency

## Notes

- Group cards now show clearer equal-group labels like `3 each`.
- Small screens switch to a wrapped group layout so 4 groups do not get squeezed into one row.
- Drag, tap, and helper CTA behavior now matches Addition and Subtraction.

## Acceptance criteria

8 rounds completable; progress recorded; layout OK on small phones.
