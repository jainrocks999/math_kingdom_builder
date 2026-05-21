# Math Kingdom Builder Screen Design Reference

This document turns the existing product docs into a design-focused, screen-by-screen reference for the full app journey, from launch to the last parent-side surfaces.

Primary source docs:
- `docs/01_project_setup.md`
- `docs/02_assets_and_resources.md`
- `docs/03_ui_design_system.md`
- `docs/04_core_features.md`
- `docs/05_kingdom_system.md`
- `docs/06_audio_and_voice.md`
- `docs/07_gamification.md`
- `docs/08_parental_monetization_compliance.md`

Note on flow assumptions:
- `Splash`, `Home`, `Sticker Album`, `Break Screen`, and some parent-side screens are partially inferred from the documented folder structure, rewards system, audio lines, and dashboard requirements.
- The learning features, kingdom system, reward behavior, and parent controls are directly documented.

## 1. Global Design Rules

### Visual Language
- Background: warm cream `#FFF9F0`
- Primary action: vibrant orange `#FF6B35`
- Secondary highlight: teal `#4ECDC4`
- Accent: sunny yellow `#FFE66D`
- Success feedback: mint green `#95E1D3`
- Text: dark charcoal `#2D3436`

### Typography
- Hero: Fredoka, 48
- H1: Fredoka, 32
- H2: Fredoka, 24
- Body: Fredoka, 16
- Caption: Fredoka, 12
- Large numerals: minimum 120px visual height

### App Constant Tokens To Use
Use these from `lib/core/constants/app_colors.dart` and `lib/core/constants/app_typography.dart`.

Colors:
- Core: `primary`, `secondary`, `accent`, `success`, `background`, `surface`
- Text: `textPrimary`, `textSecondary`
- States: `correctFeedback`, `incorrectFeedback`, `warning`, `info`, `disabled`
- Surfaces: `surfaceAlt`, `surfaceMuted`, `outline`, `outlineStrong`, `overlayScrim`
- Child screen moods: `splashSky`, `homeHighlight`, `restBackground`
- Parent flow: `parentBackground`, `parentSurface`, `parentAccent`
- Premium: `premiumGold`, `premiumGoldLight`
- Kingdom zones: `gardenGreen`, `meadowYellow`, `castleGray`, `bridgeBlue`, `pathwayPeach`, `stairsLavender`

Typography:
- Landing and major titles: `hero`, `h1`, `h2`, `h3`
- Learning prompts: `featurePrompt`, `numberDisplay`
- General UI text: `body`, `bodyStrong`, `bodySmall`, `caption`, `label`
- Buttons and cards: `button`, `buttonLarge`, `cardTitle`
- Parent area: `parentTitle`, `parentSection`, `parentValue`

### Shared Interaction Rules
- Minimum tap target: `72x72`
- Minimum drag target: `120x120`
- No countdown pressure, no game-over states, unlimited retries
- Hint appears after 3 incorrect attempts
- Mascot stays in a consistent screen position across child-facing screens
- Every correct interaction gets immediate visual and audio reinforcement

### Shared Components
- `NumberBlock`
- `HintBubble`
- `CelebrationOverlay`
- Owl mascot states: `idle`, `talking`, `thinking`, `celebrate`, `wave`

## 2. Screen Order

1. Splash Screen
2. Daily Welcome / Home Screen
3. Number Recognition
4. Counting Objects
5. Number Tracing
6. Quantity-to-Numeral Matching
7. Simple Addition
8. Simple Subtraction
9. Number Sequencing
10. Basic Patterns
11. Celebration Layer
12. Kingdom Screen
13. Sticker Album
14. Break / Rest Screen
15. Parent Gate Trigger
16. PIN Entry / First-Time PIN Setup
17. Parent Dashboard
18. Child Profiles
19. Upgrade / Restore Purchase Screen
20. Privacy / Accessibility / Data Preferences

## 3. Child-Facing Screens

### 3.1 Splash Screen
Purpose:
- Create a calm, friendly first impression and preload visual/audio identity.

