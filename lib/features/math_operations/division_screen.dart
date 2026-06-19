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

class _DivisionRound {
  const _DivisionRound({
    required this.total,
    required this.groups,
    required this.themeIndex,
  });

  final int total;
  final int groups;
  final int themeIndex;

  int get quotient => total ~/ groups;
}

class DivisionScreen extends StatefulWidget {
  const DivisionScreen({super.key});

  @override
  State<DivisionScreen> createState() => _DivisionScreenState();
}

class _DivisionScreenState extends State<DivisionScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _successPulseController;
  late final List<_DivisionRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();

  /// null = top pile, otherwise bowl index.
  final Map<String, int?> _placements = <String, int?>{};

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _DivisionRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];

  List<String> get _allIds =>
      List.generate(_round.total, (i) => 'D_$i');

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
    _resetPlacements();
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

  List<_DivisionRound> _buildRoundPlan() {
    const combos = <(int, int)>[
      (4, 2),
      (6, 2),
      (6, 3),
      (8, 2),
      (8, 4),
      (9, 3),
      (10, 2),
      (12, 3),
    ];
    final shuffled = [...combos]..shuffle(_random);
    return List.generate(
      _totalRounds,
      (i) => _DivisionRound(
        total: shuffled[i].$1,
        groups: shuffled[i].$2,
        themeIndex: i % mathOperationThemes.length,
      ),
    );
  }

  void _resetPlacements() {
    _placements
      ..clear()
      ..addEntries(_allIds.map((id) => MapEntry(id, null)));
  }

  List<String> _pileIds() =>
      _allIds.where((id) => _placements[id] == null).toList();

  List<String> _bowlIds(int bowlIndex) =>
      _allIds.where((id) => _placements[id] == bowlIndex).toList();

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
    await _tts.speak('${_round.total} divided by ${_round.groups}');
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${_round.quotient}');
  }

  void _placeInBowl(String id, int bowlIndex) {
    if (_roundSolved ||
        _showCelebration ||
        _placements[id] != null ||
        _bowlIds(bowlIndex).length >= _round.quotient) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _placements[id] = bowlIndex);

    if (_pileIds().isEmpty && _allBowlsFilled()) {
      _completeRound();
    }
  }

  bool _allBowlsFilled() {
    for (var b = 0; b < _round.groups; b++) {
      if (_bowlIds(b).length != _round.quotient) return false;
    }
    return true;
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
          _roundSolved = false;
          _resetPlacements();
        });
        _speakPrompt();
      }
    });
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration) return;
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.division,
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
            child: Image.asset('assets/images/backround.png', fit: BoxFit.cover),
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
                          '➗ ${_roundIndex + 1}/$_totalRounds',
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
                    left: _round.total,
                    operator: '÷',
                    right: _round.groups,
                    result: _round.quotient,
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
              title: 'Super!',
              emoji: '🌟',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel: 'Done',
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.pushReplacement(AppRoutes.mathOperations);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _theme.color.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Expanded(
            child: _pileZone(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: List.generate(_round.groups, (bowlIndex) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: bowlIndex == _round.groups - 1 ? 0 : 8,
                    ),
                    child: _bowlZone(bowlIndex),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pileZone() {
    final ids = _pileIds();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _theme.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.color.withValues(alpha: 0.26), width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _objectGrid(
            ids: ids,
            constraints: constraints,
            color: _theme.color,
            draggable: true,
          );
        },
      ),
    );
  }

  Widget _bowlZone(int bowlIndex) {
    final ids = _bowlIds(bowlIndex);
    return MathOpDropZone(
      label: '${ids.length}/${_round.quotient}',
      emoji: '🥣',
      color: _theme.secondaryColor,
      softColor: _theme.softColor,
      isHighlighted: _isDragging,
      onWillAccept: (data) =>
          data is String &&
          !_roundSolved &&
          _placements[data] == null &&
          ids.length < _round.quotient,
      onAccept: (data) => _placeInBowl(data as String, bowlIndex),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ids.isEmpty) {
            return Center(
              child: Text(
                '${bowlIndex + 1}',
                style: AppTypography.numberDisplay.copyWith(
                  fontSize: 28,
                  color: _theme.secondaryColor.withValues(alpha: 0.55),
                ),
              ),
            );
          }
          return _objectGrid(
            ids: ids,
            constraints: constraints,
            color: _theme.secondaryColor,
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
    if (ids.isEmpty) {
      return Center(
        child: draggable
            ? Text(_theme.emoji, style: const TextStyle(fontSize: 40))
            : const SizedBox.shrink(),
      );
    }
    final columns = ids.length <= 3 ? ids.length : 3;
    const spacing = 8.0;
    final rows = (ids.length / columns).ceil();
    final size = math.min(
      68.0,
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
        children: ids.map((id) {
          if (!draggable) {
            return MathOpObjectToken(
              size: size,
              assetPath: _theme.assetPath,
              backgroundColor: color.withValues(alpha: 0.16),
            );
          }
          return MathOpDraggableItem<String>(
            data: id,
            size: size,
            assetPath: _theme.assetPath,
            backgroundColor: color.withValues(alpha: 0.18),
            enabled: !_roundSolved,
            onDragStarted: () {
              HapticFeedback.selectionClick();
              setState(() => _isDragging = true);
            },
            onDragEnd: () {
              if (mounted) setState(() => _isDragging = false);
            },
          );
        }).toList(),
      ),
    );
  }
}
