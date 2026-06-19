# Screen: Onboarding

**File:** `lib/onboarding_screen.dart`  
**Route:** `/onboarding`  
**Status:** Implemented (2026-06-19)

## Current purpose

Three-page intro to kingdom, fun math, and rewards; CTA enters Home.

## Existing functionality

- PageView with step cards and onboarding images
- Plays music on entry (`AppAudioService.playHomeMusic`)
- Final CTA calls `markOnboardingComplete()`
- Skip button to Home

## Current issues

- ~~**P0:** Skip navigates without `markOnboardingComplete()`~~ — **Fixed**
- Duplicated `_SunnyBadge` / layout from Home — deferred (shared scaffold with Home later)

## Priority: P1 | Complexity: Low

## Development tasks

### Bug fixes
- [x] On Skip: call `markOnboardingComplete()` before `context.go(home)`
- [x] Pause/stop music when leaving (`dispose`, skip, and complete paths)

### UI
- [x] Responsive card title (clamped by width)
- [x] Larger page indicator touch area (44×44 with tap-to-jump)

### Kids experience
- [x] Swipe hint on first page

### Responsiveness
- [x] Card title/description `maxLines` + ellipsis
- [x] CTA subtitle `maxLines: 2`
- [x] Hero title scales on narrow width

### Deferred
- [ ] Extract shared `SkyBackgroundScaffold` with Home (next when Home screen is worked)

## Assets

- **Reuse:** onboarding images, `backround.png`
- **New:** No

## Acceptance criteria

- [x] Skip and “Start Learning” both mark onboarding done
- [x] Layout handles small width with scaled typography

## Implementation notes

- `_completeOnboardingAndGoHome()` shared by Skip and final CTA
- `_PageIndicatorDot` allows jumping between steps with 48dp targets
- `_SwipeHintBanner` shown only on page 0
