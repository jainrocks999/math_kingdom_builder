import 'package:flutter/material.dart';
import 'package:math_kingdom_builder/app_colors.dart';
import 'package:math_kingdom_builder/app_typography.dart';

class NumberBlock extends StatefulWidget {
  final int number;
  final VoidCallback? onTap;
  final bool isSelected;
  final double size;

  const NumberBlock({
    super.key,
    required this.number,
    this.onTap,
    this.isSelected = false,
    this.size = 120,
  });

  @override
  State<NumberBlock> createState() => _NumberBlockState();
}

class _NumberBlockState extends State<NumberBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.secondary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.secondary
                  : AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.number}',
              style: AppTypography.numberDisplay.copyWith(
                fontSize: widget.size * 0.6,
                color: widget.isSelected
                    ? AppColors.surface
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}