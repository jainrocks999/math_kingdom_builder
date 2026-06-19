# Screen: Home

**File:** `lib/features/home/home_screen.dart`  
**Route:** `/home`
**Status:** Implemented with deferred polish (2026-06-19)

## Current purpose

Main hub: Start Learning CTA, featured actions grid, quest grid, daily challenge banner.

## Existing functionality

- Loads JSON via Riverpod (`homeContentProvider`)
- Route-aware home music
- Loading and error retry states
- Navigation to all major modules

## Current issues

- Bell icon opens **Kingdom** — misleading
- Quest star dots from JSON, not live progress
- `isComingSoon` quests still tappable if flag set
- Duplicated header vs Onboarding

## Priority: P1 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Fix notification button → Rewards or split icons
- [x] Disable tap when `quest.isComingSoon`

### UI
- [ ] Extract shared header component
- [x] Grid readability at 320dp
- [ ] Resolve commented SVG bg

### Existing functionality
- [x] Bind quest stars to `RewardProgressService` or remove dots
- [x] Dynamic daily challenge from `todayCompletions`
- [x] Daily challenge routes to a real module and checks completion from progress
- [x] Daily challenge gives one bonus reward per day and does not double-claim
- [x] Use `home_music.mp3` on this screen

### New (optional)
- [x] Star count chip in header

### Kids experience
- [ ] Bounce on Start Learning press; light haptic on card tap

### Responsiveness
- [x] Grid aspect ratios on narrow phones
- [ ] Scroll performance with nested GridViews

## Assets

- **Reuse:** JSON images, `backround.png`, bear images
- **New:** No

## Components

- `HomeFeatureCard`, `HomeQuestCard`, `SkyBackgroundScaffold`, `DailyChallengeBanner`

## Acceptance criteria

Icons match destinations; daily banner is live, awards the daily bonus once, opens the real daily module; coming-soon guarded; music correct; no overflow on small Android.

## Deferred

- Extract shared header component with Onboarding when that shared scaffold work begins
- Revisit SVG background and optional haptic polish in a later UI pass
