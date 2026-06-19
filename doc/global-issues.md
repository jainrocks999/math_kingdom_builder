# Global Issues Before Screen Work

Issues that affect multiple screens. Fix in Phase 1 before deep screen work.

## Navigation

| Issue | Impact | Suggested fix |
|-------|--------|---------------|
| Onboarding “Skip” goes to Home without `markOnboardingComplete()` | Onboarding repeats every cold start | Call `markOnboardingComplete()` on skip |
| Duplicate routes `/number-recognition` and `/find-number` | Confusing router surface | Keep one canonical route |
| Home notification icon opens Kingdom | Misleading affordance | Use rewards icon or split Kingdom + Rewards |
| Math Ops, Sequencing, Patterns on Home but not in Start Learning path | Fragmented learning journey | Add links section on Start Learning |

## Theme and typography

| Issue | Impact | Suggested fix |
|-------|--------|---------------|
| Duplicate `lib/app_colors.dart` / `lib/app_typography.dart` vs `core/constants/` | Theme drift | Migrate to constants only; remove legacy |
| `BouncingGameButton` uses Google Fonts `lilitaOne` | Inconsistent with Fredoka | Use `AppTypography` |

## Reusable components needed

| Component | Used on | Purpose |
|-----------|---------|---------|
| `SkyBackgroundScaffold` | Home, Onboarding, Start Learning, many activities | Shared bg + gradient |
| `ActivityTopBar` | All learning screens | Back + title + optional stars |
| `SpeakerHintButton` | Learning screens | Replay TTS prompt |
| `RoundProgressHeader` | Quiz-style screens | “Round 3 of 10” |
| `FeedbackHelper` | All learning screens | Unified correct/wrong SFX + TTS |
| `counting_themes.dart` | Count, Match, Quiz, etc. | Single source for object themes |

## Audio and animation lifecycle

| Issue | Impact | Suggested fix |
|-------|--------|---------------|
| Two audio systems: `AppAudioService` + `AudioService` | Inconsistent usage | Single facade or clear split documented |
| `playHomeMusic()` plays `start_counting.mp3` not `home_music.mp3` | Wrong audio on Home | Wire correct asset per context |
| Learn Numbers / Trace Numbers lack `RouteAware` | Music overlap or no resume | Add RouteAware pattern |
| TTS not always stopped on dispose | Ghost speech | Audit all `FlutterTts` screens |

## Responsiveness

- Fixed hero font sizes (36–48) on Home and Start Learning
- Long vertical scroll stacks on small phones
- Drag interactions need tap fallbacks on Sequencing, Patterns, Mini Quiz, Math Ops

## Asset loading

| Issue | Impact | Suggested fix |
|-------|--------|---------------|
| `CelebrationOverlay` references missing `confetti.json` | Crash if used | Add Lottie file or remove widget |
| `mascot.riv` bundled but unused | Bundle bloat | Use later or remove |

## Dead / unused code

- `number_recognition_controller` + `CelebrationService` — not wired to current Find Number UI
- Removed unused `StickerAlbum` Hive model so Rewards persistence has one source of truth
- `StateLearningScreen` alias on Find Correct Number screen
- Commented SVG background on Home

## Functionality gaps

- Quest star dots from JSON are static — not live progress
- Parent dashboard has no sound toggles despite `AudioService` flags
- `isComingSoon` quests can still receive `onTap` if JSON flag changes
