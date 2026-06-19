# Screen: Learn Numbers

**File:** `lib/features/learn_numbers/learn_numbers_screen.dart`  
**Route:** `/learn-numbers`

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
- [ ] Stop celebration music if user leaves mid-celebration
- [ ] TTS stop in dispose (verify)

### UI
- [ ] Scale `numberDisplay` on small screens
- [ ] Selector chips min 48dp touch

### Existing functionality
- [ ] RouteAware + `playStartCountingMusic`
- [ ] “+4 stars” on completion
- [ ] Hint: “Swipe numbers or tap 🔊”

### New
- [ ] Speaker replay button

### Kids experience
- [ ] Bear clap cycle; haptic on number change

### Responsiveness
- [ ] Object grid on short screens; safe area for next button

## Assets

- **Reuse:** bear, counting JPEGs, audio
- **New:** No

## Components

- `SpeakerHintButton`, `ActivityTopBar`

## Acceptance criteria

0–30 navigable; TTS reliable; stars awarded; music clean; next learning works; responsive.
