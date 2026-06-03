import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/celebration_bear.dart';
import '../kingdom_zone_data.dart';

Future<void> showKingdomUnlockDialog(
  BuildContext context,
  KingdomZoneData zone,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: zone.color.withValues(alpha: 0.35),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: zone.color.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: zone.softColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'New Kingdom Place Unlocked',
                  style: AppTypography.bodySmall.copyWith(
                    color: zone.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const CelebrationBear(size: 100),
              const SizedBox(height: 12),
              Text(zone.emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 8),
              Text(
                zone.title,
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(
                  color: const Color(0xFF1E1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your learning adventures opened a magical new place on the map.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: const Color(0xFF5A6B7A),
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: zone.color,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: AppTypography.button,
                  ),
                  child: const Text('Explore the Map'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
