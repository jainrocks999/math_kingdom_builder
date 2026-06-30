# Screen: Settings

**Planned file:** `lib/features/alphabet/settings/alphabet_settings_screen.dart`  
**Route:** `/alphabet-settings`  
**Status:** Planned

## Purpose

Provide parent-friendly controls for language, voice, audio, and learning assistance.

## Main responsibilities

- Switch app UI language
- Switch active learning track
- Control music and SFX
- Control TTS behavior
- Control child-friendly assist settings

## Core settings sections

### Language

- App language: Hindi / English
- Active track: Hindi / English

### Audio

- Music on/off
- Sound effects on/off
- Speech rate
- Auto-play voice prompts on/off

### Voice

- Preferred TTS voice if available
- Preview current voice

### Learning support

- Tracing assist level
- Replay instructions automatically
- Daily goal target

### Parent safety

- Set/update parent PIN

## UI blocks

- Settings hero header
- Card sections
- Toggle rows
- Select inputs
- Preview buttons
- Save or instant-apply behavior

## Behavior recommendation

Use instant save for simple toggles:

- Music
- SFX
- Auto speech

Use explicit save for:

- Parent PIN
- Child profile changes if needed

## Audio preview examples

English preview:

- `Hello. Alphabet Kingdom is ready for learning.`

Hindi preview:

- `नमस्ते। Alphabet Kingdom सीखने के लिए तैयार है।`

## Edge cases

- Device may not have ideal Hindi voice
- Changing app language should not erase learning track progress
- Turning speech off should not break screens that depend on replay buttons

## Acceptance criteria

- Parent can control the experience without confusion
- Voice and audio settings apply across the app
- Track switching remains safe and predictable
