# Math Kingdom Builder — Complete Build Plan

> **Target:** Flutter app for nursery kids (ages 3–5) | iOS, Android, Web  
> **Stack:** Flutter 3.x · Riverpod · Hive · Rive · Lottie · Firebase  
> **Timeline:** ~9 months to Phase 2 launch

---

## 📁 File Index

| File | Description |
|------|-------------|
| `01_project_setup.md` | Project structure, Flutter init, packages, folder layout |
| `02_assets_and_resources.md` | Where to get graphics, fonts, audio, animations |
| `03_ui_design_system.md` | Colors, typography, components, design tokens |
| `04_core_features.md` | Step-by-step build for all 8 math features |
| `05_kingdom_system.md` | Kingdom zones, building mechanics, persistence |
| `06_audio_and_voice.md` | Voice narration, SFX, music integration |
| `07_gamification.md` | Rewards, celebrations, session management |
| `08_parental_dashboard.md` | PIN gate, progress reports, settings |
| `09_monetization.md` | Freemium model, IAP setup, RevenueCat |
| `10_compliance_and_testing.md` | COPPA, GDPR-K, accessibility, app store submission |
| `09_home_screen_guide.md` | Home screen layout, asset mapping, and where images should come from |
| `10_static_content_sqlite_assets_guide.md` | When to use SQLite vs JSON/Hive, plus how to structure asset-driven home content |
| `11_release_setup.md` | Android signing, keystore wiring, and iOS signing handoff |

---

## 🗓️ High-Level Timeline

```
Month 1–2   →  Setup + Design System + Number Recognition prototype
Month 3     →  Counting, Tracing, Matching features
Month 4     →  Addition, Subtraction, Sequencing, Patterns
Month 5     →  Kingdom system + full gamification
Month 6     →  Audio polish + Parental dashboard
Month 7     →  IAP + compliance + accessibility audit
Month 8     →  Beta testing (real kids!) + bug fixes
Month 9     →  App store submission + launch
```

---

## ✅ Build Order (recommended)

1. Flutter project scaffold + state management
2. Design system (colors, fonts, reusable widgets)
3. Number Recognition (simplest feature — use as prototype)
4. Mascot with placeholder Lottie animation
5. Audio system (voice + SFX)
6. Remaining 7 math features
7. Kingdom building system
8. Parental dashboard + PIN gate
9. IAP (monetization)
10. Compliance, accessibility, testing
11. App store submission
