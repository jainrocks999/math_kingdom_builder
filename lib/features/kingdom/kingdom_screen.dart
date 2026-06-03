import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';
import '../../data/models/kingdom_state.dart';

class KingdomScreen extends StatefulWidget {
  const KingdomScreen({super.key});

  @override
  State<KingdomScreen> createState() => _KingdomScreenState();
}

class _KingdomScreenState extends State<KingdomScreen> with RouteAware {
  final TransformationController _mapController = TransformationController();

  RewardProgressSnapshot? _progressSnapshot;
  bool _isLoadingProgress = true;
  String? _selectedZoneId;

  @override
  void initState() {
    super.initState();
    _loadProgressSnapshot();
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
  void didPopNext() {
    _loadProgressSnapshot();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressSnapshot() async {
    final snapshot = await RewardProgressService.instance.loadSnapshot();
    if (!mounted) return;

    setState(() {
      _progressSnapshot = snapshot;
      _isLoadingProgress = false;
    });
  }

  void _resetMap() {
    _mapController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final kingdomsBox = Hive.box<KingdomState>('kingdoms');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFBEE7FF),
                      AppColors.background,
                      const Color(0xFFFFF3D9),
                    ],
                    stops: const [0.0, 0.56, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 80,
              left: -30,
              child: _Cloud(width: 120, height: 52),
            ),
            const Positioned(
              top: 150,
              right: 24,
              child: _Cloud(width: 96, height: 42),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, viewport) {
                  return ValueListenableBuilder<Box<KingdomState>>(
                    valueListenable:
                        kingdomsBox.listenable(keys: const ['current']),
                    builder: (context, box, _) {
                      final storedState =
                          box.get('current') ?? KingdomState.empty();
                      final zoneData = _buildZoneData(
                        storedState,
                        _progressSnapshot,
                      );
                      final recommendedZone = _recommendedZone(zoneData);
                      final activeZone = zoneData.firstWhere(
                        (zone) =>
                            zone.id == (_selectedZoneId ?? recommendedZone.id),
                        orElse: () => recommendedZone,
                      );

                      final mapCard = ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            border: Border.all(color: AppColors.outline),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 22,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: InteractiveViewer(
                                  transformationController: _mapController,
                                  boundaryMargin: const EdgeInsets.all(180),
                                  minScale: 0.78,
                                  maxScale: 2.2,
                                  child: _KingdomMapCanvas(
                                    zones: zoneData,
                                    activeZoneId: activeZone.id,
                                    onZoneTap: (zoneId) {
                                      setState(() => _selectedZoneId = zoneId);
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 14,
                                left: 14,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Drag to explore, tap a place to zoom in your mind.',
                                      style: AppTypography.caption,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isLoadingProgress)
                                const Positioned(
                                  right: 16,
                                  top: 16,
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                      final bottomPanel = _KingdomBottomPanel(
                        activeZone: activeZone,
                        recommendedZone: recommendedZone,
                        totalStars: _progressSnapshot?.totalStars ?? 0,
                        todayCompletions:
                            _progressSnapshot?.todayCompletions ?? 0,
                        onSelectZone: (zoneId) {
                          setState(() => _selectedZoneId = zoneId);
                        },
                        onPlayRecommended: () {
                          context.push(recommendedZone.route);
                        },
                        zones: zoneData,
                      );

                      final mapHeight = viewport.maxHeight < 720
                          ? math.max(300.0, viewport.maxHeight * 0.46)
                          : math.min(540.0, viewport.maxHeight * 0.58);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewport.maxHeight,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  4,
                                  0,
                                  4,
                                  8,
                                ),
                                child: _KingdomTopBar(
                                  stars: _progressSnapshot?.totalStars ?? 0,
                                  streakDays:
                                      _progressSnapshot?.streakDays ?? 0,
                                  onBack: () => context.go(AppRoutes.home),
                                  onResetView: _resetMap,
                                ),
                              ),
                              SizedBox(
                                height: mapHeight,
                                child: mapCard,
                              ),
                              const SizedBox(height: 12),
                              bottomPanel,
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_ZoneViewData> _buildZoneData(
  KingdomState storedState,
  RewardProgressSnapshot? progress,
) {
  final learnProgress =
      (progress?.completionCountFor(RewardModuleIds.learnNumbers) ?? 0) +
          (progress?.completionCountFor(RewardModuleIds.findNumber) ?? 0);
  final countingProgress =
      progress?.completionCountFor(RewardModuleIds.countObjects) ?? 0;
  final tracingProgress =
      progress?.completionCountFor(RewardModuleIds.traceNumbers) ?? 0;
  final matchingProgress =
      progress?.completionCountFor(RewardModuleIds.matchNumbers) ?? 0;

  final zones = <_ZoneViewData>[
    _ZoneViewData(
      id: 'garden',
      title: 'Number Garden',
      subtitle: 'Flowers bloom when number lessons are done.',
      hint: 'Practice number recognition to grow brighter flowers.',
      route: AppRoutes.findNumber,
      ctaLabel: 'Play Number Quest',
      emoji: '🌷',
      icon: Icons.local_florist_rounded,
      color: AppColors.gardenGreen,
      softColor: const Color(0xFFE2F7E5),
      rect: const Rect.fromLTWH(80, 360, 270, 180),
      progress: math.max(storedState.gardenItems.length, learnProgress),
      goal: 8,
      unlocked: true,
      playable: true,
      itemCount: math.max(storedState.gardenItems.length, learnProgress),
    ),
    _ZoneViewData(
      id: 'meadow',
      title: 'Counting Meadow',
      subtitle: 'Animals gather here after counting adventures.',
      hint: 'Count objects to invite more meadow friends.',
      route: AppRoutes.counting,
      ctaLabel: 'Play Counting Quest',
      emoji: '🐑',
      icon: Icons.pets_rounded,
      color: AppColors.meadowYellow,
      softColor: const Color(0xFFFFF1BF),
      rect: const Rect.fromLTWH(395, 250, 285, 190),
      progress: math.max(storedState.meadowItems.length, countingProgress),
      goal: 6,
      unlocked: storedState.gardenItems.isNotEmpty || learnProgress > 0,
      playable: true,
      itemCount: math.max(storedState.meadowItems.length, countingProgress),
    ),
    _ZoneViewData(
      id: 'castle',
      title: 'Shape Castle',
      subtitle: 'Trace carefully and the castle rises stone by stone.',
      hint: 'Tracing numbers builds stronger walls and towers.',
      route: AppRoutes.tracing,
      ctaLabel: 'Play Tracing Quest',
      emoji: '🏰',
      icon: Icons.castle_rounded,
      color: AppColors.castleGray,
      softColor: const Color(0xFFF0F0F0),
      rect: const Rect.fromLTWH(760, 120, 270, 230),
      progress: math.max(storedState.castleItems.length, tracingProgress),
      goal: 6,
      unlocked: storedState.meadowItems.isNotEmpty || countingProgress > 0,
      playable: true,
      itemCount: math.max(storedState.castleItems.length, tracingProgress),
    ),
    _ZoneViewData(
      id: 'path',
      title: 'Pattern Pathway',
      subtitle: 'Matching wins add shining tiles to the walkway.',
      hint: 'Matching quests are a good stand-in until pattern play arrives.',
      route: AppRoutes.matching,
      ctaLabel: 'Play Matching Quest',
      emoji: '🔷',
      icon: Icons.auto_awesome_mosaic_rounded,
      color: AppColors.pathwayPeach,
      softColor: const Color(0xFFFFE5D6),
      rect: const Rect.fromLTWH(420, 540, 335, 120),
      progress:
          math.max(storedState.patternDecorations.length, matchingProgress),
      goal: 5,
      unlocked: storedState.castleItems.isNotEmpty || tracingProgress > 0,
      playable: true,
      itemCount:
          math.max(storedState.patternDecorations.length, matchingProgress),
    ),
    _ZoneViewData(
      id: 'bridge',
      title: 'Math Bridge',
      subtitle: 'Bridge stones will appear when addition opens soon.',
      hint: 'This zone is ready for the future addition quest.',
      route: AppRoutes.startlearning,
      ctaLabel: 'Open Start Learning',
      emoji: '🌉',
      icon: Icons.architecture_rounded,
      color: AppColors.bridgeBlue,
      softColor: const Color(0xFFD8F6F3),
      rect: const Rect.fromLTWH(780, 470, 250, 150),
      progress: storedState.bridgeLength,
      goal: 6,
      unlocked:
          storedState.patternDecorations.isNotEmpty || matchingProgress > 0,
      playable: false,
      itemCount: storedState.bridgeLength,
      sunshine: storedState.bridgeSunshine,
    ),
    _ZoneViewData(
      id: 'stairs',
      title: 'Sequence Stairs',
      subtitle: 'Each future sequence quest will raise another step.',
      hint: 'This staircase will light up after sequencing is built.',
      route: AppRoutes.startlearning,
      ctaLabel: 'Open Start Learning',
      emoji: '🪜',
      icon: Icons.stairs_rounded,
      color: AppColors.stairsLavender,
      softColor: const Color(0xFFF0E8FF),
      rect: const Rect.fromLTWH(105, 115, 220, 160),
      progress: storedState.staircaseSteps,
      goal: 6,
      unlocked: storedState.bridgeLength > 0,
      playable: false,
      itemCount: storedState.staircaseSteps,
    ),
  ];

  return zones;
}

_ZoneViewData _recommendedZone(List<_ZoneViewData> zones) {
  for (final zone in zones) {
    if (zone.playable && zone.unlocked && zone.progress < zone.goal) {
      return zone;
    }
  }

  return zones.firstWhere(
    (zone) => zone.playable,
    orElse: () => zones.first,
  );
}

class _KingdomTopBar extends StatelessWidget {
  const _KingdomTopBar({
    required this.stars,
    required this.streakDays,
    required this.onBack,
    required this.onResetView,
  });

  final int stars;
  final int streakDays;
  final VoidCallback onBack;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleActionButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 320;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Kingdom',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.h2.copyWith(
                              fontSize: compact ? 22 : 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Every quest adds something magical to this map.',
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoPill(
                                icon: Icons.star_rounded,
                                label:
                                    compact ? '$stars stars' : '$stars stars',
                                color: AppColors.premiumGold,
                              ),
                              _InfoPill(
                                icon: Icons.local_fire_department_rounded,
                                label: compact
                                    ? '${math.max(streakDays, 0)} day streak'
                                    : '${math.max(streakDays, 0)} day streak',
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _CircleActionButton(
          icon: Icons.center_focus_strong_rounded,
          onTap: onResetView,
        ),
      ],
    );
  }
}

class _KingdomMapCanvas extends StatelessWidget {
  const _KingdomMapCanvas({
    required this.zones,
    required this.activeZoneId,
    required this.onZoneTap,
  });

  final List<_ZoneViewData> zones;
  final String activeZoneId;
  final ValueChanged<String> onZoneTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1180,
      height: 860,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFCBEEFF),
                    const Color(0xFFE8F8FF),
                    const Color(0xFFCCEEAF),
                    const Color(0xFFACE08A),
                  ],
                  stops: const [0.0, 0.26, 0.27, 1.0],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 230,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFA1D66A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 720,
            top: 520,
            child: Transform.rotate(
              angle: -0.32,
              child: Container(
                width: 340,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FD6F6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 245,
            top: 444,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                width: 550,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7D8A3),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...zones.expand(
            (zone) => [
              _ZoneAreaWidget(
                zone: zone,
                isActive: zone.id == activeZoneId,
                onTap: () => onZoneTap(zone.id),
              ),
              ..._zoneItems(zone),
            ],
          ),
          const Positioned(
            left: 880,
            top: 42,
            child: _Cloud(width: 112, height: 50),
          ),
          const Positioned(
            left: 320,
            top: 64,
            child: _Cloud(width: 86, height: 38),
          ),
        ],
      ),
    );
  }
}

