# Screen: Parent Dashboard

**Planned file:** `lib/features/alphabet/parent_dashboard/alphabet_parent_dashboard_screen.dart`  
**Route:** `/alphabet-parent-dashboard`  
**Status:** Planned

## Purpose

Give parents a calm, useful overview of the child’s learning without turning the app into a stressful score tracker.

## Main responsibilities

- Protect adult area with PIN
- Show progress by module
- Show active track
- Show strengths and practice needs
- Provide shortcuts to settings

## Main data sections

- Active child profile
- Active learning track
- Streak and session summary
- Module completion summary
- Letter familiarity summary
- Accuracy trends
- Recommended next focus

## Recommended insight blocks

- `Letters Seen`
- `Letters Practiced`
- `Most Confident Area`
- `Needs More Practice`
- `Today’s Activities`

## Track-specific reporting

English examples:

- Uppercase recognition
- Lowercase matching
- Sound recognition
- Word builder readiness

Hindi examples:

- Swar recognition
- Vyanjan recognition
- Picture association
- Early word readiness

## UI blocks

- PIN gate
- Child switcher
- Summary cards
- Module mastery list
- Settings shortcut
- Start learning shortcut

## Tone rules

- Use gentle labels
- Avoid harsh failure language
- Prefer `Exploring`, `Practicing`, `Confident`

## Audio controls shortcut

Parent dashboard should allow quick access to:

- Music
- SFX
- Voice speed
- Auto-speech

## Edge cases

- No child profile yet should trigger setup flow
- PIN lockout should be calm and clear

## Acceptance criteria

- Parent can understand what the child is doing
- Child cannot freely access dashboard without PIN
- Insights feel helpful, not judgmental
