# Screen: Match Letter to Picture

**Planned file:** `lib/features/alphabet/matching/match_letter_picture_screen.dart`  
**Route:** `/match-letter-picture`  
**Status:** Planned

## Purpose

Build strong association between a letter, a spoken word, and a recognizable picture.

## Main responsibilities

- Show target letter
- Show multiple picture choices or match pairs
- Let child choose the correct picture for the letter
- Reinforce with spoken word

## Recommended MVP mode

Use the simplest version first:

- One target letter
- Four picture cards
- Child taps the right picture

## Possible later modes

- Drag letter to picture
- Match picture to starting letter
- Uppercase to lowercase to picture chain

## Track behavior

### English track

Examples:

- `A -> Apple`
- `B -> Ball`
- `C -> Cat`

### Hindi track

Examples:

- `अ -> अनार`
- `आ -> आम`
- `क -> कबूतर` or another culturally familiar word

## UI blocks

- Large target letter card
- Replay speaker
- Four picture options
- Word label shown after answer
- Progress indicator

## Content rules

- One dominant object only
- Avoid ambiguous images
- Keep illustrations child-obvious
- Ensure the starting sound matches the teaching goal

## Audio behavior

- Speak target letter first
- On correct answer, speak full association:
- English: `A for Apple`
- Hindi: `अ से अनार`

## Difficulty scaling

Easy:

- Very different objects and letters

Medium:

- Similar-looking letters but distinct objects

Hard:

- Similar-sound words
- Larger distractor pool

## Rewards and motivation

- Short praise after streaks
- Tiny star burst on correct

## Edge cases

- If image asset fails, do not show blank box
- If word association changes later, content IDs should remain stable

## Acceptance criteria

- Pictures are meaningful
- Child can infer the correct association
- Hindi and English examples feel natural, not forced
