# Screen: Alphabet Order

**Planned file:** `lib/features/alphabet/sequencing/alphabet_order_screen.dart`  
**Route:** `/alphabet-order`  
**Status:** Planned

## Purpose

Teach ordered recall by asking the child to complete simple letter sequences.

## Main responsibilities

- Show a letter pattern
- Hide one missing position
- Let child fill the gap
- Build order familiarity gradually

## Recommended round types

- Missing middle letter
- Missing final letter
- Two-step short sequence completion

## Track behavior

### English track

Examples:

- `A B _ D`
- `_ F G H`
- `M _ O P`

### Hindi track

Examples should respect grouped progression:

- `अ आ _ ई`
- `क ख _ घ`

Do not jump randomly across the full varnamala in early levels.

## UI blocks

- Prompt text
- Sequence row
- Option chips
- Replay or instruction button
- Progress indicator

## Difficulty progression

Phase 1:

- Ordered chunks of `4`

Phase 2:

- Longer chunks
- Similar letters

Phase 3:

- Group transition awareness

## Interaction patterns

- Tap option to fill blank
- Optional drag option later

## Feedback

Correct:

- Sequence animates complete
- Spoken confirmation

Wrong:

- Blank resets gently
- Offer replay

## Audio

- Prompt like `Which letter comes next?`
- Optional readout of visible sequence

## Data needs

- Ordered list per track
- Ordered subgroup list for Hindi
- Mastery per chunk

## Edge cases

- Hindi ordering should not overwhelm early learners
- Similar glyph confusion should be introduced gradually

## Acceptance criteria

- Child can complete short ordered sequences
- English and Hindi both use sensible progression chunks
