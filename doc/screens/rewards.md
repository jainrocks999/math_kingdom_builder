# Screen: Rewards / Stickers

**File:** `lib/features/rewards/rewards_screen.dart`  
**Route:** `/stickers`
**Status:** Implemented with deferred persistence/detail polish (2026-06-19)

## Current purpose

Browse stickers, badges, trophies; claim rewards unlocked by star threshold.

## Existing functionality

- Category tabs (stickers, badges, trophies)
- Claim flow + celebration bear
- RouteAware music
- Star total header

## Current issues

- Emoji-only rewards (acceptable for v1)
- “Claim” label less kid-friendly than “Collect!”
- Claimed reward persistence now uses `RewardProgressService` only

## Priority: P2 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Prevent double-claim taps

### UI
- [x] Locked: grayscale + lock icon
- [x] Category tabs min 48dp height
- [x] Change “Claim” → “Collect!”

### Existing functionality
- [x] Align persistence with claimed set (remove or wire `StickerAlbum`)
- [x] Progress to next reward in header

### New (optional)
- [ ] Sticker detail bottom sheet with TTS

### Kids experience
- [x] Collect animation (scale + star burst)

### Responsiveness
- [x] Grid: 2 columns phone, 3 tablet

## Deferred

- [ ] Sticker detail bottom sheet with TTS

## Assets

- **Reuse:** emoji, bear, gold palette
- **New:** No for v1

## Acceptance criteria

Claim persists through `RewardProgressService`; categories work; locked/unlocked clear; responsive grid.

## Implementation notes

- Collecting a reward now uses built-in Flutter animation only: selected reward pulse, detail-card star burst, and claimed summary bounce.
