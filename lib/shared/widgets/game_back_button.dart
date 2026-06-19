import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GameBackButton extends StatelessWidget {
  const GameBackButton({
    super.key,
    required this.onTap,
    this.size = 52,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FF6B35),
                offset: Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF2D1B69),
            size: 28,
          ),
        ),
      ),
    );
  }
}
