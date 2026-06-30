# Implementation Plan

Phased rollout with scope boundaries and testing.

## Task Sheet Update: 2026-06-22

Completed work recorded from git history on 2026-06-22:

- [x] Added translation asset support and locale discovery for app languages
- [x] Added shared app localization helpers and translation wiring across updated screens
- [x] Added English and Hindi translation files and expanded localized copy coverage
- [x] Built the Settings screen with language switching, audio toggles, speech preview, child profile switching, and parent PIN handling
- [x] Added shared completion UX pieces including `ActivityCompletionCard` and `FeedbackHelper`
- [x] Updated Start Learning next-step flow and shared next-action navigation
- [x] Polished learning modules including Learn Numbers, Count Objects, Match Numbers, Mini Quiz, Number Recognition, Number Tracing, Sequencing, Patterns, and math operation screens
- [x] Updated Home, Kingdom, Rewards, Parent Dashboard, Onboarding, Splash, loading, and placeholder flows to align with the new localization and completion experience
- [x] Added and aligned regression coverage notes through the release checklist and related task docs

Reference commits:

- `30e2721` at 2026-06-22 12:53 IST
- `ed3dca9` at 2026-06-22 17:15 IST

## Phase 1: Fix global bugs (Week 1)

**Implement**

- Onboarding skip → `markOnboardingComplete()`
- Consolidate or document audio facade (`AppAudioService` vs `AudioService`)
- `playHomeMusic()` → `home_music.mp3`
- Remove duplicate router path for find number
- Quarantine dead code (`StateLearningScreen`, unused controller)

**Do not touch**

- Learning game logic, kingdom map geometry, trace path math

**Test**

- Cold start → skip onboarding → kill app → opens Home
- Music on Home vs activity screens
- No new analyzer errors

---

## Phase 2: Reusable components (Week 1–2)

**Implement**

- `SkyBackgroundScaffold`
- `ActivityTopBar`
- `SpeakerHintButton`
- `RoundProgressHeader`
- `FeedbackHelper`
- `shared/counting_themes.dart`

**Do not touch**

- Trace path math, kingdom zone rects

**Test**

- Visual parity on Home + Onboarding
- Components on 320dp width device

---

## Phase 3: Onboarding + Home + Start Learning (Week 2)

**Implement**

- All tasks in `screens/onboarding.md`, `screens/home.md`, `screens/start-learning.md`

**Test**

- Navigation to every module
- Daily banner reflects progress
- Lock/unlock states
- Profile picker

---

## Phase 4: Learn Numbers → Trace → Count (Week 3)

**Implement**

- Guided path first three modules
- Speaker buttons, RouteAware, star toast

**Test**

- Full path with TTS
- Stars increment in `RewardProgressService`
- `StartLearningNavigation` next steps

---

## Phase 5: Find → Match → Mini Quiz (Week 4)

**Implement**

- Gated modules + quiz modes
- Standardized celebrations

**Test**

- Unlock at 4 / 8 / 14 stars
- Quiz drag on Android
- Module completion counts

---

## Phase 6: Rewards + Math Ops + Sequencing + Patterns (Week 5)

**Implement**

- Collect UX on Rewards
- Progress badges on Math Ops hub
- Tap fallbacks on drag screens

**Test**

- Claim rewards persists
- Each op records progress
- Sequencing/patterns completable

---

## Phase 7: Kingdom + Parent + Splash (Week 6)

**Implement**

- Map UX improvements
- Parent sound toggles
- Splash fallback logo

**Test**

- Zone unlock flow
- Parent PIN + toggles
- Splash on slow devices

---

## Phase Final: Testing, cleanup, performance (Week 7)

**Implement**

- Remove unused assets if not adopting Rive
- TTS / `AnimationController` dispose audit
- Image cache review

**Test checklist**

- [ ] iOS + Android small phone + tablet
- [ ] Text scale 1.3x
- [ ] Background music never doubles
- [ ] No leak warnings after 10 screen pushes
- [ ] Offline cold start
- [ ] Full Start Learning path completion

Automated regression baseline on `2026-06-20`:
- `flutter analyze` passed
- `flutter test` passed
- Manual release checklist: [release-regression-checklist.md](./release-regression-checklist.md)
