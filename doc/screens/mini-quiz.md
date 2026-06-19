# Screen: Mini Quiz

**File:** `lib/features/mini_quiz/mini_quiz_screen.dart`  
**Route:** `/mini-quiz`

## Current purpose

9 mixed rounds: tap number, drag match, write number via keypad.

## Existing functionality

- Three quiz modes rotated
- Drag-and-drop and keypad write mode
- Celebration, RouteAware music
- Highest star reward (5★)

## Current issues

- Drag mode hard on small screens
- Complex UX — needs clearer mode labels
- Keypad layout for young kids

## Priority: P1 | Complexity: High

## Development tasks

### Bug fixes
- [ ] Drag drop hit testing on various DPIs

### UI
- [ ] Mode badge: Tap / Drag / Type with emoji
- [ ] Keypad buttons min 48dp

### Existing functionality
- [ ] Shared celebration overlay

### New (optional)
- [ ] First-time drag hint overlay

### Kids experience
- [ ] Extra praise TTS on complete

### Responsiveness
- [ ] Scroll for drag overflow; large write display

## Assets

- **Reuse:** counting assets
- **New:** No

## Acceptance criteria

All three modes work; drag OK on Android; 5★ on complete; next nav works.
