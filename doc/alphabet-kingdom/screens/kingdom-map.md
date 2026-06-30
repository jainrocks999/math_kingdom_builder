# Screen: Kingdom Map

**Planned file:** `lib/features/alphabet/kingdom/alphabet_kingdom_screen.dart`  
**Route:** `/alphabet-kingdom`  
**Status:** Planned

## Purpose

Give the child a visual sense of progress across the learning world.

## Main responsibilities

- Represent lesson progress spatially
- Unlock new themed areas
- Turn practice into a journey

## Recommended world structure

### English track

- Letter Garden
- Sound Bridge
- Picture Forest
- Word Village
- Quiz Castle

### Hindi track

- Swar Meadow
- Vyanjan Path
- Chitra Bagh
- Shabd Ghar
- Quiz Mahal

## UI blocks

- Map canvas
- Current position marker
- Locked zone markers
- Claimable reward highlight
- Enter-zone CTA

## Unlock logic

Each major map zone unlocks from star thresholds or module completions.

## Child experience goals

- Feel ownership
- See visible growth
- Understand `I unlocked something`

## Audio

- Ambient soft background only
- Zone tap can speak zone name

## Edge cases

- If map art is delayed, use simpler cards first
- Do not block learning progression if map is unfinished

## Acceptance criteria

- Map reflects progress accurately
- Zone entry feels exciting but simple
