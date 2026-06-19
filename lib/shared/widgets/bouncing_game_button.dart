import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class BouncingGameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? trailingText;
  final String? trailingSvgIcon;

  const BouncingGameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.trailingText,
    this.trailingSvgIcon,
  });

  @override
  State<BouncingGameButton> createState() => _BouncingGameButtonState();
}

class _BouncingGameButtonState extends State<BouncingGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(38),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFC44A1B),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  top: _isPressed ? 8 : 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF9B73),
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 4,
                          left: 20,
                          right: 20,
                          height: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.leadingIcon != null) ...[
                                Icon(
                                  widget.leadingIcon,
                                  color: Colors.white,
                                  size: 32,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFFC44A1B),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                if (widget.text.isNotEmpty)
                                  const SizedBox(width: 8),
                              ],
                              if (widget.text.isNotEmpty)
                                Text(
                                  widget.text,
                                  style: AppTypography.buttonLarge.copyWith(
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFFC44A1B),
                                        offset: Offset(0, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              if (widget.trailingIcon != null) ...[
                                if (widget.text.isNotEmpty)
                                  const SizedBox(width: 8),
                                Icon(
                                  widget.trailingIcon,
                                  color: Colors.white,
                                  size: 32,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFFC44A1B),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ],
                              if (widget.trailingText != null) ...[
                                if (widget.text.isNotEmpty)
                                  const SizedBox(width: 8),
                                Text(
                                  widget.trailingText!,
                                  style: AppTypography.buttonLarge.copyWith(
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xFFC44A1B),
                                        offset: Offset(0, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (widget.trailingSvgIcon != null) ...[
                                if (widget.text.isNotEmpty)
                                  const SizedBox(width: 8),
                                SizedBox(
                                  width: 32,
                                  height: 34,
                                  child: SvgPicture.asset(
                                    widget.trailingSvgIcon!,
                                    width: 32,
                                    height: 32,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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
