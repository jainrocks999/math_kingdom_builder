# Screen: Kingdom Map

**File:** `lib/features/kingdom/kingdom_screen.dart`  
**Route:** `/kingdom`

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
- [ ] Locked zone CTA doesn’t open wrong routes

### UI
- [ ] Prominent “Reset map” / “Find me” button
- [ ] Loading skeleton vs spinner
- [ ] Larger zone tap targets

### Existing functionality
- [ ] Live zone progress from completion counts
- [ ] Optional soft ambient music (low volume)

### New (optional)
- [ ] Rive mascot pointer to recommended zone

### Kids experience
- [ ] Unlock dialog with bear + zone emoji

### Responsiveness
- [ ] Map height on tablets vs phones
- [ ] Bottom panel on short screens

## Assets

- **Reuse:** kingdom widgets, zone colors, emoji
- **New:** Optional `mascot.riv` — not required

## Acceptance criteria

Zones reflect progress; unlock once; play routes work; usable on small screens.
