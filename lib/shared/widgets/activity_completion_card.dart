import 'package:flutter/material.dart';

import '../../core/constants/app_typography.dart';
import 'celebration_bear.dart';

class ActivityCompletionCard extends StatelessWidget {
  const ActivityCompletionCard({
    super.key,
    required this.badgeText,
    required this.title,
    required this.message,
    required this.rewardText,
    required this.accentColor,
    required this.softColor,
    required this.shadowColor,
    required this.action,
    this.maxWidth = 390,
    this.bearSize = 132,
  });

  final String badgeText;
  final String title;
  final String message;
  final String rewardText;
  final Color accentColor;
  final Color softColor;
  final Color shadowColor;
  final Widget action;
  final double maxWidth;
  final double bearSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.22),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.24),
            blurRadius: 36,
            spreadRadius: 8,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: AppTypography.bodySmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          CelebrationBear(size: bearSize),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(
              color: const Color(0xFF1A1060),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: const Color(0xFF556172),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              rewardText,
              style: AppTypography.bodyStrong.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          action,
        ],
      ),
    );
  }
}
