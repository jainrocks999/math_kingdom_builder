# Screen: Parent Dashboard

**File:** `lib/features/parent_dashboard/parent_dashboard_screen.dart`  
**Route:** `/parent-dashboard`
**Status:** Implemented with export deferred (2026-06-19)

## Current purpose

PIN gate; view stars, streak, per-activity mastery (Exploring / Practicing / Confident).

## Existing functionality

- 4-digit PIN setup/verify with cooldown
- Activity reports for all learning modules
- Active profile name display

## Current issues

- No sound/music/TTS toggles (`AudioService` supports flags)
- No child profile switcher in dashboard
- Plain adult styling (appropriate for parent zone)

## Priority: P2 | Complexity: Low–Medium

## Development tasks

### Bug fixes
- [x] PIN cooldown message accuracy

### UI
- [x] Larger PIN fields on tablets
- [x] Clear section headers

### Existing functionality
- [x] Sound Effects ON/OFF, Music ON/OFF toggles
- [x] Optional speech rate slow/normal
- [x] Child profile switcher (reuse Start Learning pattern)

### New (optional)
- [x] Weekly summary line
- [ ] Export progress text — P4

### Responsiveness
- [x] Scroll reports on small phones

## Notes

- Audio preferences now persist and are wired into shared music/SFX/TTS helpers.
- Child profile switching is available directly inside the parent zone.
- Export remains deferred because it is explicitly low priority in the doc.

## Assets

- **Reuse:** parent color palette
- **New:** No

## Components

- `ParentSettingsSection`

## Acceptance criteria

PIN secure; toggles affect app audio; reports match `RewardProgressService`.
