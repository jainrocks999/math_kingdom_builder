# Step 2 — Assets & Resources

Where to get every visual, audio, and animation asset the app needs.

---

## 2.1 Graphics & Illustrations

### Mascot (Owl Character)
The app doc specifies a friendly owl mascot with animations. You need:
- Idle pose
- Happy dance (milestone celebration)
- Talking/narrating pose
- Thinking pose (hint)
- Waving (greeting)

| Option | Where | Cost | Notes |
|--------|-------|------|-------|
| Custom illustrator | https://www.fiverr.com → search "kids app mascot owl" | $80–$300 | Best quality, unique |
| Stock owl vectors | https://www.freepik.com/search?query=cute+owl+kids | Free tier | Good base to customize |
| AI generation | Adobe Firefly / Midjourney | Paid | For concept only, not final |

> **Recommendation:** Hire a Fiverr illustrator for the mascot. It's the face of the app — worth the investment.  
> Deliver assets in **SVG** for scalability, **PNG** at 3x for Flutter.

---

### Kingdom Zones
You need art for 6 kingdom zones: Number Garden, Counting Meadow, Shape Castle, Pattern Pathway, Math Bridge, Sequence Stairs.

| Resource | Link | What to get |
|----------|------|-------------|
| Kenney.nl (free) | https://www.kenney.nl/assets/nature-kit | Trees, flowers, animals |
| Kenney.nl (free) | https://www.kenney.nl/assets/castle-kit | Castle walls, towers |
| CraftPix.net | https://craftpix.net/categorys/2d-game-backgrounds/ | Background scenes |
| OpenGameArt.org | https://opengameart.org/art-search?keys=kids | Community CC0 assets |

---

### UI Elements
Buttons, cards, number blocks, progress indicators.

| Resource | Link | What to get |
|----------|------|-------------|
| Kenney.nl UI Pack | https://www.kenney.nl/assets/ui-pack | Buttons, panels, icons |
| Freepik vectors | https://www.freepik.com/vectors/kids-ui | Kid-themed UI elements |
| Custom | Design in Figma using the doc's color system | Fully branded |

> **Tip:** Use the doc's exact colors — Primary `#FF6B35`, Secondary `#4ECDC4`, Background `#FFF9F0`. Ask any freelancer to match these.

---

### Number Graphics
Large, colorful number typography (min 120px height per doc).

```
Fonts: Fredoka One (Google Fonts — free)
       https://fonts.google.com/specimen/Fredoka+One

Each number needs:
- Default state (colorful, large)
- Highlighted/selected state (bounces, sparkles)
- Mastered state (glowing, permanent)
```

---

## 2.2 Fonts

Both fonts are free on Google Fonts. Download and add to Flutter:

```
assets/fonts/FredokaOne-Regular.ttf       → Display / hero numbers
assets/fonts/Nunito-Regular.ttf           → Body text
assets/fonts/Nunito-SemiBold.ttf          → Labels, hints
assets/fonts/Nunito-Bold.ttf              → Buttons, CTAs
```

Add to `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: FredokaOne
      fonts:
        - asset: assets/fonts/FredokaOne-Regular.ttf

    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Regular.ttf
          weight: 400
        - asset: assets/fonts/Nunito-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
```

---

## 2.3 Audio Assets

### Voice Narration
All instructions must be pre-recorded (not generated at runtime) for consistency.

| Option | Link | Cost | Quality |
|--------|------|------|---------|
| ElevenLabs | https://elevenlabs.io | ~$5/mo | Excellent warm TTS |
| Real voice actor | https://www.fiverr.com → "children's app voice" | $50–$200 | Best — human warmth |
| Narakeet | https://www.narakeet.com | Low cost | Good, fast |
| Google WaveNet | https://cloud.google.com/text-to-speech | Free tier | Decent |

**Lines to record (minimum set):**
```
Numbers 0–10 spoken clearly: "Zero", "One", "Two" ... "Ten"
Correct feedback: "Great job!", "Amazing!", "You did it!", "Wonderful!"
Hints: "Try again!", "Almost there!", "Keep counting!"
Counting: "One, two, three..." (sequential)
Addition: "Two and one make three!"
Session end: "You've done amazing math! Let's rest our brains."
Greeting: "Welcome back! Ready to build your kingdom?"
```

**File format:** `.mp3` or `.ogg` | 44.1kHz | mono | ~50–100 files total

