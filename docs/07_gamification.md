# Step 7 — Gamification & Rewards

---

## 7.1 Reward Philosophy (from doc)

- No scores, no timers, no failure states
- All rewards tied directly to learning
- The kingdom IS the reward — no external prizes
- Celebrate every correct answer, not just milestones

---

## 7.2 Celebration Types

| Trigger | Celebration |
|---------|-------------|
| Every correct answer | Sparkle Burst (Lottie particle) |
| Topic milestone | Mascot Happy Dance (Rive animation) |
| Kingdom item added | Build-up animation (plant grows, stone appears) |
| First time opening app today | Daily welcome greeting |
| Topic fully mastered | Sticker earned + added to sticker album |

---

## 7.3 Celebration Service

```dart
// lib/core/services/celebration_service.dart

enum CelebrationType { sparkle, mascotDance, kingdomGrow, sticker }

class CelebrationService {
  final _controller = StreamController<CelebrationType>.broadcast();
  Stream<CelebrationType> get stream => _controller.stream;

  void trigger(CelebrationType type) {
    _controller.add(type);
  }
}

// In feature screen, listen to stream and show overlay:
// StreamBuilder → when sparkle received → show CelebrationOverlay
```

---

## 7.4 Session Management

Per doc: 5–10 minute sessions with gentle break reminders.

```dart
// lib/core/utils/session_timer.dart

class SessionTimer {
  final int maxMinutes;       // Set by parent (5/10/15/20)
  final VoidCallback onBreakSuggested;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _elapsedSeconds++;
      if (_elapsedSeconds >= maxMinutes * 60) {
        onBreakSuggested();
        _timer?.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  void pause() => _timer?.cancel();
  void resume() => start();
}
```

When break is triggered, mascot says:  
**"You've done amazing math! Let's rest our brains and come back later."**  
App remains open but shows a gentle rest screen. Does not force close.

---

## 7.5 Sticker Album

```dart
// Stickers earned for topic mastery
// Stored in Hive, viewable anytime, never tradable

@HiveType(typeId: 3)
class StickerAlbum extends HiveObject {
  @HiveField(0)
  final List<String> earnedStickerIds;  // e.g. 'sticker_numbers_1_5'
}

// Sticker IDs:
// 'sticker_numbers_1_5'    → Mastered numbers 1–5
// 'sticker_numbers_6_10'   → Mastered numbers 6–10
// 'sticker_counting_5'     → Counted to 5
// 'sticker_counting_10'    → Counted to 10
// 'sticker_addition'       → Completed addition module
// etc.
```

---

## 7.6 Daily Welcome

On app open, check if this is the child's first session today:

```dart
Future<String> getDailyWelcomeMessage(String childName) async {
  final prefs = await SharedPreferences.getInstance();
  final lastOpenDate = prefs.getString('last_open_date');
  final today = DateTime.now().toIso8601String().substring(0, 10);

  if (lastOpenDate != today) {
    await prefs.setString('last_open_date', today);
    final yesterday = await getYesterdayProgress();
    return "Hi $childName! You learned ${yesterday.newNumbers} new numbers yesterday!";
  }
  return "Welcome back, $childName! Ready to keep building your kingdom?";
}
```

---

## ✅ Checklist

- [ ] `CelebrationService` stream set up
- [ ] Sparkle Burst Lottie overlay working on every correct answer
- [ ] Mascot Happy Dance Rive animation triggers on milestone
- [ ] Kingdom grow animation plays when item added
- [ ] Session timer implemented with parent-configurable limit
- [ ] Break suggestion screen shows (does not force close app)
- [ ] Sticker album UI built, stickers earned on mastery
- [ ] Daily welcome message with yesterday's progress summary
