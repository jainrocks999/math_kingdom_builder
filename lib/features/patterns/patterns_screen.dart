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
import '../math_operations/math_operation_theme.dart';
import '../math_operations/math_operation_widgets.dart';

enum _PatternKind { ab, abb }

enum _PatternShape { circle, square, triangle }

class _PatternPiece {
  const _PatternPiece({
    required this.name,
    required this.color,
    required this.shape,
  });

  final String name;
  final Color color;
  final _PatternShape shape;
}

class _PatternRound {
  const _PatternRound({
    required this.kind,
    required this.sequence,
    required this.correctIndex,
    required this.options,
    required this.themeIndex,
    required this.stageLabelKey,
    required this.promptKey,
  });

  final _PatternKind kind;
  final List<int> sequence;
  final int correctIndex;
  final List<int> options;
  final int themeIndex;
  final String stageLabelKey;
  final String promptKey;
}

class PatternsScreen extends StatefulWidget {
  const PatternsScreen({super.key});

  @override
  State<PatternsScreen> createState() => _PatternsScreenState();
}

class _PatternsScreenState extends State<PatternsScreen>
    with TickerProviderStateMixin, RouteAware {
  static const _totalRounds = 8;

  static const _pieces = [
    _PatternPiece(
      name: 'red circle',
      color: AppColors.primary,
      shape: _PatternShape.circle,
    ),
    _PatternPiece(
      name: 'blue square',
      color: AppColors.bridgeBlue,
      shape: _PatternShape.square,
    ),
    _PatternPiece(
      name: 'gold triangle',
      color: AppColors.warning,
      shape: _PatternShape.triangle,
    ),
  ];

  late final FlutterTts _tts;
  late Future<void> _ttsReady;
  bool _ttsConfigured = false;
  late final AnimationController _successPulseController;
  late final List<_PatternRound> _rounds;
  final AudioService _feedbackAudio = AudioService();
  final math.Random _random = math.Random();

  int _musicRequestToken = 0;
  int _autoAdvanceToken = 0;
  int _roundIndex = 0;
  int _wrongAttempts = 0;
  int? _filledIndex;
  bool _roundSolved = false;
  bool _showCelebration = false;
  bool _isDragging = false;

  _PatternRound get _round => _rounds[_roundIndex];
  MathOperationTheme get _theme => mathOperationThemes[_round.themeIndex];
  int get _correctIndex => _round.correctIndex;
  bool get _showHint => _wrongAttempts >= 2;

  String get _spokenPatternPrompt {
    final spokenPieces = _round.sequence
        .map((index) => _pieces[index].name)
        .toList(growable: true)
      ..add(context.tr('learning.sequence_blank'));
    return '${context.tr('learning.${_round.stageLabelKey}')}. '
        '${spokenPieces.join(', ')}. '
        '${context.tr('pattern_prompts.${_round.promptKey}')}';
  }

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
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  List<_PatternRound> _buildRoundPlan() {
    final rounds = <_PatternRound>[
      _buildRound(
        kind: _PatternKind.ab,
        fullPattern: const [0, 1, 0, 1, 0],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_ab',
        promptKey: 'ab_next',
      ),
      _buildRound(
        kind: _PatternKind.ab,
        fullPattern: const [1, 0, 1, 0, 1],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_ab',
        promptKey: 'ab_turns',
      ),
      _buildRound(
        kind: _PatternKind.ab,
        fullPattern: const [0, 2, 0, 2, 0],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_ab',
        promptKey: 'ab_repeating',
      ),
      _buildRound(
        kind: _PatternKind.ab,
        fullPattern: const [2, 1, 2, 1, 2],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_ab',
        promptKey: 'ab_repeating_piece',
      ),
      _buildRound(
        kind: _PatternKind.abb,
        fullPattern: const [0, 1, 1, 0, 1, 1],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_abb',
        promptKey: 'abb_two_same',
      ),
      _buildRound(
        kind: _PatternKind.abb,
        fullPattern: const [1, 0, 0, 1, 0, 0],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_abb',
        promptKey: 'abb_group_three',
      ),
      _buildRound(
        kind: _PatternKind.abb,
        fullPattern: const [2, 1, 1, 2, 1, 1],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_abb',
        promptKey: 'abb_repeat_three',
      ),
      _buildRound(
        kind: _PatternKind.abb,
        fullPattern: const [1, 2, 2, 1, 2, 2],
        options: const [0, 1, 2],
        stageLabelKey: 'patterns_abb',
        promptKey: 'abb_complete_group',
      ),
    ];

    return rounds.asMap().entries.map((entry) {
      final round = entry.value;
      return _PatternRound(
        kind: round.kind,
        sequence: round.sequence,
        correctIndex: round.correctIndex,
        options: round.options.toList()..shuffle(_random),
        themeIndex: entry.key % mathOperationThemes.length,
        stageLabelKey: round.stageLabelKey,
        promptKey: round.promptKey,
      );
    }).toList();
  }

  _PatternRound _buildRound({
    required _PatternKind kind,
    required List<int> fullPattern,
    required List<int> options,
    required String stageLabelKey,
    required String promptKey,
  }) {
    return _PatternRound(
      kind: kind,
      sequence: fullPattern.sublist(0, fullPattern.length - 1),
      correctIndex: fullPattern.last,
      options: options,
      themeIndex: 0,
      stageLabelKey: stageLabelKey,
      promptKey: promptKey,
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
    await _tts.speak(_spokenPatternPrompt);
  }

  Future<void> _speakSuccess() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak(_pieces[_correctIndex].name);
  }

  void _registerWrongAttempt() {
    HapticFeedback.lightImpact();
    _feedbackAudio.playWrongFeedback();
    if (mounted) {
      setState(() => _wrongAttempts++);
    }
  }

  void _placePiece(int pieceIndex) {
    if (_roundSolved || _showCelebration || _filledIndex != null) return;

    if (pieceIndex != _correctIndex) {
      _registerWrongAttempt();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _filledIndex = pieceIndex;
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
          _filledIndex = null;
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
      RewardModuleIds.patterns,
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
                          '🔷 ${_roundIndex + 1}/$_totalRounds',
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
              title: context.tr('learning.patterns_complete'),
              emoji: '🔷',
              color: _theme.color,
              softColor: _theme.softColor,
              buttonLabel: context.tr('placeholder.back_to_home'),
              onButtonTap: () {
                AppAudioService.instance.stopCelebrationMusic();
                context.go(AppRoutes.home);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: mathOpStageDecoration(_theme.color),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPromptCard(),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: math.max(0, constraints.maxWidth - 12),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var i = 0; i < _round.sequence.length; i++)
                          _patternPiece(_round.sequence[i]),
                        _missingPieceSlot(),
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
      },
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _theme.softColor.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.14),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.08),
            offset: const Offset(0, 10),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _theme.color.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pattern_rounded,
                          color: Color(0xFF1A1060),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('learning.${_round.stageLabelKey}'),
                            style: AppTypography.bodyStrong.copyWith(
                              color: _theme.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('pattern_prompts.${_round.promptKey}'),
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
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _theme.color.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    context.tr(
                      'learning.round',
                      namedArgs: {
                        'current': '${_roundIndex + 1}',
                        'total': '$_totalRounds',
                      },
                    ),
                    style: AppTypography.caption.copyWith(
                      color: _theme.color,
                      fontWeight: FontWeight.w800,
                    ),
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
        border: Border.all(color: const Color(0xFFF2D468), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26F2D468),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x14F2D468),
            offset: Offset(0, 10),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr('learning.patterns_prompt'),
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

  Widget _patternPiece(int index) {
    final piece = _pieces[index];
    return _PatternToken(piece: piece, size: 72);
  }

  Widget _missingPieceSlot() {
    if (_filledIndex != null) {
      return _PatternToken(
        piece: _pieces[_filledIndex!],
        size: 72,
        highlight: true,
      );
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        if (_roundSolved) return false;
        if (details.data != _correctIndex) {
          _registerWrongAttempt();
          return false;
        }
        return true;
      },
      onAcceptWithDetails: (details) => _placePiece(details.data),
      builder: (context, candidate, rejected) {
        final active = _isDragging || candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _theme.softColor.withValues(alpha: active ? 0.75 : 0.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  active ? _theme.color : _theme.color.withValues(alpha: 0.35),
              width: active ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _theme.color.withValues(alpha: active ? 0.24 : 0.14),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: _theme.color.withValues(alpha: active ? 0.14 : 0.08),
                offset: const Offset(0, 10),
                blurRadius: 14,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '?',
              style: AppTypography.numberDisplay.copyWith(
                fontSize: 32,
                color: _theme.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _optionsTray() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: _theme.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.14),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: _theme.color.withValues(alpha: 0.08),
            offset: const Offset(0, 10),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('learning.patterns_drag_hint'),
            style: AppTypography.bodyStrong.copyWith(
              color: _theme.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _round.options.map((index) {
              final used = _filledIndex == index;
              return _DraggablePatternPiece(
                pieceIndex: index,
                piece: _pieces[index],
                enabled: !used && !_roundSolved,
                onTap: () => _placePiece(index),
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

class _PatternToken extends StatelessWidget {
  const _PatternToken({
    required this.piece,
    required this.size,
    this.highlight = false,
  });

  final _PatternPiece piece;
  final double size;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: piece.color.withValues(alpha: highlight ? 0.35 : 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlight ? piece.color : Colors.white,
          width: highlight ? 3 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: piece.color.withValues(alpha: 0.30),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: piece.color.withValues(alpha: 0.10),
            offset: const Offset(0, 10),
            blurRadius: 14,
          ),
        ],
      ),
      child: Center(child: _PatternShapeIcon(piece: piece, size: size * 0.48)),
    );
  }
}

class _PatternShapeIcon extends StatelessWidget {
  const _PatternShapeIcon({required this.piece, required this.size});

  final _PatternPiece piece;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (piece.shape) {
      case _PatternShape.circle:
        return Icon(Icons.circle, size: size, color: piece.color);
      case _PatternShape.square:
        return Icon(Icons.crop_square_rounded, size: size, color: piece.color);
      case _PatternShape.triangle:
        return Icon(
          Icons.change_history_rounded,
          size: size,
          color: piece.color,
        );
    }
  }
}

class _DraggablePatternPiece extends StatelessWidget {
  const _DraggablePatternPiece({
    required this.pieceIndex,
    required this.piece,
    required this.enabled,
    required this.onTap,
    this.onDragStarted,
    this.onDragEnd,
  });

  final int pieceIndex;
  final _PatternPiece piece;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    const size = 78.0;

    Widget token({double scale = 1, bool ghost = false}) {
      return Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: ghost ? 0.24 : 1,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: enabled ? onTap : null,
              child: _PatternToken(piece: piece, size: size),
            ),
          ),
        ),
      );
    }

    if (!enabled) {
      return token(ghost: true);
    }

    return LongPressDraggable<int>(
      data: pieceIndex,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      delay: const Duration(milliseconds: 180),
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        child: token(scale: 1.15),
      ),
      childWhenDragging: token(ghost: true),
      onDragStarted: onDragStarted,
      onDragCompleted: onDragEnd,
      onDraggableCanceled: (_, __) => onDragEnd?.call(),
      onDragEnd: (_) => onDragEnd?.call(),
      child: token(),
    );
  }
}
