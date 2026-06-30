# Screen: Home

**Planned file:** `lib/features/alphabet/home/alphabet_home_screen.dart`  
**Route:** `/alphabet-home`  
**Status:** Planned

## Purpose

Act as the main hub for the child with quick entry into the next lesson, daily challenge, rewards, map, and parent area.

## Main responsibilities

- Welcome child back
- Show current track
- Surface the next recommended lesson
- Show featured actions
- Show quest cards
- Show daily challenge progress

## Top-level UI blocks

- Header with stars and parent/settings shortcuts
- Track badge: `English Track` or `Hindi Track`
- Hero title
- Daily challenge card
- Featured action cards
- Learning quest cards
- Progress strip or streak summary

## Featured actions

- Start Learning
- Kingdom Map
- Rewards
- Parent Zone

## Quest cards

Recommended quest cards:

- Learn Letters
- Trace Letters
- Hear and Tap
- Match Letter to Picture
- Alphabet Order
- Word Builder
- Mini Quiz

## Track-aware content behavior

If active track is English:

- Hero copy references letters and sounds
- Daily challenge pulls English module

If active track is Hindi:

- Hero copy references अक्षर and शब्द
- Daily challenge pulls Hindi module

## Daily challenge examples

English:

- Hear the letter `M`
- Match `B` with `Ball`
- Find the missing letter in `A B _ D`

Hindi:

- Tap `क`
- Match `अ` with `अनार`
- Find the missing letter in a simple varnamala strip

## UI details

- Large playful cards
- Minimal dense text
- Progress labels in child-friendly language
- One dominant CTA only

## Audio

- Home background music only here
- No automatic lesson narration
- Optional tap-to-hear hero welcome

## Rewards surfacing

- Total stars
- Today progress
- Current streak
- Claimable reward badge count

## Edge cases

- Empty progress state should still feel exciting
- If no daily challenge generated, show recommended lesson instead
- If active track changes, home content must refresh instantly

## Acceptance criteria

- Child can reach the next lesson in one tap
- Parent shortcuts are visible but not distracting
- Current learning track is always obvious