Use these app tokens:
- Colors: `splashSky`, `background`, `surface`, `primary`, `accent`
- Typography: `hero` for title, `bodySmall` for loading/status text

Layout:
- Full-screen warm cream or illustrated kingdom sky background
- Centered app logo and owl mascot in `wave` pose
- Soft loading animation or floating sparkle

Design notes:
- Keep this brief and visually clean
- Favor one strong focal point over multiple decorative elements
- Audio should start softly after load, not before

Required resources:
- Logo lockup
- `assets/animations/mascot.riv`
- Optional `sparkle.json`
- Background loop music

### 3.2 Daily Welcome / Home Screen
Purpose:
- Main child landing screen with greeting, current progress, and clear next action.

Use these app tokens:
- Colors: `background`, `homeHighlight`, `surface`, `primary`, `secondary`, `accent`, `outline`
- Typography: `h1` for greeting, `body` for welcome copy, `buttonLarge` for primary CTA, `cardTitle` for entry cards

Layout:
- Top: child greeting and daily welcome message
- Center: owl mascot in `talking` or `idle` pose
- Primary CTA: continue learning
- Secondary CTAs: kingdom, sticker album
- Small hidden parent gate button in a corner

Design notes:
- This should feel like a playful classroom entrance, not a dashboard
- Keep choices limited so a 3 to 5 year old can act immediately
- Home should preview kingdom growth to reinforce motivation

States:
- First open today: greeting with yesterday progress recap
- Returning same day: shorter welcome back message
- Free version: locked previews for premium zones or topics

Required resources:
- Owl greeting states
- Home background illustration
- Progress badge or topic cards
- Hidden parent gate affordance

### 3.3 Number Recognition Screen
Purpose:
- Prototype feature and simplest teaching interaction.

Use these app tokens:
- Colors: `background`, `surface`, `primary`, `secondary`, `correctFeedback`, `incorrectFeedback`
- Typography: `featurePrompt` for target instruction, `numberDisplay` for numerals, `bodyStrong` for hint text

Layout:
- Large target prompt area
- Three oversized `NumberBlock` options
- Mascot anchored consistently
- Hint bubble near prompt area

Design notes:
- Numbers must dominate the composition
- Avoid clutter behind the blocks
- Correct tap should trigger bounce, sparkle, voice, then next round

States:
- Default prompt
- Correct feedback
- Wrong feedback with wobble
- Hint state after repeated misses

Required resources:
- Number art `0-10`
- Sparkle / confetti animation
- Number voice files
- Correct and wrong SFX

### 3.4 Counting Objects Screen
Purpose:
- Teach one-to-one correspondence by tapping or dragging objects.

Use these app tokens:
- Colors: `background`, `surface`, `secondaryLight`, `accent`, `success`, `outline`
- Typography: `featurePrompt` for instruction, `h2` for count total, `body` for helper text

Layout:
- Central playfield with scattered objects
- Clear counting progress area
- Optional target container for drag variant
- Mascot and instruction strip

Design notes:
- Object spacing must prevent accidental double taps
- Each tapped object should visibly change state
- Progress should feel cumulative and satisfying

States:
- Untapped objects
- Tapped / counted objects
- Completed count celebration

Required resources:
- Fruit, star, or animal object packs
- Count voice line set
- Checkmark or dimmed object state

### 3.5 Number Tracing Screen
Purpose:
- Develop numeral formation through guided tracing.

Use these app tokens:
- Colors: `background`, `surfaceMuted`, `primaryLight`, `secondary`, `success`, `outlineStrong`
- Typography: `featurePrompt` for tracing prompt, `h2` for completion label, `bodySmall` for support copy

Layout:
- Full-width giant dotted numeral
- Finger trail layer above the guide path
- Mascot and short instruction
- Completion reveal area

Design notes:
- The numeral path is the hero element
- Keep contrast strong between guide path and traced path
- Completion should transform into a related shape or reward moment

States:
- Idle dotted numeral
- Active tracing with sparkle trail
- Completed numeral transformation

