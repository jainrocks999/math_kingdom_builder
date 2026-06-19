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
- `StickerAlbum` Hive model unused

## Priority: P2 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Prevent double-claim taps

### UI
- [x] Locked: grayscale + lock icon
- [x] Category tabs min 48dp height
- [x] Change “Claim” → “Collect!”

### Existing functionality
- [ ] Align persistence with claimed set (remove or wire `StickerAlbum`)
- [x] Progress to next reward in header

### New (optional)
- [ ] Sticker detail bottom sheet with TTS

### Kids experience
- [ ] Collect animation (scale + star burst)

### Responsiveness
- [x] Grid: 2 columns phone, 3 tablet

## Deferred

- [ ] Remove or properly wire unused `StickerAlbum` Hive model
- [ ] Sticker detail bottom sheet with TTS

## Assets

- **Reuse:** emoji, bear, gold palette
- **New:** No for v1

## Acceptance criteria

Claim persists; categories work; locked/unlocked clear; responsive grid.
