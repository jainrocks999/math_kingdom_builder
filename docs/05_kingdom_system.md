# Step 5 — Kingdom Building System

The kingdom is the child's persistent creative space. Every math achievement adds something visible and permanent.

---

## 5.1 Kingdom Zones (from doc)

| Zone | Unlocked by | Items added |
|------|-------------|-------------|
| Number Garden | Number Recognition | Flowers, trees (one per mastered number) |
| Counting Meadow | Counting | Animals (more counting = more animals) |
| Shape Castle | Tracing | Walls, towers (each traced shape adds a part) |
| Pattern Pathway | Patterns | Fences, borders showing the created pattern |
| Math Bridge | Addition/Subtraction | Bridge stones (addition adds, subtraction clears clouds) |
| Sequence Stairs | Sequencing | Staircase steps (one per completed sequence) |

---

## 5.2 Kingdom State Model

```dart
// lib/data/models/kingdom_state.dart

@HiveType(typeId: 1)
class KingdomState extends HiveObject {
  @HiveField(0)
  final List<KingdomItem> gardenItems;

  @HiveField(1)
  final List<KingdomItem> meadowItems;

  @HiveField(2)
  final List<KingdomItem> castleItems;

  @HiveField(3)
  final int bridgeLength;        // Addition progress

  @HiveField(4)
  final bool bridgeSunshine;     // Subtraction cleared clouds

  @HiveField(5)
  final int staircaseSteps;      // Sequencing progress

  @HiveField(6)
  final List<String> patternDecorations; // Pattern colors/shapes
}

@HiveType(typeId: 2)
class KingdomItem {
  @HiveField(0)
  final String assetPath;    // e.g. 'assets/images/kingdom/garden/flower_5.png'

  @HiveField(1)
  final double x;            // Position in kingdom (0.0 to 1.0 relative)

  @HiveField(2)
  final double y;

  @HiveField(3)
  final DateTime earnedAt;
}
```

---

## 5.3 Adding Items to the Kingdom

After any feature completion, call `KingdomService.addReward()`:

```dart
class KingdomService {
  Future<void> addReward(KingdomRewardType type, dynamic data) async {
    final box = Hive.box<KingdomState>('kingdoms');
    final state = box.get('current') ?? KingdomState.empty();

    switch (type) {
      case KingdomRewardType.numberMastered:
        final number = data as int;
        // Add `number` flower items to garden
        final newItems = List.generate(number, (i) => KingdomItem(
          assetPath: 'assets/images/kingdom/garden/flower_${i % 5}.png',
          x: _randomPosition(),
          y: _randomPosition(),
          earnedAt: DateTime.now(),
        ));
        await box.put('current', state.copyWith(
          gardenItems: [...state.gardenItems, ...newItems],
        ));
        break;

      case KingdomRewardType.additionSolved:
        final sum = data as int;
        await box.put('current', state.copyWith(
          bridgeLength: state.bridgeLength + sum,
        ));
        break;

      // ... handle other reward types
    }
  }
}
```

---

## 5.4 Kingdom Screen UI

The kingdom is a scrollable/pannable 2D scene. Use `InteractiveViewer` in Flutter:

```dart
InteractiveViewer(
  boundaryMargin: const EdgeInsets.all(50),
  minScale: 0.5,
  maxScale: 2.0,
  child: Stack(
    children: [
      // Background scene image
      Image.asset('assets/images/kingdom/background.png', fit: BoxFit.cover),

      // Render each zone
      KingdomGardenZone(items: kingdomState.gardenItems),
      KingdomMeadowZone(items: kingdomState.meadowItems),
      KingdomCastleZone(items: kingdomState.castleItems),
      KingdomBridgeZone(length: kingdomState.bridgeLength),
      KingdomStairsZone(steps: kingdomState.staircaseSteps),
    ],
  ),
)
```

---

## 5.5 Item Placement Animation

When a new item is added, play a "grow from seed" animation:

```dart
// Use Lottie for the grow animation
// Then replace with static image once complete

AnimatedSwitcher(
  duration: const Duration(milliseconds: 800),
  child: isNew
      ? Lottie.asset('assets/animations/plant_grow.json', repeat: false)
      : Image.asset(item.assetPath),
)
```

---

## 5.6 Item Interactions

Children can tap any kingdom item for fun feedback:
- Tap a flower → it spins and chimes
- Tap an animal → it plays its sound
- Tap a castle tower → it lights up

Items CANNOT be deleted or moved (per doc — kingdom always reflects progress).

---

## ✅ Checklist

- [ ] `KingdomState` Hive model created
- [ ] `KingdomService.addReward()` implemented for all 6 zones
- [ ] Kingdom screen renders with `InteractiveViewer`
- [ ] New item placement animation working (grow from seed)
- [ ] Tap interactions on items working (sounds + visual)
- [ ] Kingdom data persists across app restarts (Hive)
- [ ] Mascot suggests adding reward after each activity completion
