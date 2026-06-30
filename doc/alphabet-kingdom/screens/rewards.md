# Screen: Rewards

**Planned file:** `lib/features/alphabet/rewards/alphabet_rewards_screen.dart`  
**Route:** `/alphabet-rewards`  
**Status:** Planned

## Purpose

Turn practice into visible celebration through stickers, badges, trophies, and milestone rewards.

## Main responsibilities

- Show earned stars
- Show unlocked rewards
- Let child claim new items
- Reinforce continued play

## Reward categories

- Letter stickers
- Track-themed badges
- Milestone trophies
- Streak rewards

## Reward examples

English:

- `A Apple Sticker`
- `ABC Explorer Badge`
- `First Quiz Trophy`

Hindi:

- `अ अनार Sticker`
- `स्वर स्टार Badge`
- `अक्षर मित्र Trophy`

## UI blocks

- Total stars header
- Claimable rewards strip
- Sticker album grid
- Badge shelf
- Trophy section

## Claim logic

- New rewards should feel claimable, not silently granted
- Claim action should trigger a short celebration

## Track behavior

- Rewards may be track-specific
- Some rewards can be shared globally

## Audio

- Claim sound
- Optional spoken reward name

## Edge cases

- Rewards should not depend on network
- Reopening screen should show already claimed state correctly

## Acceptance criteria

- Rewards are understandable to young children
- Claim flow is satisfying
- Track-specific reward art can scale later
