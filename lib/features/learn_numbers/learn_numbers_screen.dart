import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/tts_voice_helper.dart';

// ─── Enums & data ─────────────────────────────────────────────────────────────

enum _BearMood { idle, talking, wow, clapping }

class _CountObjectTheme {
  const _CountObjectTheme({
    required this.emoji,
    required this.assetPath,
    required this.singular,
    required this.plural,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    this.imageScale = 0.9,
  });

  final String emoji;
  final String assetPath;
  final String singular;
  final String plural;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final double imageScale;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LearnNumbersScreen extends StatefulWidget {
  const LearnNumbersScreen({super.key});

  @override
  State<LearnNumbersScreen> createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends State<LearnNumbersScreen>
    with TickerProviderStateMixin {
  // ── Data ──────────────────────────────────────────────────────────────────
  static const List<String> _numberWords = [
    'Zero',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
    'Twenty',
    'Twenty one',
    'Twenty two',
    'Twenty three',
    'Twenty four',
    'Twenty five',
    'Twenty six',
    'Twenty seven',
    'Twenty eight',
    'Twenty nine',
    'Thirty',
  ];

  static const List<_CountObjectTheme> _countObjects = [
    _CountObjectTheme(
      emoji: '🍎',
      assetPath: 'assets/images/contingobjects/apple.jpeg',
      singular: 'apple',
      plural: 'apples',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
    ),
    _CountObjectTheme(
      emoji: '🍬',
      assetPath: 'assets/images/contingobjects/candy.jpeg',
      singular: 'candy',
      plural: 'candies',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
    _CountObjectTheme(
      emoji: '🚗',
      assetPath: 'assets/images/contingobjects/car.jpeg',
      singular: 'car',
      plural: 'cars',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      imageScale: 0.74,
    ),
    _CountObjectTheme(
      emoji: '🎈',
      assetPath: 'assets/images/contingobjects/ballun.jpeg',
      singular: 'balloon',
      plural: 'balloons',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
    ),
    _CountObjectTheme(
      emoji: '⭐',
      assetPath: 'assets/images/contingobjects/start.jpeg',
      singular: 'star',
      plural: 'stars',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
  ];

  // ── State ─────────────────────────────────────────────────────────────────
  int _currentIndex = 0;
  bool _isSpeaking = false;
  int? _highlightedObjectIndex;
  _BearMood _bearMood = _BearMood.idle;
  int _bearVisualToken = 0;
  int _cardTransitionDirection = 1;
  bool _isCardTransitionExiting = false;
  int _cardTransitionToken = 0;

  // ── Controllers ───────────────────────────────────────────────────────────
  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final ScrollController _selectorController;

  // Number pop — elastic scale when digit changes
  late final AnimationController _numberPopController;

  // Objects grid reveal
  late final AnimationController _objectsRevealController;

  // Background ambient drift
  late final AnimationController _backgroundController;

  // Bear gentle float
  late final AnimationController _bearFloatController;

  // Bear "wow" bounce (one-shot)
  late final AnimationController _bearBounceController;

  // Lightweight content transition for the top card
  late final AnimationController _cardTransitionController;

  // ── Derived ───────────────────────────────────────────────────────────────
  _CountObjectTheme get _theme =>
      _countObjects[_currentIndex % _countObjects.length];

  String get _bearAssetPath {
    switch (_bearMood) {
      case _BearMood.talking:
      case _BearMood.wow:
        return 'assets/images/bear/waw.png';
      case _BearMood.clapping:
        return 'assets/images/bear/clapping.png';
      case _BearMood.idle:
        return 'assets/images/bear/idle.png';
    }
  }

  String get _bearMessage {
    switch (_bearMood) {
      case _BearMood.talking:
        return 'Listen!';
      case _BearMood.wow:
        return 'Wow!';
      case _BearMood.clapping:
        return 'Yay!';
      case _BearMood.idle:
        return 'Tap';
    }
  }

  void _setBearMood(_BearMood mood) {
    if (_bearMood != mood) {
      _bearMood = mood;
      _bearVisualToken++;
      return;
    }
    _bearMood = mood;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _selectorController = ScrollController();

    _numberPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      value: 1,
    );
    _objectsRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _bearFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _bearBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _cardTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1,
    );

    _ttsReady = _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollSelectorTo(_currentIndex, animated: false);
      _speakCurrentNumber();
    });
  }

