import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';

class _OperationCardData {
  const _OperationCardData({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.route,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.available,
    required this.progressId,
  });

  final String title;
  final String emoji;
  final String subtitle;
  final String route;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final bool available;
  final String progressId;
}

class MathOperationsScreen extends StatefulWidget {
  const MathOperationsScreen({super.key});

  static const _operations = [
    _OperationCardData(
      title: 'Addition',
      emoji: '➕',
      subtitle: 'Combine groups',
      route: AppRoutes.addition,
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      available: true,
      progressId: RewardModuleIds.addition,
    ),
    _OperationCardData(
      title: 'Subtraction',
      emoji: '➖',
      subtitle: 'Take objects away',
      route: AppRoutes.subtraction,
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      available: true,
      progressId: RewardModuleIds.subtraction,
    ),
    _OperationCardData(
      title: 'Multiplication',
      emoji: '✖️',
      subtitle: 'Build equal groups',
      route: AppRoutes.multiplication,
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      available: true,
      progressId: RewardModuleIds.multiplication,
    ),
    _OperationCardData(
      title: 'Division',
      emoji: '➗',
      subtitle: 'Share into groups',
      route: AppRoutes.division,
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      available: true,
      progressId: RewardModuleIds.division,
    ),
  ];

  @override
  State<MathOperationsScreen> createState() => _MathOperationsScreenState();
}

class _MathOperationsScreenState extends State<MathOperationsScreen>
    with RouteAware {
  RewardProgressSnapshot _progressSnapshot = const RewardProgressSnapshot(
    totalStars: 0,
    completionCounts: {},
    claimedRewardIds: <String>{},
    todayCompletions: 0,
    streakDays: 0,
  );

  int get _completedOperations => MathOperationsScreen._operations
      .where(
        (operation) =>
            _progressSnapshot.completionCountFor(
              operation.progressId,
            ) >
            0,
      )
      .length;

  int get _mathStars => MathOperationsScreen._operations.fold(
        0,
        (sum, operation) =>
            sum +
            (_progressSnapshot.completionCountFor(operation.progressId) *
                RewardProgressService.instance.starsForModule(
                  operation.progressId,
                )),
      );

  Future<void> _loadProgress() async {
    final snapshot = await RewardProgressService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _progressSnapshot = snapshot;
    });
  }

  void _goBack(BuildContext context) {
    context.go(AppRoutes.startlearning);
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _loadProgress();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextPracticeGoal = (_completedOperations + 1)
        .clamp(1, MathOperationsScreen._operations.length);

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
                  const Color(0xFF87CEEB).withValues(alpha: 0.55),
                  AppColors.background.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _goBack(context),
                          child: const SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Math Ops',
                        style: AppTypography.hero.copyWith(
                          fontSize: AppTypography.responsiveSize(
                            MediaQuery.sizeOf(context).width,
                            min: 26,
                            max: 31,
                          ),
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.28),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FFB800),
                          offset: Offset(0, 10),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.premiumGoldLight,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: Text(
                                  '🧮',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Operation Adventure',
                                    style: AppTypography.cardTitle.copyWith(
                                      color: const Color(0xFF1E1060),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Practice all four operation worlds and keep building your star bank.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _HubMetricCard(
                                emoji: '⭐',
                                label: 'Math stars',
                                value: '$_mathStars',
                                color: AppColors.warning,
                                softColor: AppColors.premiumGoldLight,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HubMetricCard(
                                emoji: '🎯',
                                label: 'Played',
                                value:
                                    '$_completedOperations/${MathOperationsScreen._operations.length}',
                                color: AppColors.secondary,
                                softColor: AppColors.secondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _completedOperations /
                                MathOperationsScreen._operations.length,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _completedOperations ==
                                  MathOperationsScreen._operations.length
                              ? 'All four operations have progress. Amazing work!'
                              : 'Next milestone: complete $nextPracticeGoal of ${MathOperationsScreen._operations.length} operation adventures.',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF5A6B7A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2D1B69),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => _goBack(context),
                            child: const Text('Back to Start Learning'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Addition, subtraction, multiplication, and division in one place.',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF5A6B7A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...MathOperationsScreen._operations.map(
                    (operation) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OperationPlayCard(
                        data: operation,
                        completionCount: _progressSnapshot.completionCountFor(
                          operation.progressId,
                        ),
                        earnedStars: _progressSnapshot.completionCountFor(
                              operation.progressId,
                            ) *
                            RewardProgressService.instance.starsForModule(
                              operation.progressId,
                            ),
                        onTap: () => context.push(operation.route),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationPlayCard extends StatelessWidget {
  const _OperationPlayCard({
    required this.data,
    required this.completionCount,
    required this.earnedStars,
    required this.onTap,
  });

  final _OperationCardData data;
  final int completionCount;
  final int earnedStars;
  final VoidCallback onTap;

  double get _progressValue => (completionCount / 3).clamp(0, 1).toDouble();

  String get _statusLabel {
    if (!data.available) return 'Coming soon';
    if (completionCount == 0) return 'Start practice';
    if (completionCount >= 3) return 'Mastered';
    return '$completionCount win${completionCount == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: data.color.withValues(alpha: 0.45),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: data.shadowColor.withValues(alpha: 0.8),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: data.color.withValues(alpha: 0.18),
                offset: const Offset(0, 10),
                blurRadius: 22,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: data.softColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: data.color.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    data.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: AppTypography.cardTitle.copyWith(
                              color: const Color(0xFF1E1060),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: data.softColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$earnedStars ⭐',
                            style: AppTypography.caption.copyWith(
                              color: data.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF6E768A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _statusLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF5A6B7A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '$completionCount/3',
                          style: AppTypography.caption.copyWith(
                            color: data.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!data.available)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Soon',
                    style: AppTypography.bodySmall.copyWith(
                      color: data.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: data.color.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: data.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubMetricCard extends StatelessWidget {
  const _HubMetricCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: softColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1E1060),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
