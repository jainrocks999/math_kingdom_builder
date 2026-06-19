# Screen: Sequencing

**File:** `lib/features/sequencing/sequencing_screen.dart`  
**Route:** `/sequencing`

## Current purpose

8 rounds: fill missing number in forward/backward sequences.

## Existing functionality

- Drag number into gap
- Hint after 2 wrong attempts
- Shared math op theme/widgets
- RouteAware music

## Current issues

- Drag-only — no tap fallback
- Sequence boxes may clip on narrow screens

## Priority: P2 | Complexity: Medium

## Development tasks

### UI
- [ ] Horizontal scroll for long sequences

### Existing functionality
- [ ] Tap option to fill gap (alternative to drag)
- [ ] Round progress header

### Kids experience
- [ ] TTS reads sequence pattern

### Responsiveness
- [ ] Sequence row on 320dp width

## Assets

- **Reuse:** math op widgets, audio
- **New:** No

## Acceptance criteria

8 rounds completable; tap or drag works; progress saved.