  Future<void> _configureTts() async {
    await _applyIndianEnglishVoice();
    await _tts.setPitch(1.04);
    await _tts.setSpeechRate(0.34);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(_onSpeechDone);
    _tts.setCancelHandler(_onSpeechDone);
    _tts.setErrorHandler((_) => _onSpeechDone());
  }

  Future<void> _applyIndianEnglishVoice() async {
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'hi-IN'],
    );
  }

  void _onSpeechDone() {
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _setBearMood(_BearMood.clapping);
    });
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || _isSpeaking) return;
      setState(() => _setBearMood(_BearMood.idle));
    });
  }

  Future<void> _speakPhrase(
    String text, {
    _BearMood mood = _BearMood.talking,
  }) async {
    if (!mounted) return;
    await _ttsReady;
    if (!mounted) return;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _isSpeaking = true;
      _setBearMood(mood);
    });
    await _tts.speak(text);
  }

  Future<void> _speakCurrentNumber() async =>
      _speakPhrase(_numberWords[_currentIndex]);

  Future<void> _selectNumber(int index, {bool speak = true}) async {
    if (index < 0 || index >= _numberWords.length) return;

    if (_currentIndex == index) {
      HapticFeedback.mediumImpact();
      if (speak) await _speakCurrentNumber();
      return;
    }

    HapticFeedback.selectionClick();
    final previousIndex = _currentIndex;
    final transitionToken = ++_cardTransitionToken;
    final transitionDirection = index > previousIndex ? 1 : -1;
    _cardTransitionController.stop();
    setState(() {
      _cardTransitionDirection = transitionDirection;
      _isCardTransitionExiting = true;
      _highlightedObjectIndex = null;
      _setBearMood(_BearMood.wow);
    });

    await _cardTransitionController.animateBack(
      0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeInCubic,
    );
    if (!mounted || transitionToken != _cardTransitionToken) return;

    setState(() {
      _isCardTransitionExiting = false;
      _currentIndex = index;
      _highlightedObjectIndex = null;
      _setBearMood(_BearMood.wow);
    });

    _numberPopController.forward(from: 0);
    _objectsRevealController.forward(from: 0);
    _bearBounceController.forward(from: 0);
    _scrollSelectorTo(index);
    _cardTransitionController.forward(from: 0);

    if (speak) await _speakCurrentNumber();
  }

  Future<void> _handleObjectTap(int index) async {
    if (_currentIndex == 0) return;
    final count = index + 1;
    final label = count == 1 ? _theme.singular : _theme.plural;
    HapticFeedback.lightImpact();
    setState(() {
      _highlightedObjectIndex = index;
      _setBearMood(_BearMood.wow);
    });
    await _speakPhrase('$count $label');
  }

  void _scrollSelectorTo(int index, {bool animated = true}) {
    if (!_selectorController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollSelectorTo(index, animated: animated);
      });
      return;
    }
    const itemWidth = 42.0 + 8.0;
    final viewport = _selectorController.position.viewportDimension;
    final target = (index * itemWidth) - ((viewport - 42.0) / 2);
    final clamped =
        target.clamp(0.0, _selectorController.position.maxScrollExtent);
    if (animated) {
      _selectorController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _selectorController.jumpTo(clamped);
    }
  }

  @override
  void dispose() {
    _selectorController.dispose();
    _numberPopController.dispose();
    _objectsRevealController.dispose();
    _backgroundController.dispose();
    _bearFloatController.dispose();
    _bearBounceController.dispose();
    _cardTransitionController.dispose();
    _tts.stop();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backround.png',
              fit: BoxFit.cover,
            ),
          ),
          // Animated tinted overlay that follows theme colour
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _theme.color.withValues(alpha: 0.08),
                  const Color(0xFFB8E4FF).withValues(alpha: 0.22),
                  AppColors.background.withValues(alpha: 0.55),
                  _theme.softColor.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          // Floating ambient bubbles
          _AmbientBubbles(
            controller: _backgroundController,
            theme: _theme,
          ),
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 800;
                final isVeryCompact = constraints.maxHeight < 710;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    isVeryCompact ? 8 : 12,
                    14,
                    isVeryCompact ? 10 : 14,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(isCompact: isCompact),
                      SizedBox(height: isVeryCompact ? 8 : 12),
                      // Main number card
                      _buildMainCard(
                        isCompact: isCompact,
                        isVeryCompact: isVeryCompact,
                      ),
                      SizedBox(height: isVeryCompact ? 8 : 10),
                      // Count card — fills remaining space
                      Expanded(
                        child: _buildCountCard(
                          isCompact: isCompact,
                          isVeryCompact: isVeryCompact,
                        ),
                      ),
                      SizedBox(height: isVeryCompact ? 8 : 10),
                      _buildSelectorBar(isCompact: isCompact),
                      SizedBox(height: isVeryCompact ? 6 : 8),
                      _buildNavRow(isCompact: isCompact),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader({required bool isCompact}) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
          isCompact: isCompact,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learn Numbers 🔢',
                style: AppTypography.hero.copyWith(
                  fontSize: isCompact ? 20 : 24,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Tap, hear, and count with bear buddy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF5A6B7A),
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _CircleButton(
          icon: _isSpeaking
              ? Icons.volume_up_rounded
              : Icons.record_voice_over_rounded,
          onTap: _speakCurrentNumber,
          color: _theme.color,
          isActive: _isSpeaking,
          isCompact: isCompact,
        ),
      ],
    );
  }

  // ── Main card ─────────────────────────────────────────────────────────────
  Widget _buildMainCard({
    required bool isCompact,
    required bool isVeryCompact,
  }) {
    return GestureDetector(
      onTap: _speakCurrentNumber,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(isVeryCompact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isVeryCompact ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _theme.color.withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _theme.shadowColor.withValues(alpha: 0.55),
                    offset: const Offset(0, 5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: _theme.color.withValues(alpha: 0.14),
                    offset: const Offset(0, 14),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _cardTransitionController,
                child: _buildMainCardContent(
                  isCompact: isCompact,
                  isVeryCompact: isVeryCompact,
                ),
                builder: (context, child) {
                  final t = Curves.easeOutCubic.transform(
                    _cardTransitionController.value,
                  );
                  final direction = _isCardTransitionExiting
                      ? -_cardTransitionDirection
                      : _cardTransitionDirection;
                  final dx = lerpDouble(26.0 * direction, 0, t)!;
                  final dy = lerpDouble(6.0, 0, t)!;
                  final scale = lerpDouble(0.985, 1.0, t)!;
                  final opacity = lerpDouble(0.18, 1.0, t)!;

                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCardContent({
    required bool isCompact,
    required bool isVeryCompact,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: isVeryCompact ? 7 : 8,
            child: _buildNumberInfoCard(
              isVeryCompact: isVeryCompact,
              isCompact: isCompact,
            ),
          ),
          SizedBox(width: isVeryCompact ? 8 : 12),
          Expanded(
            flex: isVeryCompact ? 5 : 4,
            child: _BearBuddy(
              assetPath: _bearAssetPath,
              message: _bearMessage,
              visualToken: _bearVisualToken,
              color: _theme.color,
              softColor: _theme.softColor,
              floatController: _bearFloatController,
              bounceController: _bearBounceController,
              isCompact: isCompact,
              isVeryCompact: isVeryCompact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInfo({
    required bool isVeryCompact,
    required bool isCompact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress pill
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _theme.softColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _theme.color.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _theme.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Card ${_currentIndex + 1} of ${_numberWords.length}',
                style: AppTypography.bodySmall.copyWith(
                  color: _theme.color,
                  fontSize: isVeryCompact ? 9 : 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isVeryCompact ? 6 : 10),

        // Big animated number
        AnimatedBuilder(
          animation: _numberPopController,
          builder: (context, child) {
            final t = Curves.easeOutCubic.transform(_numberPopController.value);
            final scale = lerpDouble(0.88, 1.0, t)!;
            final opacity = lerpDouble(0.40, 1.0, t)!;
            return Align(
              alignment: Alignment.center,
              child: Transform.scale(
                alignment: Alignment.center,
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: child,
                ),
              ),
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              '$_currentIndex',
              key: ValueKey(_currentIndex),
              style: AppTypography.numberDisplay.copyWith(
                fontSize: isVeryCompact
                    ? 62
                    : isCompact
                        ? 72
                        : 84,
                color: _theme.color,
                height: 0.9,
                shadows: [
                  Shadow(
                    color: _theme.shadowColor.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isVeryCompact ? 2 : 4),

        // Word label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: Align(
            alignment: Alignment.center,
            child: Text(
              _numberWords[_currentIndex],
              key: ValueKey(_numberWords[_currentIndex]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.h1.copyWith(
                fontSize: isVeryCompact
                    ? 20
                    : isCompact
                        ? 24
                        : 28,
                color: const Color(0xFF1E1060),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
        SizedBox(height: isVeryCompact ? 4 : 6),

        // Status hint
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Row(
            key: ValueKey(_isSpeaking),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSpeaking) ...[
                _PulsingDot(color: _theme.color),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  _isSpeaking ? 'Bear is speaking...' : 'Tap card to hear it',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: _isSpeaking ? _theme.color : const Color(0xFF8E9BAD),
                    fontSize: isVeryCompact ? 10 : 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInfoCard({
    required bool isVeryCompact,
    required bool isCompact,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          isVeryCompact ? 12 : 16,
          isVeryCompact ? 12 : 16,
          isVeryCompact ? 10 : 14,
          isVeryCompact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              _theme.softColor.withValues(alpha: 0.72),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _theme.color.withValues(alpha: 0.14),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -8,
              child: Container(
                width: isVeryCompact ? 52 : 64,
                height: isVeryCompact ? 52 : 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -14,
              child: Container(
                width: isVeryCompact ? 44 : 56,
                height: isVeryCompact ? 44 : 56,
                decoration: BoxDecoration(
                  color: _theme.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            _buildNumberInfo(
              isVeryCompact: isVeryCompact,
              isCompact: isCompact,
            ),
          ],
        ),
      ),
    );
  }

  // ── Count card ────────────────────────────────────────────────────────────
  Widget _buildCountCard({
    required bool isCompact,
    required bool isVeryCompact,
  }) {
    final count = _currentIndex;
    final label = count == 0
        ? 'Zero means none!'
        : '$count ${count == 1 ? _theme.singular : _theme.plural}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(isVeryCompact ? 12 : 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _theme.color.withValues(alpha: 0.32),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _theme.shadowColor.withValues(alpha: 0.50),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
              BoxShadow(
                color: _theme.color.withValues(alpha: 0.10),
                offset: const Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header row
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      'Let\'s Count ${_theme.emoji}',
                      key: ValueKey(_theme.emoji),
                      style: AppTypography.h2.copyWith(
                        color: const Color(0xFF2D1B69),
                        fontWeight: FontWeight.w800,
                        fontSize: isVeryCompact ? 15 : 17,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      key: ValueKey(label),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _theme.softColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _theme.color.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.bodySmall.copyWith(
                          color: _theme.color,
                          fontSize: isVeryCompact ? 9 : 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isVeryCompact ? 8 : 10),
              // Objects area
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(anim);
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: count == 0
                      ? _ZeroStateCard(
                          key: const ValueKey('zero'),
                          theme: _theme,
                          isCompact: isVeryCompact,
                        )
                      : _ObjectsGrid(
                          key: ValueKey('grid-$count-${_theme.emoji}'),
                          count: count,
                          theme: _theme,
                          animation: _objectsRevealController,
                          isCompact: isCompact,
                          isVeryCompact: isVeryCompact,
                          highlightedIndex: _highlightedObjectIndex,
                          onObjectTap: _handleObjectTap,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selector bar ──────────────────────────────────────────────────────────
  Widget _buildSelectorBar({required bool isCompact}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding:
              EdgeInsets.fromLTRB(0, isCompact ? 8 : 10, 0, isCompact ? 8 : 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _theme.color.withValues(alpha: 0.22),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Pick a Number',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF6F7A89),
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: isCompact ? 6 : 8),
              SizedBox(
                height: isCompact ? 36 : 40,
                child: ListView.separated(
                  controller: _selectorController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _numberWords.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () => _selectNumber(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: isCompact ? 36 : 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _theme.color
                              : _theme.softColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _theme.shadowColor.withValues(alpha: 0.5)
                                : _theme.color.withValues(alpha: 0.22),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _theme.shadowColor
                                        .withValues(alpha: 0.4),
                                    offset: const Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: _theme.color.withValues(alpha: 0.25),
                                    offset: const Offset(0, 6),
                                    blurRadius: 12,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: AppTypography.bodyStrong.copyWith(
                              fontSize: isCompact ? 13 : 15,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2D1B69),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Nav row ───────────────────────────────────────────────────────────────
  Widget _buildNavRow({required bool isCompact}) {
    return Row(
      children: [
        Expanded(
          child: _NavButton(
            label: 'Previous',
            icon: Icons.chevron_left_rounded,
            color: _theme.softColor,
            textColor: _theme.color,
            borderColor: _theme.color.withValues(alpha: 0.30),
            shadowColor: _theme.shadowColor.withValues(alpha: 0.30),
            enabled: _currentIndex > 0,
            isCompact: isCompact,
            iconLeading: true,
            onTap: () => _selectNumber(_currentIndex - 1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _NavButton(
            label: 'Next',
            icon: Icons.chevron_right_rounded,
            color: _theme.color,
            textColor: Colors.white,
            borderColor: _theme.shadowColor.withValues(alpha: 0.60),
            shadowColor: _theme.shadowColor.withValues(alpha: 0.55),
            enabled: _currentIndex < _numberWords.length - 1,
            isCompact: isCompact,
            iconLeading: false,
            onTap: () => _selectNumber(_currentIndex + 1),
          ),
        ),
      ],
    );
  }
}

// ─── Bear buddy ───────────────────────────────────────────────────────────────

class _BearBuddy extends StatelessWidget {
  const _BearBuddy({
    required this.assetPath,
    required this.message,
    required this.visualToken,
    required this.color,
    required this.softColor,
    required this.floatController,
    required this.bounceController,
    required this.isCompact,
    required this.isVeryCompact,
  });

  final String assetPath;
  final String message;
  final int visualToken;
  final Color color;
  final Color softColor;
  final AnimationController floatController;
  final AnimationController bounceController;
  final bool isCompact;
  final bool isVeryCompact;

  @override
  Widget build(BuildContext context) {
    final imgH = isVeryCompact
        ? 58.0
        : isCompact
            ? 68.0
            : 78.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isVeryCompact ? 8 : 10,
        isVeryCompact ? 10 : 12,
        isVeryCompact ? 8 : 10,
        isVeryCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.82),
            softColor.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isVeryCompact ? 7 : 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Bear Buddy',
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontSize: isVeryCompact ? 8 : 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: isVeryCompact ? 6 : 8),
          AnimatedBuilder(
            animation: Listenable.merge([floatController, bounceController]),
            builder: (context, child) {
              // Gentle float
              final floatY = math.sin(floatController.value * math.pi) * 4;
              final bounceScale = bounceController.isAnimating
                  ? lerpDouble(
                      1.0,
                      1.08,
                      Curves.easeOutCubic.transform(bounceController.value),
                    )!
                  : 1.0;
              return Transform.translate(
                offset: Offset(0, -floatY),
                child: Transform.scale(scale: bounceScale, child: child),
              );
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) {
                final scale = Tween<double>(
                  begin: 0.94,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                );
                return ScaleTransition(
                  scale: scale,
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: Image.asset(
                assetPath,
                key: ValueKey('bear-image-$visualToken-$assetPath'),
                height: imgH,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: isVeryCompact ? 6 : 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Container(
              key: ValueKey('bear-message-$visualToken-$message'),
              padding: EdgeInsets.symmetric(
                horizontal: isVeryCompact ? 5 : 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: color.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontSize: isVeryCompact ? 8.5 : 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient bubbles ──────────────────────────────────────────────────────────

class _AmbientBubbles extends StatelessWidget {
  const _AmbientBubbles({
    required this.controller,
    required this.theme,
  });

  final AnimationController controller;
  final _CountObjectTheme theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = controller.value;
        return Stack(
          children: List.generate(10, (i) {
            final wave = math.sin((v * math.pi * 2) + i * 0.7) * 16;
            final rise = math.cos((v * math.pi * 2) + i * 0.5) * 12;
            final size = 18.0 + (i % 4) * 14.0;
            return Positioned(
              left: 16 + i * 38.0 + wave,
              top: 80 + i * 72.0 + rise,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: theme.softColor.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Objects grid ─────────────────────────────────────────────────────────────

class _ObjectsGrid extends StatelessWidget {
  const _ObjectsGrid({
    super.key,
    required this.count,
    required this.theme,
    required this.animation,
    required this.isCompact,
    required this.isVeryCompact,
    required this.highlightedIndex,
    required this.onObjectTap,
  });

  final int count;
  final _CountObjectTheme theme;
  final Animation<double> animation;
  final bool isCompact;
  final bool isVeryCompact;
  final int? highlightedIndex;
  final ValueChanged<int> onObjectTap;

  @override
  Widget build(BuildContext context) {
    final display = math.min(count, 30);
    final spacing = isVeryCompact ? 6.0 : 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final columns = maxW >= 420
            ? 6
            : maxW >= 340
                ? 5
                : 4;
        final rows = (display / columns).ceil().clamp(1, 8);
        final tileW = (maxW - ((columns - 1) * spacing)) / columns;
        final tileH =
            (maxH - ((rows - 1) * spacing) - (count > 30 ? 18 : 0)) / rows;
        final tileSize = math.max(
          isVeryCompact ? 20.0 : 22.0,
          math.min(
            isCompact ? 38.0 : 46.0,
            math.min(tileW, tileH),
          ),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(display, (index) {
                    final start = (index / math.max(display, 1)) * 0.55;
                    final end = math.min(start + 0.35, 1.0);
                    final itemAnim = CurvedAnimation(
                      parent: animation,
                      curve: Interval(start, end, curve: Curves.easeOutBack),
                    );
                    final isHighlighted = highlightedIndex == index;

                    return FadeTransition(
                      opacity: itemAnim,
                      child: ScaleTransition(
                        scale: itemAnim,
                        child: GestureDetector(
                          onTap: () => onObjectTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            width: tileSize,
                            height: tileSize,
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? theme.color.withValues(alpha: 0.18)
                                  : theme.softColor.withValues(alpha: 0.80),
                              borderRadius:
                                  BorderRadius.circular(tileSize * 0.28),
                              border: Border.all(
                                color: isHighlighted
                                    ? theme.color.withValues(alpha: 0.70)
                                    : theme.color.withValues(alpha: 0.16),
                                width: isHighlighted ? 2 : 1,
                              ),
                              boxShadow: isHighlighted
                                  ? [
                                      BoxShadow(
                                        color: theme.shadowColor
                                            .withValues(alpha: 0.35),
                                        offset: const Offset(0, 3),
                                        blurRadius: 0,
                                      ),
                                      BoxShadow(
                                        color:
                                            theme.color.withValues(alpha: 0.18),
                                        offset: const Offset(0, 6),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Transform.scale(
                                scale: theme.imageScale,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(tileSize * 0.18),
                                  child: Image.asset(
                                    theme.assetPath,
                                    width: tileSize * 0.76,
                                    height: tileSize * 0.76,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            if (count > 30) ...[
              const SizedBox(height: 4),
              Text(
                '+ ${count - 30} more',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF8E9BAD),
                  fontSize: isVeryCompact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─── Zero state ───────────────────────────────────────────────────────────────

class _ZeroStateCard extends StatelessWidget {
  const _ZeroStateCard({
    super.key,
    required this.theme,
    required this.isCompact,
  });

  final _CountObjectTheme theme;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isCompact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: theme.softColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/bear/idle.png',
            height: isCompact ? 46 : 58,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isCompact ? 8 : 10),
          Text(
            'Zero Means None!',
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(
              color: const Color(0xFF1A1060),
              fontWeight: FontWeight.w800,
              fontSize: isCompact ? 17 : 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No ${theme.plural} to count yet.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF7A849A),
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav button ───────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
    required this.enabled,
    required this.isCompact,
    required this.iconLeading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final bool enabled;
  final bool isCompact;
  final bool iconLeading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.38,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: isCompact ? 44 : 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.20),
                      offset: const Offset(0, 8),
                      blurRadius: 14,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconLeading) ...[
                Icon(icon, color: textColor, size: 22),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: AppTypography.button.copyWith(
                  color: textColor,
                  fontSize: isCompact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!iconLeading) ...[
                const SizedBox(width: 3),
                Icon(icon, color: textColor, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Circle button ────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
    this.isActive = false,
    this.isCompact = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool isActive;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCompact ? 40 : 44,
        height: isCompact ? 40 : 44,
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.80),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.38)
                : color.withValues(alpha: 0.18),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isCompact ? 21 : 23,
          color: isActive ? color : const Color(0xFF5A6B7A),
        ),
      ),
    );
  }
}

// ─── Pulsing dot (speaking indicator) ────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
