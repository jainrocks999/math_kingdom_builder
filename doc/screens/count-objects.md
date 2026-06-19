# Screen: Count Objects

**File:** `lib/features/count_objects/count_objects_screen.dart`  
**Route:** `/count-objects`
**Status:** Implemented with deferred shared-helper polish (2026-06-19)

## Current purpose

10 rounds: count themed objects, pick correct number from 4 options.

## Existing functionality

- Theme rotation, TTS, correct/wrong feedback
- Celebration, auto-advance, RouteAware music
- `StartLearningNextActionButton`

## Current issues

- Duplicated celebration UI vs other screens
- Wrong feedback could be gentler first

## Priority: P1 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Music stops on push/pop (regression)

### UI
- [x] Consistent object image sizes
- [x] Answer buttons min 56dp

### Existing functionality
- [ ] `FeedbackHelper` for correct/wrong
- [x] Round header “Round X of 10”
- [x] Star toast on round complete

### New (optional)
- [ ] Tap-to-count on objects

### Kids experience
- [x] Gentle wiggle on wrong; TTS “Try again!”

### Responsiveness
- [x] 2×2 answer grid on narrow width

## Assets

- **Reuse:** counting JPEGs, audio, bear
- **New:** No

## Components

- `RoundProgressHeader`, `FeedbackHelper`

## Acceptance criteria

10 rounds completable; scoring correct; music lifecycle; completion recorded.

## Deferred

- Extract a shared `FeedbackHelper` when more quiz/counting screens are aligned
- Consider tap-to-count object interactions only if playtesting shows kids need more counting support
