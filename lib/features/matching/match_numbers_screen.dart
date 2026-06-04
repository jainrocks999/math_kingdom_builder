import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/audio_service.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../../core/utils/tts_voice_helper.dart';
import '../../shared/widgets/celebration_bear.dart';

class _MatchTheme {
  const _MatchTheme({
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

  static const List<_MatchTheme> _themes = [
    _MatchTheme(
      assetPath: 'assets/images/contingobjects/apple.jpeg',
      singular: 'apple',
      plural: 'apples',
      emoji: '🍎',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
    ),
    _MatchTheme(
      assetPath: 'assets/images/contingobjects/candy.jpeg',
      singular: 'candy',
      plural: 'candies',
      emoji: '🍬',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
    _MatchTheme(
      assetPath: 'assets/images/contingobjects/car.jpeg',
      singular: 'car',
      plural: 'cars',
      emoji: '🚗',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
    ),
    _MatchTheme(
      assetPath: 'assets/images/contingobjects/ballun.jpeg',
      singular: 'balloon',
      plural: 'balloons',
      emoji: '🎈',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
    ),
    _MatchTheme(
      assetPath: 'assets/images/contingobjects/start.jpeg',
      singular: 'star',
      plural: 'stars',
      emoji: '⭐',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
    ),
  ];

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _numberPulseController;
  late final AnimationController _celebrationController;

  final math.Random _random = math.Random();
  final AudioService _feedbackAudio = AudioService();

  late List<_MatchRound> _rounds;
  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int? _selectedCount;
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;
  List<int> _options = const [];

  _MatchRound get _currentRound => _rounds[_roundIndex];
  _MatchTheme get _theme => _themes[_currentRound.themeIndex];
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
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
  }

  List<_MatchRound> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => index + 1)
      ..shuffle(_random);
    final rounds = <_MatchRound>[];
    final themeUsage = List<int>.filled(_themes.length, 0);
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
    final candidates = List<int>.generate(_themes.length, (index) => index)
      ..sort((a, b) => themeUsage[a].compareTo(themeUsage[b]));
    final leastUsed = themeUsage[candidates.first];
    final filtered = candidates
        .where(
          (index) =>
              themeUsage[index] <= leastUsed + 1 &&
              (_themes.length == 1 || index != lastThemeIndex),
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
        if (!mounted || requestToken != _musicRequestToken || _showCelebration) {
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

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    final label = _correctCount == 1 ? _theme.singular : _theme.plural;
    await _tts.speak('Tap the group with $_correctCount $label.');
  }

  Future<void> _speakCorrectPraise() async {
    await _ttsReady;
    await _tts.stop();
    final label = _correctCount == 1 ? _theme.singular : _theme.plural;
    await _tts.speak('Great matching! $_correctCount $label.');
  }

  void _scheduleAutoAdvance() {
    final requestToken = ++_autoAdvanceToken;
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted || requestToken != _autoAdvanceToken) return;
      if (_roundIndex == _totalRounds - 1) {
        _showFinalCelebration();
      } else {
        _nextRound();
      }
    });
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
      _speakCorrectPraise();
      _scheduleAutoAdvance();
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
    _stopScreenMusic();
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
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    context.pop();
  }

  void _prepareNextLearningNavigation() {
    _autoAdvanceToken++;
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
    _autoAdvanceToken++;
    AppAudioService.instance.stopCelebrationMusic();
    AppAudioService.instance.stopBackgroundMusic();
    _tts.stop();
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
              child: Column(
                children: [
                  _buildTopBar(progress),
                  const SizedBox(height: 14),
                  _buildPromptCard(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildNumberCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildChoicesGrid()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBottomBar(),
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
                'Match Numbers',
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
          width: 94,
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
                  'Match the number to the right group.',
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1A1060),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the group that has exactly $_correctCount ${_correctCount == 1 ? _theme.singular : _theme.plural}.',
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

  Widget _buildNumberCard() {
    return AnimatedBuilder(
      animation: _numberPulseController,
      builder: (context, child) {
        final scale = 1 + ((_numberPulseController.value - 1) * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find this number',
              style: AppTypography.bodyStrong.copyWith(
                color: _theme.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$_correctCount',
              style: AppTypography.numberDisplay.copyWith(
                fontSize: 116,
                color: const Color(0xFF1A1060),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _correctCount == 1 ? _theme.singular : _theme.plural,
              style: AppTypography.h2.copyWith(
                color: _theme.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesGrid() {
    return GridView.builder(
      itemCount: _options.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) => _buildChoiceCard(_options[index]),
    );
  }

  Widget _buildChoiceCard(int count) {
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _theme.softColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.bodyStrong.copyWith(
                      color: _theme.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = count <= 4 ? 2 : (count <= 8 ? 3 : 4);
                    final rows = (count / columns).ceil();
                    const spacing = 5.0;
                    final itemSize = math.min(
                      30.0,
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
                        children: List.generate(
                          count,
                          (_) => Container(
                            width: itemSize,
                            height: itemSize,
                            decoration: BoxDecoration(
                              color: _theme.softColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2.5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Hear Again',
            icon: Icons.volume_up_rounded,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            foregroundColor: _theme.color,
            borderColor: _theme.color.withValues(alpha: 0.22),
            onTap: _speakPrompt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: _roundSolved
                ? (_roundIndex == _totalRounds - 1 ? 'Finishing...' : 'Next coming...')
                : 'Match it',
            icon: _roundSolved
                ? Icons.auto_awesome_rounded
                : Icons.touch_app_rounded,
            backgroundColor:
                _roundSolved ? _theme.color : AppColors.disabled,
            foregroundColor: Colors.white,
            borderColor: _roundSolved ? _theme.shadowColor : AppColors.disabled,
            onTap: () {},
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
                          'All $_totalRounds Matches Complete',
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
                        'Matching Complete!',
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You matched every number with the correct object group. Bear is cheering for you!',
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: foregroundColor,
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
