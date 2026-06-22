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
import 'math_operation_theme.dart';
import 'math_operation_widgets.dart';

class _MultiplicationRound {
  const _MultiplicationRound({
    required this.groups,
    required this.perGroup,
    required this.themeIndex,
  });

  final int groups;
  final int perGroup;
  final int themeIndex;

  int get product => groups * perGroup;
}

class MultiplicationScreen extends StatefulWidget {
  const MultiplicationScreen({super.key});

  @override
  State<MultiplicationScreen> createState() => _MultiplicationScreenState();
}

class _MultiplicationScreenState extends State<MultiplicationScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;
  static const _postSuccessPause = Duration(milliseconds: 250);
  static const _speechSettleDelay = Duration(milliseconds: 80);

  late final FlutterTts _tts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  late final AnimationController _successPulseController;
  late final List<_MultiplicationRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();
  final Set<String> _movedObjectIds = <String>{};

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _speechRequestToken = 0;
  int _roundIndex = 0;
  int _failedDragCount = 0;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _MultiplicationRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];

  List<String> _groupIds(int groupIndex) =>
      List.generate(_round.perGroup, (i) => 'G${groupIndex}_$i');
  List<String> get _allIds => List.generate(
        _round.groups,
        (groupIndex) => _groupIds(groupIndex),
      ).expand((ids) => ids).toList();

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _successPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1,
    );
    _ttsReady = Future<void>.value();
    _rounds = _buildRoundPlan();
    _playScreenMusic(delayed: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  Future<void> _configureTts() async {
    await AppLocalization.configureTts(_tts, context);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  List<_MultiplicationRound> _buildRoundPlan() {
    const combos = <(int, int)>[
      (2, 2),
      (2, 3),
      (3, 2),
      (2, 4),
      (3, 3),
      (4, 2),
      (3, 4),
      (4, 3),
    ];
    final shuffled = [...combos]..shuffle(_random);
    return List.generate(
      _totalRounds,
      (i) => _MultiplicationRound(
        groups: shuffled[i].$1,
        perGroup: shuffled[i].$2,
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
    await _speakText(
      context.tr(
        'learning.multiplication_speak_prompt',
        namedArgs: {
          'groups': '${_round.groups}',
          'perGroup': '${_round.perGroup}',
        },
      ),
    );
  }

  Future<void> _speakSuccess() async {
    await _speakText(
      context.tr(
        'learning.multiplication_speak_success',
        namedArgs: {
          'groups': '${_round.groups}',
          'perGroup': '${_round.perGroup}',
          'product': '${_round.product}',
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

  Future<void> _completeRound() async {
    if (_roundSolved || _showCelebration) return;
    setState(() => _roundSolved = true);
    HapticFeedback.mediumImpact();
    _successPulseController.forward(from: 0);
    _feedbackAudio.playSfx('sfx/correct.mp3');
    final token = ++_autoAdvanceToken;
    await _speakSuccess();
    if (!mounted || token != _autoAdvanceToken) return;
    await Future<void>.delayed(_postSuccessPause);
    if (!mounted || token != _autoAdvanceToken) return;
    if (_roundIndex == _totalRounds - 1) {
      _showFinalCelebration();
    } else {
      setState(() {
        _roundIndex++;
        _roundSolved = false;
        _movedObjectIds.clear();
        _failedDragCount = 0;
      });
      _speakPrompt();
    }
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
      RewardModuleIds.multiplication,
    );
    AppAudioService.instance.playCelebrationMusic();
    setState(() => _showCelebration = true);
  }

  void _goBack() {
    _autoAdvanceToken++;
    _speechRequestToken++;
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
    if (!_ttsConfigured) {
      _ttsConfigured = true;
      _ttsReady = _configureTts();
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
    _speechRequestToken++;
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
                          '✖️ ${_roundIndex + 1}/$_totalRounds',
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
                    left: _round.groups,
                    operator: '×',
                    right: _round.perGroup,
                    result: _round.product,
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
              title: context.tr('learning.multiplication_complete'),
              emoji: '🎉',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel:
                  AppLocalization.moduleTitle(context, AppRoutes.division),
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.pushReplacement(AppRoutes.division);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useWrappedGroups =
            constraints.maxWidth < 380 || _round.groups > 3;
        final wrappedRows = (_round.groups / 2).ceil();
        final helperHeight = _failedDragCount >= 2 ? 58.0 : 0.0;
        final availableStageHeight = math.max(
          240.0,
          constraints.maxHeight - 70 - helperHeight,
        );
        final groupCardHeight =
            (((availableStageHeight * 0.48) - ((wrappedRows - 1) * 8)) /
                    wrappedRows)
                .clamp(104.0, 132.0)
                .toDouble();
        final wrappedGroupsHeight =
            (wrappedRows * groupCardHeight) + ((wrappedRows - 1) * 8);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: mathOpStageDecoration(_theme.color),
          child: Column(
            children: [
              Text(
                context.tr('learning.multiplication_drag_hint'),
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
                    label: Text(context.tr('learning.need_help_move_all')),
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
                child: useWrappedGroups
                    ? Column(
                        children: [
                          SizedBox(
                            height: wrappedGroupsHeight,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                  _round.groups,
                                  (groupIndex) => SizedBox(
                                    width: ((constraints.maxWidth - 44) / 2)
                                        .clamp(120.0, 180.0),
                                    height: groupCardHeight,
                                    child: _sourceTray(groupIndex),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(child: _combinedZone()),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Row(
                              children:
                                  List.generate(_round.groups, (groupIndex) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: groupIndex == _round.groups - 1
                                          ? 0
                                          : 8,
                                    ),
                                    child: _sourceTray(groupIndex),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 2,
                            child: _combinedZone(),
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

  Widget _sourceTray(int groupIndex) {
    final ids = _groupIds(groupIndex);
    final trayColor = groupIndex.isEven ? _theme.color : _theme.secondaryColor;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: trayColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: trayColor.withValues(alpha: 0.26), width: 2),
      ),
      child: Column(
        children: [
          Text(
            context.tr(
              'learning.math_group_label',
              namedArgs: {'index': '${groupIndex + 1}'},
            ),
            style: AppTypography.bodyStrong.copyWith(
              color: trayColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr(
              'learning.math_each_label',
              namedArgs: {'count': '${_round.perGroup}'},
            ),
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _objectGrid(
                  ids: ids,
                  constraints: constraints,
                  color: trayColor,
                  draggable: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _combinedZone() {
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
                  Text(_theme.emoji, style: const TextStyle(fontSize: 44)),
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
            draggable: false,
          );
        },
      ),
    );
  }

  Widget _objectGrid({
    required List<String> ids,
    required BoxConstraints constraints,
    required Color color,
    required bool draggable,
  }) {
    if (ids.isEmpty) return const SizedBox.shrink();
    final columns = draggable
        ? (ids.length >= 4 ? 2 : ids.length)
        : (ids.length <= 3 ? ids.length : 3);
    const spacing = 8.0;
    const interactivePadding = 8.0;
    final rows = (ids.length / columns).ceil();
    final availableWidth =
        (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
    final availableHeight =
        (constraints.maxHeight - ((rows - 1) * spacing)) / rows;
    final baseSize = math.min(
      availableWidth - (draggable ? interactivePadding : 0),
      availableHeight - (draggable ? interactivePadding : 0),
    );
    final size = math.max(
      draggable ? 12.0 : 18.0,
      math.min(draggable ? 54.0 : 66.0, baseSize),
    );

    return Center(
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: WrapAlignment.center,
        children: ids.map((id) {
          if (!draggable) {
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
