# Step 4 — Core Math Features (Build Order)

Build features in this exact order. Each is a self-contained Flutter screen.  
Prototype with Feature 1 first — if it feels right, the rest follow the same pattern.

---

## Feature Build Template

Every feature follows this structure:

```
features/feature_name/
├── feature_screen.dart       # Main screen UI
├── feature_controller.dart   # Riverpod StateNotifier
├── feature_state.dart        # Immutable state class
└── widgets/                  # Feature-specific widgets
```

---

## Feature 1 — Number Recognition (0–10)

**Start here. This is your prototype.**

### What it does
- Displays large colorful number blocks
- Child taps a number → it bounces + speaks the name
- "Find the number" game: voice says a number, child taps correct one from 3 options

### State model (`number_recognition_state.dart`)

```dart
class NumberRecognitionState {
  final int currentNumber;       // The target number to find
  final List<int> options;       // 3 displayed choices
  final bool isCorrect;
  final bool showHint;
  final Set<int> masteredNumbers; // Persisted to Hive

  const NumberRecognitionState({
    required this.currentNumber,
    required this.options,
    this.isCorrect = false,
    this.showHint = false,
    this.masteredNumbers = const {},
  });
}
```

### Controller logic

```dart
// On correct tap:
// 1. Play correct chime SFX
// 2. Play voice "Great job!"
// 3. Animate number sparkle
// 4. Add to masteredNumbers in Hive
// 5. Trigger CelebrationOverlay
// 6. After 1.5s → load next number

// On wrong tap:
// 1. Wobble animation on tapped block
// 2. Play soft wrong SFX
// 3. Repeat target number voice
// 4. Reshuffle options after 2 wrong attempts
// 5. Show HintBubble after 3 wrong attempts
// NO penalty, NO score change
```

### Progression path
```
Stage 1: Numbers 1–3 only
Stage 2: Numbers 4–6 (unlocked when 1–3 mastered)
Stage 3: Numbers 7–10 (unlocked when 4–6 mastered)
Mastery threshold: 3 correct in a row for each number
```

### Kingdom reward
Mastering number N → adds N decorative items to Number Garden zone.

---

## Feature 2 — Counting Objects (1–10)

### What it does
- Scattered objects on screen (fruits, animals, stars)
- Child taps each object one by one
- Tapped objects grey out, voice counts aloud
- Final: all objects "dance", voice confirms total

### Key implementation detail

```dart
// Use a Set<int> to track tapped object indices
// Prevent double-counting: once index is in tappedSet, ignore re-tap
// Show checkmark overlay on each tapped object

Set<int> tappedIndices = {};

void onObjectTapped(int index) {
  if (tappedIndices.contains(index)) return; // Block double count
  tappedIndices.add(index);
  audioService.playCount(tappedIndices.length); // Speak "one", "two"...
  if (tappedIndices.length == totalObjects) {
    onCountingComplete();
  }
}
```

### Drag variant
Child drags correct quantity of objects into a numbered container.  
Use Flutter's `Draggable` and `DragTarget` widgets.

### Progression path
```
Stage 1: 1–3 objects in a neat row
Stage 2: 4–6 objects scattered randomly
Stage 3: 7–10 objects, mixed types
```

---

## Feature 3 — Number Tracing

### What it does
- Large number displayed full-screen width with dotted path
- Child traces with finger → green sparkle trail follows
- 30px stroke tolerance (per doc)
- Completed number transforms into related shape

### How to implement tracing

```dart
// Use GestureDetector onPanUpdate to capture touch path
// Store touch points as List<Offset>
// Compare against predefined tracing path for the number
// Tolerance check: point within 30px of nearest path point

bool isPointOnPath(Offset point, List<Offset> targetPath) {
  for (final pathPoint in targetPath) {
    if ((point - pathPoint).distance < 30.0) {
      return true;
    }
  }
  return false;
}
```

**Pre-define tracing paths** for each number as a list of Offsets scaled to screen size.

### Progression path (per doc)
```
Phase 1: Straight numbers — 1, 4, 7
Phase 2: Curved numbers — 0, 3, 6, 8, 9
Phase 3: Complex numbers — 2, 5
```

### Kingdom reward
Traced numbers → pathway stones or decorative banners.

---

## Feature 4 — Quantity-to-Numeral Matching

### What it does
- Split screen: numeral on left, scattered objects on right
- Child drags correct number of objects to the numeral zone
- Memory card variant: flip cards showing numerals and dot patterns

### Implementation

