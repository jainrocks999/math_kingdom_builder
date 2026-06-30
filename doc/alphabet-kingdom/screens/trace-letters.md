# Screen: Trace Letters

**Planned file:** `lib/features/alphabet/trace_letters/trace_letters_screen.dart`  
**Route:** `/trace-letters`  
**Status:** Planned

## Purpose

Teach early writing motion through guided tracing with friendly visual help.

## Main responsibilities

- Show correct stroke path
- Let child draw over ghost letter
- Give gentle success or retry feedback
- Move letter by letter through a small guided set

## Track behavior

### English track

Support:

- Uppercase first
- Lowercase after uppercase confidence

Recommended MVP:

- Start with uppercase only
- Add lowercase pairing later

### Hindi track

Support:

- Swar first
- Vyanjan in grouped batches

Recommended MVP:

- Start with a small set of easy swar
- Delay complex joint or visually dense forms

## UI blocks

- Back button
- Progress indicator
- Letter target card
- Stroke order hint
- Trace canvas
- Clear / retry button
- Speaker button
- Next button after success

## Tracing assist levels

Need at least:

- Full guide path
- Soft snap tolerance
- Success threshold that is forgiving

Optional later:

- Parent-controlled assist levels

## Stroke guidance

Each lesson should define:

- Ordered stroke list
- Prompt text
- Entry point
- Direction hint

## Feedback behavior

Correct:

- Soft haptic
- Short success sound
- Mascot praise

Needs retry:

- Gentle prompt
- Highlight missed section
- No harsh red failure state

## Audio

- Speak letter name
- Speak tracing prompt like `Start here`
- Hindi prompts should be very short

## Content pacing

- One letter at a time
- `5-8` letters per trace session is enough
- Do not overwhelm with full alphabet in one sitting

## Edge cases

- Very small fingers should still succeed
- Device lag should not break drawing
- Leaving mid-trace should not corrupt state

## Acceptance criteria

- Child can complete guided traces without frustration
- Stroke validation is forgiving but directional
- Screen works for both English and Hindi letter shapes
