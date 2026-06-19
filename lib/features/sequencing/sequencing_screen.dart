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
import '../math_operations/math_operation_theme.dart';
import '../math_operations/math_operation_widgets.dart';

class _SequencingRound {
  const _SequencingRound({
    required this.sequence,
    required this.missingIndex,
    required this.correctAnswer,
    required this.options,
    required this.themeIndex,
    required this.stageLabel,
    required this.prompt,
  });

  final List<int> sequence;
  final int missingIndex;
  final int correctAnswer;
  final List<int> options;
  final int themeIndex;
  final String stageLabel;
  final String prompt;
}

class _SequenceConfig {
  const _SequenceConfig({
    required this.start,
    required this.length,
    required this.step,
    required this.allowEdgeGap,
    required this.stageLabel,
  });

  final int start;
  final int length;
  final int step;
  final bool allowEdgeGap;
  final String stageLabel;
}

class SequencingScreen extends StatefulWidget {
  const SequencingScreen({super.key});

  @override
  State<SequencingScreen> createState() => _SequencingScreenState();
}

class _SequencingScreenState extends State<SequencingScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _successPulseController;
  late final List<_SequencingRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int _wrongAttempts = 0;
  int? _filledAnswer;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _SequencingRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];
  bool get _showHint => _wrongAttempts >= 2;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _successPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
    _ttsReady = _configureTts();
    _rounds = _buildRoundPlan();
    _playScreenMusic(delayed: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  Future<void> _configureTts() async {
    await TtsVoiceHelper.configureSharedAudio(_tts);
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'en-GB'],
    );
    await _tts.setPitch(1.05);
    await _tts.setSpeechRate(0.42);
    await _tts.setVolume(1.0);
  }

  List<_SequencingRound> _buildRoundPlan() {
    const configs = <_SequenceConfig>[
      _SequenceConfig(
        start: 1,
        length: 4,
        step: 1,
        allowEdgeGap: false,
        stageLabel: 'Forward Order',
      ),
      _SequenceConfig(
        start: 2,
        length: 5,
        step: 1,
        allowEdgeGap: false,
        stageLabel: 'Forward Order',
      ),
      _SequenceConfig(
        start: 4,
        length: 5,
        step: 1,
        allowEdgeGap: true,
        stageLabel: 'Forward Order',
      ),
      _SequenceConfig(
        start: 6,
        length: 5,
        step: 1,
        allowEdgeGap: true,
        stageLabel: 'Forward Order',
      ),
      _SequenceConfig(
        start: 5,
        length: 4,
        step: -1,
        allowEdgeGap: false,
        stageLabel: 'Backward Order',
      ),
      _SequenceConfig(
        start: 7,
        length: 5,
        step: -1,
        allowEdgeGap: false,
        stageLabel: 'Backward Order',
      ),
      _SequenceConfig(
        start: 10,
        length: 5,
        step: -1,
        allowEdgeGap: true,
        stageLabel: 'Backward Order',
      ),
      _SequenceConfig(
        start: 9,
        length: 6,
        step: -1,
        allowEdgeGap: true,
        stageLabel: 'Backward Order',
      ),
    ];

    return List.generate(configs.length, (index) {
      final config = configs[index];
      final sequence = List.generate(
        config.length,
        (itemIndex) => config.start + (itemIndex * config.step),
      );
      final missingIndex = _pickMissingIndex(
        length: config.length,
        allowEdgeGap: config.allowEdgeGap,
      );
      final correctAnswer = sequence[missingIndex];

      return _SequencingRound(
        sequence: sequence,
        missingIndex: missingIndex,
        correctAnswer: correctAnswer,
        options: _buildOptions(correctAnswer),
        themeIndex: index % mathOperationThemes.length,
        stageLabel: config.stageLabel,
        prompt: config.step > 0
            ? 'Fill the missing number in order.'
            : 'Count backward and fill the gap.',
      );
    });
  }

  int _pickMissingIndex({required int length, required bool allowEdgeGap}) {
    if (allowEdgeGap) {
      return _random.nextInt(length);
    }
    return 1 + _random.nextInt(length - 2);
  }

  List<int> _buildOptions(int correct) {
    final candidates = <int>[
      correct - 2,
      correct - 1,
      correct + 1,
      correct + 2,
      correct - 3,
      correct + 3,
    ];
    final pool = <int>{correct};

    for (final candidate in candidates) {
      if (candidate >= 1 && candidate <= 10) {
        pool.add(candidate);
      }
      if (pool.length == 3) break;
    }

    var fallback = 1;
    while (pool.length < 3) {
      pool.add(fallback);
      fallback++;
    }

    final options = pool.toList()..shuffle(_random);
    return options;
  }

  void _playScreenMusic({bool delayed = false}) {
    final token = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted || token != _musicRequestToken || _showCelebration) {
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
    await _tts.speak(_round.prompt);
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${_round.correctAnswer}');
  }

  bool _willAcceptNumber(int data) {
    if (_roundSolved) return false;
    if (data != _round.correctAnswer) {
      _registerWrongAttempt();
      return false;
    }
    return true;
  }

  void _registerWrongAttempt() {
    HapticFeedback.lightImpact();
    _feedbackAudio.playWrongFeedback();
    if (mounted) {
      setState(() => _wrongAttempts++);
    }
  }

  void _placeAnswer(int value) {
    if (_roundSolved || _showCelebration || _filledAnswer != null) return;

    if (value != _round.correctAnswer) {
      _registerWrongAttempt();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _filledAnswer = value;
      _roundSolved = true;
      _wrongAttempts = 0;
    });
    _successPulseController.forward(from: 0);
    _feedbackAudio.playSfx('sfx/correct.mp3');
    _speakSuccess();

    final token = ++_autoAdvanceToken;
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted || token != _autoAdvanceToken) return;
      if (_roundIndex == _totalRounds - 1) {
        _showFinalCelebration();
      } else {
        setState(() {
          _roundIndex++;
          _roundSolved = false;
          _filledAnswer = null;
          _wrongAttempts = 0;
        });
        _speakPrompt();
      }
    });
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration) return;
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.sequencing,
    );
    AppAudioService.instance.playCelebrationMusic();
    setState(() => _showCelebration = true);
  }

  void _goBack() {
    _autoAdvanceToken++;
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    context.pop();
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
  void didPush() => _playScreenMusic(delayed: true);

  @override
  void didPopNext() {
    if (!_showCelebration) _playScreenMusic(delayed: true);
  }

  @override
  void didPushNext() => _stopScreenMusic();

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _musicRequestToken++;
    _autoAdvanceToken++;
    AppAudioService.instance.stopCelebrationMusic();
    AppAudioService.instance.stopBackgroundMusic();
    _tts.stop();
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
            child:
                Image.asset('assets/images/backround.png', fit: BoxFit.cover),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.26),
                  _theme.softColor.withValues(alpha: 0.36),
                  AppColors.background.withValues(alpha: 0.76),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      MathOpCircleButton(
                        icon: Icons.arrow_back_rounded,
                        color: _theme.color,
                        onTap: _goBack,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🪜 ${_roundIndex + 1}/$_totalRounds',
                          style: AppTypography.h2.copyWith(
                            color: const Color(0xFF1A1060),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      MathOpCircleButton(
                        icon: Icons.volume_up_rounded,
                        color: _theme.color,
                        onTap: _speakPrompt,
                      ),
                      const SizedBox(width: 8),
                      MathOpProgressPill(
                        color: _theme.color,
                        softColor: _theme.softColor,
                        progress: progress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _successPulseController,
                      builder: (context, child) {
                        final scale =
                            1 + ((_successPulseController.value - 1) * 0.03);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _buildPlayArea(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showCelebration)
            MathOpCelebrationOverlay(
              title: 'Great!',
              emoji: '🪜',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel: 'Patterns',
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.pushReplacement(AppRoutes.patterns);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _theme.color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPromptCard(),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _round.sequence.length; i++) ...[
                      if (i > 0) ...[
                        const SizedBox(width: 8),
                        Icon(
                          _round.stageLabel == 'Backward Order'
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          color: _theme.color.withValues(alpha: 0.65),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (i == _round.missingIndex)
                        _missingSlot()
                      else
                        _numberSlot(_round.sequence[i], filled: true),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_showHint) ...[
            const SizedBox(height: 10),
            _buildHintCard(),
          ],
          const SizedBox(height: 14),
          _optionsTray(),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _theme.softColor.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(_theme.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _round.stageLabel,
                  style: AppTypography.bodyStrong.copyWith(
                    color: _theme.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _round.prompt,
                  style: AppTypography.h3.copyWith(
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2D468)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Say the numbers in order and look at the ones beside the gap.',
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6E5600),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missingSlot() {
    final filled = _filledAnswer;
    if (filled != null) {
      return _numberSlot(filled, filled: true, highlight: true);
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => _willAcceptNumber(details.data),
      onAcceptWithDetails: (details) => _placeAnswer(details.data),
      builder: (context, candidate, rejected) {
        final active = _isDragging || candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: _theme.softColor.withValues(alpha: active ? 0.78 : 0.48),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  active ? _theme.color : _theme.color.withValues(alpha: 0.35),
              width: active ? 4 : 3,
            ),
          ),
          child: Center(
            child: Text(
              '?',
              style: AppTypography.numberDisplay.copyWith(
                fontSize: 38,
                color: _theme.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _numberSlot(int value,
      {required bool filled, bool highlight = false}) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: highlight
            ? _theme.color.withValues(alpha: 0.22)
            : _theme.color.withValues(alpha: filled ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              highlight ? _theme.color : _theme.color.withValues(alpha: 0.30),
          width: highlight ? 3 : 2,
        ),
      ),
      child: Center(
        child: Text(
          '$value',
          style: AppTypography.numberDisplay.copyWith(
            fontSize: 34,
            color: const Color(0xFF1A1060),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _optionsTray() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: _theme.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tap or drag the missing number',
            style: AppTypography.bodyStrong.copyWith(
              color: _theme.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _round.options.map((value) {
              final used = _filledAnswer == value;
              return _DraggableNumberTile(
                value: value,
                color: _theme.color,
                softColor: _theme.softColor,
                enabled: !used && !_roundSolved,
                onTap: () => _placeAnswer(value),
                onDragStarted: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isDragging = true);
                },
                onDragEnd: () {
                  if (mounted) {
                    setState(() => _isDragging = false);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DraggableNumberTile extends StatelessWidget {
  const _DraggableNumberTile({
    required this.value,
    required this.color,
    required this.softColor,
    required this.enabled,
    required this.onTap,
    this.onDragStarted,
    this.onDragEnd,
  });

  final int value;
  final Color color;
  final Color softColor;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    const size = 82.0;

    Widget tile({double scale = 1, bool ghost = false}) {
      return Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: ghost ? 0.24 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: enabled ? onTap : null,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [softColor, color.withValues(alpha: 0.35)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: AppTypography.numberDisplay.copyWith(
                      fontSize: 36,
                      color: const Color(0xFF1A1060),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!enabled) return tile(ghost: true);

    return Draggable<int>(
      data: value,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        child: tile(scale: 1.15),
      ),
      childWhenDragging: tile(ghost: true),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      child: tile(),
    );
  }
}
