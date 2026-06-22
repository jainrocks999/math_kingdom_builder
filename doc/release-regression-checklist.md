# Release Regression Checklist

Focused public-release regression pass for `math_kingdom_builder`.

## Automated baseline

Run date: `2026-06-20`

- [x] `flutter analyze`
- [x] `flutter test`

Current automated coverage note:
- Existing widget test only verifies app boot reaches Splash loading state, so manual functional coverage is still required before public release.

## Manual test cases

### RR-01 Cold start routing
- Goal: verify first launch and repeat launch routing.
- Steps:
  1. Fresh install or clear app data.
  2. Launch app.
  3. Wait for Splash to route.
  4. Complete or skip onboarding.
  5. Kill app fully.
  6. Launch again.
- Expected:
  - First launch reaches Onboarding.
  - After completion/skip, next cold start reaches Home.

### RR-02 Splash fallback and skip
- Goal: verify splash does not hang.
- Steps:
  1. Launch app on a slower emulator/device.
  2. Observe video/fallback.
  3. On repeat launch, wait for skip availability and tap skip.
- Expected:
  - No black stuck screen.
  - Fallback logo appears if video is delayed.
  - Repeat launch can skip after the intended delay.

### RR-03 Home music lifecycle
- Goal: verify Home music starts once and never doubles.
- Steps:
  1. Open Home from Splash/Onboarding.
  2. Navigate to Start Learning.
  3. Open one activity and return back to Home.
  4. Repeat a few times.
- Expected:
  - Home music starts on Home only.
  - Activity/Home music never overlaps.
  - No audible double playback after repeated navigation.

### RR-04 Home daily challenge
- Goal: verify live daily challenge behavior.
- Steps:
  1. Open Home.
  2. Note daily challenge title and reward state.
  3. Open the daily challenge module.
  4. Complete it once.
  5. Return Home.
  6. Re-open Home again.
- Expected:
  - Banner routes to a real module.
  - Completion state updates.
  - Bonus stars are granted once only.
  - Re-entry does not double-claim.

### RR-05 Start Learning lock flow
- Goal: verify unlock gates and profile flow.
- Steps:
  1. Open Start Learning.
  2. Switch child profile.
  3. Check locked modules before enough stars.
  4. Earn stars and reopen.
- Expected:
  - Profile switch updates visible state.
  - Locked modules show correct dialogs.
  - Newly unlocked modules become playable once requirements are met.

### RR-06 Guided learning path
- Goal: verify the main child learning journey end-to-end.
- Steps:
  1. Open Start Learning.
  2. Complete Learn Numbers.
  3. Complete Trace Numbers.
  4. Complete Count Objects.
  5. Continue to Find Number, Matching, then Mini Quiz if unlocked.
- Expected:
  - Every next screen opens correctly.
  - Completion rewards/stars increment.
  - Next navigation buttons work.

### RR-07 Learn Numbers
- Goal: verify TTS and celebration flow.
- Steps:
  1. Open Learn Numbers.
  2. Swipe several numbers.
  3. Tap speaker replay.
  4. Finish the module.
- Expected:
  - TTS speaks current number.
  - Speaker replay works.
  - Completion celebration appears and exits correctly.

### RR-08 Trace Numbers ghost hint
- Goal: verify new tracing support.
- Steps:
  1. Open Trace Numbers.
  2. Fail the same stroke twice.
  3. Trace again with hint visible.
- Expected:
  - Ghost hint appears after 2 failed attempts.
  - Hint resets on successful stroke or lesson reset.

### RR-09 Count Objects tap-to-count
- Goal: verify counting support and answer flow.
- Steps:
  1. Open Count Objects.
  2. Tap objects one by one.
  3. Use Reset.
  4. Try wrong answer, then correct answer.
- Expected:
  - Count badges appear in tap order.
  - Reset clears state.
  - Wrong feedback unlocks retry.
  - Correct answer advances normally.

### RR-10 Find Correct Number
- Goal: verify audio prompt and answer correctness.
- Steps:
  1. Open Find Correct Number.
  2. Let prompt play.
  3. Use speaker replay.
  4. Try wrong and correct answers.
