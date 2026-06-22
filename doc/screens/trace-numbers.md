# Screen: Trace Numbers

**File:** `lib/features/number_tracing/trace_numbers_screen.dart`  
**Route:** `/tracing`
**Status:** Implemented with auto ghost hint support (2026-06-20)

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
- [x] Auto-advance doesn’t skip mid-draw

### UI
- [x] Replace Google Fonts with `AppTypography`
- [x] Larger trace canvas on phones

### Existing functionality
- [x] RouteAware audio pattern
- [x] Scale tolerance by `size.shortestSide`
- [x] Speaker replay for stroke prompt

### New (optional)
- [x] Clear stroke / eraser button
- [x] Ghost stroke hint after 2 failures

### Kids experience
- [x] Celebration bear on lesson complete

### Responsiveness
- [x] Canvas min height; bottom controls above gesture nav

## Assets

- **Reuse:** backgrounds, bear, SFX
- **New:** No

## Components

- Extract `TraceCanvas` widget

## Acceptance criteria

All digits traceable; kid-friendly tolerance; stars recorded; fonts consistent; no overflow.

## Deferred

- Extract `TraceCanvas` / board pieces into smaller widgets when the tracing flow is stable