---

### Sound Effects

| Sound | Where to find |
|-------|--------------|
| Correct answer chime | https://freesound.org/search/?q=success+chime+kids |
| Wrong answer (soft) | https://freesound.org/search/?q=gentle+wrong |
| Confetti / celebration | https://freesound.org/search/?q=celebration+pop |
| Button tap | https://freesound.org/search/?q=bubble+pop+soft |
| Kingdom build | https://freesound.org/search/?q=magic+sparkle |
| Number spoken tap | https://freesound.org/search/?q=soft+chime |
| Page transition | https://freesound.org/search/?q=whoosh+soft |

Also check: https://www.zapsplat.com (register free for high quality packs)

---

### Background Music

| Resource | Link | Notes |
|----------|------|-------|
| Bensound | https://www.bensound.com/royalty-free-music/children | Soft, looping kids tracks |
| AudioJungle | https://audiojungle.net/search/children+game+loop | Premium, $10–30/track |
| Free Music Archive | https://freemusicarchive.org | Search "children" filter |

> **Tip:** Get 2–3 different looping tracks for variety. Keep BPM around 80–100 (calm, not hyperactive).

---

## 2.4 Animations

### Mascot Animations (Rive)
Build the owl mascot as a Rive file with state machine:

| State | Trigger |
|-------|---------|
| `idle` | Default when no activity |
| `talking` | While voice plays |
| `celebrate` | On milestone achievement |
| `thinking` | When hint is shown |
| `wave` | App open / greeting |

- Tool: https://rive.app (free tier supports this)
- Rive community templates: https://rive.app/community (search "owl" or "bird")
- Output: `assets/animations/mascot.riv`

### Celebration Animations (Lottie)
Download free from https://lottiefiles.com/free-animations

| Animation | Search term |
|-----------|-------------|
| Confetti burst | "confetti celebration" |
| Star sparkle | "stars sparkle kids" |
| Kingdom growth | "plant growing" |
| Fireworks | "fireworks simple" |

- Output: `assets/animations/confetti.json`, `sparkle.json`, etc.

---

## 2.5 Asset Folder Structure

```
assets/
├── fonts/
│   ├── FredokaOne-Regular.ttf
│   ├── Nunito-Regular.ttf
│   ├── Nunito-SemiBold.ttf
│   └── Nunito-Bold.ttf
│
├── images/
│   ├── mascot/
│   │   ├── owl_idle.png
│   │   └── owl_celebrate.png
│   ├── numbers/
│   │   ├── num_0.svg ... num_10.svg
│   ├── kingdom/
│   │   ├── garden/
│   │   ├── castle/
│   │   ├── bridge/
│   │   └── ...
│   ├── objects/           # Fruits, animals, stars for counting
│   └── ui/                # Buttons, panels, backgrounds
│
├── audio/
│   ├── voice/
│   │   ├── numbers/       # zero.mp3, one.mp3 ... ten.mp3
│   │   ├── feedback/      # great_job.mp3, amazing.mp3 ...
│   │   └── instructions/  # per-activity prompts
│   ├── sfx/
│   │   ├── correct.mp3
│   │   ├── wrong_soft.mp3
│   │   ├── confetti.mp3
│   │   └── ...
│   └── music/
│       ├── background_1.mp3
│       └── background_2.mp3
│
└── animations/
    ├── mascot.riv          # Rive file with state machine
    ├── confetti.json       # Lottie
    ├── sparkle.json        # Lottie
    └── plant_grow.json     # Lottie
```

Add to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/mascot/
    - assets/images/numbers/
    - assets/images/kingdom/
    - assets/images/objects/
    - assets/images/ui/
    - assets/audio/voice/numbers/
    - assets/audio/voice/feedback/
    - assets/audio/voice/instructions/
    - assets/audio/sfx/
    - assets/audio/music/
    - assets/animations/
```

---

## ✅ Checklist

- [ ] Mascot character designed and delivered in SVG + PNG
- [ ] Kingdom zone art collected/purchased
- [ ] UI elements designed or sourced
- [ ] Fredoka One + Nunito fonts downloaded
- [ ] Voice lines recorded (~50 files minimum)
- [ ] SFX collected (10–15 files)
- [ ] Background music tracks (2–3 loops)
- [ ] Mascot Rive animation built with state machine
- [ ] Lottie celebration animations downloaded
- [ ] All assets added to pubspec.yaml
