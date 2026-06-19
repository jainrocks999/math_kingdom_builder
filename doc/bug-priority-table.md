# Bug Priority Table

| Priority | Screen | Bug | Impact | Suggested fix |
|----------|--------|-----|--------|---------------|
| P0 | Onboarding | Skip doesn’t mark onboarding complete | Onboarding every cold start | Call `markOnboardingComplete()` on skip |
| P1 | Home | Bell icon opens Kingdom | Wrong destination | Use rewards icon or split icons |
| P1 | Global | `playHomeMusic` uses `start_counting.mp3` | Wrong audio on Home | Play `home_music.mp3` on Home/Onboarding |
| P1 | Learn Numbers | No RouteAware music lifecycle | Music overlap / no resume | Add RouteAware + stop on leave |
| P1 | Trace Numbers | No RouteAware / no session music | Inconsistent audio | Add RouteAware pattern |
| P1 | Global | Duplicate `AudioService` classes | Maintenance risk | Consolidate or document single facade |
| P2 | Router | Duplicate `/number-recognition` route | Dead URL confusion | Keep `/find-number` only |
| P2 | Find Number | Dead `StateLearningScreen` class | Code noise | Remove alias |
| P2 | CelebrationOverlay | `confetti.json` missing | Crash if widget used | Add asset or remove widget |
| P2 | Home | Quest stars static in JSON | False progress signal | Bind live data or remove dots |
| P3 | Global | `mascot.riv` unused | Bundle size | Use later or remove |
| P3 | Global | Legacy `lib/app_colors.dart` | Theme drift | Delete after migration |
| P3 | BouncingGameButton | LilitaOne vs Fredoka | Visual inconsistency | Use Fredoka |
| P3 | number_recognition_controller | Unused dead code | Maintenance | Remove or integrate |

## Priority definitions

- **P0 Critical** — Broken flow or data; fix before any polish.
- **P1 High** — Clear UX bug or inconsistency affecting most users.
- **P2 Medium** — Polish, misleading UI, or tech debt with user impact.
- **P3 Low** — Cleanup, consistency, optional optimization.