Required resources:
- Tracing paths for each number
- Sparkle trail effect
- Related transformation art

### 3.6 Quantity-to-Numeral Matching Screen
Purpose:
- Connect abstract numerals to concrete groups.

Use these app tokens:
- Colors: `background`, `surface`, `primary`, `secondary`, `accent`, `outline`
- Typography: `numberDisplay` for target numeral, `featurePrompt` for instruction, `body` for support text

Layout:
- Split screen composition
- Left: large numeral target
- Right: object group or draggable pieces
- Bottom tray for memory variant if used

Design notes:
- The left/right contrast should be visually obvious
- Drag destination must be generously sized
- Memory variant needs large, readable cards with simple flips

Required resources:
- Numeral cards
- Dot or object group art
- Card back and flip state design

### 3.7 Simple Addition Screen
Purpose:
- Show combining groups into a larger total.

Use these app tokens:
- Colors: `background`, `surface`, `primary`, `secondary`, `success`, `bridgeBlue`
- Typography: `featurePrompt` for question, `h2` for equation line, `bodyStrong` for spoken math sentence

Layout:
- Left group, plus sign, right group, combined drop zone
- Number sentence reveal near the bottom
- Mascot near the equation area

Design notes:
- Make the combination area feel magnetic and rewarding
- Color-code the two starting groups for clarity
- The answer reveal should feel like a mini discovery

Required resources:
- Object sets in at least two colors
- Equation panel style
- Addition voice lines

### 3.8 Simple Subtraction Screen
Purpose:
- Show removal as a gentle action, not punishment.

Use these app tokens:
- Colors: `background`, `surface`, `accent`, `warning`, `success`, `bridgeBlue`
- Typography: `featurePrompt` for removal prompt, `h2` for remaining total, `body` for feedback copy

Layout:
- One main object group
- Prompt area stating how many to remove
- Remaining count area after removal

Design notes:
- Removed objects should fly, float, or hop away playfully
- The tone should feel like clearing space, not losing items
- Use brighter "remaining" emphasis after completion

Required resources:
- Object sets with remove animations
- Subtraction voice lines
- Sunshine / cloud-clearing reward art

### 3.9 Number Sequencing Screen
Purpose:
- Teach forward and backward order with missing-number gaps.

Use these app tokens:
- Colors: `background`, `surface`, `primary`, `accent`, `stairsLavender`, `outlineStrong`
- Typography: `featurePrompt` for sequence prompt, `numberDisplay` for active tiles, `buttonLarge` for answer tray blocks

Layout:
- Large number line or stepping-stone sequence
- Empty slot visibly highlighted
- Bottom option tray with three large choices

Design notes:
- Treat the sequence like a path the child completes
- Missing slot should be obvious without looking broken
- Good candidate for stair or stepping-stone visuals

Required resources:
- Number line assets or stepping tiles
- Option blocks
- Before / after prompt voice lines

### 3.10 Basic Patterns Screen
Purpose:
- Teach visual repetition and prediction.

Use these app tokens:
- Colors: `background`, `surface`, `primary`, `secondary`, `accent`, `pathwayPeach`, `stairsLavender`
- Typography: `featurePrompt` for pattern instruction, `h3` for sub-labels, `body` for optional audio guidance

Layout:
- Horizontal pattern strip
- Missing final slot
- Two or three answer choices below
- Optional audio pattern control for advanced variant

Design notes:
- Patterns should use bold contrast and large simple forms
- Start with color first, then shape, then size
- Avoid over-decorating the playfield so repetition stays readable

Required resources:
- Color, shape, and size pattern assets
- Pattern answer choices
- Optional audio cue assets

### 3.11 Celebration Layer
Purpose:
- System-wide reward surface for every correct answer and milestone.

Use these app tokens:
- Colors: `overlayScrim`, `accent`, `success`, `premiumGold`
- Typography: `h2` for short praise, `bodyStrong` for reinforcement text

Layout:
- Full-screen non-blocking overlay above the active screen
- Confetti, sparkles, or mascot celebration moment

