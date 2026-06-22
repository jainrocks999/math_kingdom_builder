import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localization.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/audio_service.dart';
import '../../shared/widgets/celebration_bear.dart';

class _TraceStrokeTemplate {
  const _TraceStrokeTemplate({
    required this.points,
    required this.promptKey,
  });

  final List<Offset> points;
  final String promptKey;
}

class _TraceLesson {
  const _TraceLesson({
    required this.value,
    required this.word,
    required this.display,
    required this.strokes,
    required this.color,
    required this.softColor,
    required this.shadowColor,
  });

  final int value;
  final String word;
  final String display;
  final List<_TraceStrokeTemplate> strokes;
  final Color color;
  final Color softColor;
  final Color shadowColor;
}

class TraceNumbersScreen extends StatefulWidget {
  const TraceNumbersScreen({super.key});

  @override
  State<TraceNumbersScreen> createState() => _TraceNumbersScreenState();
}

class _TraceNumbersScreenState extends State<TraceNumbersScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  static const int _maxProgressJump = 6;
  static const int _ghostHintFailureThreshold = 2;
  static const Duration _postSuccessPause = Duration(milliseconds: 250);
  static const Duration _speechSettleDelay = Duration(milliseconds: 80);

  final AudioService _audioService = AudioService();

  static const List<_TraceLesson> _lessons = [
    _TraceLesson(
      value: 0,
      word: 'zero',
      display: '0',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'round_loop',
          points: [
            Offset(0.50, 0.10),
            Offset(0.72, 0.16),
            Offset(0.86, 0.34),
            Offset(0.88, 0.58),
            Offset(0.76, 0.82),
            Offset(0.50, 0.90),
            Offset(0.24, 0.82),
            Offset(0.12, 0.58),
            Offset(0.14, 0.34),
            Offset(0.28, 0.16),
            Offset(0.50, 0.10),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 1,
      word: 'one',
      display: '1',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'slide_down',
          points: [
            Offset(0.36, 0.28),
            Offset(0.50, 0.12),
            Offset(0.50, 0.88),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 2,
      word: 'two',
      display: '2',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'curve_top_swoop',
          points: [
            Offset(0.20, 0.25),
            Offset(0.36, 0.12),
            Offset(0.64, 0.12),
            Offset(0.82, 0.28),
            Offset(0.76, 0.44),
            Offset(0.58, 0.60),
            Offset(0.36, 0.78),
            Offset(0.20, 0.88),
            Offset(0.82, 0.88),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 3,
      word: 'three',
      display: '3',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'two_belly_curves',
          points: [
            Offset(0.24, 0.18),
            Offset(0.48, 0.12),
            Offset(0.76, 0.22),
            Offset(0.62, 0.44),
            Offset(0.40, 0.50),
            Offset(0.64, 0.58),
            Offset(0.80, 0.76),
            Offset(0.54, 0.88),
            Offset(0.24, 0.82),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 4,
      word: 'four',
      display: '4',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'roof_line',
          points: [
            Offset(0.72, 0.12),
            Offset(0.28, 0.56),
            Offset(0.84, 0.56),
          ],
        ),
        _TraceStrokeTemplate(
          promptKey: 'standing_line',
          points: [
            Offset(0.72, 0.12),
            Offset(0.72, 0.90),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 5,
      word: 'five',
      display: '5',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'across_tummy',
          points: [
            Offset(0.80, 0.14),
            Offset(0.32, 0.14),
            Offset(0.28, 0.48),
            Offset(0.58, 0.48),
            Offset(0.78, 0.60),
            Offset(0.72, 0.84),
            Offset(0.34, 0.88),
            Offset(0.18, 0.76),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 6,
      word: 'six',
      display: '6',
      color: AppColors.gardenGreen,
      softColor: AppColors.success,
      shadowColor: Color(0xFF3A9040),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'loop_tuck',
          points: [
            Offset(0.76, 0.18),
            Offset(0.50, 0.14),
            Offset(0.24, 0.34),
            Offset(0.18, 0.62),
            Offset(0.34, 0.84),
            Offset(0.60, 0.84),
            Offset(0.76, 0.66),
            Offset(0.62, 0.50),
            Offset(0.36, 0.54),
            Offset(0.22, 0.70),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 7,
      word: 'seven',
      display: '7',
      color: AppColors.parentAccent,
      softColor: AppColors.parentBackground,
      shadowColor: Color(0xFF3A58C8),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'slide_slant',
          points: [
            Offset(0.18, 0.16),
            Offset(0.82, 0.16),
            Offset(0.44, 0.90),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 8,
      word: 'eight',
      display: '8',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'top_loop',
          points: [
            Offset(0.50, 0.12),
            Offset(0.68, 0.18),
            Offset(0.74, 0.34),
            Offset(0.50, 0.46),
            Offset(0.28, 0.34),
            Offset(0.32, 0.18),
            Offset(0.50, 0.12),
          ],
        ),
        _TraceStrokeTemplate(
          promptKey: 'bottom_loop',
          points: [
            Offset(0.50, 0.46),
            Offset(0.76, 0.58),
            Offset(0.72, 0.82),
            Offset(0.50, 0.90),
            Offset(0.28, 0.82),
            Offset(0.24, 0.58),
            Offset(0.50, 0.46),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 9,
      word: 'nine',
      display: '9',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'round_head',
          points: [
            Offset(0.42, 0.14),
            Offset(0.68, 0.20),
            Offset(0.78, 0.42),
            Offset(0.58, 0.56),
            Offset(0.32, 0.50),
            Offset(0.24, 0.28),
            Offset(0.42, 0.14),
          ],
        ),
        _TraceStrokeTemplate(
          promptKey: 'tall_tail',
          points: [
            Offset(0.72, 0.22),
            Offset(0.76, 0.88),
          ],
        ),
      ],
    ),
    _TraceLesson(
      value: 10,
      word: 'ten',
      display: '10',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      strokes: [
        _TraceStrokeTemplate(
          promptKey: 'trace_one_first',
          points: [
            Offset(0.25, 0.22),
            Offset(0.36, 0.12),
            Offset(0.36, 0.88),
          ],
        ),
        _TraceStrokeTemplate(
          promptKey: 'zero_loop',
          points: [
            Offset(0.72, 0.14),
            Offset(0.84, 0.22),
            Offset(0.90, 0.50),
            Offset(0.82, 0.80),
            Offset(0.68, 0.88),
            Offset(0.56, 0.80),
            Offset(0.50, 0.50),
            Offset(0.58, 0.22),
            Offset(0.72, 0.14),
          ],
        ),
      ],
    ),
  ];

  final Set<int> _completedLessons = <int>{};
  late final FlutterTts _tts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  bool _localizedStateInitialized = false;
  late final AnimationController _celebrationController;

  int _currentLessonIndex = 0;
  int _currentStrokeIndex = 0;
  int _currentProgressIndex = 0;
  bool _isTracing = false;
  bool _lessonComplete = false;
  bool _showFinalCelebration = false;
  bool _showGhostHint = false;
  List<List<Offset>> _completedStrokePaths = <List<Offset>>[];
  List<Offset> _activeStrokePath = <Offset>[];
  String _statusText = '';
  int _strokeFailureCount = 0;
  int _celebrationToken = 0;
  int _finalCelebrationToken = 0;
  int _musicRequestToken = 0;
  int _speechRequestToken = 0;
  int _autoAdvanceToken = 0;

  _TraceLesson get _lesson => _lessons[_currentLessonIndex];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _ttsReady = Future<void>.value();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _playScreenMusic(delayed: true);
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
    if (!_localizedStateInitialized) {
      _localizedStateInitialized = true;
      _resetLessonState(speakPrompt: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _speakLessonPrompt(includeStrokeHint: true);
      });
    }
  }

  @override
  void didPopNext() {
    _playScreenMusic(delayed: true);
  }

  @override
  void didPush() {
    _playScreenMusic(delayed: true);
  }

  @override
  void didPushNext() {
    _stopAllAudioAndSpeech();
  }

  Future<void> _configureTts() async {
    await AppLocalization.configureTts(
      _tts,
      context,
      normalRate: 0.36,
      slowRate: 0.28,
    );
    await _tts.awaitSpeakCompletion(true);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
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

  Future<void> _speakLessonPrompt({bool includeStrokeHint = false}) async {
    final word = AppLocalization.numberWord(context, _lesson.value);
    final strokeHint = includeStrokeHint
        ? ' ${context.tr('trace_strokes.${_lesson.strokes[_currentStrokeIndex].promptKey}')}'
        : '';
    await _speakText('${context.tr('learning.trace_prompt')} $word.$strokeHint');
  }

  Future<void> _speakSuccess() async {
    final word = AppLocalization.numberWord(context, _lesson.value);
    await _speakText(
      context.tr('learning.amazing_number', namedArgs: {'word': word}),
    );
  }

  void _playScreenMusic({bool delayed = false}) {
    final requestToken = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted || requestToken != _musicRequestToken) return;
        if (_showFinalCelebration) return;
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
    _autoAdvanceToken++;
    _tts.stop();
  }

  void _resetLessonState({bool speakPrompt = true}) {
    _currentStrokeIndex = 0;
    _currentProgressIndex = 0;
    _isTracing = false;
    _lessonComplete = false;
    _showGhostHint = false;
    _completedStrokePaths = <List<Offset>>[];
    _activeStrokePath = <Offset>[];
    _statusText = _promptForCurrentStroke();
    _strokeFailureCount = 0;
    if (speakPrompt) {
      _speakLessonPrompt(includeStrokeHint: true);
    }
  }

  String _promptForCurrentStroke() {
    final strokeNumber = _currentStrokeIndex + 1;
    final prompt = context.tr(
      'trace_strokes.${_lesson.strokes[_currentStrokeIndex].promptKey}',
    );
    return context.tr(
      'learning.trace_stroke_line',
      namedArgs: {
        'stroke': '$strokeNumber',
        'prompt': prompt,
        'hear_again': context.tr('learning.tap_to_hear'),
      },
    );
  }

  void _goToLesson(int index) {
    if (index < 0 || index >= _lessons.length) return;
    _celebrationToken++;
    _finalCelebrationToken++;
    _stopAllAudioAndSpeech();
    setState(() {
      _currentLessonIndex = index;
      _showFinalCelebration = false;
      _resetLessonState(speakPrompt: false);
    });
    HapticFeedback.selectionClick();
    _playScreenMusic(delayed: true);
    _speakLessonPrompt(includeStrokeHint: true);
  }

  void _goNextLesson() {
    if (_currentLessonIndex == _lessons.length - 1) {
      _goToLesson(0);
      return;
    }
    _goToLesson(_currentLessonIndex + 1);
  }

  Future<void> _advanceAfterSuccessSpeech() async {
    final requestToken = ++_autoAdvanceToken;
    await _speakSuccess();
    if (!mounted || requestToken != _autoAdvanceToken) return;
    await Future<void>.delayed(_postSuccessPause);
    if (!mounted || requestToken != _autoAdvanceToken) return;
    if (!_lessonComplete || _currentLessonIndex >= _lessons.length - 1) return;
    _goNextLesson();
  }

  void _showTracingCourseCelebration() {
    if (_showFinalCelebration) return;
    _tts.stop();
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.traceNumbers,
    );
    AppAudioService.instance.playCelebrationMusic();
    setState(() => _showFinalCelebration = true);
  }

  void _prepareNextLearningNavigation() {
    _stopAllAudioAndSpeech();
    _finalCelebrationToken++;
    setState(() {
      _showFinalCelebration = false;
    });
  }

  void _handleBackNavigation() {
    _celebrationToken++;
    _finalCelebrationToken++;
    _stopAllAudioAndSpeech();
    if (_showFinalCelebration && mounted) {
      setState(() {
        _showFinalCelebration = false;
      });
    }
    context.pop();
  }

  void _handlePanStart(Offset position, Size size) {
    if (_lessonComplete) return;
    final samples = _strokeSamples(size, _lesson.strokes[_currentStrokeIndex]);
    final start = samples.first;
    final tolerance = _startTolerance(size);
    if ((position - start).distance > tolerance) {
      _registerTracingFailure(
        context.tr(
          'learning.trace_start_from_dot',
          namedArgs: {
            'word': AppLocalization.numberWord(context, _lesson.value),
          },
        ),
      );
      return;
    }

    setState(() {
      _isTracing = true;
      _currentProgressIndex = 0;
      _activeStrokePath = <Offset>[start, position];
      _statusText = context.tr('learning.trace_follow_path');
    });
    HapticFeedback.lightImpact();
  }

  void _handlePanUpdate(Offset position, Size size) {
    if (!_isTracing || _lessonComplete) return;
    final samples = _strokeSamples(size, _lesson.strokes[_currentStrokeIndex]);
    final tolerance = _followTolerance(size);
    var furthestIndex = _currentProgressIndex;
    final searchEnd = math.min(
      samples.length - 1,
      _currentProgressIndex + _maxProgressJump,
    );

    for (var i = _currentProgressIndex; i <= searchEnd; i++) {
      if ((position - samples[i]).distance <= tolerance) {
        furthestIndex = i;
      }
    }

    final nearCurrent = (position - samples[_currentProgressIndex]).distance <=
        tolerance * 1.35;
    if (!nearCurrent && furthestIndex == _currentProgressIndex) {
      return;
    }

    setState(() {
      _activeStrokePath = <Offset>[..._activeStrokePath, position];
      _currentProgressIndex = furthestIndex;
      if (_progressForCurrentStroke(size) > 0.72 && !_lessonComplete) {
        _statusText = context.tr('learning.trace_almost_there');
      }
    });

    if (_canCompleteStroke(size, furthestIndex)) {
      _completeCurrentStroke(size);
    }
  }

  void _handlePanEnd(Size size) {
    if (!_isTracing) return;
    if (_canCompleteStroke(size, _currentProgressIndex)) {
      _completeCurrentStroke(size);
      return;
    }

    _registerTracingFailure(context.tr('learning.trace_try_again_stroke'));
  }

  void _registerTracingFailure(String message) {
    final nextFailureCount = _strokeFailureCount + 1;
    final shouldShowHint = nextFailureCount >= _ghostHintFailureThreshold;
    setState(() {
      _statusText = shouldShowHint
          ? '$message ${context.tr('learning.trace_ghost_helper_on')}'
          : message;
      _isTracing = false;
      _currentProgressIndex = 0;
      _activeStrokePath = <Offset>[];
      _strokeFailureCount = nextFailureCount;
      _showGhostHint = shouldShowHint;
    });
    HapticFeedback.selectionClick();
    _audioService.playWrongFeedback();
  }

  void _completeCurrentStroke(Size size) {
    if (!_isTracing && _activeStrokePath.isEmpty) return;
    final strokePath = List<Offset>.from(_activeStrokePath);
    final isLastStroke = _currentStrokeIndex == _lesson.strokes.length - 1;
    setState(() {
      _completedStrokePaths = <List<Offset>>[
        ..._completedStrokePaths,
        strokePath
      ];
      _activeStrokePath = <Offset>[];
      _currentProgressIndex = 0;
      _isTracing = false;
      if (isLastStroke) {
        _lessonComplete = true;
        _completedLessons.add(_currentLessonIndex);
        _statusText = context.tr(
          'learning.trace_number_complete',
          namedArgs: {'display': _lesson.display},
        );
        _celebrationToken++;
        _showGhostHint = false;
        _strokeFailureCount = 0;
      } else {
        _currentStrokeIndex++;
        _statusText = _promptForCurrentStroke();
        _showGhostHint = false;
        _strokeFailureCount = 0;
      }
    });

    if (isLastStroke) {
      _celebrationController.forward(from: 0);
      HapticFeedback.heavyImpact();
      if (_currentLessonIndex != _lessons.length - 1) {
        AppAudioService.instance.playCelebrationMusic();
        _advanceAfterSuccessSpeech();
      }
      if (_currentLessonIndex == _lessons.length - 1) {
        final celebrationToken = ++_finalCelebrationToken;
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (!mounted || celebrationToken != _finalCelebrationToken) return;
          if (!_lessonComplete || _currentLessonIndex != _lessons.length - 1) {
            return;
          }
          _showTracingCourseCelebration();
        });
      }
    } else {
      HapticFeedback.mediumImpact();
      _speakLessonPrompt(includeStrokeHint: true);
    }
  }

  double _progressForCurrentStroke(Size size) {
    final samples = _strokeSamples(size, _lesson.strokes[_currentStrokeIndex]);
    if (samples.length <= 1) return 0;
    return _currentProgressIndex / (samples.length - 1);
  }

  bool _canCompleteStroke(Size size, int progressIndex) {
    final samples = _strokeSamples(size, _lesson.strokes[_currentStrokeIndex]);
    if (samples.length <= 1 || _activeStrokePath.length < 8) return false;
    final progress = progressIndex / (samples.length - 1);
    final tracedDistance = _pathDistance(_activeStrokePath);
    final requiredDistance = _pathDistance(samples) * 0.52;
    return progress >= 0.96 && tracedDistance >= requiredDistance;
  }

  double _startTolerance(Size size) =>
      (size.shortestSide * 0.075).clamp(22.0, 34.0);

  double _followTolerance(Size size) =>
      (size.shortestSide * 0.060).clamp(18.0, 28.0);

  double _pathDistance(List<Offset> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  List<List<Offset>> _allStrokeSamples(Size size) {
    return _lesson.strokes
        .map((stroke) => _strokeSamples(size, stroke))
        .toList();
  }

  List<Offset> _strokeSamples(Size size, _TraceStrokeTemplate stroke) {
    final padding = size.shortestSide * 0.12;
    final drawRect = Rect.fromLTWH(
      padding,
      padding,
      size.width - (padding * 2),
      size.height - (padding * 2),
    );
    final scaledPoints = stroke.points
        .map(
          (point) => Offset(
            drawRect.left + (point.dx * drawRect.width),
            drawRect.top + (point.dy * drawRect.height),
          ),
        )
        .toList();
    return _samplePolyline(scaledPoints);
  }

  List<Offset> _samplePolyline(List<Offset> anchors) {
    if (anchors.length < 2) return anchors;
    final points = <Offset>[anchors.first];
    for (var i = 0; i < anchors.length - 1; i++) {
      final start = anchors[i];
      final end = anchors[i + 1];
      final distance = (end - start).distance;
      final steps = math.max(2, (distance / 8).ceil());
      for (var step = 1; step <= steps; step++) {
        final t = step / steps;
        points.add(Offset.lerp(start, end, t)!);
      }
    }
    return points;
  }

  @override
  void dispose() {
    _finalCelebrationToken++;
    appRouteObserver.unsubscribe(this);
    _stopAllAudioAndSpeech();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonProgress = (_currentLessonIndex + 1) / _lessons.length;
    final earnedStars = _completedLessons.length;

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
                  Colors.white.withValues(alpha: 0.30),
                  _lesson.softColor.withValues(alpha: 0.28),
                  AppColors.background.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 780;
                final boardSize = math.min(
                  constraints.maxWidth - 24,
                  math.max(
                    isCompact ? 308.0 : 340.0,
                    constraints.maxHeight * (isCompact ? 0.52 : 0.58),
                  ),
                );

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    isCompact ? 8 : 10,
                    18,
                    (isCompact ? 12 : 14) +
                        MediaQuery.of(context).padding.bottom * 0.2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(
                        context,
                        isCompact: isCompact,
                        lessonProgress: lessonProgress,
                        earnedStars: earnedStars,
                      ),
                      SizedBox(height: isCompact ? 6 : 8),
                      Expanded(
                        child: _buildTracingCard(
                          boardSize,
                          isCompact: isCompact,
                        ),
                      ),
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

  Widget _buildTopBar(
    BuildContext context, {
    required bool isCompact,
    required double lessonProgress,
    required int earnedStars,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CircleIconButton(
              icon: Icons.arrow_back_rounded,
              color: _lesson.color,
              onTap: _handleBackNavigation,
              size: isCompact ? 42 : 46,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.moduleTitle(context, AppRoutes.tracing),
                    style: AppTypography.h1.copyWith(
                      fontSize: isCompact ? 22 : 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1060),
                    ),
                  ),
                  Text(
                    AppLocalization.moduleSubtitle(context, AppRoutes.tracing),
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF586374),
                    ),
                  ),
                  Text(
                    '${context.tr('learning.trace_prompt')} ${context.tr('learning.tap_to_hear')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: isCompact ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7A849A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _CircleIconButton(
              icon: Icons.volume_up_rounded,
              color: _lesson.color,
              onTap: () => _speakLessonPrompt(includeStrokeHint: true),
              size: isCompact ? 42 : 46,
            ),
          ],
        ),
        SizedBox(height: isCompact ? 8 : 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeaderChip(
              icon: Icons.flag_rounded,
              label: '${_currentLessonIndex + 1}/${_lessons.length}',
              background: Colors.white.withValues(alpha: 0.92),
              foreground: const Color(0xFF4E5868),
            ),
            _HeaderChip(
              icon: Icons.star_rounded,
              label: '$earnedStars',
              background: AppColors.premiumGoldLight,
              foreground: const Color(0xFF8A6000),
            ),
            _HeaderChip(
              icon: Icons.bar_chart_rounded,
              label: '${(lessonProgress * 100).round()}%',
              background: _lesson.softColor,
              foreground: _lesson.color,
            ),
            _HeaderActionChip(
              icon: Icons.arrow_back_rounded,
              label: context.tr('learning.next'),
              foreground: _currentLessonIndex > 0
                  ? const Color(0xFF4E5868)
                  : AppColors.disabled,
              background: _currentLessonIndex > 0
                  ? Colors.white
                  : AppColors.surfaceMuted,
              onTap: _currentLessonIndex > 0
                  ? () => _goToLesson(_currentLessonIndex - 1)
                  : null,
            ),
            _HeaderActionChip(
              icon: _lessonComplete
                  ? Icons.arrow_forward_rounded
                  : Icons.refresh_rounded,
              label: _lessonComplete
                  ? (_currentLessonIndex == _lessons.length - 1
                      ? context.tr('learning.finish')
                      : context.tr('learning.next'))
                  : context.tr('learning.reset'),
              foreground: Colors.white,
              background: _lesson.color,
              onTap: () {
                if (_lessonComplete) {
                  _goNextLesson();
                  return;
                }
                _celebrationToken++;
                setState(() => _resetLessonState(speakPrompt: false));
                HapticFeedback.selectionClick();
                _speakLessonPrompt(includeStrokeHint: true);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTracingCard(double boardSize, {required bool isCompact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.92),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142D3436),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, cardConstraints) {
          final infoHeight = isCompact ? 122.0 : 136.0;
          final statusHeight = isCompact ? 54.0 : 60.0;
          final availableBoard = math.max(
            240.0,
            cardConstraints.maxHeight - infoHeight - statusHeight,
          );
          final visualBoardSize = math.min(boardSize, availableBoard);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _lesson.softColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Stroke ${_currentStrokeIndex + 1}/${_lesson.strokes.length}',
                      style: AppTypography.bodySmall.copyWith(
                        color: _lesson.color,
                        fontSize: isCompact ? 11 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(_lessonComplete ? 1.0 : _progressForCurrentStroke(Size.square(visualBoardSize))) * 100 ~/ 1}%',
                    style: AppTypography.bodyStrong.copyWith(
                      color: const Color(0xFF4B5A6A),
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8 : 10),
              _buildStrokeTracker(isCompact: isCompact),
              SizedBox(height: isCompact ? 8 : 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 14,
                  vertical: isCompact ? 9 : 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _lesson.color.withValues(alpha: 0.14),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F2D3436),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: isCompact ? 34 : 38,
                      height: isCompact ? 34 : 38,
                      decoration: BoxDecoration(
                        color: _lesson.softColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: _lesson.color,
                        size: isCompact ? 18 : 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _promptForCurrentStroke(),
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: isCompact ? 14 : 16,
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showGhostHint) ...[
                SizedBox(height: isCompact ? 8 : 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _lesson.softColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _lesson.color.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high_rounded,
                        color: _lesson.color,
                        size: isCompact ? 16 : 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('learning.trace_ghost_hint'),
                          style: AppTypography.bodySmall.copyWith(
                            color: _lesson.color,
                            fontSize: isCompact ? 11 : 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: isCompact ? 8 : 10),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: visualBoardSize,
                    height: visualBoardSize,
                    child: _buildTracingBoard(Size.square(visualBoardSize)),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 8 : 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Container(
                  key: ValueKey(_statusText),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _lesson.softColor.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _statusText,
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF4E5868),
                      fontSize: isCompact ? 13 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStrokeTracker({required bool isCompact}) {
    return Row(
      children: List.generate(_lesson.strokes.length, (index) {
        final isDone = index < _currentStrokeIndex;
        final isCurrent = index == _currentStrokeIndex && !_lessonComplete;
        final isFuture = index > _currentStrokeIndex;
        final color = isDone
            ? _lesson.color
            : isCurrent
                ? Color.lerp(_lesson.color, Colors.white, 0.12)!
                : const Color(0xFFD8DFE8);
        final bg = isDone
            ? _lesson.softColor
            : isCurrent
                ? _lesson.color.withValues(alpha: 0.14)
                : const Color(0xFFF2F5F8);

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == _lesson.strokes.length - 1 ? 0 : 8,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 10,
              vertical: isCompact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isCurrent ? _lesson.color : color.withValues(alpha: 0.22),
                width: isCurrent ? 1.6 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDone
                      ? Icons.check_rounded
                      : isCurrent
                          ? Icons.gesture_rounded
                          : Icons.more_horiz_rounded,
                  size: isCompact ? 15 : 16,
                  color: isFuture ? const Color(0xFF98A3B3) : color,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'S${index + 1}',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: isFuture ? const Color(0xFF98A3B3) : color,
                      fontSize: isCompact ? 11 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTracingBoard(Size boardSize) {
    final strokeSamples = _allStrokeSamples(boardSize);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _lesson.softColor.withValues(alpha: 0.44),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) =>
                _handlePanStart(details.localPosition, boardSize),
            onPanUpdate: (details) =>
                _handlePanUpdate(details.localPosition, boardSize),
            onPanEnd: (_) => _handlePanEnd(boardSize),
            child: CustomPaint(
              painter: _TracingBoardPainter(
                lesson: _lesson,
                strokeSamples: strokeSamples,
                currentStrokeIndex: _currentStrokeIndex,
                completedStrokePaths: _completedStrokePaths,
                activeStrokePath: _activeStrokePath,
                showGhostHint: _showGhostHint,
              ),
            ),
          ),
          IgnorePointer(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _celebrationController,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.92,
                  end: 1,
                ).animate(
                  CurvedAnimation(
                    parent: _celebrationController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: _lessonComplete
                    ? _BoardCelebration(
                        key: ValueKey('trace-success-$_celebrationToken'),
                        animation: _celebrationController,
                        display: _lesson.display,
                        color: _lesson.color,
                        softColor: _lesson.softColor,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          if (_showFinalCelebration) _buildFinalCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildFinalCelebrationOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.30),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _lesson.color.withValues(alpha: 0.18),
                  blurRadius: 28,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CelebrationBear(size: 118),
                const SizedBox(height: 10),
                Text(
                  context.tr('learning.activity_complete'),
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('learning.finish_every_challenge'),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF556172),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                StartLearningNextActionButton(
                  currentRoute: AppRoutes.tracing,
                  onPrepareNavigation: _prepareNextLearningNavigation,
                  builder: (context, label, onTap) {
                    return _HeaderActionChip(
                      icon: Icons.arrow_forward_rounded,
                      label: label,
                      foreground: Colors.white,
                      background: _lesson.color,
                      onTap: onTap,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 54,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionChip extends StatelessWidget {
  const _HeaderActionChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: foreground,
                  fontSize: 12,
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

class _TracingBoardPainter extends CustomPainter {
  const _TracingBoardPainter({
    required this.lesson,
    required this.strokeSamples,
    required this.currentStrokeIndex,
    required this.completedStrokePaths,
    required this.activeStrokePath,
    required this.showGhostHint,
  });

  final _TraceLesson lesson;
  final List<List<Offset>> strokeSamples;
  final int currentStrokeIndex;
  final List<List<Offset>> completedStrokePaths;
  final List<Offset> activeStrokePath;
  final bool showGhostHint;

  @override
  void paint(Canvas canvas, Size size) {
    final boardRect = Offset.zero & size;
    final gridPaint = Paint()
      ..color = const Color(0xFFEDE7DA)
      ..strokeWidth = 1;
    final step = size.width / 5;
    for (var i = 1; i < 5; i++) {
      final offset = step * i;
      canvas.drawLine(
          Offset(offset, 0), Offset(offset, size.height), gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lesson.color.withValues(alpha: 0.12)
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          boardRect.deflate(1.5), const Radius.circular(30)),
      framePaint,
    );

    final watermark = TextPainter(
      text: TextSpan(
        text: lesson.display,
        style: AppTypography.numberDisplay.copyWith(
          fontSize: size.width * 0.52,
          color: lesson.color.withValues(alpha: 0.05),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    watermark.paint(
      canvas,
      Offset(
        (size.width - watermark.width) / 2,
        (size.height - watermark.height) / 2,
      ),
    );

    for (var i = 0; i < strokeSamples.length; i++) {
      final samples = strokeSamples[i];
      final isComplete = i < completedStrokePaths.length;
      final isCurrent = i == currentStrokeIndex;
      if (isCurrent && showGhostHint && !isComplete) {
        _drawGhostHint(canvas, samples);
      }
      _drawGuide(canvas, samples, isCurrent: isCurrent, isComplete: isComplete);
    }

    for (var i = 0; i < completedStrokePaths.length; i++) {
      _drawUserPath(
        canvas,
        completedStrokePaths[i],
        color: lesson.color,
        alpha: 0.95,
        width: 18,
      );
    }

    if (activeStrokePath.isNotEmpty) {
      _drawUserPath(
        canvas,
        activeStrokePath,
        color: Color.lerp(lesson.color, Colors.white, 0.08)!,
        alpha: 1,
        width: 16,
      );
    }

    if (currentStrokeIndex < strokeSamples.length) {
      final currentSamples = strokeSamples[currentStrokeIndex];
      if (currentSamples.isNotEmpty) {
        _drawStartAndEndMarkers(canvas, currentSamples);
      }
    }
  }

  void _drawGuide(
    Canvas canvas,
    List<Offset> points, {
    required bool isCurrent,
    required bool isComplete,
  }) {
    final dotPaint = Paint()
      ..color = isComplete
          ? lesson.color.withValues(alpha: 0.22)
          : isCurrent
              ? lesson.color.withValues(alpha: 0.50)
              : const Color(0xFFD7DCE4);

    final radius = isCurrent ? 3.4 : 2.6;
    for (var i = 0; i < points.length; i += 3) {
      canvas.drawCircle(points[i], radius, dotPaint);
    }
  }

  void _drawGhostHint(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final glow = Paint()
      ..color = lesson.color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(path, glow);

    final stroke = Paint()
      ..color = lesson.color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  void _drawUserPath(
    Canvas canvas,
    List<Offset> points, {
    required Color color,
    required double alpha,
    required double width,
  }) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final glow = Paint()
      ..color = color.withValues(alpha: alpha * 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glow);

    final stroke = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);
  }

  void _drawStartAndEndMarkers(Canvas canvas, List<Offset> points) {
    final start = points.first;
    final end = points.last;
    final startPaint = Paint()..color = const Color(0xFF3AC87A);
    final endPaint = Paint()..color = const Color(0xFFFFB648);

    canvas.drawCircle(start, 12, startPaint);
    canvas.drawCircle(start, 6, Paint()..color = Colors.white);
    canvas.drawCircle(end, 10, endPaint);

    final endLabel = TextPainter(
      text: TextSpan(
        text: '★',
        style: AppTypography.bodyStrong.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    endLabel.paint(
        canvas, end - Offset(endLabel.width / 2, endLabel.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TracingBoardPainter oldDelegate) {
    return oldDelegate.lesson != lesson ||
        oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.completedStrokePaths != completedStrokePaths ||
        oldDelegate.activeStrokePath != activeStrokePath ||
        oldDelegate.showGhostHint != showGhostHint;
  }
}

class _BoardCelebration extends StatelessWidget {
  const _BoardCelebration({
    super.key,
    required this.animation,
    required this.display,
    required this.color,
    required this.softColor,
  });

  final Animation<double> animation;
  final String display;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bearRise = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.12, 0.92, curve: Curves.easeOutBack),
        ).value;
        final glow = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
        ).value;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
          ),
          child: Center(
            child: Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.22 + (glow * 0.10)),
                    blurRadius: 28 + (glow * 12),
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: softColor.withValues(alpha: 0.82),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 8,
                        child: Opacity(
                          opacity: glow,
                          child: Text(
                            '✨',
                            style: TextStyle(
                              color: color,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Opacity(
                          opacity: glow,
                          child: const Text(
                            '🎉',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, (1 - bearRise) * 18),
                        child: Transform.scale(
                          scale: 0.84 + (bearRise * 0.16),
                          child: Image.asset(
                            'assets/images/bear/clapping.png',
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                '🐻',
                                style: TextStyle(fontSize: 72),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    display,
                    style: AppTypography.numberDisplay.copyWith(
                      color: color,
                      fontSize: 46,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('learning.stroke_complete'),
                    style: AppTypography.h3.copyWith(
                      color: const Color(0xFF1A1060),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('learning.great_job'),
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF5E6878),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
