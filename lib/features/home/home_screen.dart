import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = <_HomeTileData>[
      const _HomeTileData(
        title: 'Start Learning',
        subtitle: 'Open the real number recognition screen.',
        route: AppRoutes.numberRecognition,
        icon: Icons.play_arrow_rounded,
        color: AppColors.primary,
      ),
      const _HomeTileData(
        title: 'Counting',
        subtitle: 'Placeholder route',
        route: AppRoutes.counting,
        icon: Icons.looks_two_rounded,
        color: AppColors.secondary,
      ),
      const _HomeTileData(
        title: 'Tracing',
        subtitle: 'Placeholder route',
        route: AppRoutes.tracing,
        icon: Icons.gesture_rounded,
        color: AppColors.accent,
      ),
      const _HomeTileData(
        title: 'Matching',
        subtitle: 'Placeholder route',
        route: AppRoutes.matching,
        icon: Icons.view_week_rounded,
        color: AppColors.gardenGreen,
      ),
      const _HomeTileData(
        title: 'Addition',
        subtitle: 'Placeholder route',
        route: AppRoutes.addition,
        icon: Icons.add_circle_outline_rounded,
        color: AppColors.bridgeBlue,
      ),
      const _HomeTileData(
        title: 'Subtraction',
        subtitle: 'Placeholder route',
        route: AppRoutes.subtraction,
        icon: Icons.remove_circle_outline_rounded,
        color: AppColors.warning,
      ),
      const _HomeTileData(
        title: 'Sequencing',
        subtitle: 'Placeholder route',
        route: AppRoutes.sequencing,
        icon: Icons.stairs_rounded,
        color: AppColors.stairsLavender,
      ),
      const _HomeTileData(
        title: 'Patterns',
        subtitle: 'Placeholder route',
        route: AppRoutes.patterns,
        icon: Icons.auto_awesome_mosaic_rounded,
        color: AppColors.pathwayPeach,
      ),
      const _HomeTileData(
        title: 'Kingdom',
        subtitle: 'Placeholder route',
        route: AppRoutes.kingdom,
        icon: Icons.castle_rounded,
        color: AppColors.castleGray,
      ),
      const _HomeTileData(
        title: 'Sticker Album',
        subtitle: 'Placeholder route',
        route: AppRoutes.stickers,
        icon: Icons.star_border_rounded,
        color: AppColors.premiumGold,
      ),
      const _HomeTileData(
        title: 'Parent Dashboard',
        subtitle: 'Placeholder route',
        route: AppRoutes.parentDashboard,
        icon: Icons.lock_outline_rounded,
        color: AppColors.parentAccent,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.homeHighlight,
                        AppColors.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome to Math Kingdom', style: AppTypography.h1),
                      const SizedBox(height: 12),
                      Text(
                        'Splash navigation is now routed through go_router. Use this screen to open the working activity and all placeholder routes.',
                        style: AppTypography.body,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            context.go(AppRoutes.numberRecognition),
                        child: const Text('Continue To Number Recognition'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tile = tiles[index];
                    return _HomeRouteCard(tile: tile);
                  },
                  childCount: tiles.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeRouteCard extends StatelessWidget {
  const _HomeRouteCard({required this.tile});

  final _HomeTileData tile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => context.go(tile.route),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: tile.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(tile.icon, color: tile.color, size: 28),
                ),
                const Spacer(),
                Text(tile.title, style: AppTypography.cardTitle),
                const SizedBox(height: 6),
                Text(tile.subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTileData {
  const _HomeTileData({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
}
