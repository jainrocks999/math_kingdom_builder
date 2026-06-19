# Existing Functionality Improvement Opportunities

How current features can be improved without adding heavy new scope.

| Functionality | Current behavior | Problem | Improvement | Screens | Priority | Complexity |
|---------------|------------------|---------|-------------|---------|----------|------------|
| Learning flow | Guided path ends at Mini Quiz | Ops/patterns/sequencing separate | Extend navigation or “More Adventures” section | Start Learning, Home | P1 | Medium |
| Audio feedback | SFX/TTS varies per screen | Inconsistent delight | Standardize via shared `FeedbackHelper` | All learning | P1 | Low |
| Background music | Same track for home and learning | `home_music` unused | `home_music` on Home; `start_counting` on activities | Home, activities | P2 | Low |
| Reward system | Stars on completion; manual claim | Weak immediate loop | “+N stars” toast before celebration | All learning | P1 | Medium |
| Progress tracking | Per-module counts; kingdom sync | Home quest stars static | Bind quest cards to `RewardProgressService` | Home | P2 | Medium |
| Parent zone | PIN + activity list | No settings | Sound on/off, speech rate | Parent | P2 | Low |
| Sticker system | Emoji rewards in UI | Detail view still basic | Add optional sticker detail sheet later | Rewards | P3 | Low |
| Onboarding | 3 swipe cards + CTA | Skip breaks persistence | Mark complete on skip | Onboarding | P0 | Low |
| Instructions | TTS auto-speaks | Kids miss text | One-line instruction + speaker replay | Learning screens | P1 | Low |
| Celebrations | Per-screen custom overlays | Duplication | `CelebrationBear` + shared overlay | All learning | P2 | Medium |
| Empty/loading | Home has loading/error | Other screens bare | Shared skeleton / “Oops” state | Home, Kingdom, Rewards | P2 | Low |
| Error states | Home retry on JSON fail | Silent image fallbacks | Kid-friendly empty state component | Global | P2 | Low |

## Improvement themes

### Learning flow
- Keep `StartLearningNavigation.learningModules` as the primary path.
- Surface Math Ops, Patterns, and Sequencing from Start Learning without forcing them into star gates initially.

### Audio feedback
- Correct: `correct.mp3` + short TTS praise.
- Wrong: `wrong_soft.mp3` only — gentle, no harsh messaging.

### Reward system
- Call `RewardProgressService.recordModuleCompletion` consistently at end of each activity.
- Show star count change in UI before navigating to next screen.

### Progress tracking
- Home quest `stars` field in JSON should reflect live data or be removed to avoid false progress.

### Parent zone
- Wire `AudioService.setMusicEnabled` / `setSfxEnabled` to toggles in parent dashboard.

### Onboarding / instructions
- Visible kid instruction on each activity: “Tap the speaker to hear again.”

### Celebrations
- Prefer `CelebrationBear` + optional confetti Lottie when asset is added.

### Empty / loading / error
- Reuse Home’s retry pattern: title, short message, primary retry button, bear illustration.
