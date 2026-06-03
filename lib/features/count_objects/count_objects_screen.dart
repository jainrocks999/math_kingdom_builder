import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/tts_voice_helper.dart';
import '../../shared/widgets/celebration_bear.dart';

class _CountTheme {
  const _CountTheme({
    required this.assetPath,
    required this.singular,
    required this.plural,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
  });

  final String assetPath;
  final String singular;
  final String plural;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
}

class _RoundConfig {
  const _RoundConfig({
    required this.count,
    required this.themeIndex,
  });

  final int count;
  final int themeIndex;
}

class CountObjectsScreen extends StatefulWidget {
  const CountObjectsScreen({super.key});

  @override
  State<CountObjectsScreen> createState() => _CountObjectsScreenState();
}

class _CountObjectsScreenState extends State<CountObjectsScreen>
    with TickerProviderStateMixin, RouteAware {
  static const int _totalRounds = 10;

  static const List<_CountTheme> _themes = [
    _CountTheme(
      assetPath: 'assets/images/contingobjects/apple.jpeg',
      singular: 'apple',
      plural: 'apples',
      emoji: '🍎',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
    ),
    _CountTheme(
      assetPath: 'assets/images/contingobjects/candy.jpeg',
      singular: 'candy',
      plural: 'candies',
      emoji: '🍬',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
    _CountTheme(
      assetPath: 'assets/images/contingobjects/car.jpeg',
      singular: 'car',
      plural: 'cars',
      emoji: '🚗',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
    ),
    _CountTheme(
      assetPath: 'assets/images/contingobjects/ballun.jpeg',
      singular: 'balloon',
      plural: 'balloons',
      emoji: '🎈',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
    ),
    _CountTheme(
      assetPath: 'assets/images/contingobjects/start.jpeg',
      singular: 'star',
      plural: 'stars',
      emoji: '⭐',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
  ];

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _cardPopController;
  late final AnimationController _celebrationController;
  late List<_RoundConfig> _rounds;

  final math.Random _random = math.Random();

  int _musicRequestToken = 0;
  int _roundIndex = 0;
  int? _selectedAnswer;
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;
  List<int> _options = const [];

  _RoundConfig get _currentRound => _rounds[_roundIndex];
  _CountTheme get _theme => _themes[_currentRound.themeIndex];
  int get _correctCount => _currentRound.count;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _cardPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1,
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ttsReady = _configureTts();
    _rounds = _buildRoundPlan();
    _prepareRound();
    _playScreenMusic(delayed: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakPrompt();
    });
  }

  Future<void> _configureTts() async {
    await TtsVoiceHelper.configureSharedAudio(_tts);
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'en-GB'],
    );
    await _tts.setPitch(1.04);
    await _tts.setSpeechRate(0.38);
    await _tts.setVolume(1.0);
  }

  void _playScreenMusic({bool delayed = false}) {
    final requestToken = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted || requestToken != _musicRequestToken) return;
        AppAudioService.instance.playStartCountingMusic();
      },
    );
  }

  void _stopScreenMusic() {
    _musicRequestToken++;
    AppAudioService.instance.stopBackgroundMusic();
  }

  void _prepareRound() {
    final correct = _correctCount;
    final options = <int>{correct};
    while (options.length < 4) {
      final candidate = (_random.nextInt(_totalRounds) + 1);
      options.add(candidate);
    }
    _options = options.toList()..shuffle();
    _selectedAnswer = null;
    _answerLocked = false;
    _roundSolved = false;
  }

  List<_RoundConfig> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => index + 1)
      ..shuffle(_random);
    final rounds = <_RoundConfig>[];
    final themeUsage = List<int>.filled(_themes.length, 0);
    var lastThemeIndex = -1;

    for (final count in counts) {
      final themeIndex = _pickThemeIndex(
        themeUsage: themeUsage,
        lastThemeIndex: lastThemeIndex,
      );
      themeUsage[themeIndex]++;
      lastThemeIndex = themeIndex;
      rounds.add(_RoundConfig(count: count, themeIndex: themeIndex));
    }

    return rounds;
  }

  int _pickThemeIndex({
    required List<int> themeUsage,
    required int lastThemeIndex,
  }) {
    final candidates = List<int>.generate(_themes.length, (index) => index)
      ..sort((a, b) => themeUsage[a].compareTo(themeUsage[b]));
    final leastUsedCount = themeUsage[candidates.first];
    final filtered = candidates
        .where(
          (index) =>
              themeUsage[index] <= leastUsedCount + 1 &&
              (_themes.length == 1 || index != lastThemeIndex),
        )
        .toList();

    final pool = filtered.isNotEmpty ? filtered : candidates;
    return pool[_random.nextInt(pool.length)];
  }

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    final label = _correctCount == 1 ? _theme.singular : _theme.plural;
    await _tts.speak('Count the $label. How many do you see?');
  }

  Future<void> _speakCorrectAnswer() async {
    await _ttsReady;
    await _tts.stop();
    final label = _correctCount == 1 ? _theme.singular : _theme.plural;
    await _tts.speak('Great job! $_correctCount $label.');
  }

  Future<void> _speakWrongAnswer() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('Try again. Count carefully.');
  }

  Future<void> _handleAnswerTap(int answer) async {
    if (_answerLocked || _showCelebration) return;

    setState(() {
      _selectedAnswer = answer;
      _answerLocked = true;
    });

    final isCorrect = answer == _correctCount;
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _cardPopController.forward(from: 0);
      if (_roundIndex == _totalRounds - 1) {
        if (!mounted) return;
        setState(() {
          _roundSolved = true;
        });
        await _ttsReady;
        await _tts.stop();
        Future<void>.delayed(const Duration(milliseconds: 850), () {
          _showFinalCelebration();
        });
        return;
      }
      await _speakCorrectAnswer();
      if (!mounted) return;
      setState(() {
        _roundSolved = true;
      });
    } else {
      HapticFeedback.heavyImpact();
      await _speakWrongAnswer();
      if (!mounted) return;
      setState(() {
        _answerLocked = false;
        _selectedAnswer = null;
      });
    }
  }

  void _goToNextRound() {
    if (!_roundSolved || _showCelebration) return;
    if (_roundIndex >= _totalRounds - 1) {
      _showFinalCelebration();
      return;
    }
    setState(() {
      _roundIndex++;
      _prepareRound();
    });
    _speakPrompt();
  }

  void _restartGame() {
    AppAudioService.instance.stopCelebrationMusic();
    _playScreenMusic(delayed: true);
    setState(() {
      _rounds = _buildRoundPlan();
      _roundIndex = 0;
      _showCelebration = false;
      _prepareRound();
    });
    _speakPrompt();
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration || !_roundSolved) return;
    if (_roundIndex != _totalRounds - 1) return;
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.countObjects,
    );
    AppAudioService.instance.playCelebrationMusic();
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward(from: 0);
  }

  void _goBack() {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    context.pop();
  }

  void _prepareNextLearningNavigation() {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    setState(() {
      _showCelebration = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.unsubscribe(this);
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    _playScreenMusic(delayed: true);
  }

  @override
  void didPopNext() {
    if (!_showCelebration) {
      _playScreenMusic(delayed: true);
    }
  }

  @override
  void didPushNext() {
    _stopScreenMusic();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _musicRequestToken++;
    AppAudioService.instance.stopCelebrationMusic();
    _tts.stop();
    _cardPopController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + 1) / _totalRounds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backround.png',
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  _theme.softColor.withValues(alpha: 0.35),
                  AppColors.background.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                children: [
                  _buildTopBar(progress),
                  const SizedBox(height: 16),
                  _buildPromptCard(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildObjectsCard()),
                  const SizedBox(height: 16),
                  _buildAnswerGrid(),
                  const SizedBox(height: 14),
                  _buildBottomAction(),
                ],
              ),
            ),
          ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar(double progress) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          color: _theme.color,
          onTap: _goBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Count Objects',
                style: AppTypography.h1.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Round ${_roundIndex + 1} of $_totalRounds',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF586374),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 92,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
          ),
          child: Column(
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: AppTypography.bodyStrong.copyWith(
                  color: _theme.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: _theme.softColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_theme.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: _theme.softColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _theme.emoji,
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How many ${_correctCount == 1 ? _theme.singular : _theme.plural}?',
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1A1060),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Count each picture and tap the correct number.',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF5F6C7B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CircleButton(
            icon: Icons.volume_up_rounded,
            color: _theme.color,
            onTap: _speakPrompt,
          ),
        ],
      ),
    );
  }

  Widget _buildObjectsCard() {
    return AnimatedBuilder(
      animation: _cardPopController,
      builder: (context, child) {
        final scale = 1 + ((_cardPopController.value - 1) * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _theme.color.withValues(alpha: 0.18)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x142D3436),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 520 ? 4 : 3;
            final rows = (_correctCount / columns).ceil();
            const spacing = 14.0;
            final itemSize = math.min(
              110.0,
              math.min(
                (constraints.maxWidth - ((columns - 1) * spacing)) / columns,
                (constraints.maxHeight - ((rows - 1) * spacing)) / rows,
              ),
            );
            return Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: List.generate(
                  _correctCount,
                  (index) => Container(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      color: _theme.softColor.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _theme.color.withValues(alpha: 0.16),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _theme.assetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswerGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: _options.map((option) {
        final isSelected = _selectedAnswer == option;
        final isCorrect = option == _correctCount;
        final bgColor = _answerLocked && isSelected
            ? (isCorrect
                ? AppColors.correctFeedback
                : AppColors.incorrectFeedback)
            : Colors.white.withValues(alpha: 0.94);
        final borderColor = _answerLocked && isSelected
            ? (isCorrect ? AppColors.gardenGreen : AppColors.primary)
            : _theme.color.withValues(alpha: 0.20);

        return Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _handleAnswerTap(option),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$option',
                  style: AppTypography.numberDisplay.copyWith(
                    fontSize: 42,
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction() {
    final isLastRound = _roundIndex == _totalRounds - 1;
    final label = isLastRound ? 'Finish' : 'Next';
    final isEnabled = _roundSolved;
    return SizedBox(
      width: double.infinity,
      child: _ActionButton(
        label: label,
        icon: Icons.arrow_forward_rounded,
        backgroundColor: isEnabled ? _theme.color : AppColors.disabled,
        foregroundColor: Colors.white,
        borderColor: isEnabled ? _theme.shadowColor : AppColors.disabled,
        onTap: isEnabled ? _goToNextRound : () {},
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final scale = 0.88 + (_celebrationController.value * 0.12);
        return Material(
          color: Colors.black.withValues(alpha: 0.42),
          child: SafeArea(
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: math.min(MediaQuery.of(context).size.width - 32, 380),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: _theme.color.withValues(alpha: 0.22),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _theme.color.withValues(alpha: 0.24),
                        blurRadius: 36,
                        spreadRadius: 8,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _theme.softColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'All $_totalRounds Rounds Complete',
                          style: AppTypography.bodySmall.copyWith(
                            color: _theme.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const CelebrationBear(size: 132),
                      const SizedBox(height: 14),
                      Text(
                        'Counting Complete!',
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You finished every counting challenge from 1 to 10. Keep going with the next adventure!',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF556172),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      StartLearningNextActionButton(
                        currentRoute: AppRoutes.counting,
                        onPrepareNavigation: _prepareNextLearningNavigation,
                        builder: (context, label, onTap) {
                          return _ActionButton(
                            label: label,
                            icon: Icons.arrow_forward_rounded,
                            backgroundColor: _theme.color,
                            foregroundColor: Colors.white,
                            borderColor: _theme.shadowColor,
                            onTap: onTap,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyStrong.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
