# Alphabet Kingdom — Product Overview

## Product summary

Alphabet Kingdom is a bilingual early-learning app for ages roughly `3-7`. It teaches English letters and Hindi varnamala through playful lessons, tracing, listening, matching, sequencing, and beginner word-building.

The app should feel:

- Warm
- Safe
- Repeatable
- Rewarding
- Audio-guided
- Parent-friendly

## Core promise

The child should be able to:

- Hear a letter
- See a letter
- Recognize the letter in options
- Trace the letter
- Connect the letter with a word or picture
- Build confidence through repetition

## Why this works well as a sibling app

Math Kingdom Builder already proves the following product mechanics:

- Guided module journey
- Star rewards
- Unlock thresholds
- TTS support
- Parent dashboard
- Home hub + quest cards
- Celebration loops

Alphabet Kingdom can reuse the same product skeleton and replace number content with letter content.

## Learning tracks

### English track

Focus:

- Uppercase letters
- Lowercase letters
- Letter names
- Basic phonics sounds
- Object association
- Very simple word building

Recommended progression:

1. `A-Z` uppercase recognition
2. Lowercase pairing
3. Phonics sound replay
4. Match letter to object
5. Missing letter sequences
6. Build `2-3` letter beginner words

### Hindi track

Focus:

- `स्वर` first
- `व्यंजन` next
- Akshar sound familiarity
- Picture association
- Tracing structure
- Simple `2-letter` and `3-letter` words before matras

Recommended progression:

1. `अ` to `अः`
2. `क` group onward in manageable sections
3. Sound-led recognition
4. Picture matching
5. Varnamala order activities
6. Simple words without matras
7. Matras only in a later phase

## Key design rule

Do not force Hindi to mimic English one-to-one.

- English naturally supports uppercase/lowercase pairing and phonics
- Hindi naturally supports swar/vyanjan grouping and akshar recognition

The UX shell can stay consistent, but the learning content inside each track should respect the language.

## Screen map

| Order | Screen | Route | Main job |
|------|--------|-------|----------|
| 1 | Splash | `/alphabet-splash` | Branding, preload, route decision |
| 2 | Onboarding | `/alphabet-onboarding` | Explain learning value to child/parent |
| 3 | Language Track Selection | `/choose-language-track` | Pick Hindi or English path |
| 4 | Home | `/alphabet-home` | Main hub, daily challenge, quick actions |
| 5 | Start Learning | `/alphabet-start-learning` | Core guided path and module unlocks |
| 6 | Learn Letters | `/learn-letters` | See and hear letters |
| 7 | Trace Letters | `/trace-letters` | Draw letters with guided strokes |
| 8 | Hear and Tap Letter | `/hear-letter` | Audio-driven recognition |
| 9 | Match Letter to Picture | `/match-letter-picture` | Connect letter and meaning |
| 10 | Alphabet Order | `/alphabet-order` | Sequence practice |
| 11 | Word Builder | `/word-builder` | Early reading/spelling |
| 12 | Mini Quiz | `/alphabet-quiz` | Mixed review |
| 13 | Kingdom Map | `/alphabet-kingdom` | Meta progression |
| 14 | Rewards | `/alphabet-rewards` | Stickers, badges, trophies |
| 15 | Parent Dashboard | `/alphabet-parent-dashboard` | Track child progress |
| 16 | Settings | `/alphabet-settings` | Control language, voice, sound |

## Reusable module mapping from Math Kingdom Builder

| Current math module | Alphabet equivalent |
|---------------------|--------------------|
| Learn Numbers | Learn Letters |
| Trace Numbers | Trace Letters |
| Find Correct Number | Hear and Tap Letter |
| Match Numbers | Match Letter to Picture |
| Sequencing | Alphabet Order |
| Mini Quiz | Alphabet Quiz |
| Rewards | Rewards |
| Parent Dashboard | Parent Dashboard |
| Kingdom Map | Kingdom Map |

## Content architecture

### Shared data each letter item should have

- `id`
- `track`: `english` or `hindi`
- `group`: for example `uppercase`, `lowercase`, `swar`, `ka_varg`
- `symbol`
- `display_name`
- `tts_label`
- `phonetic_hint`
- `example_word`
- `example_word_hindi`
- `example_word_english`
- `image_asset`
- `stroke_paths`
- `difficulty_level`
- `is_unlocked_by_default`

### Example English item

```json
{
  "id": "en_a_upper",
  "track": "english",
  "group": "uppercase",
  "symbol": "A",
  "display_name": "A",
  "tts_label": "A",
  "phonetic_hint": "a as in apple",
  "example_word": "Apple",
  "image_asset": "assets/images/alphabet/apple.png",
  "difficulty_level": 1
}
```

### Example Hindi item

```json
{
  "id": "hi_swar_a",
  "track": "hindi",
  "group": "swar",
  "symbol": "अ",
  "display_name": "अ",
  "tts_label": "अ",
  "phonetic_hint": "a",
  "example_word": "अनार",
  "image_asset": "assets/images/alphabet/anar.png",
  "difficulty_level": 1
}
```

## Reward system

Suggested reward logic:

- `Learn Letters`: `2★`
- `Trace Letters`: `3★`
- `Hear and Tap Letter`: `3★`
- `Match Letter to Picture`: `3★`
- `Alphabet Order`: `3★`
- `Word Builder`: `4★`
- `Mini Quiz`: `5★`

Suggested unlock thresholds:

- Learn Letters: `0★`
- Trace Letters: `0★`
- Hear and Tap Letter: `4★`
- Match Letter to Picture: `8★`
- Alphabet Order: `12★`
- Word Builder: `16★`
- Mini Quiz: `22★`

## Audio and TTS rules

- Auto-speak only once on first arrival of a new card
- Always provide manual replay
- Music should be soft and non-distracting
- Correct answer SFX should be cheerful but short
- Wrong answer SFX should be gentle
- TTS locale should switch with track and app language
- English track can optionally use phonics playback separate from letter name playback

## Parent-facing controls needed

- App language
- Child learning track
- Voice language/accent
- Music on/off
- Sound effects on/off
- Speech rate
- Auto-play voice prompts on/off
- Tracing assist level
- Daily goal target

## Progress model

Track at least:

- Current active track
- Letters seen
- Letters mastered
- Trace attempts
- Recognition accuracy
- Match accuracy
- Sequence accuracy
- Word-builder accuracy
- Daily streak
- Session count
- Total stars

## MVP recommendation

If we want a fast first release, launch:

- Splash
- Onboarding
- Language Track Selection
- Home
- Start Learning
- Learn Letters
- Trace Letters
- Hear and Tap Letter
- Match Letter to Picture
- Mini Quiz
- Rewards
- Parent Dashboard
- Settings

Move `Alphabet Order`, `Word Builder`, and richer `Kingdom Map` polish to phase two if needed.
