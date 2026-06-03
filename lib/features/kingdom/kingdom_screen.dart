import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';
import '../../data/models/kingdom_state.dart';
import 'kingdom_service.dart';
import 'kingdom_zone_data.dart';
import 'widgets/kingdom_bottom_panel.dart';
import 'widgets/kingdom_map_canvas.dart';
import 'widgets/kingdom_shared_widgets.dart';
import 'widgets/kingdom_top_bar.dart';
import 'widgets/kingdom_unlock_dialog.dart';

class KingdomScreen extends StatefulWidget {
  const KingdomScreen({super.key});

  @override
  State<KingdomScreen> createState() => _KingdomScreenState();
}

class _KingdomScreenState extends State<KingdomScreen> with RouteAware {
  final TransformationController _mapController = TransformationController();

  RewardProgressSnapshot? _progressSnapshot;
  bool _isLoading = true;
  String? _selectedZoneId;
  Size _mapViewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _refreshKingdom();
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
    _refreshKingdom();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refreshKingdom() async {
    setState(() => _isLoading = true);

    final syncResult = await KingdomService.instance.loadSyncedState();
    if (!mounted) return;

    setState(() {
      _progressSnapshot = syncResult.progress;
      _isLoading = false;
    });

    _showUnlockCelebrations(syncResult);
  }

  Future<void> _showUnlockCelebrations(KingdomSyncResult syncResult) async {
    if (syncResult.newlyUnlockedZoneIds.isEmpty || !mounted) return;

    final zones = buildKingdomZones(syncResult.state, syncResult.progress);
    final newlyUnlocked = zones
        .where((zone) => syncResult.newlyUnlockedZoneIds.contains(zone.id))
        .toList()
      ..sort((a, b) => a.rect.top.compareTo(b.rect.top));

    for (final zone in newlyUnlocked) {
      if (!mounted) return;
      setState(() => _selectedZoneId = zone.id);
      _focusOnZone(zone);
      await showKingdomUnlockDialog(context, zone);
    }
  }

  void _resetMapView() {
    _mapController.value = Matrix4.identity();
  }

  void _focusOnZone(KingdomZoneData zone) {
    if (_mapViewportSize == Size.zero) return;

    final scale = math.min(
      1.35,
      math.max(
        0.85,
        (_mapViewportSize.width / zone.rect.width) * 0.92,
      ),
    );
    final dx = -zone.rect.center.dx * scale + _mapViewportSize.width / 2;
    final dy = -zone.rect.center.dy * scale + _mapViewportSize.height / 2;

    _mapController.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _handleZoneTap(KingdomZoneData zone) {
    setState(() => _selectedZoneId = zone.id);
    _focusOnZone(zone);
  }

  void _handleSelectZone(String zoneId, List<KingdomZoneData> zones) {
    final zone = zones.firstWhere(
      (entry) => entry.id == zoneId,
      orElse: () => zones.first,
    );
    setState(() => _selectedZoneId = zoneId);
    _focusOnZone(zone);
  }

  void _openQuest(KingdomZoneData zone) {
    if (!zone.playable || !zone.unlocked) return;
    context.push(zone.route);
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
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
              child: KingdomCloud(width: 120, height: 52),
            ),
            const Positioned(
              top: 150,
              right: 24,
              child: KingdomCloud(width: 96, height: 42),
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
                      final zones = buildKingdomZones(
                        storedState,
                        _progressSnapshot,
                      );
                      final recommendedZone = recommendedKingdomZone(zones);
                      final activeZone = zones.firstWhere(
                        (zone) =>
                            zone.id == (_selectedZoneId ?? recommendedZone.id),
                        orElse: () => recommendedZone,
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
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                                child: KingdomTopBar(
                                  stars: _progressSnapshot?.totalStars ?? 0,
                                  streakDays:
                                      _progressSnapshot?.streakDays ?? 0,
                                  onBack: _goBack,
                                  onResetView: _resetMapView,
                                ),
                              ),
                              SizedBox(
                                height: mapHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      border: Border.all(
                                        color: AppColors.outline,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.shadow,
                                          blurRadius: 22,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, mapConstraints) {
                                        _mapViewportSize = Size(
                                          mapConstraints.maxWidth,
                                          mapConstraints.maxHeight,
                                        );

                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: InteractiveViewer(
                                                transformationController:
                                                    _mapController,
                                                boundaryMargin:
                                                    const EdgeInsets.all(180),
                                                minScale: 0.78,
                                                maxScale: 2.2,
                                                child: KingdomMapCanvas(
                                                  zones: zones,
                                                  activeZoneId: activeZone.id,
                                                  recommendedZoneId:
                                                      recommendedZone.id,
                                                  onZoneTap: _handleZoneTap,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 14,
                                              left: 14,
                                              right: 14,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                          alpha: 0.92,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(999),
                                                        border: Border.all(
                                                          color:
                                                              AppColors.outline,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                        child: Text(
                                                          'Drag to explore • Tap a place to focus',
                                                          style: AppTypography
                                                              .caption,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (_isLoading) ...[
                                                    const SizedBox(width: 10),
                                                    const SizedBox(
                                                      width: 26,
                                                      height: 26,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2.4,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _KingdomMascotHint(recommendedZone: recommendedZone),
                              const SizedBox(height: 10),
                              KingdomBottomPanel(
                                activeZone: activeZone,
                                recommendedZone: recommendedZone,
                                totalStars: _progressSnapshot?.totalStars ?? 0,
                                todayCompletions:
                                    _progressSnapshot?.todayCompletions ?? 0,
                                onSelectZone: (zoneId) =>
                                    _handleSelectZone(zoneId, zones),
                                onPlayActiveZone: () => _openQuest(activeZone),
                                onPlayRecommended: () =>
                                    _openQuest(recommendedZone),
                                zones: zones,
                              ),
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

class _KingdomMascotHint extends StatelessWidget {
  const _KingdomMascotHint({required this.recommendedZone});

  final KingdomZoneData recommendedZone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: recommendedZone.softColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: recommendedZone.color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Text(recommendedZone.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendedZone.isComplete
                  ? 'Amazing! Try another zone or replay a favorite quest.'
                  : 'Let us grow ${recommendedZone.title} today!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
