# External Asset Requirements

Only assets that are missing or optional. Most work can use existing bundle.

| Asset | Type | Screen | Purpose | Required / Optional | Reuse existing? |
|-------|------|--------|---------|---------------------|-----------------|
| `confetti.json` | Lottie | Celebrations | Confetti overlay | Optional | No — missing; use bear animation instead |
| `home_music.mp3` | MP3 | Home, Onboarding | Distinct hub music | Optional | Yes — already in bundle, wire up |
| Sticker PNGs | PNG | Rewards | Unique sticker art | Optional | Yes — emoji sufficient for v1 |
| Voice MP3s per number | MP3 | Learn Numbers | Pre-recorded voice | Optional | Yes — TTS works today |
| `mascot.riv` | Rive | Home, Kingdom | Animated mascot | Optional | Yes — already bundled |

## No new packages required

Planned work uses existing dependencies:

- `audioplayers`, `flutter_tts`, `lottie`, `rive`, `go_router`, `riverpod`, `hive`, `shared_preferences`

## If adding confetti Lottie

- **Why existing isn’t enough:** `CelebrationOverlay` expects `assets/animations/confetti.json` which is not in the repo.
- **Alternative:** Use `CelebrationBear` only — no external download needed.
- **Free source:** LottieFiles free confetti animations (verify license) or generate simple confetti JSON.
- **Priority:** P3 optional polish.

## If adding sticker PNGs

- **Why emoji may be enough:** Rewards screen already uses emoji with themed card colors — matches app style.
- **When to add:** If parents/kids want collectible visual variety beyond emoji.
- **Priority:** P4 future.
