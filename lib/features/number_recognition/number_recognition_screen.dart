import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/audio_service.dart';
import '../../core/utils/tts_voice_helper.dart';
import '../../shared/widgets/celebration_bear.dart';

class StateLearningScreen extends StatefulWidget {
  const StateLearningScreen({super.key});

  @override
  State<StateLearningScreen> createState() => _StateLearningScreenState();
}

class _StateLearningScreenState extends State<StateLearningScreen>
    with TickerProviderStateMixin {
  late final FlutterTts _flutterTts;
  late final Future<void> _ttsReady;
  late final AnimationController _speakerPulseController;
  late final AnimationController _cardBounceController;
  late final AnimationController _celebrationController;

  final List<NumberSystem> _numberSystems = [
    NumberSystem(
      name: 'English',
      locale: 'en-US',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: const Color(0xFFC94A18),
      emoji: '🇬🇧',
      numbers: [
        NumberData(digit: '0', word: 'Zero', symbol: '0'),
        NumberData(digit: '1', word: 'One', symbol: '1'),
        NumberData(digit: '2', word: 'Two', symbol: '2'),
        NumberData(digit: '3', word: 'Three', symbol: '3'),
        NumberData(digit: '4', word: 'Four', symbol: '4'),
        NumberData(digit: '5', word: 'Five', symbol: '5'),
        NumberData(digit: '6', word: 'Six', symbol: '6'),
        NumberData(digit: '7', word: 'Seven', symbol: '7'),
        NumberData(digit: '8', word: 'Eight', symbol: '8'),
        NumberData(digit: '9', word: 'Nine', symbol: '9'),
        NumberData(digit: '10', word: 'Ten', symbol: '10'),
      ],
    ),
    NumberSystem(
      name: 'Hindi',
      locale: 'hi-IN',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: const Color(0xFF2AADA4),
      emoji: '🇮🇳',
      numbers: [
        NumberData(digit: '०', word: 'Shunya', symbol: '0'),
        NumberData(digit: '१', word: 'Ek', symbol: '1'),
        NumberData(digit: '२', word: 'Do', symbol: '2'),
        NumberData(digit: '३', word: 'Teen', symbol: '3'),
        NumberData(digit: '४', word: 'Chaar', symbol: '4'),
        NumberData(digit: '५', word: 'Paanch', symbol: '5'),
        NumberData(digit: '६', word: 'Chhe', symbol: '6'),
        NumberData(digit: '७', word: 'Saat', symbol: '7'),
        NumberData(digit: '८', word: 'Aath', symbol: '8'),
        NumberData(digit: '९', word: 'Nau', symbol: '9'),
        NumberData(digit: '१०', word: 'Das', symbol: '10'),
      ],
    ),
    NumberSystem(
      name: 'Gujarati',
      locale: 'gu-IN',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: const Color(0xFFA888E8),
      emoji: '🇮🇳',
      numbers: [
        NumberData(digit: '૦', word: 'Shunya', symbol: '0'),
        NumberData(digit: '૧', word: 'Ek', symbol: '1'),
        NumberData(digit: '૨', word: 'Be', symbol: '2'),
        NumberData(digit: '૩', word: 'Tran', symbol: '3'),
        NumberData(digit: '૪', word: 'Chaar', symbol: '4'),
        NumberData(digit: '૫', word: 'Paanch', symbol: '5'),
        NumberData(digit: '૬', word: 'Chhah', symbol: '6'),
        NumberData(digit: '૭', word: 'Saat', symbol: '7'),
        NumberData(digit: '૮', word: 'Aath', symbol: '8'),
        NumberData(digit: '૯', word: 'Nav', symbol: '9'),
        NumberData(digit: '૧૦', word: 'Das', symbol: '10'),
      ],
    ),
  ];

  int _selectedSystemIndex = 0;
  int _currentNumberIndex = 0;
  List<int> _currentOptions = const [];
  int? _selectedOptionIndex;
  bool _hasAnsweredCorrectly = false;
  bool _isSpeaking = false;
  bool _showCelebration = false;
  int _correctAnswersCount = 0;

  NumberSystem get _currentSystem => _numberSystems[_selectedSystemIndex];
  NumberData get _currentNumber => _currentSystem.numbers[_currentNumberIndex];

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
    _ttsReady = _initTts();
    _prepareQuestion(autoSpeak: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakCurrentPrompt();
      }
    });
  }

  Future<void> _initTts() async {
    await TtsVoiceHelper.configureSharedAudio(_flutterTts);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(1.05);
    await TtsVoiceHelper.applyPreferredVoice(
      _flutterTts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'hi-IN', 'gu-IN'],
    );
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  void _prepareQuestion({required bool autoSpeak}) {
    final allIndices =
        List<int>.generate(_currentSystem.numbers.length, (i) => i)
          ..remove(_currentNumberIndex)
          ..shuffle();

    final options = <int>[_currentNumberIndex, ...allIndices.take(3)]
      ..shuffle();

    setState(() {
      _currentOptions = options;
      _selectedOptionIndex = null;
      _hasAnsweredCorrectly = false;
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
    await _ttsReady;
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    setState(() => _isSpeaking = true);
    await TtsVoiceHelper.applyPreferredVoice(
      _flutterTts,
      locale: _currentSystem.locale,
      fallbackLocales: const ['en-IN', 'hi-IN', 'gu-IN', 'en-US'],
    );
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.speak(_currentNumber.word);
  }

  void _handleAnswerTap(int optionIndex) {
    if (_showCelebration) return;

    final chosenIndex = _currentOptions[optionIndex];
    final isCorrect = chosenIndex == _currentNumberIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      if (isCorrect) {
        _hasAnsweredCorrectly = true;
        if (_correctAnswersCount < _currentNumberIndex + 1) {
          _correctAnswersCount = _currentNumberIndex + 1;
        }
      }
    });

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _cardBounceController.forward(from: 0);
      _speakCurrentPrompt();
      if (_currentNumberIndex == _currentSystem.numbers.length - 1) {
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!mounted || _showCelebration) return;
          if (!_hasAnsweredCorrectly) return;
          _showCompletionCelebration();
        });
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _nextNumber() {
    if (!_hasAnsweredCorrectly) return;

    if (_currentNumberIndex >= _currentSystem.numbers.length - 1) {
      _showCompletionCelebration();
      return;
    }

    setState(() {
      _currentNumberIndex++;
    });
    _prepareQuestion(autoSpeak: true);
    HapticFeedback.lightImpact();
  }

  void _previousNumber() {
    if (_currentNumberIndex == 0) return;

    setState(() {
      _currentNumberIndex--;
    });
    _prepareQuestion(autoSpeak: false);
    HapticFeedback.lightImpact();
  }

  void _showCompletionCelebration() {
    if (_showCelebration) return;
    _flutterTts.stop();
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0);
    AppAudioService.instance.playCelebrationMusic();
  }

  void _resetCurrentSystem() {
    AppAudioService.instance.stopCelebrationMusic();
    _flutterTts.stop();
    setState(() {
      _currentNumberIndex = 0;
      _correctAnswersCount = 0;
      _showCelebration = false;
    });
    _prepareQuestion(autoSpeak: true);
  }

  void _goBackToLearningMenu() {
    AppAudioService.instance.stopCelebrationMusic();
    _flutterTts.stop();
    Navigator.of(context).pop();
  }

  void _selectSystem(int index) {
    if (_selectedSystemIndex == index) return;

    AppAudioService.instance.stopCelebrationMusic();
    setState(() {
      _selectedSystemIndex = index;
      _currentNumberIndex = 0;
      _correctAnswersCount = 0;
      _showCelebration = false;
    });
    _prepareQuestion(autoSpeak: true);
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    AppAudioService.instance.stopCelebrationMusic();
    _flutterTts.stop();
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 16),
                        _buildSystemSelector(),
                        const SizedBox(height: 16),
                        _buildProgressCard(),
                        const SizedBox(height: 18),
                        _buildLearningCard(),
                        const SizedBox(height: 18),
                        _buildAnswerSection(),
                        const SizedBox(height: 18),
                        _buildNavigationControls(),
                      ],
                    ),
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
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              'Number Recognition',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
            ),
            Text(
              _currentSystem.name,
              style: AppTypography.bodySmall.copyWith(
                color: _currentSystem.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
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

  Widget _buildSystemSelector() {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _numberSystems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final system = _numberSystems[index];
          final isSelected = index == _selectedSystemIndex;

          return GestureDetector(
            onTap: () => _selectSystem(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? system.color
                    : AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? system.color
                      : system.color.withValues(alpha: 0.35),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: system.color.withValues(alpha: 0.24),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [
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
                  Text(system.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    system.name,
                    style: AppTypography.bodyStrong.copyWith(
                      color: isSelected ? AppColors.surface : system.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard() {
    final total = _currentSystem.numbers.length;
    final progress =
        (_currentNumberIndex + (_hasAnsweredCorrectly ? 1 : 0)) / total;

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
              Text(
                'Number ${_currentNumberIndex + 1} of $total',
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                _hasAnsweredCorrectly ? 'Correct!' : 'Listen carefully',
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
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _currentSystem.softColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _currentSystem.color.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hearing_rounded,
                      size: 18, color: _currentSystem.color),
                  const SizedBox(width: 6),
                  Text(
                    'Listen and choose',
                    style: AppTypography.bodyStrong.copyWith(
                      color: _currentSystem.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the speaker and pick the correct number.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _speakCurrentPrompt,
              child: AnimatedBuilder(
                animation: _speakerPulseController,
                builder: (context, child) {
                  final scale = _isSpeaking
                      ? 1 + (_speakerPulseController.value * 0.08)
                      : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.info, AppColors.bridgeBlue],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: 0.65),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bridgeBlue.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 46,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isSpeaking ? 'Listening...' : 'Tap to hear again',
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.bridgeBlue,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 26),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _hasAnsweredCorrectly
                  ? Column(
                      key: ValueKey('answer_${_currentNumber.digit}'),
                      children: [
                        Text(
                          _currentNumber.digit,
                          style: AppTypography.numberDisplay.copyWith(
                            color: _currentSystem.color,
                            fontSize: 86,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentNumber.word,
                          style: AppTypography.h2.copyWith(
                            color: _currentSystem.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      key: const ValueKey('mystery'),
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: _currentSystem.softColor.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _currentSystem.color.withValues(alpha: 0.18),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: AppTypography.numberDisplay.copyWith(
                            color: _currentSystem.color,
                            fontSize: 88,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
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
            'Which number did you hear?',
            style: AppTypography.bodyStrong.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              return _buildAnswerCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(int optionIndex) {
    final number = _currentSystem.numbers[_currentOptions[optionIndex]];
    final isSelected = optionIndex == _selectedOptionIndex;
    final isCorrect = _currentOptions[optionIndex] == _currentNumberIndex;

    Color borderColor = _currentSystem.color.withValues(alpha: 0.25);
    Color backgroundColor = AppColors.surface;
    Color textColor = _currentSystem.color;

    if (isSelected && isCorrect) {
      borderColor = AppColors.gardenGreen;
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.4);
      textColor = AppColors.gardenGreen;
    } else if (isSelected && !isCorrect) {
      borderColor = AppColors.incorrectFeedback;
      backgroundColor = AppColors.incorrectFeedback.withValues(alpha: 0.35);
      textColor = const Color(0xFFC94A18);
    } else if (_hasAnsweredCorrectly && isCorrect) {
      borderColor = AppColors.gardenGreen.withValues(alpha: 0.7);
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.25);
      textColor = AppColors.gardenGreen;
    }

    return GestureDetector(
      onTap: () => _handleAnswerTap(optionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: textColor.withValues(alpha: 0.14),
              offset: const Offset(0, 7),
              blurRadius: 14,
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
    );
  }

  Widget _buildNavigationControls() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Previous',
            icon: Icons.arrow_back_rounded,
            onTap: _currentNumberIndex > 0 ? _previousNumber : null,
            backgroundColor: AppColors.surface.withValues(alpha: 0.92),
            foregroundColor: AppColors.textSecondary,
            borderColor: AppColors.outlineStrong,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: _currentNumberIndex == _currentSystem.numbers.length - 1
                ? 'Finish'
                : 'Next',
            icon: Icons.arrow_forward_rounded,
            onTap: _hasAnsweredCorrectly ? _nextNumber : null,
            backgroundColor: _hasAnsweredCorrectly
                ? _currentSystem.color
                : AppColors.disabled,
            foregroundColor: AppColors.surface,
            borderColor: _hasAnsweredCorrectly
                ? _currentSystem.shadowColor
                : AppColors.disabled,
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
                            opacity: sparkleCurve.value,
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
                            opacity: sparkleCurve.value,
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
                            opacity: sparkleCurve.value,
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
                      'Amazing!',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.premiumGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You finished all ${_currentSystem.name} numbers.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bear is clapping for your smart work!',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Go Back',
                            icon: Icons.arrow_back_rounded,
                            onTap: _goBackToLearningMenu,
                            backgroundColor:
                                AppColors.surface.withValues(alpha: 0.96),
                            foregroundColor: AppColors.textSecondary,
                            borderColor: AppColors.outlineStrong,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            label: 'Re-learn',
                            icon: Icons.replay_rounded,
                            onTap: _resetCurrentSystem,
                            backgroundColor: _currentSystem.color,
                            foregroundColor: AppColors.surface,
                            borderColor: _currentSystem.shadowColor,
                          ),
                        ),
                      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
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
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          children: [
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyStrong.copyWith(
                color: foregroundColor,
                fontSize: 14,
              ),
            ),
          ],
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
    required this.name,
    required this.locale,
    required this.numbers,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.emoji,
  });

  final String name;
  final String locale;
  final List<NumberData> numbers;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String emoji;
}
