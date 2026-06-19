# Screen: Learn Numbers

**File:** `lib/features/learn_numbers/learn_numbers_screen.dart`  
**Route:** `/learn-numbers`
**Status:** Implemented (2026-06-19)

## Current purpose

Explore numbers 0–30 with object themes, TTS, bear reactions, completion celebration.

## Existing functionality

- Number selector, giant digit, object grid
- Bear mood states (`idle`, `waw`, `clapping`)
- TTS + completion celebration + `recordModuleCompletion`
- `StartLearningNextActionButton`

## Current issues

- No RouteAware — music overlap / no resume
- No session background music (only celebration at end)
- Large file (~1800 lines)
- No speaker replay button

## Priority: P1 | Complexity: High

## Development tasks

### Bug fixes
- [x] Stop celebration music if user leaves mid-celebration
- [x] TTS stop in dispose (verify)

### UI
- [x] Scale `numberDisplay` on small screens
- [x] Selector chips min 48dp touch

### Existing functionality
- [x] RouteAware + `playStartCountingMusic`
- [x] “+4 stars” on completion
- [x] Hint: “Swipe numbers or tap 🔊”

### New
- [x] Speaker replay button

### Kids experience
- [x] Bear clap cycle; haptic on number change

### Responsiveness
- [x] Object grid on short screens; safe area for next button

## Assets

- **Reuse:** bear, counting JPEGs, audio
- **New:** No

## Components

- `SpeakerHintButton`, `ActivityTopBar`

## Acceptance criteria

0–30 navigable; TTS reliable; stars awarded; music clean; next learning works; responsive.
