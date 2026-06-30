# Screen: Hear and Tap Letter

**Planned file:** `lib/features/alphabet/hear_letter/hear_and_tap_letter_screen.dart`  
**Route:** `/hear-letter`  
**Status:** Planned

## Purpose

Train listening-based letter recognition by asking the child to hear a prompt and choose the correct letter.

## Main responsibilities

- Speak a letter clearly
- Show multiple options
- Let child choose one
- Give immediate feedback
- Repeat with mixed rounds

## Round format

- `1` spoken target
- `4` visible options
- `1` correct answer
- `3` distractors

## Track behavior

### English track

Prompt types:

- Letter name prompt
- Later optional phonics sound prompt

MVP recommendation:

- Start with letter names only
- Add phonics mode later

### Hindi track

Prompt types:

- Akshar pronunciation

## UI blocks

- Speaker button
- Prompt title
- Option grid
- Progress strip
- Mascot or feedback area

## Option design

- Letters must be large
- Avoid too many lookalike distractors too early
- Increase difficulty gradually

## Difficulty progression

Easy:

- Strongly distinct letters

Medium:

- Similar families

Hard:

- Visually close letters
- Same-group Hindi letters
- Upper/lowercase confusion pairs in English

## Feedback

Correct:

- Highlight card
- Success SFX
- Spoken praise

Wrong:

- Gentle wrong SFX
- Replay available instantly
- Brief hint like `Listen again`

## Audio

- Auto-speak prompt at round start
- Replay button always visible
- Avoid stacking speech requests

## Progress logic

Track:

- First-try accuracy
- Total attempts
- Confusing pairs

## Edge cases

- Child may tap before speech ends
- Parent may mute audio and rely on replay
- Some device TTS pronunciations may need fallback later

## Acceptance criteria

- Prompt replay always works
- Options are readable and tappable
- Difficulty can scale without changing whole screen architecture
