# New Feature Suggestions

Practical additions only. Marked as required vs optional and whether existing resources suffice.

| Feature | Why useful for kids | Screen | Existing resources? | External assets? | Priority | Complexity | When |
|---------|---------------------|--------|---------------------|------------------|----------|------------|------|
| Speaker replay button | Re-hear instructions | All learning | Yes (TTS) | No | P1 | Low | Now |
| Star burst on correct | Immediate reward feel | Learning screens | Yes (icons, colors) | No | P1 | Low | Now |
| Live daily challenge | Motivates return visits | Home | Yes (progress service) | No | P2 | Medium | Now |
| Sound settings | Parent controls noise | Parent | Yes (AudioService flags) | No | P2 | Low | Now |
| Retry messaging | Reduces frustration | Quiz, Find, Count | Yes | No | P2 | Low | Now |
| Kingdom shortcut after lesson | Connects learning to map | Post-celebration | Yes | No | P3 | Medium | Later |
| Confetti Lottie | Extra delight | Celebrations | Partial (widget exists) | Yes — Lottie JSON | P3 | Low | Later |
| Rive mascot on Home | More life on hub | Home | Yes (`mascot.riv`) | No | P4 | Medium | Later |
| Hindi number words | Localization | Learn Numbers | TTS locales | No | P4 | High | Future |
| Daily crown badge | Streak reward visual | Start Learning | Emoji + colors | No | P3 | Low | Later |

## Not recommended (out of scope)

- Social features, leaderboards, or online multiplayer
- Heavy gamification (coins shop, IAP) — commented Firebase/IAP not active
- Full curriculum CMS or server-driven lessons
- Advanced analytics dashboards for parents

## Good examples aligned with app scope

- Daily learning goal (already partially implemented — surface on Home)
- Stars after completing activity (implemented — improve visibility)
- Sticker unlock system (implemented in Rewards — improve “Collect!” UX)
- Voice instruction button (TTS replay)
- Simple progress on Start Learning (implemented — polish)
- Parent sound/language settings (sound first; language later)
- Retry wrong answers (soft feedback + hints)
- Level-based flow (star gates on Start Learning)
- Celebration after lesson (`CelebrationBear` + music)
- Offline progress save (already via SharedPreferences + Hive)
