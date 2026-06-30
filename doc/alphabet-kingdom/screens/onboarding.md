# Screen: Onboarding

**Planned file:** `lib/features/alphabet/onboarding/alphabet_onboarding_screen.dart`  
**Route:** `/alphabet-onboarding`  
**Status:** Planned

## Purpose

Explain the app in a joyful, simple way for the child while giving the parent confidence about bilingual learning, audio guidance, and rewards.

## Main responsibilities

- Introduce the mascot and learning world
- Set expectation that the app teaches letters through play
- Highlight Hindi + English support
- Move user to language track selection
- Mark onboarding complete on finish or skip

## Recommended page count

Use `3` pages only.

## Page content

### Page 1

Goal:

- Show colorful learning kingdom

Message:

- Letters are fun
- We hear them, tap them, and trace them

### Page 2

Goal:

- Introduce bilingual tracks

Message:

- Learn English letters
- Learn Hindi अक्षर
- Pick one path and grow at your pace

### Page 3

Goal:

- Explain rewards and parent controls

Message:

- Earn stars
- Unlock fun
- Parents can track progress safely

## UI structure

- Hero illustration
- Large title
- One short description
- Page indicator dots
- `Next` button
- Final `Start Learning` button
- Visible `Skip`

## Copy rules

- Child-friendly
- Maximum `1-2` short sentences per card
- Avoid heavy parent-focused text

## Interaction details

- Swipe allowed
- Buttons allowed
- Page indicator tappable
- Skip should immediately mark onboarding complete

## Localization notes

- Copy must exist in Hindi and English
- Hindi text should remain simple, not overly formal
- Use `अक्षर`, `सीखो`, `सुनो`, `ट्रेस करो` style vocabulary

## Audio

- Optional page narration
- Replay speaker on each card optional
- Do not auto-speak long paragraphs

## Edge cases

- Skip must not break persistence
- Returning users should not see onboarding again unless reset by parent

## Acceptance criteria

- First-time user understands app purpose
- Skip and finish both persist completion state
- Next destination is always track selection
