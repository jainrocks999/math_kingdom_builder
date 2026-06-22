import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localization.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/audio_service.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../../shared/widgets/celebration_bear.dart';

class FindCorrectNumberScreen extends StatefulWidget {
  const FindCorrectNumberScreen({super.key});

  @override
  State<FindCorrectNumberScreen> createState() =>
      _FindCorrectNumberScreenState();
}

class _FindCorrectNumberScreenState extends State<FindCorrectNumberScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _postSuccessPause = Duration(milliseconds: 250);
  static const _speechSettleDelay = Duration(milliseconds: 80);

  late final FlutterTts _flutterTts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  bool _localizedStateInitialized = false;
  late final AnimationController _speakerPulseController;
  late final AnimationController _cardBounceController;
  late final AnimationController _celebrationController;
  late List<int> _roundOrder;

  static const _numberSystem = NumberSystem(
    color: AppColors.primary,
    softColor: AppColors.primaryLight,
    shadowColor: Color(0xFFC94A18),
    emoji: '🔢',
  );

  static const int _numberCount = 11;

  List<NumberData> _numbersFor(BuildContext context) {
    return List.generate(_numberCount, (index) {
      final digit = '$index';
      return NumberData(
        digit: digit,
        word: AppLocalization.numberWord(context, index),
        symbol: digit,
      );
    });
  }

  final AudioService _feedbackAudio = AudioService();

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _speechRequestToken = 0;
  int _currentRoundIndex = 0;
  List<int> _currentOptions = const [];
  int? _selectedOptionIndex;
  bool _answerLocked = false;
  bool _hasAnsweredCorrectly = false;
  bool _isSpeaking = false;
  bool _showCelebration = false;
  int _correctAnswersCount = 0;
  int _wrongAttemptsThisRound = 0;

  NumberSystem get _currentSystem => _numberSystem;
  List<NumberData> get _numbers => _numbersFor(context);
  List<int> get _currentRoundOrder => _roundOrder;
  int get _currentNumberIndex => _currentRoundOrder[_currentRoundIndex];
  NumberData get _currentNumber => _numbers[_currentNumberIndex];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _speakerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _cardBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _roundOrder = _buildRoundOrder(_numberCount);
    _ttsReady = Future<void>.value();
    _playScreenMusic(delayed: true);
  }

  Future<void> _initTts() async {
    await AppLocalization.configureTts(_flutterTts, context);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.05);
  }

  List<int> _buildRoundOrder(int totalItems) {
    final order = List<int>.generate(totalItems, (index) => index);
    order.shuffle();
    return order;
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
    if (mounted && _isSpeaking) {
      setState(() => _isSpeaking = false);
    } else {
      _isSpeaking = false;
    }
    _flutterTts.stop();
  }

  void _prepareQuestion({required bool autoSpeak}) {
    final allIndices =
        List<int>.generate(_numbers.length, (i) => i)
          ..remove(_currentNumberIndex)
          ..shuffle();

    final options = <int>[_currentNumberIndex, ...allIndices.take(3)]
      ..shuffle();

    setState(() {
      _currentOptions = options;
      _selectedOptionIndex = null;
      _answerLocked = false;
      _hasAnsweredCorrectly = false;
      _wrongAttemptsThisRound = 0;
    });

    if (autoSpeak) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _speakCurrentPrompt();
        }
      });
    }
  }

  Future<void> _speakCurrentPrompt() async {
    await _speakText(_currentNumber.word);
  }

  Future<void> _speakCorrectAppreciation() async {
    if (!mounted) return;
    await _speakText(
      context.tr(
        'learning.amazing_number',
        namedArgs: {'word': _currentNumber.word},
      ),
    );
  }

  Future<void> _speakText(String text) async {
    final token = ++_speechRequestToken;
    await _ttsReady;
    if (!mounted || token != _speechRequestToken) return;
    await _flutterTts.stop();
    if (!mounted || token != _speechRequestToken) return;
    await Future<void>.delayed(_speechSettleDelay);
    if (!mounted || token != _speechRequestToken) return;
    setState(() => _isSpeaking = true);
    if (!mounted || token != _speechRequestToken) return;
    try {
      await _flutterTts.speak(text);
    } finally {
      if (mounted && token == _speechRequestToken) {
        setState(() => _isSpeaking = false);
      }
    }
  }

  Future<void> _advanceAfterCorrectAnswer() async {
    final requestToken = ++_autoAdvanceToken;
    await _speakCorrectAppreciation();
    if (!mounted || requestToken != _autoAdvanceToken) return;
    await Future<void>.delayed(_postSuccessPause);
    if (!mounted || requestToken != _autoAdvanceToken) return;
    if (_currentRoundIndex == _numbers.length - 1) {
      _showCompletionCelebration();
    } else {
      _nextNumber();
    }
  }

  void _handleAnswerTap(int optionIndex) {
    if (_showCelebration || _answerLocked) return;

    final chosenIndex = _currentOptions[optionIndex];
    final isCorrect = chosenIndex == _currentNumberIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _answerLocked = true;
      if (isCorrect) {
        _hasAnsweredCorrectly = true;
        if (_correctAnswersCount < _currentRoundIndex + 1) {
          _correctAnswersCount = _currentRoundIndex + 1;
        }
      }
    });

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _cardBounceController.forward(from: 0);
      _feedbackAudio.playSfx('sfx/correct.mp3');
      _advanceAfterCorrectAnswer();
    } else {
      HapticFeedback.lightImpact();
      _feedbackAudio.playWrongFeedback();
      _speakWrongAnswerHint();
      final requestToken = ++_autoAdvanceToken;
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || requestToken != _autoAdvanceToken) return;
        setState(() {
          _wrongAttemptsThisRound++;
          _selectedOptionIndex = null;
          _answerLocked = false;
        });
      });
    }
  }

  Future<void> _speakWrongAnswerHint() async {
    if (!mounted) return;
    await _speakText(context.tr('learning.try_again_hear'));
  }

  void _nextNumber() {
    if (!_hasAnsweredCorrectly) return;

    if (_currentRoundIndex >= _numbers.length - 1) {
      _showCompletionCelebration();
      return;
    }

    _autoAdvanceToken++;
    setState(() {
      _currentRoundIndex++;
    });
    _prepareQuestion(autoSpeak: true);
    HapticFeedback.lightImpact();
  }

  void _previousNumber() {
    if (_currentRoundIndex == 0) return;

    _autoAdvanceToken++;
    _speechRequestToken++;
    _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _currentRoundIndex--;
    });
    _prepareQuestion(autoSpeak: false);
    HapticFeedback.lightImpact();
  }

  void _showCompletionCelebration() {
    if (_showCelebration) return;
    _stopAllAudioAndSpeech();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.findNumber,
    );
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0);
    AppAudioService.instance.playCelebrationMusic();
  }

  void _prepareNextLearningNavigation() {
    _autoAdvanceToken++;
    _stopAllAudioAndSpeech();
    setState(() {
      _showCelebration = false;
    });
  }

  void _goBackToLearningMenu() {
    _autoAdvanceToken++;
    _stopAllAudioAndSpeech();
    Navigator.of(context).pop();
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
      _ttsReady = _initTts();
    }
    if (!_localizedStateInitialized) {
      _localizedStateInitialized = true;
      _prepareQuestion(autoSpeak: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _speakCurrentPrompt();
        }
      });
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
    _speakerPulseController.dispose();
    _cardBounceController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactLayout = constraints.maxHeight < 860;

                if (compactLayout) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      16 + (MediaQuery.of(context).padding.bottom * 0.2),
                    ),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 12),
                          _buildProgressCard(),
                          const SizedBox(height: 12),
                          _buildLearningCard(),
                          const SizedBox(height: 12),
                          _buildAnswerSection(),
                          const SizedBox(height: 12),
                          _buildNavigationControls(),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    16 + (MediaQuery.of(context).padding.bottom * 0.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 12),
                      _buildProgressCard(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(child: _buildLearningCard()),
                            const SizedBox(height: 12),
                            _buildAnswerSection(),
                            const SizedBox(height: 12),
                            _buildNavigationControls(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          'assets/images/svg/math_kingdom_bg.svg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withValues(alpha: 0.18),
                _currentSystem.softColor.withValues(alpha: 0.24),
                AppColors.overlayScrim.withValues(alpha: 0.14),
                AppColors.restBackground.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: _goBackToLearningMenu,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text(
                AppLocalization.moduleTitle(context, AppRoutes.findNumber),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                ),
              ),
              Text(
                context.tr('learning.find_prompt'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: _currentSystem.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.premiumGold.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$_correctAnswersCount',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.premiumGold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final total = _numbers.length;
    final progress =
        (_currentRoundIndex + (_hasAnsweredCorrectly ? 1 : 0)) / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
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
                      'current': '${_currentRoundIndex + 1}',
                      'total': '$total',
                    },
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _hasAnsweredCorrectly
                    ? context.tr('learning.great_job')
                    : context.tr('learning.find_prompt'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: _hasAnsweredCorrectly
                      ? AppColors.gardenGreen
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(_currentSystem.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard() {
    return AnimatedBuilder(
      animation: _cardBounceController,
      builder: (context, child) {
        final scale = 1 +
            (_cardBounceController.value *
                0.04 *
                (1 - _cardBounceController.value));
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _currentSystem.color.withValues(alpha: 0.42),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _currentSystem.shadowColor.withValues(alpha: 0.55),
              offset: const Offset(0, 7),
              blurRadius: 0,
            ),
            BoxShadow(
              color: _currentSystem.color.withValues(alpha: 0.16),
              offset: const Offset(0, 16),
              blurRadius: 30,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            final hasBoundedHeight = constraints.maxHeight.isFinite;
            final tightLayout = screenHeight < 760 || screenWidth < 360;
            final cardHeight = hasBoundedHeight ? constraints.maxHeight : 0.0;
            final veryTightLayout =
                hasBoundedHeight && (cardHeight < 330 || screenHeight < 690);
            final compactCard =
                tightLayout || (hasBoundedHeight && cardHeight < 420);

            final horizontalPadding = veryTightLayout ? 14.0 : 18.0;
            final topPadding = veryTightLayout ? 14.0 : 20.0;
            final bottomPadding = veryTightLayout ? 14.0 : 22.0;
            final badgeHorizontalPadding = veryTightLayout ? 10.0 : 14.0;
            final badgeVerticalPadding = veryTightLayout ? 6.0 : 8.0;
            final badgeIconSize = veryTightLayout ? 14.0 : 16.0;
            final badgeFontSize = veryTightLayout ? 12.0 : 13.0;
            final speakerSize = veryTightLayout
                ? 44.0
                : compactCard
                    ? 52.0
                    : 64.0;
            final speakerIconSize = veryTightLayout
                ? 18.0
                : compactCard
                    ? 22.0
                    : 28.0;
            final instructionFontSize = veryTightLayout ? 12.0 : 14.0;
            final helperFontSize = veryTightLayout ? 12.0 : 14.0;
            final revealCardSize = veryTightLayout
                ? 94.0
                : compactCard
                    ? 124.0
                    : 160.0;
            final digitSize = veryTightLayout
                ? 48.0
                : compactCard
                    ? 62.0
                    : 86.0;
            final wordSize =
                veryTightLayout ? 20.0 : (compactCard ? 24.0 : 30.0);
            final mysterySize = veryTightLayout
                ? 44.0
                : compactCard
                    ? 58.0
                    : 76.0;
            final topSectionGap =
                veryTightLayout ? 8.0 : (compactCard ? 12.0 : 16.0);
            final helperGap = veryTightLayout ? 6.0 : 10.0;
            final resultGap =
                veryTightLayout ? 10.0 : (compactCard ? 14.0 : 22.0);
            final footerGap = veryTightLayout ? 8.0 : 14.0;
            final footerBearSize = veryTightLayout ? 34.0 : 44.0;
            final footerPadding = veryTightLayout ? 8.0 : 10.0;
            final footerFontSize =
                veryTightLayout ? 12.0 : (compactCard ? 13.0 : 14.0);
            final resultWidget = AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _hasAnsweredCorrectly
                  ? FittedBox(
                      key: ValueKey('answer_${_currentNumber.digit}'),
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentNumber.digit,
                            style: AppTypography.numberDisplay.copyWith(
                              color: _currentSystem.color,
                              fontSize: digitSize,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: veryTightLayout ? 2 : 4),
                          Text(
                            _currentNumber.word,
                            style: AppTypography.h2.copyWith(
                              color: _currentSystem.color,
                              fontWeight: FontWeight.w700,
                              fontSize: wordSize,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('mystery'),
                      width: revealCardSize,
                      height: revealCardSize,
                      decoration: BoxDecoration(
                        color: _currentSystem.softColor.withValues(alpha: 0.55),
                        borderRadius:
                            BorderRadius.circular(veryTightLayout ? 22 : 28),
                        border: Border.all(
                          color: _currentSystem.color.withValues(alpha: 0.18),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0,
                              veryTightLayout ? -2 : (compactCard ? -4 : -2)),
                          child: Text(
                            '?',
                            style: AppTypography.h1.copyWith(
                              color: _currentSystem.color,
                              fontSize: mysterySize,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
            );

            final footerWidget = AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _hasAnsweredCorrectly
                  ? Container(
                      key: ValueKey('praise_${_currentNumber.symbol}'),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: footerPadding,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.correctFeedback.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.gardenGreen.withValues(alpha: 0.55),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          CelebrationBear(size: footerBearSize),
                          SizedBox(width: veryTightLayout ? 8 : 10),
                          Expanded(
                            child: Text(
                              context.tr(
                                'learning.amazing_number',
                                namedArgs: {'word': _currentNumber.word},
                              ),
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyStrong.copyWith(
                                color: AppColors.gardenGreen,
                                fontSize: footerFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      _wrongAttemptsThisRound >= 2
                          ? context.tr('learning.try_again_hear')
                          : context.tr('learning.tap_to_hear'),
                      key: ValueKey('hint_$_wrongAttemptsThisRound'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: veryTightLayout ? 11.5 : 12.5,
                      ),
                    ),
            );

            final content = Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                mainAxisSize:
                    hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: badgeHorizontalPadding,
                            vertical: badgeVerticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: _currentSystem.softColor
                                .withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color:
                                  _currentSystem.color.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.hearing_rounded,
                                size: badgeIconSize,
                                color: _currentSystem.color,
                              ),
                              SizedBox(width: veryTightLayout ? 4 : 6),
                              Flexible(
                                child: Text(
                                  context.tr('learning.find_prompt'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: _currentSystem.color,
                                    fontSize: badgeFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: veryTightLayout ? 8 : 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _speakCurrentPrompt();
                          },
                          customBorder: const CircleBorder(),
                          child: AnimatedBuilder(
                            animation: _speakerPulseController,
                            builder: (context, child) {
                              final scale = _isSpeaking
                                  ? 1 + (_speakerPulseController.value * 0.08)
                                  : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              width: speakerSize,
                              height: speakerSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isSpeaking
                                      ? [
                                          _currentSystem.color,
                                          _currentSystem.shadowColor,
                                        ]
                                      : const [
                                          AppColors.info,
                                          AppColors.bridgeBlue,
                                        ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isSpeaking
                                      ? _currentSystem.softColor.withValues(
                                          alpha: 0.95,
                                        )
                                      : AppColors.surface.withValues(
                                          alpha: 0.65,
                                        ),
                                  width: _isSpeaking ? 4 : 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isSpeaking
                                            ? _currentSystem.shadowColor
                                            : AppColors.bridgeBlue)
                                        .withValues(alpha: 0.28),
                                    blurRadius: _isSpeaking ? 22 : 18,
                                    spreadRadius: _isSpeaking ? 3 : 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.volume_up_rounded,
                                size: speakerIconSize,
                                color: _currentSystem.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: topSectionGap),
                  Text(
                    context.tr('learning.find_prompt'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: instructionFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: helperGap),
                  Text(
                    _isSpeaking
                        ? context.tr('learning.listen')
                        : context.tr('learning.tap_to_hear'),
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.bridgeBlue,
                      fontSize: helperFontSize,
                    ),
                  ),
                  SizedBox(height: resultGap),
                  if (hasBoundedHeight)
                    Expanded(
                      child: Center(child: resultWidget),
                    )
                  else
                    Center(child: resultWidget),
                  SizedBox(height: footerGap),
                  if (hasBoundedHeight)
                    Flexible(
                      child: Center(child: footerWidget),
                    )
                  else
                    footerWidget,
                ],
              ),
            );

            return content;
          },
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('learning.find_prompt'),
            style: AppTypography.bodyStrong.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: isNarrow ? 92 : 104,
                ),
                itemBuilder: (context, index) {
                  return _buildAnswerCard(index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(int optionIndex) {
    final number = _numbers[_currentOptions[optionIndex]];
    final isSelected = optionIndex == _selectedOptionIndex;
    final isCorrect = _currentOptions[optionIndex] == _currentNumberIndex;
    final showHintHighlight =
        !_hasAnsweredCorrectly && _wrongAttemptsThisRound >= 2 && isCorrect;

    Color borderColor = _currentSystem.color.withValues(alpha: 0.25);
    Color backgroundColor = AppColors.surface;
    Color textColor = _currentSystem.color;

    if (isSelected && isCorrect) {
      borderColor = AppColors.correctFeedback;
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.4);
      textColor = const Color(0xFF2F7A63);
    } else if (isSelected && !isCorrect) {
      borderColor = AppColors.incorrectFeedback;
      backgroundColor = AppColors.incorrectFeedback.withValues(alpha: 0.35);
      textColor = const Color(0xFFC94A18);
    } else if (_hasAnsweredCorrectly && isCorrect) {
      borderColor = AppColors.correctFeedback.withValues(alpha: 0.72);
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.25);
      textColor = const Color(0xFF2F7A63);
    } else if (showHintHighlight) {
      borderColor = _currentSystem.color.withValues(alpha: 0.75);
      backgroundColor = _currentSystem.softColor.withValues(alpha: 0.7);
      textColor = _currentSystem.color;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleAnswerTap(optionIndex),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: textColor.withValues(
                  alpha: showHintHighlight ? 0.22 : 0.14,
                ),
                offset: const Offset(0, 7),
                blurRadius: showHintHighlight ? 18 : 14,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number.digit,
                style: AppTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                number.word,
                style: AppTypography.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: context.tr('learning.previous'),
            icon: Icons.arrow_back_rounded,
            onTap: _currentRoundIndex > 0 ? _previousNumber : null,
            backgroundColor: AppColors.surface.withValues(alpha: 0.92),
            foregroundColor: AppColors.textSecondary,
            borderColor: AppColors.outlineStrong,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: context.tr('learning.speaker'),
            icon: Icons.volume_up_rounded,
            onTap: _speakCurrentPrompt,
            backgroundColor: _currentSystem.color,
            foregroundColor: AppColors.surface,
            borderColor: _currentSystem.shadowColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final overlayCurve = CurvedAnimation(
          parent: _celebrationController,
          curve: Curves.easeOutCubic,
        );
        final bearCurve = CurvedAnimation(
          parent: _celebrationController,
          curve: const Interval(0.10, 0.90, curve: Curves.elasticOut),
        );
        final sparkleCurve = CurvedAnimation(
          parent: _celebrationController,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
        );
        final sparkleOpacity = sparkleCurve.value.clamp(0.0, 1.0);
        return Container(
          color: Colors.black.withValues(alpha: 0.28),
          child: Center(
            child: Transform.scale(
              scale: 0.88 + (overlayCurve.value * 0.12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withValues(alpha: 0.28),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.7 + (sparkleCurve.value * 0.3),
                          child: Opacity(
                            opacity: sparkleOpacity,
                            child: Container(
                              width: 142,
                              height: 142,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentSystem.softColor
                                    .withValues(alpha: 0.85),
                                boxShadow: [
                                  BoxShadow(
                                    color: _currentSystem.color
                                        .withValues(alpha: 0.18),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 16,
                          child: Opacity(
                            opacity: sparkleOpacity,
                            child: const Text(
                              '✨',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Opacity(
                            opacity: sparkleOpacity,
                            child: const Text(
                              '🎉',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, (1 - bearCurve.value) * 24),
                          child: Transform.scale(
                            scale: 0.82 + (bearCurve.value * 0.18),
                            child: const CelebrationBear(size: 120),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('learning.great_job'),
                      style: AppTypography.h1.copyWith(
                        color: AppColors.premiumGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('learning.finish_every_challenge'),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('learning.great_job'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    StartLearningNextActionButton(
                      currentRoute: AppRoutes.findNumber,
                      onPrepareNavigation: _prepareNextLearningNavigation,
                      builder: (context, label, onTap) {
                        return _ActionButton(
                          label: label,
                          icon: Icons.arrow_forward_rounded,
                          onTap: onTap,
                          backgroundColor: _currentSystem.color,
                          foregroundColor: AppColors.surface,
                          borderColor: _currentSystem.shadowColor,
                        );
                      },
                    ),
                  ],
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
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: foregroundColor,
                    fontSize: 14,
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

class NumberData {
  const NumberData({
    required this.digit,
    required this.word,
    required this.symbol,
  });

  final String digit;
  final String word;
  final String symbol;
}

class NumberSystem {
  const NumberSystem({
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.emoji,
  });

  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String emoji;
}
