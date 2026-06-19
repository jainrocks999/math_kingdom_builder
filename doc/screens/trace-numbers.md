# Screen: Trace Numbers

**File:** `lib/features/number_tracing/trace_numbers_screen.dart`  
**Route:** `/tracing`

## Current purpose

Trace digits 0–9+ with stroke templates, multi-stroke lessons, celebration.

## Existing functionality

- Stroke path validation with tolerance
- Per-digit color themes
- TTS per stroke
- `recordModuleCompletion` on finish

## Current issues

- No RouteAware / session music
- Mixed Google Fonts + Fredoka
- Tracing tolerance may frustrate small screens

## Priority: P1 | Complexity: High

## Development tasks

### Bug fixes
- [ ] Auto-advance doesn’t skip mid-draw

### UI
- [ ] Replace Google Fonts with `AppTypography`
- [ ] Larger trace canvas on phones

### Existing functionality
- [ ] RouteAware audio pattern
- [ ] Scale tolerance by `size.shortestSide`
- [ ] Speaker replay for stroke prompt

### New (optional)
- [ ] Clear stroke / eraser button
- [ ] Ghost stroke hint after 2 failures

### Kids experience
- [ ] Celebration bear on lesson complete

### Responsiveness
- [ ] Canvas min height; bottom controls above gesture nav

## Assets

- **Reuse:** backgrounds, bear, SFX
- **New:** No

## Components

- Extract `TraceCanvas` widget

## Acceptance criteria

All digits traceable; kid-friendly tolerance; stars recorded; fonts consistent; no overflow.