- Expected:
  - Prompt audio is understandable.
  - Replay works.
  - No layout cut-off on smaller phones.

### RR-11 Match Numbers
- Goal: verify matching rounds on small layouts.
- Steps:
  1. Open Match Numbers on a narrow device/emulator.
  2. Play several rounds.
  3. Trigger wrong and correct choices.
- Expected:
  - Object preview and number layout remain readable.
  - Correct matching advances.
  - Wrong feedback does not freeze the round.

### RR-12 Mini Quiz resume + completion
- Goal: verify long-flow persistence.
- Steps:
  1. Open Mini Quiz.
  2. Play 3-5 rounds.
  3. Leave the screen.
  4. Return to Mini Quiz.
  5. Finish the quiz.
- Expected:
  - Quiz resumes at last unfinished step.
  - Drag, tap, missing number, compare, and write modes all work.
  - Final celebration card appears and next navigation works.

### RR-13 Rewards collect flow
- Goal: verify reward persistence and feedback.
- Steps:
  1. Open Rewards.
  2. Collect one unlocked reward.
  3. Return to Home or Start Learning.
  4. Reopen Rewards.
  5. Open Sticker Card on a sticker.
- Expected:
  - Reward stays claimed.
  - Collect animation plays once.
  - Sticker detail sheet opens and TTS works.

### RR-14 Math operations and quest routes
- Goal: verify side-module entry points.
- Steps:
  1. Open Addition, Subtraction, Multiplication, Division from their routes.
  2. Complete at least one round in each.
  3. Open Patterns and Sequencing.
- Expected:
  - No blocked routes.
  - Completion records stars/progress.
  - Prompt and answer interactions still work.

### RR-15 Kingdom map
- Goal: verify map usability and ambient music.
- Steps:
  1. Open Kingdom.
  2. Pan/zoom, use Find Me, use Reset.
  3. Tap zones.
  4. Open a playable zone and return.
- Expected:
  - Ambient music plays softly on Kingdom only.
  - Find Me focuses the recommended zone.
  - Locked zones do not open wrong routes.
  - Returning from quest resumes Kingdom music.

### RR-16 Parent dashboard
- Goal: verify parent-only controls and reporting.
- Steps:
  1. Open Parent Dashboard.
  2. Enter/set PIN.
  3. Toggle Music and SFX.
  4. Change speech rate.
  5. Switch child profile.
- Expected:
  - PIN flow works with correct messaging.
  - Audio settings persist.
  - Profile switch updates report content.

### RR-17 Offline cold start
- Goal: verify app still opens without network.
- Steps:
  1. Put device in airplane mode.
  2. Kill app fully.
  3. Launch app.
  4. Navigate Home, Start Learning, Rewards, Kingdom.
- Expected:
  - App still cold-starts.
  - Core local-content screens remain usable.

### RR-18 Text scale 1.3x
- Goal: verify accessibility sizing.
- Steps:
  1. Set device text scale to about `1.3x`.
  2. Revisit Home, Start Learning, Count Objects, Mini Quiz, Rewards.
- Expected:
  - No major text overflow or clipped CTA text.
  - Core controls remain tappable.

### RR-19 Small-phone pass
- Goal: verify compact layouts.
- Steps:
  1. Test on about `320dp` width Android device/emulator.
  2. Open Home, Start Learning, Count Objects, Find Number, Rewards.
- Expected:
  - No bottom overflows.
  - No cut-off card content.
  - Primary actions remain visible without broken layout.

### RR-20 Repeated navigation leak smoke test
- Goal: verify no obvious lifecycle/audio leaks.
- Steps:
  1. Navigate Home → Start Learning → one activity → back.
  2. Repeat roughly 10 times.
  3. Watch debug console.
- Expected:
  - No repeated audio stacking.
  - No obvious ticker/dispose warnings.
  - No crash or progressive slowdown.

## Release recommendation

- Ready for internal beta / QA now.
- Public release recommended after the manual cases above are executed and only real bugs are fixed.
