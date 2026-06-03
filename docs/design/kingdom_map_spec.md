# Kingdom Map Spec

This document defines what the `Kingdom Map` screen should do in `Math Kingdom Builder`, how it should feel for the child, and what we should build first.

Related references:
- `docs/05_kingdom_system.md`
- `docs/design/screen_design_reference.md`
- `lib/data/models/kingdom_state.dart`
- `lib/core/router/app_router.dart`

## 1. Purpose

The kingdom map should be the child's living reward world.

It should do three jobs:
- show learning progress in a visual way
- motivate the child to complete more quests
- create a persistent world that keeps growing over time

It should not feel like a settings page or a plain level list.

## 2. Core User Story

Child flow:
- child finishes a learning activity
- app awards stars and a kingdom reward
- child opens `Kingdom Map`
- a new item or area appears with a small celebration
- child taps around the map and sees playful feedback
- app highlights the next useful quest

Parent value:
- progress is easy to understand visually
- growth feels meaningful even without reading stats

## 3. Map Zones

Use the zone structure already defined in `docs/05_kingdom_system.md`.

### Number Garden
- unlocked by: number recognition
- grows with: flowers, bushes, number trees
- feedback: petals spin, soft chime

### Counting Meadow
- unlocked by: counting activities
- grows with: animals, hay bales, clouds, sunflowers
- feedback: animals wiggle or make sound

### Shape Castle
- unlocked by: tracing
- grows with: walls, towers, flags, windows
- feedback: tower glow, flag wave

### Pattern Pathway
- unlocked by: pattern activities
- grows with: fence pieces, tile patterns, banners
- feedback: tiles pulse in repeating sequence

### Math Bridge
- unlocked by: addition and subtraction
- grows with: bridge stones, rails, sunshine after cloud clearing
- feedback: stones pop in, water sparkle

### Sequence Stairs
- unlocked by: sequencing
- grows with: steps, railings, lanterns
- feedback: lights climb upward step by step

## 4. Must-Have Functionality

### 4.1 Pan and Zoom
- map should support drag to explore
- map should support zoom in and out
- use `InteractiveViewer`
- child should never get lost; include a reset-to-center button

### 4.2 Visible Locked and Unlocked Areas
- locked zones should be covered by clouds, fog, or faded color
- unlocked zones should feel bright and welcoming
- newly unlocked zones should show a short reveal animation

### 4.3 Reward Placement
- each completed module should add something visible to the map
- reward placement should be automatic, not manual
- new rewards should animate when first shown

### 4.4 Tap Interactions
- every important kingdom item should react on tap
- response should be immediate: motion, glow, sound, or sparkle
- interactions should be safe and non-destructive

### 4.5 Persistent Save State
- kingdom growth should always remain saved
- map should look the same after app restart
- use `KingdomState` as the canonical data source

### 4.6 Next Quest Highlight
- one zone or quest entry should be highlighted as the next recommended action
- example: glow ring, bouncing marker, mascot hint

### 4.7 Celebration Moments
- first unlock in a zone
- full zone milestone
- streak-based milestone
- bridge completion or castle upgrade

## 5. Nice-to-Have Functionality

- day/night ambience changes
- seasonal decorations
- hidden surprise tap events
- badge popups for milestones
- mascot walkthrough of new unlocked area
- simple camera fly-to-new-item animation

## 6. Screen Structure

Recommended widget structure:

```dart
Scaffold(
  body: Stack(
    children: [
      KingdomBackground(),
      InteractiveViewer(
        minScale: 0.8,
        maxScale: 2.2,
        child: SizedBox(
          width: mapWidth,
          height: mapHeight,
          child: Stack(
            children: [
              KingdomZoneLayer(),
              KingdomItemsLayer(),
              KingdomLocksLayer(),
              KingdomHighlightLayer(),
            ],
          ),
        ),
      ),
      KingdomTopBar(),
      KingdomBottomPanel(),
      MascotHintAnchor(),
      if (showUnlockCelebration) KingdomUnlockOverlay(),
    ],
  ),
)
```

## 7. Recommended UI Sections

### Top Bar
- back button
- title: `My Kingdom`
- stars count
- optional streak badge

### Main Map Area
- full visual kingdom world
- pannable and zoomable
- animated zones and placed rewards

### Bottom Progress Panel
- current zone progress
- short child-friendly message
- CTA button: `Play Next Quest`

### Mascot Hint
- gives one simple instruction
- example: `Let us grow the bridge today!`

## 8. Data and Progress Rules

Current model already supports:
- `gardenItems`
- `meadowItems`
- `castleItems`
- `bridgeLength`
- `bridgeSunshine`
- `staircaseSteps`
- `patternDecorations`

Recommended reward mapping:

| Learning feature | Kingdom result |
|---|---|
| number recognition | add flowers or trees to garden |
| counting | add animals or meadow items |
| tracing | add castle parts |
| patterns | add pathway decorations |
| addition | increase bridge length |
| subtraction | clear clouds / add sunshine |
| sequencing | increase stair steps |

## 9. Interaction Rules for Kids

- no deleting kingdom items
- no dragging items into wrong places
- no penalties
- no fail state on the map
- every tap should do something delightful
- keep important targets large and spaced out

## 10. Suggested MVP

Build the first version in this order:

1. `KingdomScreen` with static background and `InteractiveViewer`
2. render all existing `KingdomState` zones
3. show locked vs unlocked zone visuals
4. animate newly earned reward items
5. add tap feedback on items
6. add bottom panel with `next quest` CTA

This is enough for a meaningful first release.

## 11. Suggested V2

After MVP is stable:

1. add mascot guided hints
2. add camera focus on new unlock
3. add richer zone-specific sound effects
4. add bigger milestone celebrations
5. add more decorative variety per reward type

## 12. Practical Flutter File Structure

Recommended structure:

```text
lib/features/kingdom/
  kingdom_screen.dart
  kingdom_controller.dart
  kingdom_state.dart
  widgets/
    kingdom_background.dart
    kingdom_top_bar.dart
    kingdom_bottom_panel.dart
    kingdom_zone_layer.dart
    kingdom_item_widget.dart
    kingdom_unlock_overlay.dart
    kingdom_next_quest_badge.dart
```

If we want to keep data centralized, UI state can stay local while persistence continues to use:
- `lib/data/models/kingdom_state.dart`

## 13. Definition of Success

The kingdom map is successful if:
- child immediately understands that learning grows the kingdom
- every completed activity changes something visible
- the screen feels playful even without reading text
- progress stays saved and rewarding across sessions
- the next learning action is clear from the map
