import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/tts_voice_helper.dart';
import '../StartLearning/start_learning_next_action_button.dart';
import '../count_objects/counting_themes.dart';
import '../../shared/widgets/celebration_bear.dart';
import '../../shared/widgets/celebration_overlay.dart';
import '../../shared/widgets/kid_loading_view.dart';

enum _QuizMode {
  tapNumber,
  dragMatch,
  writeNumber,
  missingNumber,
  compareGroups
}

class _QuizRound {
  const _QuizRound({
    required this.answer,
    required this.themeIndex,
    required this.mode,
    this.sequenceStart,
    this.sequenceLength,
    this.missingIndex,
    this.leftCount,
    this.rightCount,
    this.findMore,
  });

  final int answer;
  final int themeIndex;
  final _QuizMode mode;
  final int? sequenceStart;
  final int? sequenceLength;
  final int? missingIndex;
  final int? leftCount;
  final int? rightCount;
  final bool? findMore;
}

class MiniQuizScreen extends StatefulWidget {
  const MiniQuizScreen({super.key});

  @override
  State<MiniQuizScreen> createState() => _MiniQuizScreenState();
}

class _MiniQuizScreenState extends State<MiniQuizScreen>
    with TickerProviderStateMixin, RouteAware {
  static const int _totalRounds = 35;
  static const String _quizProgressKeyPrefix = 'mini_quiz_progress_v2';

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _celebrationController;
  late final AnimationController _successPulseController;

  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();

  List<_QuizRound> _rounds = const [];
  List<int> _tapOptions = const [];
  List<int> _dragOptions = const [];
  final List<int> _writeKeypad = const [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int? _selectedTapNumber;
  int? _draggedNumber;
  int? _droppedNumber;
  bool? _selectedCompareLeft;
  String _writtenAnswer = '';
  bool _answerLocked = false;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _hasShownDragHint = false;

  _QuizRound get _currentRound => _rounds[_roundIndex];
  CountingTheme get _theme => countingThemes[_currentRound.themeIndex];
  int get _correctAnswer => _currentRound.answer;
  bool get _correctCompareSideIsLeft {
    final leftCount = _currentRound.leftCount ?? 0;
    final rightCount = _currentRound.rightCount ?? 0;
    if (_currentRound.findMore == true) {
      return leftCount > rightCount;
    }
    return leftCount < rightCount;
  }

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
    _restoreOrCreateQuiz();
  }

  Future<void> _configureTts() async {
    await TtsVoiceHelper.configureSharedAudio(_tts);
    await TtsVoiceHelper.applyPreferredVoice(
      _tts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'en-GB'],
    );
    await _tts.setPitch(1.04);
    await TtsVoiceHelper.applyPreferredSpeechRate(
      _tts,
      normalRate: 0.4,
      slowRate: 0.3,
    );
    await _tts.setVolume(1.0);
  }

  List<_QuizRound> _buildRoundPlan() {
    final counts = List<int>.generate(_totalRounds, (index) => (index % 9) + 1)
      ..shuffle(_random);
    final modes = <_QuizMode>[];
    for (var i = 0; i < 7; i++) {
      modes.addAll(const [
        _QuizMode.tapNumber,
        _QuizMode.dragMatch,
        _QuizMode.writeNumber,
        _QuizMode.missingNumber,
        _QuizMode.compareGroups,
      ]);
    }
    modes.shuffle(_random);
    final rounds = <_QuizRound>[];
    final themeUsage = List<int>.filled(countingThemes.length, 0);
    var lastThemeIndex = -1;

    for (var i = 0; i < _totalRounds; i++) {
      final themeIndex = _pickThemeIndex(
        themeUsage: themeUsage,
        lastThemeIndex: lastThemeIndex,
      );
      rounds.add(_buildRound(
        answer: counts[i],
        themeIndex: themeIndex,
        mode: modes[i],
      ));
      themeUsage[themeIndex]++;
      lastThemeIndex = themeIndex;
    }
    return rounds;
  }

  _QuizRound _buildRound({
    required int answer,
    required int themeIndex,
    required _QuizMode mode,
  }) {
    switch (mode) {
      case _QuizMode.tapNumber:
      case _QuizMode.dragMatch:
      case _QuizMode.writeNumber:
        return _QuizRound(answer: answer, themeIndex: themeIndex, mode: mode);
      case _QuizMode.missingNumber:
        final sequenceLength = 4;
        final minStart = math.max(1, answer - (sequenceLength - 1));
        final maxStart = math.min(9 - sequenceLength + 1, answer);
        final sequenceStart =
            minStart + _random.nextInt((maxStart - minStart) + 1);
        final missingIndex = answer - sequenceStart;
        return _QuizRound(
          answer: answer,
          themeIndex: themeIndex,
          mode: mode,
          sequenceStart: sequenceStart,
          sequenceLength: sequenceLength,
          missingIndex: missingIndex,
        );
      case _QuizMode.compareGroups:
        var leftCount = (_random.nextInt(8) + 1);
        var rightCount = (_random.nextInt(8) + 1);
        while (leftCount == rightCount) {
          rightCount = (_random.nextInt(8) + 1);
        }
        final findMore = _random.nextBool();
        final answerCount = findMore
            ? math.max(leftCount, rightCount)
            : math.min(leftCount, rightCount);
        return _QuizRound(
          answer: answerCount,
          themeIndex: themeIndex,
          mode: mode,
          leftCount: leftCount,
          rightCount: rightCount,
          findMore: findMore,
        );
    }
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

  void _prepareRound({
    String restoredWrittenAnswer = '',
    bool persist = true,
  }) {
    final answer = _correctAnswer;

    final tapOptions = <int>{answer};
    while (tapOptions.length < 4) {
      tapOptions.add(_random.nextInt(9) + 1);
    }

    final dragOptions = <int>{answer};
    while (dragOptions.length < 3) {
      dragOptions.add(_random.nextInt(9) + 1);
    }

    _tapOptions = tapOptions.toList()..shuffle(_random);
    _dragOptions = dragOptions.toList()..shuffle(_random);
    _selectedTapNumber = null;
    _draggedNumber = null;
    _droppedNumber = null;
    _selectedCompareLeft = null;
    _writtenAnswer = restoredWrittenAnswer;
    _answerLocked = false;
    _roundSolved = false;
    if (persist) {
      _saveQuizProgress();
    }
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
    _tts.stop();
  }

  Future<void> _restoreOrCreateQuiz() async {
    final savedState = await _loadQuizProgress();
    if (!mounted) return;

    if (savedState != null) {
      final savedRounds = _decodeRounds(savedState['rounds']);
      if (savedRounds.length < 30) {
        await _clearQuizProgress();
        return _restoreOrCreateQuiz();
      }
      final savedIndex = (savedState['roundIndex'] as int?) ?? 0;
      final restoredIndex =
          savedRounds.isEmpty ? 0 : savedIndex.clamp(0, savedRounds.length - 1);
      setState(() {
        _rounds = savedRounds.isEmpty ? _buildRoundPlan() : savedRounds;
        _roundIndex = restoredIndex;
        _hasShownDragHint = savedState['hasShownDragHint'] as bool? ?? false;
        _prepareRound(
          restoredWrittenAnswer: savedState['writtenAnswer'] as String? ?? '',
          persist: false,
        );
      });
    } else {
      final freshRounds = _buildRoundPlan();
      setState(() {
        _rounds = freshRounds;
        _roundIndex = 0;
        _prepareRound(persist: false);
      });
    }

    _saveQuizProgress();
    _playScreenMusic(delayed: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _rounds.isNotEmpty) {
        _speakPrompt();
      }
    });
  }

  Future<Map<String, dynamic>?> _loadQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _quizProgressKey();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  Future<void> _saveQuizProgress() async {
    if (_rounds.isEmpty || _showCelebration) return;
    final prefs = await SharedPreferences.getInstance();
    final key = await _quizProgressKey();
    final payload = jsonEncode({
      'roundIndex': _roundIndex,
      'writtenAnswer': _writtenAnswer,
      'hasShownDragHint': _hasShownDragHint,
      'rounds': _rounds.map(_encodeRound).toList(),
    });
    await prefs.setString(key, payload);
  }

  Future<void> _clearQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _quizProgressKey();
    await prefs.remove(key);
  }

  Future<String> _quizProgressKey() async {
    final snapshot = await ChildProfileService.instance.loadSnapshot();
    return '${_quizProgressKeyPrefix}_${snapshot.activeIndex}';
  }

  Map<String, dynamic> _encodeRound(_QuizRound round) {
    return {
      'answer': round.answer,
      'themeIndex': round.themeIndex,
      'mode': round.mode.name,
      'sequenceStart': round.sequenceStart,
      'sequenceLength': round.sequenceLength,
      'missingIndex': round.missingIndex,
      'leftCount': round.leftCount,
      'rightCount': round.rightCount,
      'findMore': round.findMore,
    };
  }

  List<_QuizRound> _decodeRounds(Object? rawRounds) {
    if (rawRounds is! List) return const [];
    return rawRounds.whereType<Map>().map((rawRound) {
      final map = rawRound.map(
        (key, value) => MapEntry('$key', value),
      );
      return _QuizRound(
        answer: (map['answer'] as num?)?.toInt() ?? 1,
        themeIndex: (map['themeIndex'] as num?)?.toInt() ?? 0,
        mode: _QuizMode.values.firstWhere(
          (mode) => mode.name == map['mode'],
          orElse: () => _QuizMode.tapNumber,
        ),
        sequenceStart: (map['sequenceStart'] as num?)?.toInt(),
        sequenceLength: (map['sequenceLength'] as num?)?.toInt(),
        missingIndex: (map['missingIndex'] as num?)?.toInt(),
        leftCount: (map['leftCount'] as num?)?.toInt(),
        rightCount: (map['rightCount'] as num?)?.toInt(),
        findMore: map['findMore'] as bool?,
      );
    }).toList(growable: false);
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
      case _QuizMode.missingNumber:
        return 'Missing Quiz';
      case _QuizMode.compareGroups:
        return 'Compare Quiz';
    }
  }

  String _modeEmoji(_QuizMode mode) {
    switch (mode) {
      case _QuizMode.tapNumber:
        return '👆';
      case _QuizMode.dragMatch:
        return '🧲';
      case _QuizMode.writeNumber:
        return '⌨️';
      case _QuizMode.missingNumber:
        return '🧩';
      case _QuizMode.compareGroups:
        return '⚖️';
    }
  }

  String _modeInstruction(_QuizMode mode) {
    switch (mode) {
      case _QuizMode.tapNumber:
        return 'Count the objects and tap the matching number.';
      case _QuizMode.dragMatch:
        return 'Count the objects and drag the matching number to the box.';
      case _QuizMode.writeNumber:
        return 'Count the objects and write the answer using the keypad.';
      case _QuizMode.missingNumber:
        return 'Count the objects and fill the missing number.';
      case _QuizMode.compareGroups:
        return _currentRound.findMore == true
            ? 'Count both groups and tap the one with more objects.'
            : 'Count both groups and tap the one with fewer objects.';
    }
  }

  Future<void> _speakPrompt() async {
    await _ttsReady;
    await _tts.stop();
    final label = _objectLabel(_correctAnswer);
    final prompt = switch (_currentRound.mode) {
      _QuizMode.tapNumber => 'Count the $label and tap the matching number.',
      _QuizMode.dragMatch =>
        'Count the $label and drag the matching number into the box.',
      _QuizMode.writeNumber => 'Count the $label and write the answer.',
      _QuizMode.missingNumber =>
        'Count the $label and fill the missing number in the sequence.',
      _QuizMode.compareGroups => _currentRound.findMore == true
          ? 'Count both groups and tap the group with more $label.'
          : 'Count both groups and tap the group with fewer $label.',
    };
    await _tts.speak(prompt);
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    final label = _objectLabel(_correctAnswer);
    final praise = switch (_currentRound.mode) {
      _QuizMode.compareGroups => _currentRound.findMore == true
          ? 'Amazing! You found the group with more $label.'
          : 'Amazing! You found the group with fewer $label.',
      _ => 'Amazing! You got $_correctAnswer $label right.',
    };
    await _tts.speak(praise);
  }

  Future<void> _speakCompletionPraise() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak(
      'Quiz champion. You completed all $_totalRounds quiz rounds.',
    );
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
    _saveQuizProgress();
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
    _saveQuizProgress();
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
    _saveQuizProgress();
  }

  void _backspaceWriteDigit() {
    if (_answerLocked || _showCelebration || _writtenAnswer.isEmpty) return;
    setState(() {
      _writtenAnswer = _writtenAnswer.substring(0, _writtenAnswer.length - 1);
    });
    _saveQuizProgress();
  }

  void _clearWrittenAnswer() {
    if (_answerLocked || _showCelebration || _writtenAnswer.isEmpty) return;
    setState(() {
      _writtenAnswer = '';
    });
    _saveQuizProgress();
  }

  void _handleCompareChoice(bool isLeft) {
    if (_answerLocked || _showCelebration) return;
    final correctIsLeft = _correctCompareSideIsLeft;
    setState(() {
      _selectedCompareLeft = isLeft;
    });
    _saveQuizProgress();
    if (isLeft == correctIsLeft) {
      _markCorrect();
    } else {
      _markWrong();
      final requestToken = ++_autoAdvanceToken;
      Future<void>.delayed(const Duration(milliseconds: 650), () {
        if (!mounted || requestToken != _autoAdvanceToken) return;
        setState(() {
          _selectedCompareLeft = null;
        });
      });
    }
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
    _clearQuizProgress();
    _stopAllAudioAndSpeech();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.miniQuiz,
    );
    AppAudioService.instance.playCelebrationMusic();
    _speakCompletionPraise();
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
    _stopAllAudioAndSpeech();
    _celebrationController.dispose();
    _successPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x40FFFFFF),
                    Color(0x40FFF2D9),
                    Color(0xB8F5F7FB),
                  ],
                ),
              ),
            ),
            const KidLoadingView(
              title: 'Mini Quiz',
              subtitle: 'Building your next quiz adventure.',
              compact: true,
            ),
          ],
        ),
      );
    }

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
          if (_showCelebration) const CelebrationOverlay(isVisible: true),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrowWidth = constraints.maxWidth < 380;
                final isCompactHeight = constraints.maxHeight < 760;
                final isVeryCompactHeight = constraints.maxHeight < 690;
                final gap = isVeryCompactHeight ? 10.0 : 14.0;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    16 + (MediaQuery.of(context).padding.bottom * 0.2),
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(
                        progress,
                        compact: isCompactHeight,
                        narrowWidth: isNarrowWidth,
                      ),
                      SizedBox(height: gap),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _successPulseController,
                          builder: (context, child) {
                            final scale = 1 +
                                ((_successPulseController.value - 1) * 0.03);
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: _buildActivityPanel(
                            narrowWidth: isNarrowWidth,
                            compactHeight: isCompactHeight,
                            veryCompactHeight: isVeryCompactHeight,
                          ),
                        ),
                      ),
                      SizedBox(height: isVeryCompactHeight ? 10 : 12),
                      _buildBottomBar(compact: isVeryCompactHeight),
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
                'Mini Quiz',
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
                      'Round ${_roundIndex + 1} of $_totalRounds',
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
                  _buildModeBadge(compact: compact),
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

  Widget _buildModeBadge({bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: _theme.softColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
      ),
      child: Text(
        '${_modeEmoji(_currentRound.mode)} ${_modeLabel(_currentRound.mode)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: _theme.color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildActivityPanel({
    required bool narrowWidth,
    required bool compactHeight,
    required bool veryCompactHeight,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(veryCompactHeight ? 14 : 18),
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
        _QuizMode.tapNumber => _buildTapQuiz(compactHeight: compactHeight),
        _QuizMode.dragMatch => _buildDragQuiz(
            narrowWidth: narrowWidth,
            compactHeight: compactHeight,
            veryCompactHeight: veryCompactHeight,
          ),
        _QuizMode.writeNumber => _buildWriteQuiz(
            narrowWidth: narrowWidth,
            compactHeight: compactHeight,
          ),
        _QuizMode.missingNumber =>
          _buildMissingQuiz(compactHeight: compactHeight),
        _QuizMode.compareGroups => _buildCompareQuiz(
            narrowWidth: narrowWidth,
            compactHeight: compactHeight,
          ),
      },
    );
  }

  Widget _buildTapQuiz({bool compactHeight = false}) {
    return Column(
      children: [
        Text(
          _modeInstruction(_QuizMode.tapNumber),
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrong.copyWith(
            color: _theme.color,
            fontWeight: FontWeight.w800,
            fontSize: compactHeight ? 13 : 14,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildObjectGroupCard(_correctAnswer),
        ),
        const SizedBox(height: 12),
        _buildNumberChoiceGrid(
          options: _tapOptions,
          selectedValue: _selectedTapNumber,
          compactHeight: compactHeight,
          onTap: _handleTapChoice,
        ),
      ],
    );
  }

  Widget _buildMissingQuiz({bool compactHeight = false}) {
    final sequenceStart = _currentRound.sequenceStart ?? _correctAnswer;
    final sequenceLength = _currentRound.sequenceLength ?? 4;
    final missingIndex = _currentRound.missingIndex ?? 0;
    final sequence = List<int>.generate(
      sequenceLength,
      (index) => sequenceStart + index,
    );

    return Column(
      children: [
        Text(
          _modeInstruction(_QuizMode.missingNumber),
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrong.copyWith(
            color: _theme.color,
            fontWeight: FontWeight.w800,
            fontSize: compactHeight ? 13 : 14,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildObjectGroupCard(_correctAnswer),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < sequence.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: compactHeight ? 58 : 66,
                  decoration: BoxDecoration(
                    color: i == missingIndex
                        ? _theme.softColor.withValues(alpha: 0.42)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: i == missingIndex
                          ? _theme.color.withValues(alpha: 0.5)
                          : _theme.color.withValues(alpha: 0.18),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      i == missingIndex ? '?' : '${sequence[i]}',
                      style: AppTypography.h2.copyWith(
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _buildNumberChoiceGrid(
          options: _tapOptions,
          selectedValue: _selectedTapNumber,
          compactHeight: compactHeight,
          onTap: _handleTapChoice,
        ),
      ],
    );
  }

  Widget _buildDragQuiz({
    required bool narrowWidth,
    required bool compactHeight,
    required bool veryCompactHeight,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = narrowWidth || constraints.maxHeight < 430;
        final objectCardHeight = stackVertically
            ? (veryCompactHeight ? 160.0 : 190.0)
            : double.infinity;
        final dropZoneHeight = stackVertically
            ? (veryCompactHeight ? 110.0 : 128.0)
            : double.infinity;

        final prompt = !_hasShownDragHint && !_roundSolved
            ? Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _theme.softColor.withValues(alpha: 0.34),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: _theme.color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  'Hold a number card and drag it into the glowing box.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: _theme.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : const SizedBox.shrink();

        final upperSection = stackVertically
            ? Column(
                children: [
                  SizedBox(
                    height: objectCardHeight,
                    child: _buildObjectGroupCard(_correctAnswer),
                  ),
                  SizedBox(height: veryCompactHeight ? 10 : 12),
                  SizedBox(
                    height: dropZoneHeight,
                    child: _buildDropZone(compact: true),
                  ),
                ],
              )
            : Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildObjectGroupCard(_correctAnswer)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropZone()),
                  ],
                ),
              );

        final chipSection = _buildDragOptions(
          narrowWidth: narrowWidth,
          compactHeight: compactHeight,
          wrap: stackVertically,
        );

        return Column(
          children: [
            prompt,
            if (stackVertically)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: objectCardHeight,
                      child: _buildObjectGroupCard(_correctAnswer),
                    ),
                    SizedBox(height: veryCompactHeight ? 10 : 12),
                    SizedBox(
                      height: dropZoneHeight,
                      child: _buildDropZone(compact: true),
                    ),
                  ],
                ),
              )
            else
              upperSection,
            const SizedBox(height: 12),
            chipSection,
          ],
        );
      },
    );
  }

  Widget _buildCompareQuiz({
    required bool narrowWidth,
    required bool compactHeight,
  }) {
    final stackVertically = narrowWidth;
    final leftCount = _currentRound.leftCount ?? 1;
    final rightCount = _currentRound.rightCount ?? 2;

    final choices = stackVertically
        ? Column(
            children: [
              Expanded(
                child: _buildCompareChoiceCard(
                  count: leftCount,
                  isLeft: true,
                  compactHeight: compactHeight,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildCompareChoiceCard(
                  count: rightCount,
                  isLeft: false,
                  compactHeight: compactHeight,
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: _buildCompareChoiceCard(
                  count: leftCount,
                  isLeft: true,
                  compactHeight: compactHeight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompareChoiceCard(
                  count: rightCount,
                  isLeft: false,
                  compactHeight: compactHeight,
                ),
              ),
            ],
          );

    return Column(
      children: [
        Text(
          _modeInstruction(_QuizMode.compareGroups),
          textAlign: TextAlign.center,
          style: AppTypography.bodyStrong.copyWith(
            color: _theme.color,
            fontWeight: FontWeight.w800,
            fontSize: compactHeight ? 13 : 14,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: choices),
      ],
    );
  }

  Widget _buildDropZone({bool compact = false}) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => !_answerLocked,
      onAcceptWithDetails: (details) => _handleDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final isCorrectDrop = _droppedNumber == _correctAnswer;
        final isWrongDrop =
            _droppedNumber != null && _droppedNumber != _correctAnswer;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isCorrectDrop
                ? AppColors.correctFeedback.withValues(alpha: 0.48)
                : isWrongDrop
                    ? AppColors.incorrectFeedback.withValues(alpha: 0.30)
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _droppedNumber == null ? 'Drop number here' : '$_droppedNumber',
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w900,
                  fontSize: _droppedNumber == null
                      ? (compact ? 24 : 28)
                      : (compact ? 54 : 62),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragOptions({
    required bool narrowWidth,
    required bool compactHeight,
    required bool wrap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final availableWidth = math.max(constraints.maxWidth, 1);
        final cardWidth = wrap
            ? math.min(110.0, (availableWidth - spacing) / 2)
            : (availableWidth - (spacing * (_dragOptions.length - 1))) /
                _dragOptions.length;
        final cardHeight = math.min(
          narrowWidth ? 84.0 : 96.0,
          math.max(64.0, cardWidth * (compactHeight ? 0.78 : 0.74)),
        );

        final chips = _dragOptions.map((value) {
          final chip = wrap
              ? SizedBox(
                  width: cardWidth,
                  child: _buildDraggableChip(
                    value: value,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                )
              : Expanded(
                  child: _buildDraggableChip(
                    value: value,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                );
          return chip;
        }).toList();

        if (wrap) {
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: chips,
          );
        }

        return Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: spacing),
              chips[i],
            ],
          ],
        );
      },
    );
  }

  Widget _buildDraggableChip({
    required int value,
    required double cardWidth,
    required double cardHeight,
  }) {
    return Draggable<int>(
      data: value,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: _answerLocked ? 0 : 1,
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
        if (!_hasShownDragHint) {
          setState(() {
            _hasShownDragHint = true;
          });
        }
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
    );
  }

  Widget _buildWriteQuiz({
    required bool narrowWidth,
    required bool compactHeight,
  }) {
    final canCheck = _writtenAnswer.isNotEmpty && !_answerLocked;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = narrowWidth || constraints.maxHeight < 440;
        final displayCard = Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: compactHeight ? 14 : 18,
            horizontal: 12,
          ),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _writtenAnswer.isEmpty ? '_' : _writtenAnswer,
                  style: AppTypography.numberDisplay.copyWith(
                    fontSize: stackVertically ? 80 : 72,
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );

        final keypad = GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _writeKeypad.length + 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: compactHeight ? 54 : 60,
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
        );

        final rightPane = stackVertically
            ? Expanded(
                child: Column(
                  children: [
                    displayCard,
                    const SizedBox(height: 12),
                    Expanded(child: keypad),
                  ],
                ),
              )
            : Expanded(
                child: Column(
                  children: [
                    displayCard,
                    const SizedBox(height: 12),
                    Expanded(child: keypad),
                  ],
                ),
              );

        return Column(
          children: [
            Expanded(
              child: stackVertically
                  ? Column(
                      children: [
                        SizedBox(
                          height: compactHeight ? 150 : 176,
                          child: _buildObjectGroupCard(_correctAnswer),
                        ),
                        const SizedBox(height: 12),
                        rightPane,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildObjectGroupCard(_correctAnswer)),
                        const SizedBox(width: 12),
                        rightPane,
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
      },
    );
  }

  Widget _buildNumberChoiceGrid({
    required List<int> options,
    required int? selectedValue,
    required bool compactHeight,
    required ValueChanged<int> onTap,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: compactHeight ? 86 : 98,
      ),
      itemBuilder: (context, index) {
        final value = options[index];
        final isSelected = selectedValue == value;
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
            onTap: () => onTap(value),
            child: Container(
              constraints: const BoxConstraints(minHeight: 72),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: AppTypography.numberDisplay.copyWith(
                    fontSize: compactHeight ? 46 : 52,
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            'Count the ${_objectLabel(count)}',
            style: AppTypography.bodyStrong.copyWith(
              color: _theme.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildObjectPreviewGrid(count),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareChoiceCard({
    required int count,
    required bool isLeft,
    required bool compactHeight,
  }) {
    final isSelected = _selectedCompareLeft == isLeft;
    final isCorrect = _correctCompareSideIsLeft == isLeft;

    Color backgroundColor = Colors.white;
    Color borderColor = _theme.color.withValues(alpha: 0.22);

    if (isSelected && isCorrect) {
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.46);
      borderColor = AppColors.gardenGreen;
    } else if (isSelected && !isCorrect) {
      backgroundColor = AppColors.incorrectFeedback.withValues(alpha: 0.34);
      borderColor = AppColors.incorrectFeedback;
    } else if (_roundSolved && isCorrect) {
      backgroundColor = AppColors.correctFeedback.withValues(alpha: 0.24);
      borderColor = AppColors.gardenGreen.withValues(alpha: 0.72);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _handleCompareChoice(isLeft),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            children: [
              Text(
                isLeft ? 'Group A' : 'Group B',
                style: AppTypography.bodyStrong.copyWith(
                  color: _theme.color,
                  fontWeight: FontWeight.w800,
                  fontSize: compactHeight ? 13 : 14,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildObjectPreviewGrid(count)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectPreviewGrid(int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = count <= 4 ? 2 : (count <= 8 ? 3 : 4);
        final rows = (count / columns).ceil();
        const spacing = 6.0;
        final itemSize = math.min(
          46.0,
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
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: itemSize * 0.32,
                          color: _theme.color,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar({bool compact = false}) {
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
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 12 : 14,
            ),
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
                          '+5 stars earned!',
                          style: AppTypography.bodyStrong.copyWith(
                            color: _theme.color,
                            fontWeight: FontWeight.w800,
                          ),
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
