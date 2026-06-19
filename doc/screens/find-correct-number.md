# Screen: Find Correct Number

**File:** `lib/features/number_recognition/number_recognition_screen.dart`  
**Routes:** `/find-number`, `/number-recognition`

## Current purpose

Hear number word, tap correct digit card (0–10 rounds).

## Existing functionality

- TTS prompt, speaker pulse animation
- Wrong attempts → shuffle / hint
- `AudioService` SFX, RouteAware music
- Celebration + `StartLearningNextActionButton`

## Current issues

- Dead `StateLearningScreen` alias
- Unused `number_recognition_controller`
- Duplicate router paths
- Option cards may be small

## Priority: P1 | Complexity: Medium

## Development tasks

### Bug fixes
- [ ] Remove `StateLearningScreen` alias
- [ ] Deprecate duplicate route

### UI
- [ ] Option cards min 72dp
- [ ] Speaker highlight when speaking

### Existing functionality
- [ ] Subtle correct highlight after 2 wrongs
- [ ] Speaker replay

### Kids experience
- [ ] Mini bear burst on correct

### Responsiveness
- [ ] 2×2 option grid on narrow screens

## Assets

- **Reuse:** SVG arrow, bear, SFX
- **New:** No

## Components

- `SpeakerPulseButton`

## Acceptance criteria

Audio clear; hints work; stars on complete; responsive grid.