Design notes:
- Keep frequent celebrations short
- Reserve stronger full-screen effects for milestones and mastery
- Animation should never obscure the main prompt for too long

Variants:
- Sparkle burst for correct answer
- Mascot dance for milestone
- Kingdom growth animation for reward placement
- Sticker earn moment for topic mastery

Required resources:
- `confetti.json`
- `sparkle.json`
- Mascot celebrate state
- Sticker art set

### 3.12 Kingdom Screen
Purpose:
- Persistent visual reward space that makes learning progress tangible.

Use these app tokens:
- Colors: `background`, `gardenGreen`, `meadowYellow`, `castleGray`, `bridgeBlue`, `pathwayPeach`, `stairsLavender`
- Typography: `h1` for screen title, `cardTitle` for zone labels, `bodySmall` for helper copy

Layout:
- Large pannable 2D scene using `InteractiveViewer`
- Distinct zones for garden, meadow, castle, pathway, bridge, stairs
- New items animate into place

Design notes:
- This should feel expansive and collectible, not like a menu
- Each zone needs a distinct silhouette and color identity
- Children should immediately notice what changed after a completed lesson

Interactions:
- Tap flower: spin + chime
- Tap animal: sound
- Tap castle piece: glow

Required resources:
- Full kingdom background
- Zone-specific art packs
- Grow/build animation
- Ambient kingdom SFX

### 3.13 Sticker Album
Purpose:
- Secondary mastery reward surface.

Use these app tokens:
- Colors: `background`, `surface`, `premiumGoldLight`, `accent`, `outline`
- Typography: `h1` for album title, `cardTitle` for category tabs, `caption` for earned state labels

Layout:
- Book, album, or collectible binder presentation
- Large sticker pages with clear empty and earned slots
- Topic grouping by learning area

Design notes:
- This should feel tactile and special
- Use fewer stickers per page with big artwork rather than dense grids
- Reinforce "earned by learning" rather than "completion percentage"

Required resources:
- Sticker set by topic
- Album pages
- Earned/unearned sticker states

### 3.14 Break / Rest Screen
Purpose:
- Gentle session pause when the parent-configured time limit is reached.

Use these app tokens:
- Colors: `restBackground`, `surface`, `secondaryLight`, `textPrimary`, `textSecondary`
- Typography: `h1` for the reassurance headline, `body` for rest message, `button` for return action

Layout:
- Calm full-screen scene
- Owl mascot with reassuring message
- Optional button to return home or stay idle

Design notes:
- The tone must be soft, never abrupt
- Use lower visual energy than active learning screens
- Good place for slower animation and quieter palette accents

Required resources:
- Rest-screen illustration
- Session break voice line
- Mascot calm/talking pose

## 4. Parent-Facing Screens

### 4.1 Parent Gate Trigger
Purpose:
- Hidden child-safe entry point into parent controls.

Use these app tokens:
- Colors: `textSecondary` with low opacity or `outline`
- Typography: none visible in child mode

Layout:
- Small low-emphasis circular target placed away from primary child actions

Design notes:
- Must be discoverable by adults but visually irrelevant to children
- Do not style like a button children want to tap repeatedly

### 4.2 PIN Entry / First-Time PIN Setup
Purpose:
- Secure access to settings and purchases.

Use these app tokens:
- Colors: `parentBackground`, `parentSurface`, `parentAccent`, `outline`, `incorrectFeedback`
- Typography: `parentTitle` for heading, `body` for instructions, `buttonLarge` for keypad actions

Layout:
- Clean keypad or 4-digit input flow
- Friendly explanation copy
- Cooldown feedback after 3 failed attempts

Design notes:
- Distinguish first-time setup from later unlock flow
- Parent UI can be more structured and less playful than child UI

Required resources:
- Numeric keypad
- Setup and error states

### 4.3 Parent Dashboard
Purpose:
- Central management area for progress, limits, audio, and feature access.

