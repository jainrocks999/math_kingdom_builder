# Screen: Splash

**Planned file:** `lib/features/alphabet/splash/alphabet_splash_screen.dart`  
**Route:** `/alphabet-splash`  
**Status:** Planned

## Purpose

Introduce the app brand, preload core assets, restore child state, and decide the first destination.

## Primary user

- Child
- Parent on first launch

## Main responsibilities

- Show app identity
- Play short visual intro
- Restore saved onboarding state
- Restore active child profile
- Restore selected language track
- Decide whether to open onboarding, track selection, or home

## Entry conditions

- App launched fresh
- App resumed from terminated state

## Exit routes

- `/alphabet-onboarding`
- `/choose-language-track`
- `/alphabet-home`

## UI structure

- Full-screen background illustration
- App logo or mascot center stage
- Short title text: `Alphabet Kingdom`
- Subtitle in current app language
- Soft loading indicator
- Optional `Skip` after `2-3` seconds only if intro media is longer

## Loading work

- Translation init
- Audio settings load
- Parent PIN state load
- Child profile load
- Progress snapshot load
- Last selected learning track load
- Optional cached letter data load

## Content notes

- Keep copy very short
- Avoid teaching content here
- Hindi and English title can stay brand-consistent rather than fully localized if needed

## Audio

- No loud intro
- One soft branded sound at most
- No speech prompt unless accessibility mode requires it

## Edge cases

- If progress data fails, continue with defaults
- If selected track is missing, route to track selection
- If onboarding completed flag is broken, favor onboarding rather than risk confusion

## Accessibility

- Skip button must be reachable
- No flashing animation
- Respect reduced motion if implemented

## Acceptance criteria

- Loads reliably
- Never traps user on splash
- Routes correctly for first-time and returning users
- No audio overlap into next screen
