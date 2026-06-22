import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localization.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../shared/helpers/feedback_helper.dart';
import '../../shared/widgets/celebration_bear.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import 'counting_themes.dart';

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

  late final FlutterTts _tts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  late final AnimationController _cardPopController;
  late final AnimationController _celebrationController;
  late List<_RoundConfig> _rounds;

  final math.Random _random = math.Random();

  int _musicRequestToken = 0;
  int _roundIndex = 0;
  int? _selectedAnswer;
  List<int> _countedObjectOrder = const [];
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;
  List<int> _options = const [];

  _RoundConfig get _currentRound => _rounds[_roundIndex];
  CountingTheme get _theme => countingThemes[_currentRound.themeIndex];
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
    _ttsReady = Future<void>.value();
    _rounds = _buildRoundPlan();
    _prepareRound();
    _playScreenMusic(delayed: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakPrompt();
    });
  }

  Future<void> _configureTts() async {
    await AppLocalization.configureTts(
      _tts,
      context,
      normalRate: 0.38,
      slowRate: 0.28,
    );
    await _tts.setPitch(1.04);
    await _tts.setVolume(1.0);
  }

  String _objectLabel(BuildContext context, int count) =>
      AppLocalization.objectLabel(context, _theme.id, count);

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

  void _stopAllAudioAndSpeech() {
    _stopScreenMusic();
    AppAudioService.instance.stopCelebrationMusic();
    _tts.stop();
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
    _countedObjectOrder = const [];
  }

  List<_RoundConfig> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => index + 1)
      ..shuffle(_random);
    final rounds = <_RoundConfig>[];
    final themeUsage = List<int>.filled(countingThemes.length, 0);
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
    final candidates =
        List<int>.generate(countingThemes.length, (index) => index)
          ..sort((a, b) => themeUsage[a].compareTo(themeUsage[b]));
    final leastUsedCount = themeUsage[candidates.first];
    final filtered = candidates
        .where(
          (index) =>
              themeUsage[index] <= leastUsedCount + 1 &&
              (countingThemes.length == 1 || index != lastThemeIndex),
        )
        .toList();

    final pool = filtered.isNotEmpty ? filtered : candidates;
    return pool[_random.nextInt(pool.length)];
  }

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    if (!mounted) return;
    final label = _objectLabel(context, _correctCount);
    await _tts.speak(
      context.tr('learning.count_the', namedArgs: {'label': label}),
    );
  }

  Future<void> _speakCorrectAnswer() async {
    await _ttsReady;
    await _tts.stop();
    if (!mounted) return;
    await _tts.speak(
      context.tr(
        'learning.great_count',
        namedArgs: {
          'count': '$_correctCount',
          'label': _objectLabel(context, _correctCount),
        },
      ),
    );
  }

  Future<void> _speakWrongAnswer() async {
    await _ttsReady;
    await _tts.stop();
    if (!mounted) return;
    await _tts.speak(context.tr('learning.try_again_count'));
  }

  Future<void> _handleAnswerTap(int answer) async {
    if (_answerLocked || _showCelebration) return;

    setState(() {
      _selectedAnswer = answer;
      _answerLocked = true;
    });

    final isCorrect = answer == _correctCount;
    if (isCorrect) {
      _cardPopController.forward(from: 0);
      await FeedbackHelper.playCorrect(
        speak: _roundIndex == _totalRounds - 1 ? null : _speakCorrectAnswer,
      );
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
      if (!mounted) return;
      setState(() {
        _roundSolved = true;
      });
    } else {
      await FeedbackHelper.playWrong(speak: _speakWrongAnswer);
      if (!mounted) return;
      setState(() {
        _answerLocked = false;
        _selectedAnswer = null;
      });
    }
  }

  Future<void> _handleObjectTap(int index) async {
    if (_showCelebration) return;

    final existingIndex = _countedObjectOrder.indexOf(index);
    final updatedOrder = List<int>.from(_countedObjectOrder);
    if (existingIndex == -1) {
      updatedOrder.add(index);
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.selectionClick();
    }

    final spokenCount =
        existingIndex == -1 ? updatedOrder.length : existingIndex + 1;

    setState(() {
      _countedObjectOrder = updatedOrder;
    });

    await _ttsReady;
    await _tts.stop();
    if (!mounted) return;
    if (spokenCount == _correctCount && existingIndex == -1) {
      await _tts.speak(
        context.tr(
          'learning.great_count',
          namedArgs: {
            'count': '$_correctCount',
            'label': _objectLabel(context, _correctCount),
          },
        ),
      );
      return;
    }
    await _tts.speak(
      '${AppLocalization.numberWord(context, spokenCount)} '
      '${_objectLabel(context, spokenCount)}',
    );
  }

  void _resetTappedObjects() {
    if (_countedObjectOrder.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _countedObjectOrder = const [];
    });
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
    _stopAllAudioAndSpeech();
    context.pop();
  }

  void _prepareNextLearningNavigation() {
    _stopAllAudioAndSpeech();
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
    if (!_ttsConfigured) {
      _ttsConfigured = true;
      _ttsReady = _configureTts();
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
    _stopAllAudioAndSpeech();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _musicRequestToken++;
    _stopAllAudioAndSpeech();
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
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                20 + (MediaQuery.of(context).padding.bottom * 0.2),
              ),
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
                AppLocalization.moduleTitle(context, AppRoutes.counting),
                style: AppTypography.h1.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                context.tr(
                  'learning.round',
                  namedArgs: {
                    'current': '${_roundIndex + 1}',
                    'total': '$_totalRounds',
                  },
                ),
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
                  context.tr(
                    'learning.how_many',
                    namedArgs: {
                      'label': _objectLabel(context, _correctCount),
                    },
                  ),
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1A1060),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${context.tr('learning.count_prompt')} ${context.tr('learning.tap_to_hear')}',
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _theme.softColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _countedObjectOrder.isEmpty
                        ? context.tr('learning.tap_objects_to_count')
                        : '${_countedObjectOrder.length}/$_correctCount',
                    style: AppTypography.bodySmall.copyWith(
                      color: _theme.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                if (_countedObjectOrder.isNotEmpty)
                  TextButton.icon(
                    onPressed: _resetTappedObjects,
                    style: TextButton.styleFrom(
                      foregroundColor: _theme.color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(context.tr('learning.reset')),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 520 ? 4 : 3;
                  final rows = (_correctCount / columns).ceil();
                  const spacing = 14.0;
                  final itemSize = math.min(
                    110.0,
                    math.min(
                      (constraints.maxWidth - ((columns - 1) * spacing)) /
                          columns,
                      (constraints.maxHeight - ((rows - 1) * spacing)) / rows,
                    ),
                  );
                  return Center(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: List.generate(_correctCount, (index) {
                        final countedIndex = _countedObjectOrder.indexOf(index);
                        final isCounted = countedIndex != -1;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _handleObjectTap(index),
                            child: Container(
                              width: itemSize,
                              height: itemSize,
                              decoration: BoxDecoration(
                                color: isCounted
                                    ? _theme.softColor.withValues(alpha: 0.88)
                                    : _theme.softColor.withValues(alpha: 0.42),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isCounted
                                      ? _theme.color.withValues(alpha: 0.6)
                                      : _theme.color.withValues(alpha: 0.16),
                                  width: isCounted ? 2.4 : 1.4,
                                ),
                                boxShadow: isCounted
                                    ? [
                                        BoxShadow(
                                          color: _theme.color.withValues(
                                            alpha: 0.18,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Stack(
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        _theme.assetPath,
                                        fit: BoxFit.contain,
                                        width: itemSize * 0.72,
                                        height: itemSize * 0.72,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.auto_awesome_rounded,
                                            size: itemSize * 0.34,
                                            color: _theme.color,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (isCounted)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: _theme.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${countedIndex + 1}',
                                            style:
                                                AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final buttonHeight = isNarrow ? 74.0 : 82.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: buttonHeight,
          ),
          itemBuilder: (context, index) {
            final option = _options[index];
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
                  constraints: const BoxConstraints(minHeight: 56),
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
                        fontSize: isNarrow ? 36 : 42,
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomAction() {
    final isLastRound = _roundIndex == _totalRounds - 1;
    final label =
        isLastRound ? context.tr('learning.finish') : context.tr('learning.next');
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
                          context.tr(
                            'learning.all_rounds_complete',
                            namedArgs: {'total': '$_totalRounds'},
                          ),
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
                        context.tr('learning.counting_complete'),
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.tr('learning.finish_every_challenge'),
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF556172),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _theme.softColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _theme.color.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          context.tr(
                            'learning.stars_earned',
                            namedArgs: {
                              'stars': '${RewardProgressService.instance.starsForModule(RewardModuleIds.countObjects)}',
                            },
                          ),
                          style: AppTypography.bodyStrong.copyWith(
                            color: _theme.color,
                            fontWeight: FontWeight.w800,
                          ),
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
