# Current App Overview

## What the app does

Math Kingdom Builder is a Flutter kids math learning app for ages ~3–7. Children explore numbers through swipe-and-listen lessons, tracing, counting, matching, quizzes, patterns, sequencing, and basic operations. Progress earns stars that unlock activities, kingdom map zones, and sticker/badge/trophy rewards. A PIN-gated parent dashboard shows activity mastery.

## Main screens and routes

| Module | Route | Screen file |
|--------|-------|-------------|
| Splash | `/` | `lib/splash_screen.dart` |
| Onboarding | `/onboarding` | `lib/onboarding_screen.dart` |
| Home | `/home` | `lib/features/home/home_screen.dart` |
| Start Learning hub | `/start-learning` | `lib/features/StartLearning/start_learning_screen.dart` |
| Learn Numbers | `/learn-numbers` | `lib/features/learn_numbers/learn_numbers_screen.dart` |
| Trace Numbers | `/tracing` | `lib/features/number_tracing/trace_numbers_screen.dart` |
| Count Objects | `/count-objects` | `lib/features/count_objects/count_objects_screen.dart` |
| Find Correct Number | `/find-number`, `/number-recognition` | `lib/features/number_recognition/number_recognition_screen.dart` |
| Match Numbers | `/matching` | `lib/features/matching/match_numbers_screen.dart` |
| Mini Quiz | `/mini-quiz` | `lib/features/mini_quiz/mini_quiz_screen.dart` |
| Math Operations hub | `/math-operations` | `lib/features/math_operations/math_operations_screen.dart` |
| Addition | `/addition` | `lib/features/math_operations/addition_screen.dart` |
| Subtraction | `/subtraction` | `lib/features/math_operations/subtraction_screen.dart` |
| Multiplication | `/multiplication` | `lib/features/math_operations/multiplication_screen.dart` |
| Division | `/division` | `lib/features/math_operations/division_screen.dart` |
| Sequencing | `/sequencing` | `lib/features/sequencing/sequencing_screen.dart` |
| Patterns | `/patterns` | `lib/features/patterns/patterns_screen.dart` |
| Kingdom Map | `/kingdom` | `lib/features/kingdom/kingdom_screen.dart` |
| Rewards / Stickers | `/stickers` | `lib/features/rewards/rewards_screen.dart` |
| Parent Dashboard | `/parent-dashboard` | `lib/features/parent_dashboard/parent_dashboard_screen.dart` |

## Current design style

- Warm candy-castle theme: cream background (`#FFF9F0`), vibrant orange primary (`#FF6B35`), teal secondary (`#4ECDC4`)
- Fredoka font family, rounded cards with 3D “pressed” bottom shadows
- Sky-gradient overlays on `assets/images/backround.png` background image
- Emoji + bear mascot (`idle`, `waw`, `clapping`) for delight
- Kid-sized tap targets (theme minimum button 72×72)

Design tokens live in `lib/core/constants/app_colors.dart` and `lib/core/constants/app_typography.dart`.

## Current assets and resources

| Category | Available |
|----------|-----------|
| Images | `backround.png`, onboarding (3), bear (3), counting objects (5 JPEGs), SVG bg + arrow |
| Audio | `start_counting.mp3`, `home_music.mp3`, `celebration.mp3`, `correct.mp3`, `wrong_soft.mp3` |
| Video | `splash_video.mp4` |
| Animation | `mascot.riv` (unused), `confetti.json` referenced but missing |
| Fonts | Fredoka variable (`assets/fonts/`) |
| Data JSON | `assets/data/home/featured_actions.json`, `quests.json` |

## Shared widgets and services

- **Widgets:** `CelebrationBear`, `BouncingGameButton`, `HintBubble`, `NumberBlock`, `PlaceholderScreen`, `StartLearningNextActionButton`
- **Audio:** `AppAudioService` (background/celebration), `AudioService` (SFX/TTS singleton in `core/utils/`)
- **Progress:** `RewardProgressService`, `KingdomService`, `ChildProfileService`, `AppSessionService`
- **Navigation:** `go_router` via `lib/core/router/app_router.dart`
- **State:** Riverpod for home content; most learning screens use local `StatefulWidget` state

## Existing functionality summary

- Offline-first persistence: Hive (profiles, kingdom state, lesson progress) + SharedPreferences (stars, streaks, rewards)
- TTS voice guidance on most learning screens (en-IN preferred)
- Star rewards + module unlock gates on Start Learning hub
- Daily goal (3 adventures), streak tracking
- Kingdom map with zone unlock tied to progress
- Rewards screen with claimable stickers/badges/trophies
- Parent PIN + progress dashboard
- Guided “Next Learning” path via `StartLearningNavigation`
- Route-aware background music on many screens via `AppAudioService`
