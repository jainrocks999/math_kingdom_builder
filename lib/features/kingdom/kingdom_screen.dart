import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../data/models/kingdom_state.dart';
import '../../data/models/reward_catalog.dart';
import '../../shared/widgets/bottom_banner_layout.dart';
import '../../shared/widgets/game_back_button.dart';
import '../../shared/widgets/kid_loading_view.dart';
import '../../core/utils/responsive_layout.dart';
import 'kingdom_service.dart';
import 'kingdom_zone_data.dart';
import 'widgets/journey_path.dart';
import 'widgets/journey_sections.dart';
import 'widgets/kingdom_shared_widgets.dart';
import 'widgets/kingdom_unlock_dialog.dart';

/// "My Journey Map": the child's learning path, the activities they have
/// performed and the badges they have earned.
class KingdomScreen extends StatefulWidget {
  const KingdomScreen({super.key});

  @override
  State<KingdomScreen> createState() => _KingdomScreenState();
}

class _KingdomScreenState extends State<KingdomScreen> with RouteAware {
  final Map<String, GlobalKey> _zoneKeys = {};

  RewardProgressSnapshot? _progressSnapshot;
  bool _isLoading = true;
  bool _didAutoScroll = false;
  int _musicRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _playAmbientMusic(delayed: true);
    _refreshJourney();
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
    _playAmbientMusic(delayed: true);
    _refreshJourney();
  }

  @override
  void didPush() {
    _playAmbientMusic(delayed: true);
  }

  @override
  void didPushNext() {
    _stopAmbientMusic();
  }

  @override
  void dispose() {
    _musicRequestToken++;
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _playAmbientMusic({bool delayed = false}) {
    final requestToken = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted || requestToken != _musicRequestToken) return;
        AppAudioService.instance.playKingdomMusic();
      },
    );
  }

  void _stopAmbientMusic() {
    _musicRequestToken++;
    AppAudioService.instance.stopBackgroundMusic();
  }

  GlobalKey _keyForZone(String zoneId) =>
      _zoneKeys.putIfAbsent(zoneId, GlobalKey.new);

  Future<void> _refreshJourney() async {
    setState(() => _isLoading = true);

    final syncResult = await KingdomService.instance.loadSyncedState();
    if (!mounted) return;

    setState(() {
      _progressSnapshot = syncResult.progress;
      _isLoading = false;
    });

    final zones = buildKingdomZones(syncResult.state, syncResult.progress);
    if (!_didAutoScroll) {
      _didAutoScroll = true;
      _scrollToZone(recommendedKingdomZone(zones).id);
    }
    _showUnlockCelebrations(syncResult, zones);
  }

  void _scrollToZone(String zoneId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _zoneKeys[zoneId]?.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.45,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _showUnlockCelebrations(
    KingdomSyncResult syncResult,
    List<KingdomZoneData> zones,
  ) async {
    if (syncResult.newlyUnlockedZoneIds.isEmpty || !mounted) return;

    final newlyUnlocked = zones
        .where((zone) => syncResult.newlyUnlockedZoneIds.contains(zone.id))
        .toList();

    for (final zone in newlyUnlocked) {
      if (!mounted) return;
      _scrollToZone(zone.id);
      await showKingdomUnlockDialog(context, zone);
    }
  }

  void _openZone(KingdomZoneData zone) {
    if (!zone.playable || !zone.unlocked) return;
    _openRoute(zone.route);
  }

  void _openRoute(String route) {
    _stopAmbientMusic();
    context.push(route);
  }

  void _showStop(KingdomZoneData zone, KingdomZoneData recommendedZone) {
    showJourneyStopSheet(
      context,
      zone: zone,
      status: journeyStopStatus(zone, recommendedZone),
      onPlay: () => _openZone(zone),
    );
  }

  void _showFinish(bool journeyComplete) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            context.tr(
              journeyComplete
                  ? 'kingdom.journey_complete'
                  : 'kingdom.finish_locked',
            ),
          ),
        ),
      );
  }

  void _goBack() {
    _musicRequestToken++;
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
      body: ScreenBannerHost(
        child: Stack(
          children: [
            // Same background image and tint as the home hub screens.
            Positioned.fill(
              child: Image.asset(
                'assets/images/backround.png',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: AdaptiveContentWidth(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _JourneyHeader(
                        onBack: _goBack,
                        isRefreshing: _isLoading && _progressSnapshot != null,
                      ),
                    ),
                    Expanded(
                      child: _progressSnapshot == null
                          ? KidLoadingView(
                              title: context.tr('kingdom.loading'),
                            )
                          : ValueListenableBuilder<Box<KingdomState>>(
                              valueListenable: kingdomsBox
                                  .listenable(keys: const ['current']),
                              builder: (context, box, _) => _buildJourney(
                                box.get('current') ?? KingdomState.empty(),
                                _progressSnapshot!,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourney(
    KingdomState storedState,
    RewardProgressSnapshot progress,
  ) {
    final zones = buildKingdomZones(storedState, progress);
    final recommendedZone = recommendedKingdomZone(zones);
    final journeyComplete = zones.every((zone) => zone.isComplete);
    final placesDone = zones.where((zone) => zone.isComplete).length;
    final totalActivities = progress.completionCounts.values
        .fold<int>(0, (total, count) => total + count);
    final badgesUnlocked = rewardCatalog
        .where((reward) => reward.unlockStars <= progress.totalStars)
        .length;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refreshJourney,
      // Not a lazy ListView: the path stops must be built for
      // Scrollable.ensureVisible to reach them.
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JourneyStatsRow(
              stars: progress.totalStars,
              activities: totalActivities,
              badgesUnlocked: badgesUnlocked,
              badgesTotal: rewardCatalog.length,
              streakDays: progress.streakDays,
            ),
            const SizedBox(height: 14),
            JourneyContinueCard(
              recommendedZone: recommendedZone,
              journeyComplete: journeyComplete,
              todayCompletions: progress.todayCompletions,
              onContinue: () => _openZone(recommendedZone),
            ),
            const SizedBox(height: 22),
            JourneySectionHeader(
              title: '🗺️ ${context.tr('kingdom.path_title')}',
              trailing: KingdomMiniBadge(
                label: context.tr(
                  'kingdom.places_done',
                  namedArgs: {
                    'done': '$placesDone',
                    'total': '${zones.length}',
                  },
                ),
                color: AppColors.gardenGreen,
              ),
            ),
            JourneyCard(
              color: Colors.white.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: JourneyPath(
                zones: zones,
                recommendedZone: recommendedZone,
                zoneKeys: {
                  for (final zone in zones) zone.id: _keyForZone(zone.id)
                },
                onZoneTap: (zone) => _showStop(zone, recommendedZone),
                onFinishTap: () => _showFinish(journeyComplete),
              ),
            ),
            const SizedBox(height: 22),
            JourneySectionHeader(
              title: '🏅 ${context.tr('kingdom.badges_title')}',
              trailing: TextButton(
                onPressed: () => _openRoute(AppRoutes.stickers),
                child: Text(
                  context.tr('kingdom.see_all'),
                  style: AppTypography.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            JourneyBadgesStrip(
              stars: progress.totalStars,
              onOpenAlbum: () => _openRoute(AppRoutes.stickers),
            ),
            const SizedBox(height: 22),
            JourneySectionHeader(
              title: '🎯 ${context.tr('kingdom.activities_title')}',
            ),
            JourneyActivityLog(
              completionCounts: progress.completionCounts,
              onPlay: (activity) => _openRoute(activity.route),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.onBack, required this.isRefreshing});

  final VoidCallback onBack;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GameBackButton(onTap: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('kingdom.title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h2,
              ),
              Text(
                context.tr('kingdom.subtitle'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        if (isRefreshing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
