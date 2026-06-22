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
import '../../core/utils/audio_service.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../count_objects/counting_themes.dart';
import '../../shared/widgets/celebration_bear.dart';

class _MatchRound {
  const _MatchRound({
    required this.count,
    required this.themeIndex,
  });

  final int count;
  final int themeIndex;
}

class MatchNumbersScreen extends StatefulWidget {
  const MatchNumbersScreen({super.key});

  @override
  State<MatchNumbersScreen> createState() => _MatchNumbersScreenState();
}

class _MatchNumbersScreenState extends State<MatchNumbersScreen>
    with TickerProviderStateMixin, RouteAware {
  static const int _totalRounds = 10;
  static const _postSuccessPause = Duration(milliseconds: 250);
  static const _speechSettleDelay = Duration(milliseconds: 80);

  late final FlutterTts _tts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  late final AnimationController _numberPulseController;
  late final AnimationController _celebrationController;

  final math.Random _random = math.Random();
  final AudioService _feedbackAudio = AudioService();

  late List<_MatchRound> _rounds;
  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _speechRequestToken = 0;
  int _roundIndex = 0;
  int? _selectedCount;
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;
  List<int> _options = const [];

  _MatchRound get _currentRound => _rounds[_roundIndex];
  CountingTheme get _theme => countingThemes[_currentRound.themeIndex];
  int get _correctCount => _currentRound.count;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _numberPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
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
    await AppLocalization.configureTts(_tts, context, normalRate: 0.4, slowRate: 0.3);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setPitch(1.04);
    await _tts.setVolume(1.0);
  }

  String _objectLabel(BuildContext context, int count) =>
      AppLocalization.objectLabel(context, _theme.id, count);

  List<_MatchRound> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => index + 1)
      ..shuffle(_random);
    final rounds = <_MatchRound>[];
    final themeUsage = List<int>.filled(countingThemes.length, 0);
    var lastThemeIndex = -1;

    for (final count in counts) {
      final themeIndex = _pickThemeIndex(
        themeUsage: themeUsage,
        lastThemeIndex: lastThemeIndex,
      );
      rounds.add(_MatchRound(count: count, themeIndex: themeIndex));
      themeUsage[themeIndex]++;
      lastThemeIndex = themeIndex;
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
    final leastUsed = themeUsage[candidates.first];
    final filtered = candidates
        .where(
          (index) =>
              themeUsage[index] <= leastUsed + 1 &&
              (countingThemes.length == 1 || index != lastThemeIndex),
        )
        .toList();
    final pool = filtered.isNotEmpty ? filtered : candidates;
    return pool[_random.nextInt(pool.length)];
  }

  void _prepareRound() {
    final correct = _correctCount;
    final options = <int>{correct};
    while (options.length < 4) {
      options.add(_random.nextInt(_totalRounds) + 1);
    }
    _options = options.toList()..shuffle();
    _selectedCount = null;
    _answerLocked = false;
    _roundSolved = false;
  }

  void _playScreenMusic({bool delayed = false}) {
    final requestToken = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted ||
            requestToken != _musicRequestToken ||
            _showCelebration) {
          return;
        }
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
    _speechRequestToken++;
    _tts.stop();
  }

  Future<void> _speakPrompt() async {
    if (!mounted) return;
    final label = _objectLabel(context, _correctCount);
    await _speakText(
      context.tr('learning.how_many', namedArgs: {'label': label}),
    );
  }

  Future<void> _speakCorrectPraise() async {
    if (!mounted) return;
    await _speakText(
      context.tr(
        'learning.great_count',
        namedArgs: {
          'count': '$_correctCount',
          'label': _objectLabel(context, _correctCount),
        },
      ),
    );
  }

  Future<void> _speakText(String text) async {
    final token = ++_speechRequestToken;
    await _ttsReady;
    if (!mounted || token != _speechRequestToken) return;
    await _tts.stop();
    if (!mounted || token != _speechRequestToken) return;
    await Future<void>.delayed(_speechSettleDelay);
    if (!mounted || token != _speechRequestToken) return;
    await _tts.speak(text);
  }

  Future<void> _advanceAfterCorrectAnswer() async {
    final requestToken = ++_autoAdvanceToken;
    await _speakCorrectPraise();
    if (!mounted || requestToken != _autoAdvanceToken) return;
    await Future<void>.delayed(_postSuccessPause);
    if (!mounted || requestToken != _autoAdvanceToken) return;
    if (_roundIndex == _totalRounds - 1) {
      _showFinalCelebration();
    } else {
      _nextRound();
    }
  }

  void _handleOptionTap(int option) {
    if (_answerLocked || _showCelebration) return;

    final isCorrect = option == _correctCount;

    setState(() {
      _selectedCount = option;
      _answerLocked = true;
      if (isCorrect) {
        _roundSolved = true;
      }
    });

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _numberPulseController.forward(from: 0);
      _feedbackAudio.playSfx('sfx/correct.mp3');
      _advanceAfterCorrectAnswer();
    } else {
      HapticFeedback.heavyImpact();
      _feedbackAudio.playWrongFeedback();
      final requestToken = ++_autoAdvanceToken;
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || requestToken != _autoAdvanceToken) return;
        setState(() {
          _selectedCount = null;
          _answerLocked = false;
        });
      });
    }
  }

  void _nextRound() {
    if (_roundIndex >= _totalRounds - 1) {
      _showFinalCelebration();
      return;
    }
    _autoAdvanceToken++;
    _speechRequestToken++;
    setState(() {
      _roundIndex++;
      _prepareRound();
    });
    _speakPrompt();
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration || !_roundSolved) return;
    if (_roundIndex != _totalRounds - 1) return;
    _autoAdvanceToken++;
    _stopAllAudioAndSpeech();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.matchNumbers,
    );
    AppAudioService.instance.playCelebrationMusic();
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward(from: 0);
  }

  void _goBack() {
    _autoAdvanceToken++;
    _stopAllAudioAndSpeech();
    context.pop();
  }

  void _prepareNextLearningNavigation() {
    _autoAdvanceToken++;
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
    _autoAdvanceToken++;
    _speechRequestToken++;
    _stopAllAudioAndSpeech();
    _numberPulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_roundIndex + (_roundSolved ? 1 : 0)) / _totalRounds;

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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrowWidth = constraints.maxWidth < 360;
                  final isVeryCompactHeight = constraints.maxHeight < 700;
                  final isCompactHeight = constraints.maxHeight < 760;
                  final gap = isVeryCompactHeight
                      ? 8.0
                      : (isCompactHeight ? 10.0 : 14.0);

                  return Column(
                    children: [
                      _buildTopBar(
                        progress,
                        compact: isCompactHeight,
                        narrowWidth: isNarrowWidth,
                      ),
                      SizedBox(height: gap),
                      _buildPromptCard(
                        compact: isCompactHeight,
                        veryCompact: isVeryCompactHeight,
                        narrowWidth: isNarrowWidth,
                      ),
                      SizedBox(height: gap),
                      Expanded(
                        child: _buildGameBoard(
                          isCompactHeight: isCompactHeight,
                          isVeryCompactHeight: isVeryCompactHeight,
                          isNarrowWidth: isNarrowWidth,
                        ),
                      ),
                      SizedBox(height: isVeryCompactHeight ? 8 : 12),
                      _buildBottomBar(compact: isVeryCompactHeight),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildGameBoard({
    required bool isCompactHeight,
    required bool isVeryCompactHeight,
    required bool isNarrowWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout = constraints.maxWidth >= 760;

        if (useWideLayout) {
          return Row(
            children: [
              Expanded(child: _buildNumberCard()),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: _buildChoicesGrid(
                  preferLargeCards: true,
                ),
              ),
            ],
          );
        }

        final numberCard = SizedBox(
          height: isVeryCompactHeight ? 122 : (isCompactHeight ? 142 : 176),
          child: _buildNumberCard(compact: true),
        );

        final choicesGrid = Expanded(
          child: _buildChoicesGrid(
            preferLargeCards: true,
            compactHeight: isVeryCompactHeight,
            narrowWidth: isNarrowWidth,
          ),
        );

        return Column(
          children: [
            if (isNarrowWidth) choicesGrid else numberCard,
            SizedBox(height: isVeryCompactHeight ? 8 : 12),
            if (isNarrowWidth) numberCard else choicesGrid,
          ],
        );
      },
    );
  }

  Widget _buildTopBar(
    double progress, {
    required bool compact,
    required bool narrowWidth,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _CircleButton(
              icon: Icons.arrow_back_rounded,
              color: _theme.color,
              onTap: _goBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalization.moduleTitle(context, AppRoutes.matching),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h1.copyWith(
                  fontSize: narrowWidth ? 22 : 24,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: narrowWidth ? 10 : 12,
                vertical: compact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
              ),
              child: Text(
                '${(progress * 100).round()}%',
                style: AppTypography.bodyStrong.copyWith(
                  color: _theme.color,
                  fontWeight: FontWeight.w800,
                  fontSize: narrowWidth ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 10 : 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: narrowWidth ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _theme.color.withValues(alpha: 0.16)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(
                        'learning.round',
                        namedArgs: {
                          'current': '${_roundIndex + 1}',
                          'total': '$_totalRounds',
                        },
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        color: const Color(0xFF1A1060),
                        fontSize: narrowWidth ? 14 : 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _roundSolved
                        ? context.tr('learning.great_job')
                        : context.tr('learning.match_prompt'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color:
                          _roundSolved ? AppColors.gardenGreen : _theme.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
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

  Widget _buildPromptCard({
    bool compact = false,
    bool veryCompact = false,
    bool narrowWidth = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(veryCompact ? 12 : (compact ? 16 : 18)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
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
      child: narrowWidth
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: veryCompact ? 46 : 56,
                      height: veryCompact ? 46 : 56,
                      decoration: BoxDecoration(
                        color: _theme.softColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          _theme.emoji,
                          style: TextStyle(
                            fontSize: veryCompact ? 22 : 28,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    _CircleButton(
                      icon: Icons.volume_up_rounded,
                      color: _theme.color,
                      onTap: _speakPrompt,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('learning.match_prompt'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1A1060),
                    fontSize: veryCompact ? 15 : 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: veryCompact ? 4 : 6),
                Text(
                  context.tr(
                    'learning.how_many',
                    namedArgs: {
                      'label': _objectLabel(context, _correctCount),
                    },
                  ),
                  maxLines: veryCompact ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF5F6C7B),
                    fontSize: veryCompact ? 12 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: veryCompact ? 50 : (compact ? 60 : 68),
                  height: veryCompact ? 50 : (compact ? 60 : 68),
                  decoration: BoxDecoration(
                    color: _theme.softColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _theme.emoji,
                      style: TextStyle(
                        fontSize: veryCompact ? 24 : (compact ? 30 : 34),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: veryCompact ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('learning.match_prompt'),
                        maxLines: veryCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.cardTitle.copyWith(
                          color: const Color(0xFF1A1060),
                          fontSize: veryCompact ? 15 : (compact ? 17 : 19),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: veryCompact ? 4 : 6),
                      Text(
                        context.tr(
                    'learning.how_many',
                    namedArgs: {
                      'label': _objectLabel(context, _correctCount),
                    },
                  ),
                        maxLines: veryCompact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF5F6C7B),
                          fontSize: veryCompact ? 12 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: veryCompact ? 8 : 10),
                _CircleButton(
                  icon: Icons.volume_up_rounded,
                  color: _theme.color,
                  onTap: _speakPrompt,
                ),
              ],
            ),
    );
  }

  Widget _buildNumberCard({bool compact = false}) {
    return AnimatedBuilder(
      animation: _numberPulseController,
      builder: (context, child) {
        final scale = 1 + ((_numberPulseController.value - 1) * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 16 : 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _theme.color.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: _theme.color.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShortCard = constraints.maxHeight < 170;
            final numberFontSize =
                compact ? math.min(82.0, constraints.maxHeight * 0.48) : 116.0;
            final labelFontSize = compact ? (isShortCard ? 20.0 : 24.0) : null;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('learning.match_prompt'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: _theme.color,
                    fontSize: compact ? 14 : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: isShortCard ? 4 : (compact ? 8 : 18)),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$_correctCount',
                      style: AppTypography.numberDisplay.copyWith(
                        fontSize: numberFontSize,
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isShortCard ? 2 : (compact ? 4 : 10)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _objectLabel(context, _correctCount),
                    maxLines: 1,
                    style: AppTypography.h2.copyWith(
                      color: _theme.color,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChoicesGrid({
    bool preferLargeCards = false,
    bool compactHeight = false,
    bool narrowWidth = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = narrowWidth
            ? 8.0
            : (compactHeight ? 10.0 : (preferLargeCards ? 14.0 : 12.0));
        const crossAxisCount = 2;
        final rowCount = (_options.length / crossAxisCount).ceil();
        final viewportPadding = narrowWidth ? 2.0 : (compactHeight ? 4.0 : 6.0);
        final availableHeight = math.max(
          0.0,
          constraints.maxHeight - (viewportPadding * 2),
        );
        final mainAxisExtent = rowCount == 0
            ? availableHeight
            : (availableHeight - ((rowCount - 1) * spacing)) / rowCount;

        return GridView.builder(
          padding: EdgeInsets.symmetric(vertical: viewportPadding),
          itemCount: _options.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: (context, index) => _buildChoiceCard(
            _options[index],
            compactHeight: compactHeight,
            narrowWidth: narrowWidth,
          ),
        );
      },
    );
  }

  Widget _buildChoiceCard(
    int count, {
    bool compactHeight = false,
    bool narrowWidth = false,
  }) {
    final isSelected = _selectedCount == count;
    final isCorrect = count == _correctCount;

    Color borderColor = _theme.color.withValues(alpha: 0.22);
    Color backgroundColor = Colors.white.withValues(alpha: 0.95);

    if (isSelected && isCorrect) {
      borderColor = AppColors.gardenGreen;
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.46);
    } else if (isSelected && !isCorrect) {
      borderColor = AppColors.incorrectFeedback;
      backgroundColor = AppColors.incorrectFeedback.withValues(alpha: 0.34);
    } else if (_roundSolved && isCorrect) {
      borderColor = AppColors.gardenGreen.withValues(alpha: 0.72);
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.24);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _handleOptionTap(count),
        child: Container(
          padding: EdgeInsets.all(narrowWidth ? 6 : (compactHeight ? 8 : 10)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.16),
                blurRadius: compactHeight ? 8 : 12,
                offset: Offset(0, compactHeight ? 3 : 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => _buildObjectPreview(
                    count,
                    constraints,
                    narrowWidth: narrowWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectPreview(
    int count,
    BoxConstraints constraints, {
    bool narrowWidth = false,
  }) {
    final columns = switch (count) {
      <= 2 => count,
      <= 4 => 2,
      <= 6 => 3,
      _ => 4,
    };
    final rows = (count / columns).ceil();
    final spacing = narrowWidth ? 6.0 : 8.0;
    final maxSize = switch (count) {
      <= 2 => narrowWidth ? 46.0 : 54.0,
      <= 4 => narrowWidth ? 42.0 : 50.0,
      <= 6 => narrowWidth ? 38.0 : 44.0,
      _ => narrowWidth ? 34.0 : 38.0,
    };
    final itemSize = math.min(
      maxSize,
      math.min(
        (constraints.maxWidth - ((columns - 1) * spacing)) / columns,
        (constraints.maxHeight - ((rows - 1) * spacing)) / rows,
      ),
    );
    final previewWidth = (columns * itemSize) + ((columns - 1) * spacing);

    return Center(
      child: SizedBox(
        width: previewWidth,
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(
            count,
            (_) => Container(
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                color: _theme.softColor.withValues(alpha: 0.54),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: 1.6,
                ),
              ),
              padding: EdgeInsets.all(itemSize * 0.08),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  _theme.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: itemSize * 0.34,
                        color: _theme.color,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar({bool compact = false}) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: context.tr('learning.speaker'),
            icon: Icons.volume_up_rounded,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            foregroundColor: _theme.color,
            borderColor: _theme.color.withValues(alpha: 0.22),
            onTap: _speakPrompt,
            compact: compact,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: _roundSolved
                ? (_roundIndex == _totalRounds - 1
                    ? context.tr('learning.finish')
                    : context.tr('learning.next'))
                : context.tr('learning.match_prompt'),
            icon: _roundSolved
                ? Icons.auto_awesome_rounded
                : Icons.touch_app_rounded,
            backgroundColor: _roundSolved ? _theme.color : AppColors.disabled,
            foregroundColor: Colors.white,
            borderColor: _roundSolved ? _theme.shadowColor : AppColors.disabled,
            onTap: () {},
            compact: compact,
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final scale = 0.88 + (_celebrationController.value * 0.12);
        return Material(
          color: Colors.black.withValues(alpha: 0.38),
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
                        context.tr('learning.activity_complete'),
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
                      const SizedBox(height: 22),
                      StartLearningNextActionButton(
                        currentRoute: AppRoutes.matching,
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
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 10 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: compact ? 16 : 18),
              SizedBox(width: compact ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: foregroundColor,
                    fontSize: compact ? 13 : null,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
