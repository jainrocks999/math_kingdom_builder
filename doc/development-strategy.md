# Development Strategy

## Principles

1. **One screen at a time** — finish bugs → existing improvements → UI polish → small new features → acceptance criteria before moving on.
2. **Fix global issues first** so every screen benefits (duplicate services, audio lifecycle, onboarding skip, missing assets).
3. **Improve existing functionality** before adding features (feedback, progress, rewards feel).
4. **Improve UI/UX** using existing cards, colors, bear, shadows — no full redesign.
5. **Add small useful features only** where they clearly help kids (replay voice, retry hint, speaker button).
6. **Performance cleanup last** — after screens are stable.
7. **Optional enhancements** only if time remains (Rive mascot, confetti Lottie).

## Implementation order (high level)

```
Global fixes → Shared components → Onboarding → Home → Start Learning
→ Guided learning path (Learn → Trace → Count → Find → Match → Quiz)
→ Rewards → Math Ops + Sequencing + Patterns → Kingdom → Parent → Splash polish
→ Final testing & performance
```

See [recommended-screen-order.md](./recommended-screen-order.md) and [implementation-plan.md](./implementation-plan.md) for detail.

## What to reuse

- `AppColors` / `AppTypography` from `core/constants/`
- Bear images, counting object JPEGs, existing SFX and BGM
- `CelebrationBear`, `StartLearningNextActionButton`, math operation widgets
- `RewardProgressService` for stars and completion — do not duplicate persistence

## What to avoid

- New navigation or state-management libraries
- Large packs of voice MP3s unless TTS quality is proven insufficient
- Heavy particle systems or new animation packages
- Redesigning the candy-castle card shadow identity

## Definition of done (per screen)

Each screen doc includes **Acceptance Criteria**. A screen is complete when:

- Listed P0/P1 bugs for that screen are fixed
- UI works on small Android (~320dp) and typical iOS phones
- Audio/TTS does not leak or overlap when navigating away
- Progress/stars record correctly if the screen awards completion
- No new analyzer warnings introduced in touched files
