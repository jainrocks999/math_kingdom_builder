# Screen: Mini Quiz

**Planned file:** `lib/features/alphabet/quiz/alphabet_mini_quiz_screen.dart`  
**Route:** `/alphabet-quiz`  
**Status:** Planned

## Purpose

Provide a mixed review experience that combines recognition, listening, matching, sequence thinking, and light word recall.

## Main responsibilities

- Rotate activity types
- Measure comfort without feeling like a formal exam
- Deliver the biggest reward loop
- Encourage replay

## Recommended quiz modes

- Tap the heard letter
- Match letter to picture
- Fill missing letter in sequence
- Choose lowercase for uppercase or reverse
- Fill missing letter in simple word

## Hindi-specific quiz modes

- Tap heard akshar
- Match akshar to picture
- Fill missing swar or simple vyanjan sequence
- Complete a simple word chunk

## Round count

Suggested MVP:

- `10-15` rounds

Full version:

- `20-30` rounds with resume support

## UI blocks

- Progress indicator
- Mode badge
- Question card
- Answer area
- Replay speaker
- Celebration overlay on finish

## Difficulty design

- Start with easy wins
- Mix challenge gradually
- Avoid consecutive frustrating rounds

## Resume behavior

Should persist:

- Current round
- Mode
- Correct count
- Current options if needed

## Reward logic

- Highest star payout among core modules
- Completion badge
- Optional streak bonus

## Audio

- Every audio-dependent round needs replay
- Stop speech before changing mode

## Feedback tone

- Quiz should feel like a game
- Never show score in a stressful red/green exam style
- Prefer labels like `Great`, `Nice try`, `Let us hear again`

## Edge cases

- Leaving mid-quiz should not lose all progress
- If track changes, old quiz resume should not bleed into the new track

## Acceptance criteria

- Quiz feels varied
- Resume works
- Completion reward feels special
