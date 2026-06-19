import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

BoxDecoration mathOpStageDecoration(
  Color color, {
  double radius = 28,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: color.withValues(alpha: 0.20),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.24),
        offset: const Offset(0, 6),
        blurRadius: 0,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.10),
        offset: const Offset(0, 12),
        blurRadius: 22,
      ),
    ],
  );
}

class MathOpCircleButton extends StatelessWidget {
  const MathOpCircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      shadowColor: color.withValues(alpha: 0.18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.16),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class MathOpProgressPill extends StatelessWidget {
  const MathOpProgressPill({
    super.key,
    required this.color,
    required this.softColor,
    required this.progress,
  });

  final Color color;
  final Color softColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 98,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${(progress * 100).round()}%',
            style: AppTypography.bodyStrong.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: softColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class MathOpObjectToken extends StatelessWidget {
  const MathOpObjectToken({
    super.key,
    required this.size,
    required this.assetPath,
    required this.backgroundColor,
    this.removed = false,
    this.dragging = false,
  });

  final double size;
  final String assetPath;
  final Color backgroundColor;
  final bool removed;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.08 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedOpacity(
        opacity: removed ? 0.12 : 1,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dragging
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.92),
              width: dragging ? 3 : 1.5,
            ),
            boxShadow: dragging
                ? [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: size * 0.46,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Large, easy-to-grab draggable object for young children.
class MathOpDraggableItem<T extends Object> extends StatelessWidget {
  const MathOpDraggableItem({
    super.key,
    required this.data,
    required this.size,
    required this.assetPath,
    required this.backgroundColor,
    required this.enabled,
    this.placeholderOpacity = 0.15,
    this.onTap,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
    this.onDragCanceled,
  });

  final T data;
  final double size;
  final String assetPath;
  final Color backgroundColor;
  final bool enabled;
  final double placeholderOpacity;
  final VoidCallback? onTap;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDragCanceled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return MathOpObjectToken(
        size: size,
        assetPath: assetPath,
        backgroundColor: backgroundColor,
        removed: true,
      );
    }

    final feedbackSize = size * 1.22;

    return Draggable<T>(
      data: data,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: backgroundColor.withValues(alpha: 0.45),
        child: MathOpObjectToken(
          size: feedbackSize,
          assetPath: assetPath,
          backgroundColor: backgroundColor,
          dragging: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: placeholderOpacity,
        child: MathOpObjectToken(
          size: size,
          assetPath: assetPath,
          backgroundColor: backgroundColor,
        ),
      ),
      onDragStarted: onDragStarted,
      onDragCompleted: onDragCompleted,
      onDraggableCanceled: (_, __) => onDragCanceled?.call(),
      onDragEnd: (_) => onDragEnd?.call(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: MathOpObjectToken(
              size: size,
              assetPath: assetPath,
              backgroundColor: backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}

class MathOpDropZone extends StatelessWidget {
  const MathOpDropZone({
    super.key,
    required this.label,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.isHighlighted,
    required this.child,
    this.onWillAccept,
    this.onAccept,
  });

  final String label;
  final String emoji;
  final Color color;
  final Color softColor;
  final bool isHighlighted;
  final Widget child;
  final bool Function(Object? data)? onWillAccept;
  final void Function(Object data)? onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (details) =>
          onWillAccept?.call(details.data) ?? true,
      onAcceptWithDetails: (details) => onAccept?.call(details.data),
      builder: (context, candidate, rejected) {
        final active = isHighlighted || candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: softColor.withValues(alpha: active ? 0.62 : 0.30),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active ? color : color.withValues(alpha: 0.26),
              width: active ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: active ? 0.24 : 0.14),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: color.withValues(alpha: active ? 0.16 : 0.08),
                offset: const Offset(0, 10),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swipe_rounded, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '$emoji $label',
                    style: AppTypography.bodyStrong.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class MathOpEquationBanner extends StatelessWidget {
  const MathOpEquationBanner({
    super.key,
    required this.left,
    required this.operator,
    required this.right,
    required this.result,
    required this.solved,
    required this.color,
    required this.softColor,
  });

  final int left;
  final String operator;
  final int right;
  final int? result;
  final bool solved;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: solved
            ? AppColors.correctFeedback.withValues(alpha: 0.40)
            : softColor.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: solved
              ? AppColors.gardenGreen.withValues(alpha: 0.72)
              : color.withValues(alpha: 0.20),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (solved ? AppColors.gardenGreen : color).withValues(
              alpha: 0.18,
            ),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            offset: const Offset(0, 10),
            blurRadius: 18,
          ),
        ],
      ),
      child: FittedBox(
        child: Text(
          '$left $operator $right = ${solved ? result : '?'}',
          style: AppTypography.numberDisplay.copyWith(
            fontSize: 44,
            color: const Color(0xFF1A1060),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class MathOpCelebrationOverlay extends StatelessWidget {
  const MathOpCelebrationOverlay({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.buttonLabel,
    required this.onButtonTap,
  });

  final String title;
  final String emoji;
  final Color color;
  final Color softColor;
  final String buttonLabel;
  final VoidCallback onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      child: SafeArea(
        child: Center(
          child: Container(
            width: 340,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border:
                  Border.all(color: color.withValues(alpha: 0.22), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.24),
                  blurRadius: 36,
                  spreadRadius: 8,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1A1060),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onButtonTap,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(buttonLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
