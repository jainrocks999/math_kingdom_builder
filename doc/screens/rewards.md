# Screen: Rewards / Stickers

**File:** `lib/features/rewards/rewards_screen.dart`  
**Route:** `/stickers`

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
- [ ] Prevent double-claim taps

### UI
- [ ] Locked: grayscale + lock icon
- [ ] Category tabs min 48dp height
- [ ] Change “Claim” → “Collect!”

### Existing functionality
- [ ] Align persistence with claimed set (remove or wire `StickerAlbum`)
- [ ] Progress to next reward in header

### New (optional)
- [ ] Sticker detail bottom sheet with TTS

### Kids experience
- [ ] Collect animation (scale + star burst)

### Responsiveness
- [ ] Grid: 2 columns phone, 3 tablet

## Assets

- **Reuse:** emoji, bear, gold palette
- **New:** No for v1

## Acceptance criteria

Claim persists; categories work; locked/unlocked clear; responsive grid.