```dart
// Use Flutter DragTarget widget for the numeral zone
// Count how many objects have been dropped
// When count matches numeral → trigger success

// Memory card: use a GridView of face-down cards
// onTap → reveal card (flip animation)
// Check if two flipped cards match (numeral == dot count)
```

---

## Feature 5 — Simple Addition (Within 5)

### What it does
- Two groups of objects shown (e.g. 2 red balls + 1 blue ball)
- Child drags all objects into a combined area
- App counts total: "2 and 1 make 3!"
- Number sentence appears: "2 + 1 = 3"

### State

```dart
class AdditionState {
  final int groupA;         // e.g. 2
  final int groupB;         // e.g. 1
  final int answer;         // groupA + groupB
  final List<Object> objectsA;
  final List<Object> objectsB;
  final List<Object> combinedObjects;
  final bool isSolved;
}
```

### Progression path
```
Stage 1: Totals of 2–3 (e.g. 1+1, 1+2, 2+1)
Stage 2: Totals of 4–5
Stage 3: Include +0 and +1 as confidence builders
```

### Kingdom reward
Bridge extends by the sum amount (e.g. answer=3 → 3 new bridge stones).

---

## Feature 6 — Simple Subtraction (Within 5)

### What it does
- Group of objects on screen (e.g. 4 birds)
- Voice: "Tap 2 birds to fly away"
- Tapped objects animate off-screen
- Remaining counted: "4 take away 2 leaves 2!"

### Key difference from addition
Children are **removing** not dragging. Use tap-to-remove, not drag.

```dart
void onObjectTapped(int index) {
  if (removedCount >= targetRemoveCount) return;
  removedCount++;
  animateObjectAway(index);     // Fly/hop off screen
  if (removedCount == targetRemoveCount) {
    onSubtractionComplete();
  }
}
```

### Kingdom reward
Removing clouds reveals sunshine (thematic: subtraction "clears" things).

---

## Feature 7 — Number Sequencing

### What it does
- Number line with one missing slot (e.g. 1, 2, _, 4, 5)
- Child drags correct number block from bottom tray to fill gap
- "Before/after" variant: voice asks "What comes after 6?" → 3 options

### Implementation

```dart
// Generate sequences with 1 missing slot
// Randomize which position is missing (beginning, middle, end)
// Bottom tray shows 3 options including the correct answer + 2 distractors

List<int> generateOptions(int correctAnswer) {
  final distractors = [correctAnswer - 1, correctAnswer + 1]
    ..shuffle();
  return [correctAnswer, distractors[0], distractors[1]]..shuffle();
}
```

### Progression path
```
Stage 1: Forward sequences 1–5
Stage 2: Forward sequences 1–10
Stage 3: Backward sequences 5–1, then 10–1
Stage 4: Missing numbers at ends, not just middle
```

---

## Feature 8 — Basic Patterns (AB, ABB)

### What it does
- Horizontal pattern with one missing item at end
- Child selects from 2–3 options at bottom
- Sound pattern variant (visual + audio)

### Pattern generation

```dart
enum PatternType { AB, ABB, ABC }

List<PatternItem> generatePattern(PatternType type, int length) {
  // AB: red, blue, red, blue, ...
  // ABB: red, blue, blue, red, blue, blue, ...
  // Generate N items, hide last, ask child to complete
}
```

### Progression path
```
Stage 1: AB patterns — colors
Stage 2: AB patterns — shapes
Stage 3: AB patterns — sizes
Stage 4: ABB patterns
Stage 5: ABC patterns (advanced)
```

---

## Shared Feature Rules

Every feature must implement these:

```dart
// 1. No timer pressure — remove any countdown UI
// 2. Unlimited retries — never "game over"
// 3. Hint after 3 wrong — show HintBubble, never penalize
// 4. Audio feedback on every interaction
// 5. Save progress to Hive after each correct answer
// 6. Trigger kingdom reward after feature completion
// 7. Mascot visible in consistent screen position
```

---

## ✅ Checklist

- [ ] Feature 1 (Number Recognition) built and tested on device
- [ ] Audio playing correctly on tap
- [ ] Correct/incorrect feedback animations working
- [ ] Hive saving mastery progress
- [ ] Feature 2 (Counting) — double-count prevention working
- [ ] Feature 3 (Tracing) — 30px tolerance implemented
- [ ] Feature 4 (Matching) — drag and drop working
- [ ] Feature 5 (Addition) — combined area drag working
- [ ] Feature 6 (Subtraction) — tap-to-remove with animation
- [ ] Feature 7 (Sequencing) — gap filling working
- [ ] Feature 8 (Patterns) — pattern generation correct
- [ ] All features: no timers, no penalty states
- [ ] All features: save progress to Hive
