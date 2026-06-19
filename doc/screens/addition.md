# Screen: Addition

**File:** `lib/features/math_operations/addition_screen.dart`  
**Route:** `/addition`

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
- [ ] Drag hit boxes; music lifecycle

### UI
- [ ] Larger draggable objects
- [ ] Clear equation: `2 + 3 = ?`

### Existing functionality
- [ ] “Tap to move all” after 2 failed drags (optional)
- [ ] TTS reads equation

### Responsiveness
- [ ] Drag zone on narrow screens

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
