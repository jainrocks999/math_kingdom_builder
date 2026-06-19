# Screen: Patterns

**File:** `lib/features/patterns/patterns_screen.dart`  
**Route:** `/patterns`

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
- [ ] Horizontal scroll or wrap for pattern row

### Existing functionality
- [ ] Tap-to-place fallback
- [ ] TTS describes pattern (“red circle, blue square…”)

### Responsiveness
- [ ] Pattern pieces on narrow screens

## Assets

- **Reuse:** `AppColors` for shapes
- **New:** No

## Acceptance criteria

8 rounds completable; hints work; progress saved.
