# Developer Notes

Constraints, testing focus, and safe changes for implementers.

## Do not change

- Core color palette and candy-castle 3D card shadow identity
- Fredoka as primary kid-facing font
- Hive box schemas without a migration plan
- Parent PIN security model (cooldown, obscure fields)
- Kingdom zone layout coordinates without UX review
- Star unlock thresholds (4 / 8 / 14) without product approval

## Test carefully

- **Audio lifecycle** across push/pop: Home → Start Learning → activity → back
- **TTS + BGM on iOS** — `AppAudioService` copies assets to temp directory
- **Trace validation** across screen sizes and DPI
- **Drag-and-drop** on Mini Quiz, Math Ops, Sequencing, Patterns on real Android
- **Unlock dialogs** — only once per newly unlocked module/route
- **Onboarding flag** persistence (skip + complete paths)

## Can postpone

- Rive `mascot.riv` integration
- `confetti.json` Lottie (bear-only celebrations first)
- Hindi / regional voices
- Unique sticker PNG artwork
- Firebase / analytics (commented in `pubspec.yaml`)

## Avoid

- New navigation or state-management libraries
- Replacing TTS with large voice MP3 packs without proven need
- Heavy particle systems or new animation packages
- Force-push or destructive git operations on shared branches

## Safe using existing resources

- All UI polish via `AppColors`, `AppTypography`, bear PNGs, counting JPEGs, emoji, SFX/BGM
- Consolidating duplicate widgets and audio helpers
- Binding Home / Start Learning to `RewardProgressService` without schema changes
- Parent sound toggles via existing `AudioService` flags

## File locations (quick reference)

| Area | Path |
|------|------|
| Router | `lib/core/router/app_router.dart` |
| Colors / typography | `lib/core/constants/` |
| Background audio | `lib/core/services/audio_service.dart` |
| SFX / TTS utils | `lib/core/utils/audio_service.dart` |
| Progress / stars | `lib/core/services/reward_progress_service.dart` |
| Start Learning nav | `lib/features/StartLearning/start_learning_navigation.dart` |
| Home JSON | `assets/data/home/` |

## Updating these docs

When implementation changes behavior (routes, unlock rules, assets), update the matching `doc/screens/*.md` file and bump notes in `doc/README.md` if structure changes.