List<Widget> _zoneItems(_ZoneViewData zone) {
  if (!zone.unlocked) {
    return [
      Positioned(
        left: zone.rect.left + 22,
        top: zone.rect.top + 18,
        child: const _Cloud(width: 84, height: 36),
      ),
      Positioned(
        left: zone.rect.right - 110,
        top: zone.rect.top + zone.rect.height / 2 - 10,
        child: const _Cloud(width: 90, height: 40),
      ),
    ];
  }

  final items = <Widget>[];
  switch (zone.id) {
    case 'garden':
      for (var i = 0; i < zone.itemCount; i++) {
        final column = i % 4;
        final row = i ~/ 4;
        items.add(
          Positioned(
            left: zone.rect.left + 28 + (column * 52) + (row.isOdd ? 10 : 0),
            top: zone.rect.bottom - 48 - (row * 32),
            child: const _MapItemBubble(
              icon: Icons.local_florist_rounded,
              color: AppColors.gardenGreen,
              glowColor: Color(0xFF93E89C),
            ),
          ),
        );
      }
      break;
    case 'meadow':
      for (var i = 0; i < zone.itemCount; i++) {
        final column = i % 3;
        final row = i ~/ 3;
        items.add(
          Positioned(
            left: zone.rect.left + 36 + (column * 70),
            top: zone.rect.top + 72 + (row * 34),
            child: const _MapItemBubble(
              icon: Icons.pets_rounded,
              color: AppColors.warning,
              glowColor: Color(0xFFFFE9B0),
            ),
          ),
        );
      }
      break;
    case 'castle':
      for (var i = 0; i < zone.itemCount; i++) {
        final width = 36.0 + (i * 8);
        final height = 26.0 + (i * 12);
        items.add(
          Positioned(
            left: zone.rect.left + 40 + (i * 26),
            top: zone.rect.bottom - height - 18,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.castleGray.withValues(alpha: 0.95),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.castle_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }
      break;
    case 'path':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 32 + (i * 54),
            top: zone.rect.top + 38 + ((i.isEven ? 0 : 14)),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.pathwayPeach,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        );
      }
      break;
    case 'bridge':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 18 + (i * 28),
            top: zone.rect.top + 74 - ((i % 2) * 6),
            child: Container(
              width: 20,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFF3D08B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7B26C)),
              ),
            ),
          ),
        );
      }
      if (zone.sunshine) {
        items.add(
          Positioned(
            right: 40,
            top: zone.rect.top - 28,
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 36,
              color: AppColors.accent,
            ),
          ),
        );
      }
      break;
    case 'stairs':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 26 + (i * 20),
            top: zone.rect.bottom - 28 - (i * 12),
            child: Container(
              width: 48,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.stairsLavender,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      }
      break;
  }

  return items;
}

