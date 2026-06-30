# Screen: Language Track Selection

**Planned file:** `lib/features/alphabet/track_selection/language_track_selection_screen.dart`  
**Route:** `/choose-language-track`  
**Status:** Planned

## Purpose

Help the parent or child choose which learning journey to enter first: English or Hindi.

## Why this screen matters

This is the key product decision point. Without it, the app may feel crowded and confusing because Hindi and English content progress differently.

## Main responsibilities

- Present two clear track cards
- Explain what each track contains
- Save active track
- Allow track switching later from settings or parent dashboard

## Options

### English Track

Includes:

- `A-Z`
- Uppercase and lowercase
- Letter sounds
- Object words
- Easy word building

### Hindi Track

Includes:

- `स्वर`
- `व्यंजन`
- Letter sounds
- Picture association
- Simple शब्द practice

## UI structure

- Screen title
- One-line helper text
- Two large track cards
- Visual badge for each track
- `Continue` button after selection
- Small note: track can be changed later

## Card content

Each card should show:

- Language name
- Native script
- Sample letters
- Age-friendly subtitle
- Friendly illustration

## Suggested card text

English:

- Title: `English Letters`
- Preview: `A B C`
- Subtitle: `Learn letters, sounds, and simple words`

Hindi:

- Title: `हिन्दी अक्षर`
- Preview: `अ आ इ`
- Subtitle: `स्वर, व्यंजन और आसान शब्द सीखें`

## Selection behavior

- One card selected at a time
- Selection animates softly
- Continue disabled until selection is made

## Parent considerations

- If child is under `4`, parent may prefer one-track-only mode
- Later we can support dual-track home, but not in MVP

## Persistence

Save:

- `active_track`
- `track_selected_at`
- optional `has_seen_track_explainer`

## Audio

- Tap on each card can speak the language title
- Do not auto-speak both cards on screen load

## Edge cases

- If no selection saved, always return here after onboarding
- If track content pack is unavailable, show graceful retry

## Acceptance criteria

- User can clearly understand the difference
- Selection persists
- Home screen opens in the selected track
