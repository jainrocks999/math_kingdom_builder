# Step 3 — UI Design System

Build the design system first. Every feature screen will use these shared constants and widgets.

---

## 3.1 Color Constants

Create `lib/core/constants/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // From the feature documentation
  static const Color primary     = Color(0xFFFF6B35); // Vibrant Orange
  static const Color secondary   = Color(0xFF4ECDC4); // Teal
  static const Color accent      = Color(0xFFFFE66D); // Sunny Yellow
  static const Color success     = Color(0xFF95E1D3); // Mint Green
  static const Color background  = Color(0xFFFFF9F0); // Warm Cream
  static const Color surface     = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF2D3436); // Dark Charcoal
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray

  // Derived shades for states
  static const Color primaryLight = Color(0xFFFFD4C2);
  static const Color secondaryLight = Color(0xFFB8F0EC);
  static const Color correctFeedback = Color(0xFF95E1D3);
  static const Color incorrectFeedback = Color(0xFFFFB3A7);

  // Kingdom zone colors
  static const Color gardenGreen    = Color(0xFF6BCB77);
  static const Color meadowYellow   = Color(0xFFFFD166);
  static const Color castleGray     = Color(0xFFB8B8D1);
  static const Color bridgeBlue     = Color(0xFF4ECDC4);
}
```

---

## 3.2 Typography

Create `lib/core/constants/app_typography.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // From doc: Hero 48px, H1 32px, H2 24px, Body 16px, Caption 12px

  static const TextStyle hero = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 48,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 32,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 24,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberDisplay = TextStyle(
    fontFamily: 'FredokaOne',
    fontSize: 120,   // Minimum 120px per doc
    color: AppColors.primary,
    height: 1.0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );
}
```

---

## 3.3 Theme Setup

In `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';

class MathKingdomApp extends ConsumerWidget {
  const MathKingdomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Math Kingdom Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.hero,
          headlineLarge: AppTypography.h1,
          headlineMedium: AppTypography.h2,
          bodyMedium: AppTypography.body,
          labelSmall: AppTypography.caption,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            textStyle: AppTypography.button,
            minimumSize: const Size(72, 72), // Min tap target from doc
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      // TODO: add router
      home: const Scaffold(body: Center(child: Text('Math Kingdom'))),
    );
  }
}
```

---

## 3.4 Reusable Widgets

### Number Block Widget
`lib/shared/widgets/number_block.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class NumberBlock extends StatefulWidget {
  final int number;
  final VoidCallback? onTap;
  final bool isSelected;
  final double size;

  const NumberBlock({
    super.key,
    required this.number,
    this.onTap,
    this.isSelected = false,
    this.size = 120,
  });

  @override
  State<NumberBlock> createState() => _NumberBlockState();
}

class _NumberBlockState extends State<NumberBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.secondary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.secondary
                  : AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.number}',
              style: AppTypography.numberDisplay.copyWith(
                fontSize: widget.size * 0.6,
                color: widget.isSelected
                    ? AppColors.surface
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

### Hint Bubble Widget
`lib/shared/widgets/hint_bubble.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class HintBubble extends StatelessWidget {
  final String text;
  final bool isVisible;

  const HintBubble({super.key, required this.text, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

---

### Celebration Overlay
`lib/shared/widgets/celebration_overlay.dart`

```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CelebrationOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    this.isVisible = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          'assets/animations/confetti.json',
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () => onComplete?.call());
          },
        ),
      ),
    );
  }
}
```

---

## 3.5 Tap Target Rule

Per the doc: minimum 72×72px tap, 120×120px drag. Enforce with a global check:

```dart
// In any GestureDetector or InkWell, set minimum size:
SizedBox(
  width: 72,
  height: 72,
  child: yourTappableWidget,
)
```

---

## ✅ Checklist

- [ ] `app_colors.dart` created with all 8 colors from doc
- [ ] `app_typography.dart` created with all 5 text styles
- [ ] Theme applied in `app.dart`
- [ ] `NumberBlock` widget built and tested
- [ ] `HintBubble` widget built
- [ ] `CelebrationOverlay` with Lottie built
- [ ] 72px minimum tap target enforced across all widgets
- [ ] Light smoke test: run app, see warm cream background