class _ZoneAreaWidget extends StatelessWidget {
  const _ZoneAreaWidget({
    required this.zone,
    required this.isActive,
    required this.onTap,
  });

  final _ZoneViewData zone;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = !zone.unlocked;

    return Positioned.fromRect(
      rect: zone.rect,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 145;
              final cozy = constraints.maxHeight < 180;
              final padding = compact ? 12.0 : (cozy ? 14.0 : 18.0);
              final titleStyle = compact
                  ? AppTypography.bodyStrong.copyWith(
                      color: isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    )
                  : AppTypography.h3.copyWith(
                      color: isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    );

              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.white.withValues(alpha: 0.50)
                      : zone.softColor
                          .withValues(alpha: isActive ? 0.96 : 0.82),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isActive
                        ? zone.color
                        : zone.color.withValues(alpha: isLocked ? 0.28 : 0.55),
                    width: isActive ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          zone.color.withValues(alpha: isActive ? 0.22 : 0.10),
                      blurRadius: isActive ? 22 : 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          zone.emoji,
                          style: TextStyle(fontSize: compact ? 20 : 26),
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Expanded(
                          child: Text(
                            zone.title,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                        if (!zone.playable)
                          _MiniBadge(
                            label: 'Soon',
                            color: AppColors.info,
                          ),
                      ],
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    if (!compact)
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            isLocked
                                ? 'Unlock this place by growing earlier zones.'
                                : zone.subtitle,
                            maxLines: cozy ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: compact ? 1.2 : 1.35,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        isLocked
                            ? 'Unlock by growing earlier zones.'
                            : zone.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(height: compact ? 6 : 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: compact ? 8 : 10,
                        value: (zone.progress / math.max(zone.goal, 1))
                            .clamp(0, 1),
                        backgroundColor: Colors.white.withValues(alpha: 0.75),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLocked ? AppColors.disabled : zone.color,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    Text(
                      '${zone.progress}/${zone.goal} kingdom rewards',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: isLocked
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _KingdomBottomPanel extends StatelessWidget {
  const _KingdomBottomPanel({
    required this.activeZone,
    required this.recommendedZone,
    required this.totalStars,
    required this.todayCompletions,
    required this.onSelectZone,
    required this.onPlayRecommended,
    required this.zones,
  });

  final _ZoneViewData activeZone;
  final _ZoneViewData recommendedZone;
  final int totalStars;
  final int todayCompletions;
  final ValueChanged<String> onSelectZone;
  final VoidCallback onPlayRecommended;
  final List<_ZoneViewData> zones;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: activeZone.softColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(activeZone.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeZone.title, style: AppTypography.h3),
                    const SizedBox(height: 4),
                    Text(activeZone.hint, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _InfoPill(
                icon: Icons.star_rounded,
                label: '$totalStars total',
                color: AppColors.premiumGold,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: (activeZone.progress / math.max(activeZone.goal, 1))
                  .clamp(0, 1),
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(
                activeZone.unlocked ? activeZone.color : AppColors.disabled,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activeZone.unlocked
                ? '${activeZone.progress}/${activeZone.goal} rewards placed here'
                : 'This area is still hidden behind kingdom clouds.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: zones
                .map(
                  (zone) => ChoiceChip(
                    label: Text(zone.title),
                    selected: zone.id == activeZone.id,
                    onSelected: (_) => onSelectZone(zone.id),
                    selectedColor: zone.softColor,
                    backgroundColor: AppColors.surfaceMuted,
                    labelStyle: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: zone.id == activeZone.id
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: zone.id == activeZone.id
                            ? zone.color
                            : AppColors.outline,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: recommendedZone.softColor.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: recommendedZone.color.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.explore_rounded,
                    color: recommendedZone.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next best quest', style: AppTypography.bodyStrong),
                      const SizedBox(height: 4),
                      Text(
                        '${recommendedZone.title} is the fastest way to grow the kingdom now.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Today completed: $todayCompletions quest${todayCompletions == 1 ? '' : 's'}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: onPlayRecommended,
                  style: FilledButton.styleFrom(
                    backgroundColor: recommendedZone.color,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    textStyle: AppTypography.button,
                  ),
                  child: Text(recommendedZone.ctaLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapItemBubble extends StatefulWidget {
  const _MapItemBubble({
    required this.icon,
    required this.color,
    required this.glowColor,
  });

  final IconData icon;
  final Color color;
  final Color glowColor;

  @override
  State<_MapItemBubble> createState() => _MapItemBubbleState();
}

class _MapItemBubbleState extends State<_MapItemBubble> {
  bool _active = false;

  void _triggerPop() {
    if (_active) return;
    setState(() => _active = true);
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _active = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerPop,
      child: AnimatedScale(
        scale: _active ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _active ? widget.glowColor : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _active ? 0.35 : 0.18),
                blurRadius: _active ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.color, width: 2),
          ),
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.12,
            top: height * 0.18,
            child: _CloudPuff(size: height * 0.58),
          ),
          Positioned(
            left: width * 0.34,
            top: 0,
            child: _CloudPuff(size: height * 0.72),
          ),
          Positioned(
            right: width * 0.10,
            top: height * 0.14,
            child: _CloudPuff(size: height * 0.56),
          ),
          Positioned(
            left: width * 0.2,
            right: width * 0.16,
            bottom: 0,
            child: Container(
              height: height * 0.42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudPuff extends StatelessWidget {
  const _CloudPuff({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ZoneViewData {
  const _ZoneViewData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.route,
    required this.ctaLabel,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.rect,
    required this.progress,
    required this.goal,
    required this.unlocked,
    required this.playable,
    required this.itemCount,
    this.sunshine = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String hint;
  final String route;
  final String ctaLabel;
  final String emoji;
  final IconData icon;
  final Color color;
  final Color softColor;
  final Rect rect;
  final int progress;
  final int goal;
  final bool unlocked;
  final bool playable;
  final int itemCount;
  final bool sunshine;
}
