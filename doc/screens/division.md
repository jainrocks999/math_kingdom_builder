# Screen: Division

**File:** `lib/features/math_operations/division_screen.dart`  
**Route:** `/division`
**Status:** Implemented with shared math-op polish applied (2026-06-19)

## Current purpose

8 rounds: share objects into equal groups for division.

## Existing functionality

- Shared math operation widgets and themes
- TTS, celebration, RouteAware music
- `RewardModuleIds.division` completion

## Priority: P2 | Complexity: Medium

## Development tasks

Same pattern as [addition.md](./addition.md):

- [x] Visual “sharing into groups” clarity
- [x] Equation display (e.g. `6 ÷ 2 = ?`)
- [x] Drag/tap targets for young users
- [x] Music lifecycle regression

## Notes

- Tap now auto-shares an object into the next valid bowl, so division is easier for younger kids.
- Bowl cards show clearer labels and wrapped layout on smaller screens.
- Repeated failed drags unlock a helper CTA to distribute all remaining objects safely.

## Acceptance criteria

8 rounds completable; progress recorded; responsive layout.
