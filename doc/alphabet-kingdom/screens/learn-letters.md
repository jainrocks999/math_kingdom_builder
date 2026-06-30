# Screen: Learn Letters

**Planned file:** `lib/features/alphabet/learn_letters/learn_letters_screen.dart`  
**Route:** `/learn-letters`  
**Status:** Planned

## Purpose

Help the child see, hear, and become familiar with letters one at a time.

## Main responsibilities

- Present one letter clearly
- Play its name or sound
- Show one picture association
- Allow forward/back movement
- Build familiarity without testing pressure

## Track behavior

### English track

Show:

- Uppercase letter
- Lowercase pair
- Letter name
- Optional phonics sound
- Example object

Example:

- `A`
- `a`
- `A for Apple`
- optional phonics replay: `/a/`

### Hindi track

Show:

- Akshar
- Sound-led pronunciation
- Example word
- Picture
- Group badge like `स्वर` or `व्यंजन`

Example:

- `अ`
- `अ से अनार`

## Core UI blocks

- Top bar with back and speaker
- Track badge
- Large letter display
- Secondary paired display if relevant
- Example picture card
- Example word label
- Scrollable selector rail
- Previous / next controls

## Interaction design

- Tap speaker to hear the current letter
- Tap secondary speaker to hear example word
- Swipe or tap next/previous to move between letters
- Tap selector chip to jump to a letter

## Content rules

English:

- Keep one strong object example per letter
- Avoid confusing phonics variants in MVP
- Prefer common child vocabulary: `Apple`, `Ball`, `Cat`

Hindi:

- Use culturally familiar examples
- Avoid rare textbook words where possible
- Prefer words a young child can visualize easily

## Audio behavior

- Auto-speak current letter on first open
- Manual replay for letter
- Manual replay for example word
- English may offer separate `name` and `sound` buttons in later phase

## Visual rules

- Letter must dominate the screen
- Example picture large enough for recognition
- Avoid cluttering with too many labels

## Progress logic

Mark a letter as `seen` when:

- It is shown for more than a minimal threshold
- Or the child taps replay

Mark lesson complete when:

- Child explores a reasonable batch
- Or reaches end-of-set

## Edge cases

- If TTS for a specific symbol is weak, use custom recorded fallback later
- If Hindi pronunciation is awkward on device TTS, keep UI working and allow manual content overrides

## Acceptance criteria

- Child can browse letters smoothly
- Audio reliably matches visible content
- English and Hindi content both feel native to their track
