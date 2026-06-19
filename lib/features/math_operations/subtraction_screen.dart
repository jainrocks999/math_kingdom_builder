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

class _SubtractionRound {
  const _SubtractionRound({
    required this.total,
    required this.removeCount,
    required this.themeIndex,
  });

  final int total;
  final int removeCount;
  final int themeIndex;

  int get remaining => total - removeCount;
}

class SubtractionScreen extends StatefulWidget {
  const SubtractionScreen({super.key});

  @override
  State<SubtractionScreen> createState() => _SubtractionScreenState();
}

class _SubtractionScreenState extends State<SubtractionScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;

  late final FlutterTts _tts;
  late final Future<void> _ttsReady;
  late final AnimationController _successPulseController;
  late final List<_SubtractionRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();
  final Set<String> _removedObjectIds = <String>{};

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int _failedDragCount = 0;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _SubtractionRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];
  List<String> get _allIds => List.generate(_round.total, (i) => 'T_$i');

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

  List<_SubtractionRound> _buildRoundPlan() {
    const combos = <(int, int)>[
      (3, 1),
      (4, 1),
      (4, 2),
      (5, 1),
      (5, 2),
      (5, 3),
      (3, 2),
      (4, 3),
    ];
    final shuffled = [...combos]..shuffle(_random);
    return List.generate(
      _totalRounds,
      (i) => _SubtractionRound(
        total: shuffled[i].$1,
        removeCount: shuffled[i].$2,
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
    await _tts.speak(
      '${_round.total} minus ${_round.removeCount} equals what? Take away ${_round.removeCount}.',
    );
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak(
      '${_round.total} minus ${_round.removeCount} equals ${_round.remaining}',
    );
  }

  void _removeObject(String id) {
    if (_roundSolved || _showCelebration || _removedObjectIds.contains(id)) {
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _removedObjectIds.add(id));
    if (_removedObjectIds.length == _round.removeCount) {
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
          _removedObjectIds.clear();
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

  void _removeAllNeeded() {
    if (_roundSolved || _showCelebration) return;
    final remainingToRemove = _allIds
        .where((id) => !_removedObjectIds.contains(id))
        .take(_round.removeCount - _removedObjectIds.length);
    HapticFeedback.mediumImpact();
    setState(() {
      _removedObjectIds.addAll(remainingToRemove);
      _isDragging = false;
    });
    if (_removedObjectIds.length == _round.removeCount) {
      _completeRound();
    }
  }

  void _showFinalCelebration() {
    if (!mounted || _showCelebration) return;
    _stopScreenMusic();
    RewardProgressService.instance.recordModuleCompletion(
      RewardModuleIds.subtraction,
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
                          '➖ ${_roundIndex + 1}/$_totalRounds',
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
                    operator: '-',
                    right: _round.removeCount,
                    result: _round.remaining,
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
              title: 'Amazing!',
              emoji: '☀️',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel: 'Multiplication',
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.pushReplacement(AppRoutes.multiplication);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: mathOpStageDecoration(_theme.color),
      child: Column(
        children: [
          Text(
            'Drag or tap the objects you want to take away.',
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
                onPressed: _removeAllNeeded,
                icon: const Icon(Icons.touch_app_rounded),
                label: const Text('Need help? Tap to take away'),
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
            flex: 2,
            child: _groupTray(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _removalZone(),
          ),
        ],
      ),
    );
  }

  Widget _groupTray() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _theme.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _theme.color.withValues(alpha: 0.26),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Take away ${_round.removeCount}',
                style: AppTypography.bodyStrong.copyWith(
                  color: _theme.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${_round.total - _removedObjectIds.length} left here',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF5B6778),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final visibleIds = _allIds;
                return _objectGrid(
                  ids: visibleIds,
                  constraints: constraints,
                  color: _theme.color,
                  removed: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _removalZone() {
    return MathOpDropZone(
      label: '${_removedObjectIds.length}/${_round.removeCount}',
      emoji: '🌤️',
      color: _theme.secondaryColor,
      softColor: _theme.softColor,
      isHighlighted: _isDragging,
      onWillAccept: (data) =>
          data is String &&
          !_roundSolved &&
          !_removedObjectIds.contains(data) &&
          _removedObjectIds.length < _round.removeCount,
      onAccept: (data) => _removeObject(data as String),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_removedObjectIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_theme.emoji, style: const TextStyle(fontSize: 42)),
                  const SizedBox(height: 8),
                  Text(
                    'Drag objects here to take them away',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF5B6778),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          return _objectGrid(
            ids: _removedObjectIds.toList(),
            constraints: constraints,
            color: _theme.secondaryColor,
            removed: true,
          );
        },
      ),
    );
  }

  Widget _objectGrid({
    required List<String> ids,
    required BoxConstraints constraints,
    required Color color,
    required bool removed,
  }) {
    if (ids.isEmpty) return const SizedBox.shrink();
    final columns = ids.length <= 3 ? ids.length : 3;
    const spacing = 8.0;
    const interactivePadding = 8.0;
    final rows = (ids.length / columns).ceil();
    final availableWidth =
        (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
    final availableHeight =
        (constraints.maxHeight - ((rows - 1) * spacing)) / rows;
    final size = math.max(
      38.0,
      math.min(
        removed ? 70.0 : 64.0,
        math.min(
          availableWidth - (removed ? 0 : interactivePadding),
          availableHeight - (removed ? 0 : interactivePadding),
        ),
      ),
    );

    return Center(
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        alignment: WrapAlignment.center,
        children: ids.map((id) {
          if (removed) {
            return MathOpObjectToken(
              size: size,
              assetPath: _theme.assetPath,
              backgroundColor: color.withValues(alpha: 0.16),
            );
          }

          final isRemoved = _removedObjectIds.contains(id);
          return MathOpDraggableItem<String>(
            data: id,
            size: size,
            assetPath: _theme.assetPath,
            backgroundColor: color.withValues(alpha: 0.18),
            enabled: !isRemoved && !_roundSolved,
            onTap: () => _removeObject(id),
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
