# Screen: Parent Dashboard

**File:** `lib/features/parent_dashboard/parent_dashboard_screen.dart`  
**Route:** `/parent-dashboard`

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
- [ ] PIN cooldown message accuracy

### UI
- [ ] Larger PIN fields on tablets
- [ ] Clear section headers

### Existing functionality
- [ ] Sound Effects ON/OFF, Music ON/OFF toggles
- [ ] Optional speech rate slow/normal
- [ ] Child profile switcher (reuse Start Learning pattern)

### New (optional)
- [ ] Weekly summary line
- [ ] Export progress text — P4

### Responsiveness
- [ ] Scroll reports on small phones

## Assets

- **Reuse:** parent color palette
- **New:** No

## Components

- `ParentSettingsSection`

## Acceptance criteria

PIN secure; toggles affect app audio; reports match `RewardProgressService`.
