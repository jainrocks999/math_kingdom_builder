# Step 8 — Parental Dashboard

---

## 8.1 Parent Gate (PIN Protection)

Per doc: hold a small non-obvious button for 3 seconds to enter parent area.

```dart
// lib/features/parent_dashboard/parent_gate_widget.dart

class ParentGateButton extends StatefulWidget { ... }

class _ParentGateButtonState extends State<ParentGateButton> {
  Timer? _holdTimer;
  bool _isHolding = false;

  void _onLongPressStart(_) {
    _holdTimer = Timer(const Duration(seconds: 3), () {
      // Navigate to PIN entry screen
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const PinEntryScreen(),
      ));
    });
  }

  void _onLongPressEnd(_) {
    _holdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: Container(
        width: 24, height: 24,          // Small, non-obvious
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
```

---

## 8.2 PIN Entry Screen

```dart
// 4-digit PIN
// Store PIN hash in SharedPreferences (not plain text)
// On first setup: ask parent to set a PIN
// After 3 wrong attempts: show cooldown (30 seconds)

import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPin(String pin) {
  final bytes = utf8.encode(pin);
  return sha256.convert(bytes).toString();
}
```

---

## 8.3 Dashboard Features

### Progress Report
```
No scores — uses labels: "Exploring" | "Practicing" | "Confident"

Thresholds:
- Exploring: < 3 correct in activity
- Practicing: 3–7 correct
- Confident: 8+ correct with consistent accuracy
```

```dart
enum MasteryLevel { exploring, practicing, confident }

MasteryLevel getMasteryLevel(int correctCount) {
  if (correctCount < 3) return MasteryLevel.exploring;
  if (correctCount < 8) return MasteryLevel.practicing;
  return MasteryLevel.confident;
}
```

### Time Management Settings

```dart
@HiveType(typeId: 4)
class ParentSettings extends HiveObject {
  @HiveField(0)
  int dailySessionLimitMinutes;   // 5 / 10 / 15 / 20

  @HiveField(1)
  bool subtractionEnabled;        // Toggle topics on/off

  @HiveField(2)
  bool patternsEnabled;

  @HiveField(3)
  String speechRate;              // 'slow' | 'normal'

  @HiveField(4)
  bool musicEnabled;

  @HiveField(5)
  bool sfxEnabled;

  @HiveField(6)
  bool analyticsOptIn;
}
```

### Multi-Profile Support

Per doc: up to 4 child profiles.

```dart
@HiveType(typeId: 0)
class ChildProfile extends HiveObject {
  @HiveField(0)
  late String id;         // UUID

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String avatarAsset;  // e.g. 'avatar_cat.png'

  @HiveField(3)
  late DateTime createdAt;
}
```

---

## ✅ Checklist

- [ ] Parent gate: hold 3 seconds to access
- [ ] PIN entry: set on first use, hash stored
- [ ] Progress report: Exploring/Practicing/Confident labels
- [ ] Visual chart showing progress per topic
- [ ] Session limit selector (5/10/15/20 min)
- [ ] Topic toggles (subtraction, patterns on/off)
- [ ] Speech rate setting (slow/normal)
- [ ] Music and SFX toggles
- [ ] Multi-profile: up to 4 profiles, separate kingdoms
- [ ] Data & privacy: show what's collected, cloud backup toggle

---
---

# Step 9 — Monetization

---

## 9.1 Model Summary (from doc)

- **Free:** Numbers 1–5, counting to 5, limited kingdom
- **Full unlock: $4.99** one-time purchase
- No subscriptions, no ads, no IAP in child UI

---

## 9.2 RevenueCat Setup (recommended)

RevenueCat handles Apple + Google IAP with one API.

```bash
flutter pub add purchases_flutter
```

```dart
// lib/core/services/purchase_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const _apiKeyIos     = 'YOUR_REVENUECAT_IOS_KEY';
  static const _apiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY';
  static const _fullUnlockId  = 'math_kingdom_full';   // Your product ID

  Future<void> init() async {
    await Purchases.configure(PurchasesConfiguration(
      Platform.isIOS ? _apiKeyIos : _apiKeyAndroid,
    ));
  }

  Future<bool> isFullVersionUnlocked() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey('full_access');
  }

  Future<bool> purchaseFullVersion() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.getPackage('full_unlock');
      if (package == null) return false;
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey('full_access');
  }
}
```

---

## 9.3 Gating Content

```dart
// Check before showing premium features
final isPremium = await purchaseService.isFullVersionUnlocked();

if (!isPremium && featureRequiresPremium) {
  // Show upgrade prompt in PARENT DASHBOARD only
  // Never show purchase UI to the child
  Navigator.pushNamed(context, '/parent/upgrade');
}
```

