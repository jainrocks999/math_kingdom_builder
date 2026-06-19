# Recommended Screen Development Order

Safe sequence for screen-by-screen implementation.

| Order | Screen | Why this stage | Dependencies | New features now? |
|-------|--------|----------------|--------------|-------------------|
| 1 | **Global fixes** | Blocks repeat onboarding, audio confusion | None | No — fixes only |
| 2 | **Onboarding** | P0 skip bug | Global | No |
| 3 | **Home** | Central navigation hub | Onboarding | Live daily banner — yes |
| 4 | **Start Learning** | Learning entry + locks | Home | Recommended module — yes |
| 5 | **Learn Numbers** | First guided module | Start Learning | Speaker button — yes |
| 6 | **Trace Numbers** | Second guided module | Learn Numbers | Eraser — optional |
| 7 | **Count Objects** | Core counting | Trace | Standardize feedback |
| 8 | **Find Correct Number** | First gated module (4★) | Count + stars | Speaker button |
| 9 | **Match Numbers** | Gated (8★) | Find Number | Shared themes |
| 10 | **Mini Quiz** | Path capstone (14★) | Match | Mode labels |
| 11 | **Rewards** | Meaning for stars | Quiz progress | Collect animation |
| 12 | **Math Operations hub + 4 ops** | Home quest path | Core flow stable | Progress badges |
| 13 | **Sequencing + Patterns** | Home quest modules | Math widgets | Tap fallback |
| 14 | **Kingdom Map** | Meta progression | Progress service | Mascot — later |
| 15 | **Parent Dashboard** | Settings when stable | Audio service | Sound toggles |
| 16 | **Splash** | Polish last | All flows | Skip — optional |

## Postpone

- Rive mascot integration
- Confetti Lottie (unless asset added)
- Hindi / regional TTS
- Export progress from parent dashboard
- Unique sticker PNG artwork

## Parallel work caution

Do not refactor **Trace path validation** and **Kingdom zone geometry** in the same sprint as global audio changes — high regression risk.
