import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class BouncingGameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String? trailingText;

  const BouncingGameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.trailingText,
  });

  @override
  State<BouncingGameButton> createState() => _BouncingGameButtonState();
}

class _BouncingGameButtonState extends State<BouncingGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: const Color(0xFFC44A1B), // The dark "casing" or bottom lip
          borderRadius: BorderRadius.circular(38),
          border: Border.all(
            color: Colors.white,
            width: 4, // Chunky white border
          ),
          boxShadow: [
            // Soft drop shadow on the ground
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            // --- The Button Face ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              top: _isPressed ? 8 : 0, // Physically slides down into the casing
              left: 0,
              right: 0,
              height: 60, // Fixed height for the face
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF9B73), // Glossy orange top
                      AppColors.primary, // Base primary orange
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // --- Cartoon Glass Reflection ---
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
                    // --- Button Content ---
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            Icon(
                              widget.leadingIcon,
                              color: Colors.white,
                              size: 32, // Increased size to match the chunky text
                              shadows: const [Shadow(color: Color(0xFFC44A1B), offset: Offset(0, 2))],
                            ),
                            if (widget.text.isNotEmpty) const SizedBox(width: 8),
                          ],
                          if (widget.text.isNotEmpty)
                            Text(
                              widget.text,
                              style: GoogleFonts.lilitaOne(
                                textStyle: AppTypography.button.copyWith(
                                  fontSize: 26,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  shadows: const [Shadow(color: Color(0xFFC44A1B), offset: Offset(0, 2), blurRadius: 0)],
                                ),
                              ),
                            ),
                          if (widget.trailingIcon != null) ...[
                            if (widget.text.isNotEmpty) const SizedBox(width: 8),
                            Icon(
                              widget.trailingIcon,
                              color: Colors.white,
                              size: 32, // Increased size to match the chunky text
                              shadows: const [Shadow(color: Color(0xFFC44A1B), offset: Offset(0, 2))],
                            ),
                          ],
                          if (widget.trailingText != null) ...[
                            if (widget.text.isNotEmpty) const SizedBox(width: 8),
                            Text(
                              widget.trailingText!,
                              style: GoogleFonts.lilitaOne(
                                textStyle: AppTypography.button.copyWith(
                                  fontSize: 26,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                  shadows: const [Shadow(color: Color(0xFFC44A1B), offset: Offset(0, 2), blurRadius: 0)],
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
    );
  }
}