import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'top_snackbar.dart';

/// Asks a question young children can't answer before something only a
/// grown-up should do (e.g. opening an ad, which leaves the app).
///
/// Returns true only when the right answer was tapped.
Future<bool> showParentalGate(BuildContext context) async {
  final passed = await showDialog<bool>(
    context: context,
    builder: (_) => const _ParentalGateDialog(),
  );
  if (passed == false && context.mounted) {
    TopSnackbar.show(
      context,
      message: context.tr('parental_gate.wrong'),
      color: AppColors.parentAccent,
      softColor: const Color(0xFFEAF0FF),
      icon: Icons.lock_outline_rounded,
    );
  }
  return passed == true;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  final _random = math.Random();
  late final int _a = 6 + _random.nextInt(4);
  late final int _b = 6 + _random.nextInt(4);
  late final int _answer = _a * _b;

  /// The right answer plus three nearby wrong ones, shuffled.
  late final List<int> _choices = () {
    final choices = <int>{_answer};
    while (choices.length < 4) {
      final offset = (_random.nextInt(4) + 1) * (_random.nextBool() ? 1 : -1);
      final wrong = _answer + offset * (_random.nextBool() ? 1 : _a);
      if (wrong > 0) choices.add(wrong);
    }
    return choices.toList()..shuffle(_random);
  }();

  static const _ink = Color(0xFF1E1060);
  static const _muted = Color(0xFF5A6B7A);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.parentAccent.withValues(alpha: 0.35),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.parentAccent.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5C7AEA), Color(0xFF7E62E0)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.parentAccent.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.tr('parental_gate.badge'),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.parentAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('parental_gate.title'),
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('parental_gate.message'),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: _muted,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.parentAccent.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    '$_a × $_b = ?',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1.copyWith(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.3,
                  children: [
                    for (final choice in _choices)
                      _AnswerTile(
                        value: choice,
                        onTap: () =>
                            Navigator.of(context).pop(choice == _answer),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.tr('parental_gate.cancel'),
                    style: AppTypography.bodyStrong.copyWith(color: _muted),
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

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.parentAccent.withValues(alpha: 0.15),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.parentAccent.withValues(alpha: 0.45),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.parentAccent.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$value',
              style: AppTypography.h2.copyWith(
                color: AppColors.parentAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
