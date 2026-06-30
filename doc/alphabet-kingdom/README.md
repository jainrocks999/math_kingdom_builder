# Alphabet Kingdom — Documentation Pack

Screen-by-screen product documentation for a bilingual Hindi + English early-learning app built in the same spirit as Math Kingdom Builder.

## Goal

Create a child-friendly learning app that teaches:

- English alphabet recognition
- English phonics basics
- Hindi varnamala recognition
- Hindi sound association
- Letter tracing and early writing habits
- Simple word-building progression

## Product direction

This concept should feel like a sibling app to Math Kingdom Builder, not a totally different product. We should reuse:

- Reward loops
- TTS guidance
- Parent dashboard concepts
- Child profile flow
- Progress unlocks
- Friendly mascot-led learning

## Recommended screen order

1. Splash
2. Onboarding
3. Language Track Selection
4. Home
5. Start Learning
6. Learn Letters
7. Trace Letters
8. Hear and Tap Letter
9. Match Letter to Picture
10. Alphabet Order
11. Word Builder
12. Mini Quiz
13. Kingdom Map
14. Rewards
15. Parent Dashboard
16. Settings

## Important product rule

Hindi and English should live in the same app, but the child should usually learn in one track at a time.

- English track: `A-Z`, uppercase/lowercase, sounds, simple phonics
- Hindi track: `स्वर`, `व्यंजन`, sound familiarity, simple shabd, later matras

Do not mix both tracks too aggressively on the same exercise screen unless the activity is explicitly a bilingual bridge activity.

## Files in this pack

| Document | Purpose |
|----------|---------|
| [overview.md](./overview.md) | Product vision, content structure, routes, rewards, track strategy |
| [screens/splash.md](./screens/splash.md) | Brand entry and loading flow |
| [screens/onboarding.md](./screens/onboarding.md) | Parent/child introduction flow |
| [screens/language-track-selection.md](./screens/language-track-selection.md) | English vs Hindi learning path selection |
| [screens/home.md](./screens/home.md) | Main hub with featured cards and daily challenges |
| [screens/start-learning.md](./screens/start-learning.md) | Core module path and unlock logic |
| [screens/learn-letters.md](./screens/learn-letters.md) | Letter discovery and TTS-led learning |
| [screens/trace-letters.md](./screens/trace-letters.md) | Guided tracing flow |
| [screens/hear-and-tap-letter.md](./screens/hear-and-tap-letter.md) | Letter recognition by listening |
| [screens/match-letter-picture.md](./screens/match-letter-picture.md) | Picture-word-letter association |
| [screens/alphabet-order.md](./screens/alphabet-order.md) | Sequence and missing-letter logic |
| [screens/word-builder.md](./screens/word-builder.md) | Early word formation |
| [screens/mini-quiz.md](./screens/mini-quiz.md) | Mixed assessment loop |
| [screens/kingdom-map.md](./screens/kingdom-map.md) | Meta progression world |
| [screens/rewards.md](./screens/rewards.md) | Stars, badges, sticker album |
| [screens/parent-dashboard.md](./screens/parent-dashboard.md) | Adult-only progress review |
| [screens/settings.md](./screens/settings.md) | Language, voice, speed, audio, learning controls |

## How to use

1. Read [overview.md](./overview.md) first.
2. Build one screen from `screens/` at a time.
3. Keep content and reward logic aligned with the chosen language track.
4. Reuse Math Kingdom Builder components where possible.
5. Treat every screen doc as an implementation checklist plus product reference.
