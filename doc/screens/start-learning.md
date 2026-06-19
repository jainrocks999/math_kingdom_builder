# Screen: Start Learning

**File:** `lib/features/StartLearning/start_learning_screen.dart`  
**Route:** `/start-learning`

## Current purpose

Central learning hub: profile picker, daily goal, streak, locked/unlocked modules, rewards summary.

## Existing functionality

- Star gates: Find 4★, Match 8★, Quiz 14★
- Unlock / locked dialogs
- Child profile switcher
- RouteAware background music
- Per-module progress bars

## Current issues

- Math Ops, Patterns, Sequencing not listed (only on Home quests)
- Rewards card progress logic unclear
- Long vertical scroll

## Priority: P1 | Complexity: Medium

## Development tasks

### Bug fixes
- [ ] Unlock dialog only once per route (regression)

### UI
- [ ] Reduce duplicate welcome when title shows profile
- [ ] Stronger locked card visual

### Existing functionality
- [ ] “More Adventures” links: Math Ops, Patterns, Sequencing
- [ ] Fix Rewards card labels

### New (optional)
- [ ] Highlight recommended next module

### Kids experience
- [ ] Unlock sound on dialog; simpler locked text

### Responsiveness
- [ ] Momentum stat ellipsis; learning card layout on narrow width

## Assets

- **Reuse:** bear, backgrounds, emoji
- **New:** No

## Components

- `LearningModuleCard`

## Acceptance criteria

Lock/unlock correct; profile switch works; daily goal accurate; all entry points discoverable; music lifecycle OK.
