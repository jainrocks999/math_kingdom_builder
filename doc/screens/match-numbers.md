# Screen: Match Numbers

**File:** `lib/features/matching/match_numbers_screen.dart`  
**Route:** `/matching`
**Status:** Implemented (2026-06-19)

## Current purpose

Show object group + number choices; match count to digit (10 rounds).

## Existing functionality

- Theme rotation, TTS, number pulse animation
- Correct/wrong feedback, celebration, RouteAware music
- Next learning navigation

## Current issues

- Object preview may crowd layout on small screens
- Duplicated theme list (same as Count Objects)

## Priority: P2 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Auto-advance race during celebration

### UI
- [x] Stack layout on narrow width (objects above numbers)

### Existing functionality
- [x] Shared `counting_themes.dart`
- [x] Round progress header

### Responsiveness
- [x] Layout on 320dp width

## Assets

- **Reuse:** counting images, audio
- **New:** No

## Acceptance criteria

Matching logic correct; layout on small phones; progress saved.
