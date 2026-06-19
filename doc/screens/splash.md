# Screen: Splash

**File:** `lib/splash_screen.dart`  
**Route:** `/`

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
- [ ] Verify video dispose on navigate (regression test)

### UI
- [ ] Static logo fallback under spinner (`assets/logo/`)
- [ ] Safe area / aspect ratio on notched devices

### Existing functionality
- [ ] Shorten fallback to 4s if video stalled

### New (optional)
- [ ] Tap to skip after 2s on repeat launches

### Kids experience
- [ ] No error text visible to child

### Responsiveness
- [ ] Test `BoxFit.cover` on 320dp and tablets

## Assets

- **Reuse:** `splash_video.mp4`, app logos
- **New:** No

## Components

- Optional: `SplashFallbackLogo`

## Acceptance criteria

Splash reaches Home or Onboarding within 6s; no crash on video failure; acceptable on small and large screens.