**Content gating:**

| Free | Premium ($4.99) |
|------|----------------|
| Numbers 1–5 | Numbers 6–10 |
| Counting to 5 | Counting to 10 |
| Number Garden zone only | All 6 kingdom zones |
| — | Addition & Subtraction |
| — | Patterns |
| — | Tracing all numbers |
| — | All future updates |

---

## ✅ Checklist

- [ ] RevenueCat account created, iOS + Android API keys added
- [ ] Product `math_kingdom_full` created in App Store Connect + Google Play
- [ ] `PurchaseService` integrated
- [ ] `isFullVersionUnlocked()` gate on all premium features
- [ ] Purchase prompt shown only in parent dashboard (never to child)
- [ ] Restore purchases button in parent dashboard
- [ ] Test purchase flow with sandbox accounts (Apple + Google)

---
---

# Step 10 — Compliance, Accessibility & App Store Submission

---

## 10.1 COPPA Compliance

Per doc: zero PII from children under 13.

```dart
// What you MUST NOT collect:
// - Child's real name (use nickname or first name only, stored locally)
// - Email address from child
// - Device identifiers linked to child
// - Location data
// - Behavioral advertising data

// What you CAN collect (with parent opt-in):
// - Anonymous usage events (e.g. "activity_completed", "feature_used")
// - No user IDs, no device fingerprints

// Firebase Analytics setup for COPPA:
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
  parentSettings.analyticsOptIn,
);
```

---

## 10.2 GDPR-K Checklist

- [ ] No third-party advertising SDKs in the app
- [ ] No behavioral tracking or remarketing pixels
- [ ] Privacy policy written and hosted (use https://iubenda.com for kids apps)
- [ ] Data deletion: honor requests within 30 days
- [ ] All data stored locally (Hive) or encrypted cloud backup only

---

## 10.3 Accessibility

```dart
// VoiceOver / TalkBack support
// Wrap all interactive elements with Semantics widget

Semantics(
  label: 'Number block showing the number five',
  button: true,
  child: NumberBlock(number: 5, onTap: handleTap),
)

// High contrast mode
// Add a high contrast theme option in parent settings

// Minimum tap targets (already enforced: 72x72px)
// All enforced in design system (Step 3)
```

---

## 10.4 Performance Targets (from doc)

| Metric | Target | How to achieve |
|--------|--------|----------------|
| App launch | < 2 seconds | Lazy load non-critical assets |
| Activity transition | < 300ms | Use Flutter's built-in transitions |
| Audio latency | < 100ms | Pre-load audio files at startup |
| RAM usage | < 150MB | Compress images, use SVG where possible |
| Download size | < 100MB | Use Flutter's `--split-debug-info`, compress audio |

Test on a **mid-range Android device** (e.g. Redmi Note series), not just flagship.

---

## 10.5 App Store Submission

### Apple App Store
1. Set age rating: **4+** under "Apps > Ratings"
2. Select category: **Education**
3. Enable **Made for Kids** flag (Kids Category)
4. Privacy Nutrition Labels: set "Data Not Collected" if COPPA-compliant
5. Review guidelines: https://developer.apple.com/app-store/kids/

### Google Play
1. Set content rating: **Everyone** (ESRB) or **Early Childhood** (Google)
2. Opt into **Designed for Families** program
3. Declare data safety: no data collected / shared
4. https://support.google.com/googleplay/android-developer/answer/9893335

---

## 10.6 Beta Testing (Critical!)

Before submission, test with **real children ages 3–5**.

```
Test script for parents to run:
1. Can the child open the app alone? (no reading required)
2. Do they understand what to tap without being told?
3. Do they get frustrated at any point?
4. Does the mascot voice feel natural?
5. Can they find the home button?
6. Do they want to play again?
```

Iterate on any "no" answers. UI for 3-year-olds is brutal to get right — test early and often.

---

## ✅ Final Launch Checklist

- [ ] COPPA: no PII collected, analytics opt-in only
- [ ] GDPR-K: privacy policy live, data deletion flow tested
- [ ] Accessibility: all elements have Semantics labels
- [ ] High contrast mode available
- [ ] Performance: launch < 2s, audio < 100ms on mid-range device
- [ ] App size < 100MB compressed
- [ ] Beta tested with at least 5 real children ages 3–5
- [ ] Apple: Kids Category, Made for Kids, privacy labels set
- [ ] Google: Designed for Families, content rating, data safety
- [ ] In-app purchase tested in sandbox (both platforms)
- [ ] Restore purchase flow tested
- [ ] Parent dashboard tested: PIN, session limits, progress
- [ ] App works fully offline (airplane mode test)
- [ ] All 8 math features working end-to-end
- [ ] Kingdom saves and restores correctly after app restart
