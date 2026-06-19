# Screen: Find Correct Number

**File:** `lib/features/number_recognition/number_recognition_screen.dart`  
**Routes:** `/find-number`, `/number-recognition`
**Status:** Implemented with deferred cleanup (2026-06-19)

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
- [x] Remove `StateLearningScreen` alias
- [x] Deprecate duplicate route

### UI
- [x] Option cards min 72dp
- [x] Speaker highlight when speaking

### Existing functionality
- [x] Subtle correct highlight after 2 wrongs
- [x] Speaker replay

### Kids experience
- [x] Mini bear burst on correct

### Responsiveness
- [x] 2×2 option grid on narrow screens

## Assets

- **Reuse:** SVG arrow, bear, SFX
- **New:** No

## Components

- `SpeakerPulseButton`

## Acceptance criteria

Audio clear; hints work; stars on complete; responsive grid.

## Deferred

- Remove or wire the unused `number_recognition_controller` in a broader cleanup pass
- Consider consolidating this screen’s feedback patterns with other quiz-style screens if a shared helper is introduced
