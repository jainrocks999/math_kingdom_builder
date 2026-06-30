# Screen: Start Learning

**Planned file:** `lib/features/alphabet/start_learning/alphabet_start_learning_screen.dart`  
**Route:** `/alphabet-start-learning`  
**Status:** Planned

## Purpose

Provide the guided lesson path with module locks, progress summaries, recommended next action, and reward visibility.

## Main responsibilities

- Show all core alphabet modules
- Explain lock/unlock progression
- Highlight recommended next activity
- Show per-module progress
- Provide a structured learning journey

## Recommended module order

1. Learn Letters
2. Trace Letters
3. Hear and Tap Letter
4. Match Letter to Picture
5. Alphabet Order
6. Word Builder
7. Mini Quiz
8. Rewards

## Unlock logic

- Learn Letters: unlocked
- Trace Letters: unlocked
- Hear and Tap: unlock at `4★`
- Match Letter to Picture: unlock at `8★`
- Alphabet Order: unlock at `12★`
- Word Builder: unlock at `16★`
- Mini Quiz: unlock at `22★`

## UI blocks

- Profile summary
- Current track summary
- Today goal / streak card
- Recommended next lesson card
- Module list with progress bars
- Rewards shortcut
- More adventures or coming next section

## Card details per module

Each module card should show:

- Emoji or icon
- Title
- Subtitle
- Lock state
- Required stars if locked
- Completion count or mastery label
- Tap action

## Track-specific labels

English examples:

- `Learn Letters`
- `Trace Letters`
- `Hear and Tap`
- `Match with Picture`
- `Alphabet Order`
- `Word Builder`

Hindi examples:

- `अक्षर सीखें`
- `अक्षर ट्रेस करें`
- `सुनो और चुनो`
- `चित्र से मिलाओ`
- `क्रम पूरा करो`
- `शब्द बनाओ`

## Recommended next logic

Recommend the first:

- Untried unlocked module
- Then least-practiced unlocked module
- Then most recent incomplete module

## Audio

- Soft learning-screen background music
- Unlock dialog sound
- No auto-speech for whole screen

## Edge cases

- If child switches track, progress cards should show track-specific progress
- If all current modules completed, suggest free play or mini quiz replay

## Acceptance criteria

- Module locks behave correctly
- Child understands what is next
- Rewards feel connected to lesson completion
