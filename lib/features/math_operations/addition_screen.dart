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
import 'math_operation_theme.dart';
import 'math_operation_widgets.dart';

class _AdditionRound {
  const _AdditionRound({
    required this.groupA,
    required this.groupB,
    required this.themeIndex,
  });

  final int groupA;
  final int groupB;
  final int themeIndex;

  int get total => groupA + groupB;
}

class AdditionScreen extends StatefulWidget {
  const AdditionScreen({super.key});

  @override
  State<AdditionScreen> createState() => _AdditionScreenState();
}

class _AdditionScreenState extends State<AdditionScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _successPulseController;
  late final List<_AdditionRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();
  final Set<String> _movedObjectIds = <String>{};

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int _failedDragCount = 0;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _AdditionRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];

  List<String> get _groupAIds => List.generate(_round.groupA, (i) => 'A_$i');
  List<String> get _groupBIds => List.generate(_round.groupB, (i) => 'B_$i');
  List<String> get _allIds => [..._groupAIds, ..._groupBIds];

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
    await TtsVoiceHelper.applyPreferredSpeechRate(
      _tts,
      normalRate: 0.42,
      slowRate: 0.3,
    );
    await _tts.setVolume(1.0);
  }

  List<_AdditionRound> _buildRoundPlan() {
    const combos = <(int, int)>[
      (1, 1),
      (1, 2),
      (2, 1),
      (2, 2),
      (1, 3),
      (3, 1),
      (2, 3),
      (3, 2),
    ];
    final shuffled = [...combos]..shuffle(_random);
    return List.generate(
      _totalRounds,
      (i) => _AdditionRound(
        groupA: shuffled[i].$1,
        groupB: shuffled[i].$2,
        themeIndex: i % mathOperationThemes.length,
      ),
    );
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
    await _tts.speak('${_round.groupA} plus ${_round.groupB} equals what?');
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak(
      '${_round.groupA} plus ${_round.groupB} equals ${_round.total}',
    );
  }

  void _moveObject(String id) {
    if (_roundSolved || _showCelebration || _movedObjectIds.contains(id)) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _movedObjectIds.add(id));
    if (_movedObjectIds.length == _allIds.length) {
      _completeRound();
    }
  }

  void _completeRound() {
    if (_roundSolved || _showCelebration) return;
    setState(() => _roundSolved = true);
    HapticFeedback.mediumImpact();
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
          _movedObjectIds.clear();
          _failedDragCount = 0;
          _roundSolved = false;
        });
        _speakPrompt();
      }
    });
  }

  void _handleFailedDrag() {
    if (_roundSolved || _showCelebration) return;
    setState(() {
      _failedDragCount++;
      _isDragging = false;
    });
  }

  void _moveAllRemaining() {
    if (_roundSolved || _showCelebration) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _movedObjectIds.addAll(_allIds);
      _isDragging = false;
    });
    _completeRound();
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration) return;
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.addition,
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
                          '➕ ${_roundIndex + 1}/$_totalRounds',
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
                  const SizedBox(height: 12),
                  MathOpEquationBanner(
                    left: _round.groupA,
                    operator: '+',
                    right: _round.groupB,
                    result: _round.total,
                    solved: _roundSolved,
                    color: _theme.color,
                    softColor: _theme.softColor,
                  ),
                  const SizedBox(height: 12),
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
              emoji: '🎉',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel: 'Subtraction',
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.pushReplacement(AppRoutes.subtraction);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: mathOpStageDecoration(_theme.color),
          child: Column(
            children: [
              Text(
                'Drag or tap every object into the bowl.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyStrong.copyWith(
                  color: const Color(0xFF5A6B7A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_failedDragCount >= 2 && !_roundSolved) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _moveAllRemaining,
                    icon: const Icon(Icons.touch_app_rounded),
                    label: const Text('Need help? Tap to move all'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _theme.color,
                      side: BorderSide(
                        color: _theme.color.withValues(alpha: 0.32),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: isNarrow
                    ? Column(
                        children: [
                          Expanded(
                            child: _sourceTray(
                              count: _round.groupA,
                              color: _theme.color,
                              ids: _groupAIds,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '+',
                              style: AppTypography.numberDisplay.copyWith(
                                fontSize: 30,
                                color: _theme.color,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _sourceTray(
                              count: _round.groupB,
                              color: _theme.secondaryColor,
                              ids: _groupBIds,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 2,
                            child: _bowl(),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _sourceTray(
                                    count: _round.groupA,
                                    color: _theme.color,
                                    ids: _groupAIds,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '+',
                                    style: AppTypography.numberDisplay.copyWith(
                                      fontSize: 32,
                                      color: _theme.color,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _sourceTray(
                                    count: _round.groupB,
                                    color: _theme.secondaryColor,
                                    ids: _groupBIds,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 2,
                            child: _bowl(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sourceTray({
    required int count,
    required Color color,
    required List<String> ids,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.26), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTypography.bodyStrong.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _objectGrid(
                  ids: ids,
                  constraints: constraints,
                  color: color,
                  inBowl: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bowl() {
    return MathOpDropZone(
      label: '${_movedObjectIds.length}/${_allIds.length}',
      emoji: '🥣',
      color: _theme.color,
      softColor: _theme.softColor,
      isHighlighted: _isDragging,
      onWillAccept: (data) =>
          data is String && !_roundSolved && !_movedObjectIds.contains(data),
      onAccept: (data) => _moveObject(data as String),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_movedObjectIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _theme.emoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: _theme.color.withValues(alpha: 0.7),
                    size: 28,
                  ),
                ],
              ),
            );
          }
          return _objectGrid(
            ids: _movedObjectIds.toList(),
            constraints: constraints,
            color: _theme.color,
            inBowl: true,
          );
        },
      ),
    );
  }

  Widget _objectGrid({
    required List<String> ids,
    required BoxConstraints constraints,
    required Color color,
    required bool inBowl,
  }) {
    if (ids.isEmpty) return const SizedBox.shrink();
    final columns = ids.length <= 2 ? ids.length : 2;
    const spacing = 8.0;
    const interactivePadding = 8.0;
    final rows = (ids.length / columns).ceil();
    final availableWidth =
        (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
    final availableHeight =
        (constraints.maxHeight - ((rows - 1) * spacing)) / rows;
    final size = math.max(
      40.0,
      math.min(
        inBowl ? 82.0 : 72.0,
        math.min(
          availableWidth - (inBowl ? 0 : interactivePadding),
          availableHeight - (inBowl ? 0 : interactivePadding),
        ),
      ),
    );

    return Center(
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: WrapAlignment.center,
        children: ids.map((id) {
          if (inBowl) {
            return MathOpObjectToken(
              size: size,
              assetPath: _theme.assetPath,
              backgroundColor: color.withValues(alpha: 0.16),
            );
          }

          final moved = _movedObjectIds.contains(id);
          return MathOpDraggableItem<String>(
            data: id,
            size: size,
            assetPath: _theme.assetPath,
            backgroundColor: color.withValues(alpha: 0.18),
            enabled: !moved && !_roundSolved,
            onTap: () => _moveObject(id),
            onDragStarted: () {
              HapticFeedback.selectionClick();
              setState(() => _isDragging = true);
            },
            onDragCompleted: () {
              if (mounted) {
                setState(() {
                  _isDragging = false;
                  _failedDragCount = 0;
                });
              }
            },
            onDragCanceled: _handleFailedDrag,
            onDragEnd: () {
              if (mounted) setState(() => _isDragging = false);
            },
          );
        }).toList(),
      ),
    );
  }
}
