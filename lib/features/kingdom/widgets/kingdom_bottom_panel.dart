import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../kingdom_zone_data.dart';
import 'kingdom_shared_widgets.dart';

class KingdomBottomPanel extends StatelessWidget {
  const KingdomBottomPanel({
    super.key,
    required this.activeZone,
    required this.recommendedZone,
    required this.totalStars,
    required this.todayCompletions,
    required this.onSelectZone,
    required this.onPlayActiveZone,
    required this.onPlayRecommended,
    required this.zones,
  });

  final KingdomZoneData activeZone;
  final KingdomZoneData recommendedZone;
  final int totalStars;
  final int todayCompletions;
  final ValueChanged<String> onSelectZone;
  final VoidCallback onPlayActiveZone;
  final VoidCallback onPlayRecommended;
  final List<KingdomZoneData> zones;

  @override
  Widget build(BuildContext context) {
    final canPlayActive =
        activeZone.playable && activeZone.unlocked && !activeZone.isComplete;
    final showActiveCta = canPlayActive || (activeZone.playable && activeZone.unlocked);

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
                child:
                    Text(activeZone.emoji, style: const TextStyle(fontSize: 28)),
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
              KingdomInfoPill(
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
              value: activeZone.progressFraction,
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
          if (showActiveCta) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPlayActiveZone,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(activeZone.ctaLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: activeZone.color,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: AppTypography.button,
                ),
              ),
            ),
          ],
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 520;

                final textColumn = Column(
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
                );

                final playButton = FilledButton(
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
                );

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          Expanded(child: textColumn),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: playButton),
                    ],
                  );
                }

                return Row(
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
                    Expanded(child: textColumn),
                    const SizedBox(width: 12),
                    playButton,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