Use these app tokens:
- Colors: `parentBackground`, `parentSurface`, `parentAccent`, `surfaceMuted`, `outline`, `success`, `warning`
- Typography: `parentTitle` for page heading, `parentSection` for groups, `parentValue` for status values, `label` for control labels

Layout:
- Top summary: child profile and recent progress
- Progress cards by topic
- Session settings
- Audio settings
- Topic toggles
- Links to upgrade, restore, privacy, and profiles

Design notes:
- This should feel trustworthy and calm
- Use simple charts and status labels: `Exploring`, `Practicing`, `Confident`
- Avoid dark patterns, urgency, or noisy sales language

Required resources:
- Progress chart components
- Settings toggles
- Profile cards

### 4.4 Child Profiles
Purpose:
- Manage up to four child profiles with separate kingdoms and progress.

Use these app tokens:
- Colors: `parentBackground`, `parentSurface`, `primaryLight`, `secondaryLight`, `outline`
- Typography: `parentTitle` for heading, `cardTitle` for profile names, `bodySmall` for metadata

Layout:
- Avatar cards with name and last-played info
- Add profile action
- Edit profile sheet

Design notes:
- Keep this visual but orderly
- Avatars should be recognizable at a glance

Required resources:
- Avatar assets
- Empty-state card
- Profile editing form

### 4.5 Upgrade / Restore Purchase Screen
Purpose:
- Monetization surface kept entirely inside the parent area.

Use these app tokens:
- Colors: `parentBackground`, `parentSurface`, `premiumGold`, `premiumGoldLight`, `parentAccent`, `outline`
- Typography: `parentTitle` for page title, `parentSection` for plan comparison, `buttonLarge` for purchase CTA, `bodySmall` for legal/support copy

Layout:
- Simple comparison between free and full unlock
- One primary purchase CTA
- One restore purchases CTA

Design notes:
- Keep messaging factual and child-safe
- Emphasize one-time purchase, no ads, no subscriptions
- Never style this like a child reward screen

Required resources:
- Free vs premium comparison block
- Purchase confirmation and restore states

### 4.6 Privacy / Accessibility / Data Preferences
Purpose:
- Explain collection choices and accessibility options clearly.

Use these app tokens:
- Colors: `parentBackground`, `parentSurface`, `info`, `success`, `outline`, `textPrimary`, `textSecondary`
- Typography: `parentTitle` for screen title, `parentSection` for grouped settings, `body` for explanations, `label` for toggles and rows

Layout:
- Analytics opt-in
- Cloud backup toggle if implemented
- High contrast mode
- Data/privacy explanation

Design notes:
- This area should prioritize clarity over decoration
- Accessibility settings deserve equal prominence to data settings

## 5. Cross-Screen Resource Checklist

### Core Art
- Owl mascot in 5 states
- Home background
- Kingdom background and 6 zone art sets
- Number graphics `0-10`
- Counting object packs
- Sticker collection art

### Motion
- Mascot Rive file
- Confetti Lottie
- Sparkle Lottie
- Plant/build growth Lottie

### Audio
- Number voice files `0-10`
- Feedback voice lines
- Instruction voice lines
- Addition and subtraction sentence lines
- Correct, wrong, tap, celebration, and build SFX
- 2 to 3 calm looping music tracks

### UI Components
- Large button system
- Number blocks
- Cards, trays, pattern slots, sequence slots
- Parent dashboard charts and toggles

## 6. Recommended Design Delivery Order

1. Splash
2. Home
3. Number Recognition prototype
4. Shared reward layer
5. Remaining 7 learning screens
6. Kingdom screen
7. Sticker album
8. Break screen
9. Parent flow: gate, PIN, dashboard, profiles, upgrade, privacy

## 7. Open Design Decisions

- Confirm whether `Home` opens directly into the next lesson or presents a small activity chooser.
- Confirm whether `Sticker Album` is a dedicated screen or a panel launched from `Home` or `Kingdom`.
- Confirm whether premium locked content appears as disabled cards in child UI or stays fully hidden until parent unlock.
- Confirm whether `Splash` includes a logo-only load or a short mascot greeting beat.
