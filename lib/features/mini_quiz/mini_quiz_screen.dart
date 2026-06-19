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
import '../../core/utils/tts_voice_helper.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../../shared/widgets/celebration_bear.dart';

enum _QuizMode { tapNumber, dragMatch, writeNumber }

class _QuizTheme {
  const _QuizTheme({
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

class _QuizRound {
  const _QuizRound({
    required this.answer,
    required this.themeIndex,
    required this.mode,
  });

  final int answer;
  final int themeIndex;
  final _QuizMode mode;
}

class MiniQuizScreen extends StatefulWidget {
  const MiniQuizScreen({super.key});

  @override
  State<MiniQuizScreen> createState() => _MiniQuizScreenState();
}

class _MiniQuizScreenState extends State<MiniQuizScreen>
    with TickerProviderStateMixin, RouteAware {
  static const int _totalRounds = 9;

  static const List<_QuizTheme> _themes = [
    _QuizTheme(
      assetPath: 'assets/images/contingobjects/apple.jpeg',
      singular: 'apple',
      plural: 'apples',
      emoji: '🍎',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
    ),
    _QuizTheme(
      assetPath: 'assets/images/contingobjects/candy.jpeg',
      singular: 'candy',
      plural: 'candies',
      emoji: '🍬',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
    _QuizTheme(
      assetPath: 'assets/images/contingobjects/car.jpeg',
      singular: 'car',
      plural: 'cars',
      emoji: '🚗',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
    ),
    _QuizTheme(
      assetPath: 'assets/images/contingobjects/ballun.jpeg',
      singular: 'balloon',
      plural: 'balloons',
      emoji: '🎈',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
    ),
    _QuizTheme(
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
  late final AnimationController _celebrationController;
  late final AnimationController _successPulseController;

  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();

  late List<_QuizRound> _rounds;
  List<int> _tapOptions = const [];
  List<int> _dragOptions = const [];
  final List<int> _writeKeypad = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int? _selectedTapNumber;
  int? _draggedNumber;
  int? _droppedNumber;
  String _writtenAnswer = '';
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;

  _QuizRound get _currentRound => _rounds[_roundIndex];
  _QuizTheme get _theme => _themes[_currentRound.themeIndex];
  int get _correctAnswer => _currentRound.answer;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _successPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
      value: 1,
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

  List<_QuizRound> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => (index % 10) + 1)
      ..shuffle(_random);
    final modes = <_QuizMode>[
      _QuizMode.tapNumber,
      _QuizMode.dragMatch,
      _QuizMode.writeNumber,
      _QuizMode.tapNumber,
      _QuizMode.dragMatch,
      _QuizMode.writeNumber,
      _QuizMode.tapNumber,
      _QuizMode.dragMatch,
      _QuizMode.writeNumber,
    ]..shuffle(_random);
    final rounds = <_QuizRound>[];
    final themeUsage = List<int>.filled(_themes.length, 0);
    var lastThemeIndex = -1;

    for (var i = 0; i < _totalRounds; i++) {
      final themeIndex = _pickThemeIndex(
        themeUsage: themeUsage,
        lastThemeIndex: lastThemeIndex,
      );
      rounds.add(
        _QuizRound(
          answer: counts[i],
          themeIndex: themeIndex,
          mode: modes[i],
        ),
      );
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
    final answer = _correctAnswer;

    final tapOptions = <int>{answer};
    while (tapOptions.length < 4) {
      tapOptions.add(_random.nextInt(10) + 1);
    }

    final dragOptions = <int>{answer};
    while (dragOptions.length < 3) {
      dragOptions.add(_random.nextInt(10) + 1);
    }

    _tapOptions = tapOptions.toList()..shuffle(_random);
    _dragOptions = dragOptions.toList()..shuffle(_random);
    _selectedTapNumber = null;
    _draggedNumber = null;
    _droppedNumber = null;
    _writtenAnswer = '';
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

  String _objectLabel(int count) {
    return count == 1 ? _theme.singular : _theme.plural;
  }

  String _modeLabel(_QuizMode mode) {
    switch (mode) {
      case _QuizMode.tapNumber:
        return 'Tap Quiz';
      case _QuizMode.dragMatch:
        return 'Drag Quiz';
      case _QuizMode.writeNumber:
        return 'Write Quiz';
    }
  }

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    final label = _objectLabel(_correctAnswer);
    final prompt = switch (_currentRound.mode) {
      _QuizMode.tapNumber => 'Tap the number $_correctAnswer.',
      _QuizMode.dragMatch => 'Drag number $_correctAnswer to match the $label.',
      _QuizMode.writeNumber =>
        'Count the $label and write number $_correctAnswer.',
    };
    await _tts.speak(prompt);
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    final label = _objectLabel(_correctAnswer);
    await _tts.speak('Amazing! You got $_correctAnswer $label right.');
  }

  void _markCorrect() {
    if (_answerLocked || _showCelebration) return;

    setState(() {
      _answerLocked = true;
      _roundSolved = true;
    });

    HapticFeedback.mediumImpact();
    _successPulseController.forward(from: 0);
    _feedbackAudio.playSfx('sfx/correct.mp3');
    _speakSuccess();
    _scheduleAutoAdvance();
  }

  void _markWrong() {
    HapticFeedback.heavyImpact();
    _feedbackAudio.playWrongFeedback();
  }

  void _scheduleAutoAdvance() {
    final requestToken = ++_autoAdvanceToken;
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || requestToken != _autoAdvanceToken) return;
      if (_roundIndex == _totalRounds - 1) {
        _showFinalCelebration();
      } else {
        _goToNextRound();
      }
    });
  }

  void _handleTapChoice(int value) {
    if (_answerLocked || _showCelebration) return;
    setState(() {
      _selectedTapNumber = value;
    });
    if (value == _correctAnswer) {
      _markCorrect();
    } else {
      _markWrong();
      final requestToken = ++_autoAdvanceToken;
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || requestToken != _autoAdvanceToken) return;
        setState(() {
          _selectedTapNumber = null;
        });
      });
    }
  }

  void _handleDrop(int? value) {
    if (_answerLocked || _showCelebration || value == null) return;
    setState(() {
      _droppedNumber = value;
    });
    if (value == _correctAnswer) {
      _markCorrect();
    } else {
      _markWrong();
      final requestToken = ++_autoAdvanceToken;
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || requestToken != _autoAdvanceToken) return;
        setState(() {
          _droppedNumber = null;
        });
      });
    }
  }

  void _appendWriteDigit(int digit) {
    if (_answerLocked || _showCelebration || _writtenAnswer.length >= 2) return;
    setState(() {
      if (_writtenAnswer == '0') {
        _writtenAnswer = '$digit';
      } else {
        _writtenAnswer += '$digit';
      }
    });
  }

  void _backspaceWriteDigit() {
    if (_answerLocked || _showCelebration || _writtenAnswer.isEmpty) return;
    setState(() {
      _writtenAnswer = _writtenAnswer.substring(0, _writtenAnswer.length - 1);
    });
  }

  void _clearWrittenAnswer() {
    if (_answerLocked || _showCelebration || _writtenAnswer.isEmpty) return;
    setState(() {
      _writtenAnswer = '';
    });
  }

  void _checkWrittenAnswer() {
    if (_answerLocked || _showCelebration || _writtenAnswer.isEmpty) return;
    final parsed = int.tryParse(_writtenAnswer);
    if (parsed == _correctAnswer) {
      _markCorrect();
    } else {
      _markWrong();
    }
  }

  void _goToNextRound() {
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
      RewardModuleIds.miniQuiz,
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
    _celebrationController.dispose();
    _successPulseController.dispose();
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
                    child: AnimatedBuilder(
                      animation: _successPulseController,
                      builder: (context, child) {
                        final scale =
                            1 + ((_successPulseController.value - 1) * 0.03);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _buildActivityPanel(),
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
                'Mini Quiz',
                style: AppTypography.h1.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${_modeLabel(_currentRound.mode)} • Round ${_roundIndex + 1} of $_totalRounds',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF586374),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 96,
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
    final subtitle = switch (_currentRound.mode) {
      _QuizMode.tapNumber => 'Tap the correct number to answer the quiz.',
      _QuizMode.dragMatch =>
        'Drag the correct number card into the glowing drop zone.',
      _QuizMode.writeNumber =>
        'Count the objects and write the answer using the keypad.',
    };

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
              child: Text(_theme.emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question: $_correctAnswer ${_objectLabel(_correctAnswer)}',
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1A1060),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
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

  Widget _buildActivityPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _theme.color.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: switch (_currentRound.mode) {
        _QuizMode.tapNumber => _buildTapQuiz(),
        _QuizMode.dragMatch => _buildDragQuiz(),
        _QuizMode.writeNumber => _buildWriteQuiz(),
      },
    );
  }

  Widget _buildTapQuiz() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Tap number $_correctAnswer',
              style: AppTypography.h1.copyWith(
                fontSize: 40,
                color: _theme.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tapOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            final value = _tapOptions[index];
            final isSelected = _selectedTapNumber == value;
            final isCorrect = value == _correctAnswer;

            Color bgColor = Colors.white;
            Color borderColor = _theme.color.withValues(alpha: 0.20);

            if (isSelected && isCorrect) {
              bgColor = AppColors.correctFeedback.withValues(alpha: 0.48);
              borderColor = AppColors.gardenGreen;
            } else if (isSelected && !isCorrect) {
              bgColor = AppColors.incorrectFeedback.withValues(alpha: 0.36);
              borderColor = AppColors.incorrectFeedback;
            } else if (_roundSolved && isCorrect) {
              bgColor = AppColors.correctFeedback.withValues(alpha: 0.26);
              borderColor = AppColors.gardenGreen.withValues(alpha: 0.72);
            }

            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _handleTapChoice(value),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: AppTypography.numberDisplay.copyWith(
                        fontSize: 52,
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDragQuiz() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildObjectGroupCard(_correctAnswer)),
              const SizedBox(width: 12),
              Expanded(
                child: DragTarget<int>(
                  onWillAcceptWithDetails: (_) => !_answerLocked,
                  onAcceptWithDetails: (details) => _handleDrop(details.data),
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    final isCorrectDrop = _droppedNumber == _correctAnswer;
                    final isWrongDrop = _droppedNumber != null &&
                        _droppedNumber != _correctAnswer;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isCorrectDrop
                            ? AppColors.correctFeedback.withValues(alpha: 0.48)
                            : isWrongDrop
                                ? AppColors.incorrectFeedback
                                    .withValues(alpha: 0.30)
                                : _theme.softColor.withValues(
                                    alpha: isHovering ? 0.62 : 0.34,
                                  ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isCorrectDrop
                              ? AppColors.gardenGreen
                              : isWrongDrop
                                  ? AppColors.incorrectFeedback
                                  : _theme.color.withValues(alpha: 0.28),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _droppedNumber == null
                              ? 'Drop number here'
                              : '$_droppedNumber',
                          textAlign: TextAlign.center,
                          style: AppTypography.h1.copyWith(
                            color: const Color(0xFF1A1060),
                            fontWeight: FontWeight.w900,
                            fontSize: _droppedNumber == null ? 28 : 62,
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
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final cardWidth =
                (constraints.maxWidth - (spacing * (_dragOptions.length - 1))) /
                    _dragOptions.length;
            final cardHeight = math.min(
              96.0,
              math.max(76.0, cardWidth * 0.74),
            );

            return Row(
              children: _dragOptions.map((value) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: value == _dragOptions.last ? 0 : spacing,
                  ),
                  child: LongPressDraggable<int>(
                    data: value,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _DragNumberChip(
                        value: value,
                        color: _theme.color,
                        softColor: _theme.softColor,
                        shadowColor: _theme.shadowColor,
                        width: cardWidth,
                        height: cardHeight,
                        isFeedback: true,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _DragNumberChip(
                        value: value,
                        color: _theme.color,
                        softColor: _theme.softColor,
                        shadowColor: _theme.shadowColor,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                    onDragStarted: () {
                      setState(() {
                        _draggedNumber = value;
                      });
                    },
                    onDraggableCanceled: (_, __) {
                      setState(() {
                        _draggedNumber = null;
                      });
                    },
                    onDragEnd: (_) {
                      setState(() {
                        _draggedNumber = null;
                      });
                    },
                    child: _DragNumberChip(
                      value: value,
                      color: _theme.color,
                      softColor: _theme.softColor,
                      shadowColor: _theme.shadowColor,
                      width: cardWidth,
                      height: cardHeight,
                      isActive: _draggedNumber == value,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWriteQuiz() {
    final canCheck = _writtenAnswer.isNotEmpty && !_answerLocked;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildObjectGroupCard(_correctAnswer)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _theme.softColor.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _theme.color.withValues(alpha: 0.22),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Write the answer',
                            style: AppTypography.bodyStrong.copyWith(
                              color: _theme.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _writtenAnswer.isEmpty ? '_' : _writtenAnswer,
                            style: AppTypography.numberDisplay.copyWith(
                              fontSize: 72,
                              color: const Color(0xFF1A1060),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _writeKeypad.length + 2,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) {
                          if (index < _writeKeypad.length) {
                            final digit = _writeKeypad[index];
                            return _KeypadButton(
                              label: '$digit',
                              color: _theme.color,
                              softColor: _theme.softColor,
                              onTap: () => _appendWriteDigit(digit),
                            );
                          }
                          if (index == _writeKeypad.length) {
                            return _KeypadButton(
                              label: '⌫',
                              color: _theme.color,
                              softColor: _theme.softColor,
                              onTap: _backspaceWriteDigit,
                            );
                          }
                          return _KeypadButton(
                            label: 'C',
                            color: _theme.color,
                            softColor: _theme.softColor,
                            onTap: _clearWrittenAnswer,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _BottomButton(
          label: canCheck ? 'Check Answer' : 'Write Answer',
          color: canCheck ? _theme.color : AppColors.disabled,
          shadowColor: canCheck ? _theme.shadowColor : AppColors.disabled,
          onTap: canCheck ? _checkWrittenAnswer : null,
        ),
      ],
    );
  }

  Widget _buildObjectGroupCard(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: _theme.color.withValues(alpha: 0.22), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '$count ${_objectLabel(count)}',
            style: AppTypography.bodyStrong.copyWith(
              color: _theme.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = count <= 4 ? 2 : (count <= 8 ? 3 : 4);
                final rows = (count / columns).ceil();
                const spacing = 6.0;
                final itemSize = math.min(
                  46.0,
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
                          color: _theme.softColor.withValues(alpha: 0.46),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
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
    );
  }

  Widget _buildBottomBar() {
    final statusText = _roundSolved
        ? 'Great job! Next quiz is coming...'
        : 'Solve this round to keep your streak going.';

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
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _roundSolved
                  ? AppColors.correctFeedback.withValues(alpha: 0.56)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _roundSolved
                    ? AppColors.gardenGreen.withValues(alpha: 0.65)
                    : _theme.color.withValues(alpha: 0.18),
                width: 2,
              ),
            ),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: AppTypography.bodyStrong.copyWith(
                color: _roundSolved
                    ? AppColors.gardenGreen
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
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
          color: Colors.black.withValues(alpha: 0.40),
          child: SafeArea(
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: math.min(MediaQuery.of(context).size.width - 32, 390),
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
                          'All $_totalRounds Quiz Rounds Complete',
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
                        'Mini Quiz Complete!',
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You solved tap, drag, and write challenges like a quiz champion.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF556172),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      StartLearningNextActionButton(
                        currentRoute: AppRoutes.miniQuiz,
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

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: shadowColor, width: 2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyStrong.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _DragNumberChip extends StatelessWidget {
  const _DragNumberChip({
    required this.value,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    this.isActive = false,
    this.isFeedback = false,
    this.width,
    this.height,
  });

  final int value;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final bool isActive;
  final bool isFeedback;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? softColor : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 2),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.24),
            offset: Offset(0, isFeedback ? 10 : 6),
            blurRadius: isFeedback ? 18 : 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: AppTypography.numberDisplay.copyWith(
            fontSize: 44,
            color: const Color(0xFF1A1060),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    return isFeedback ? Transform.scale(scale: 1.0, child: card) : card;
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.22), width: 2),
            boxShadow: [
              BoxShadow(
                color: softColor.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.h2.copyWith(
                color: const Color(0xFF1A1060),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
