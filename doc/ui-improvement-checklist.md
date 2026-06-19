# UI Improvement Checklist

Grouped checklist for implementation passes. Apply globally then per screen.

## Colors

- [x] Remove duplicate `lib/app_colors.dart`; use `core/constants/app_colors.dart` only
- [ ] Use `correctFeedback` / `incorrectFeedback` for answer states consistently
- Progress: `Mini Quiz`, `Matching`, `Count Objects`, `Find Correct Number`, and `Number Recognition` now use semantic feedback colors
- [ ] Parent zone keeps `parentAccent` — don’t mix into kid screens arbitrarily

## Typography

- [x] Fredoka everywhere; remove Google Fonts LilitaOne from `BouncingGameButton`
- [x] Responsive scaling for hero text (clamp by screen width)
- [ ] Minimum ~14sp for kid-readable subtitles
- Progress: key header subtitles bumped to 14sp where practical (`Home`, `Rewards`, `Learn Numbers`, `Matching`), and secondary card subtitles were raised from 11sp to 12sp in `Home` and `Start Learning`

## Spacing

- [ ] Standard screen padding: 18 horizontal, 16 top (match Home)
- [ ] Card internal padding 14–18 consistent
- [ ] 12–18px between stacked learning cards

## Buttons

- [ ] Minimum 48×48 touch targets; primary CTAs 52+ height
- [x] Shared back button style (from Start Learning `_BackButton`)
- [ ] `BouncingGameButton` for primary game actions where appropriate
- Progress: shared math-ops circle buttons now use 52px touch targets
- Progress: `BouncingGameButton`, onboarding controls, and Number Recognition controls now use `InkWell`

## Cards

- [ ] Unified 3D shadow pattern (offset Y 5–6, blur 0)
- [ ] Border radius 24–28 for large cards, 18 for chips
- Progress: math operation stage cards now use a shared surface decoration for Addition/Subtraction/Multiplication/Division
- Progress: Sequencing and Patterns prompt/hint/options cards now match the same layered card treatment

## Icons and images

- [ ] `errorBuilder` with emoji/icon fallback on all `Image.asset` cards
- Progress: high-traffic fallbacks added for onboarding illustrations, celebration bear, math-op object tokens, tracing celebration bear, learn/count/match object visuals, and mini quiz object visuals
- [ ] Bear assets for celebrations consistently

## Animations

- [ ] Press scale ~0.96 on tappable cards
- [ ] `CelebrationBear` on module completions
- [ ] Don’t start `AnimationController` in `build()` without lifecycle

## Sounds

- [ ] Correct: `correct.mp3` + short TTS
- [ ] Wrong: `wrong_soft.mp3` only (gentle)
- [ ] Module complete: `celebration.mp3`
- Progress: wrong feedback is centralized through `playWrongFeedback()`, celebration music is centralized through `playCelebrationMusic()`, and major game flows use `correct.mp3`

## Empty states

- [x] Shared kid-friendly “Oops” component with bear

## Error states

- [x] Home retry pattern for Kingdom/Rewards load failures

## Loading states

- [x] Primary-color spinner or skeleton cards on key kid screens (not bare spinner)

## Touch targets

- [x] Audit `GestureDetector` without minimum hit area
- Progress: remaining raw `GestureDetector` usage is intentional for tracing/canvas interactions plus `NumberBlock`

## Responsive layout

- [ ] `LayoutBuilder` breakpoints: &lt;360, 360–400, &gt;400 width
- [ ] Stack vs row for quiz grids on narrow phones
- [ ] Test text scale factor 1.3x
