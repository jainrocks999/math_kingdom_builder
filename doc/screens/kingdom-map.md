# Screen: Kingdom Map

**File:** `lib/features/kingdom/kingdom_screen.dart`  
**Route:** `/kingdom`
**Status:** Implemented with ambient audio deferred (2026-06-19)

## Current purpose

Interactive pan/zoom map; zones unlock with progress; launch quests from zones.

## Existing functionality

- Hive kingdom state + `KingdomService` sync
- Zone unlock dialogs
- Bottom panel with zone CTA
- Cloud decorations, gradient sky

## Current issues

- Pan/zoom may confuse young kids
- Meadow unlock rules non-obvious
- Basic loading spinner
- No ambient audio

## Priority: P2 | Complexity: Medium

## Development tasks

### Bug fixes
- [x] Locked zone CTA doesn’t open wrong routes

### UI
- [x] Prominent “Reset map” / “Find me” button
- [x] Loading skeleton vs spinner
- [x] Larger zone tap targets

### Existing functionality
- [x] Live zone progress from completion counts
- [ ] Optional soft ambient music (low volume)

### New (optional)
- [ ] Rive mascot pointer to recommended zone

### Kids experience
- [x] Unlock dialog with bear + zone emoji

### Responsiveness
- [x] Map height on tablets vs phones
- [x] Bottom panel on short screens

## Notes

- Recommended-zone focusing is now easier through a dedicated `Find Me` action.
- Kingdom data already reflects live progress from `RewardProgressService`; loading polish was added on top.
- Ambient audio is still deferred because it is optional and current map usability was the higher-value fix.

## Assets

- **Reuse:** kingdom widgets, zone colors, emoji
- **New:** Optional `mascot.riv` — not required

## Acceptance criteria

Zones reflect progress; unlock once; play routes work; usable on small screens.
