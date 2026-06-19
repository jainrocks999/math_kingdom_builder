# UI Improvement Checklist

Grouped checklist for implementation passes. Apply globally then per screen.

## Colors

- [ ] Remove duplicate `lib/app_colors.dart`; use `core/constants/app_colors.dart` only
- [ ] Use `correctFeedback` / `incorrectFeedback` for answer states consistently
- [ ] Parent zone keeps `parentAccent` — don’t mix into kid screens arbitrarily

## Typography

- [ ] Fredoka everywhere; remove Google Fonts LilitaOne from `BouncingGameButton`
- [ ] Responsive scaling for hero text (clamp by screen width)
- [ ] Minimum ~14sp for kid-readable subtitles

## Spacing

- [ ] Standard screen padding: 18 horizontal, 16 top (match Home)
- [ ] Card internal padding 14–18 consistent
- [ ] 12–18px between stacked learning cards

## Buttons

- [ ] Minimum 48×48 touch targets; primary CTAs 52+ height
- [ ] Shared back button style (from Start Learning `_BackButton`)
- [ ] `BouncingGameButton` for primary game actions where appropriate

## Cards

- [ ] Unified 3D shadow pattern (offset Y 5–6, blur 0)
- [ ] Border radius 24–28 for large cards, 18 for chips

## Icons and images

- [ ] `errorBuilder` with emoji/icon fallback on all `Image.asset` cards
- [ ] Bear assets for celebrations consistently

## Animations

- [ ] Press scale ~0.96 on tappable cards
- [ ] `CelebrationBear` on module completions
- [ ] Don’t start `AnimationController` in `build()` without lifecycle

## Sounds

- [ ] Correct: `correct.mp3` + short TTS
- [ ] Wrong: `wrong_soft.mp3` only (gentle)
- [ ] Module complete: `celebration.mp3`

## Empty states

- [ ] Shared kid-friendly “Oops” component with bear

## Error states

- [ ] Home retry pattern for Kingdom/Rewards load failures

## Loading states

- [ ] Primary-color spinner or skeleton cards on kid screens (not bare spinner)

## Touch targets

- [ ] Audit `GestureDetector` without minimum hit area

## Responsive layout

- [ ] `LayoutBuilder` breakpoints: &lt;360, 360–400, &gt;400 width
- [ ] Stack vs row for quiz grids on narrow phones
- [ ] Test text scale factor 1.3x
