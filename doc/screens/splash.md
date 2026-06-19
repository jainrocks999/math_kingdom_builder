# Screen: Splash

**File:** `lib/splash_screen.dart`  
**Route:** `/`
**Status:** Implemented with skip/fallback polish (2026-06-19)

## Current purpose

Plays branded splash video, then routes to Onboarding (first launch) or Home.

## Existing functionality

- Video player with blur backdrop
- 6-second fallback timer if video fails
- Reads onboarding flag from `AppSessionService`

## Current issues

- Black screen + spinner until video initializes — no static fallback
- No skip for repeat launches
- Video may feel long every cold start

## Priority: P2 | Complexity: Low

## Development tasks

### Bug fixes
- [x] Verify video dispose on navigate (regression-safe lifecycle)

### UI
- [x] Static logo fallback under spinner (`assets/logo/`)
- [x] Safe area / aspect ratio on notched devices

### Existing functionality
- [x] Shorten fallback to 4s if video stalled

### New (optional)
- [x] Tap to skip after 2s on repeat launches

### Kids experience
- [x] No error text visible to child

### Responsiveness
- [x] `BoxFit.cover` kept with safe fallback content for small/large screens

## Notes

- Repeat launches can skip after a short delay, while first-time launches still route naturally into onboarding.
- Video fallback now shows a friendly branded logo instead of a black spinner-only screen.

## Assets

- **Reuse:** `splash_video.mp4`, app logos
- **New:** No

## Components

- Optional: `SplashFallbackLogo`

## Acceptance criteria

Splash reaches Home or Onboarding within 6s; no crash on video failure; acceptable on small and large screens.
