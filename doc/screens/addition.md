# Screen: Addition

**File:** `lib/features/math_operations/addition_screen.dart`  
**Route:** `/addition`
**Status:** Implemented with shared math-op polish applied (2026-06-19)

## Current purpose

8 rounds: drag/combine object groups to learn addition.

## Existing functionality

- Drag objects into merge zone
- TTS, `MathOpCelebrationOverlay`, RouteAware music
- `RewardModuleIds.addition` completion

## Current issues

- Drag heavy for youngest users
- Touch targets on small screens

## Priority: P2 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Drag hit boxes; music lifecycle

### UI
- [x] Larger draggable objects
- [x] Clear equation: `2 + 3 = ?`

### Existing functionality
- [x] “Tap to move all” after 2 failed drags (optional)
- [x] TTS reads equation

### Responsiveness
- [x] Drag zone on narrow screens

## Notes

- Objects now support both drag and tap, which makes the screen easier for younger kids.
- After repeated failed drags, a helper CTA can complete the move-all action without blocking progress.
- Narrow screens switch to a stacked tray layout so the drop zone stays usable.

## Assets

- **Reuse:** `math_operation_widgets.dart`, themes, counting images
- **New:** No

## Acceptance criteria

8 rounds completable; drag works on Android; stars recorded.

## Related screens

Subtraction, Multiplication, and Division share the same math op patterns — apply equivalent tasks in:

- `screens/subtraction.md`
- `screens/multiplication.md`
- `screens/division.md`
