# Screen: Word Builder

**Planned file:** `lib/features/alphabet/word_builder/word_builder_screen.dart`  
**Route:** `/word-builder`  
**Status:** Planned

## Purpose

Move from isolated letters into simple word formation.

## Important note

This screen should be introduced only after basic recognition confidence exists. It is not a first-week screen for every child.

## Track behavior

### English track

MVP focus:

- `2-3` letter simple words
- Prefer highly visual words

Examples:

- `CAT`
- `SUN`
- `BAT`

Possible exercise types:

- Fill missing first letter
- Arrange letters in order
- Hear word and choose missing letter

### Hindi track

MVP focus:

- Simple non-matra words first
- Very short and familiar words

Examples depend on content strategy, but should be:

- Visually easy
- Common in speech
- Not linguistically overloaded

Matra-based content should be phase two unless deliberately planned.

## UI blocks

- Picture target
- Spoken target word
- Letter slots
- Draggable or tappable letter options
- Check / continue action

## Best MVP mode

Use one mode first:

- Show picture
- Show incomplete word
- Child fills one missing letter

This is simpler than full freeform spelling.

## Content rules

- Use only letters already taught
- Keep word length short
- Avoid silent-letter complexity in English
- Avoid matra complexity in Hindi MVP

## Feedback

Correct:

- Word reads aloud
- Picture celebrates

Wrong:

- Reset only the wrong slot
- Offer `Listen again`

## Audio

- Tap picture to hear word
- Tap letter tile to hear letter
- On success, speak full word slowly

## Progress logic

Track:

- Word families completed
- Common mistake letters
- Reading confidence progression

## Edge cases

- If a child has not unlocked enough letters, keep this module locked
- Hindi content must be reviewed carefully for age-appropriateness

## Acceptance criteria

- Word-building feels achievable
- Not too hard for early learners
- Both tracks can scale independently
