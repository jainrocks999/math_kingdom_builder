import 'package:easy_localization/easy_localization.dart';
import 'package:emath_app/core/constants/app_colors.dart';
import 'package:emath_app/core/constants/app_typography.dart';
import 'package:emath_app/core/services/premium_service.dart';
import 'package:emath_app/features/parent_dashboard/widgets/parent_report_tabs.dart';
import 'package:emath_app/shared/widgets/top_snackbar.dart';
import 'package:flutter/material.dart';

class UpgradeToProCard extends StatefulWidget {
  const UpgradeToProCard({super.key});

  @override
  State<UpgradeToProCard> createState() => _UpgradeToProCardState();
}

class _UpgradeToProCardState extends State<UpgradeToProCard> {
  final _premium = PremiumService.instance;

  @override
  void initState() {
    super.initState();
    _premium.status.addListener(_onStatusChanged);
    if (_premium.product.value == null) _premium.loadProduct();
  }

  @override
  void dispose() {
    _premium.status.removeListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged() {
    if (!mounted) return;
    final key = switch (_premium.status.value) {
      PremiumStatus.purchased => 'premium.thank_you',
      PremiumStatus.pending => 'premium.pending',
      PremiumStatus.cancelled => 'premium.cancelled',
      PremiumStatus.error => 'premium.error',
      _ => null,
    };
    if (key == null) return;
    TopSnackbar.show(context,
        message: context.tr(key),
        color: AppColors.parentAccent,
        softColor: const Color(0xFFEAF0FF),
        icon: _premium.status.value == PremiumStatus.purchased
            ? Icons.celebration_rounded
            : Icons.info_outline_rounded);
  }

  Future<void> _buy() async {
    await _premium.buyRemoveAds();
  }

  Future<void> _restore() async {
    final restored = await _premium.restorePurchases();
    if (!mounted || restored) return;
    TopSnackbar.show(
      context,
      message: context.tr('premium.nothing_to_restore'),
      color: AppColors.parentAccent,
      softColor: const Color(0xFFEAF0FF),
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _premium.adsRemoved,
        builder: (context, adsRemoved, _) {
          if (adsRemoved) return const _ProActiveCard();

          return ParentCard(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🚫', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('premium.title'),
                          style: AppTypography.bodyStrong.copyWith(
                            color: parentInk,
                          ),
                        ),
                        Text(
                          context.tr('premium.subtitle'),
                          style: AppTypography.caption.copyWith(
                            color: parentMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<PremiumStatus>(
                  valueListenable: _premium.status,
                  builder: (context, status, _) {
                    final busy = status == PremiumStatus.loading;
                    return ValueListenableBuilder(
                      valueListenable: _premium.product,
                      builder: (context, product, _) => SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : _buy,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.parentAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  // Price comes from Google Play, in the
                                  // parent's own currency.
                                  product == null
                                      ? context.tr('premium.buy')
                                      : context.tr(
                                          'premium.buy_with_price',
                                          namedArgs: {'price': product.price},
                                        ),
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: _restore,
                  child: Text(
                    context.tr('premium.restore'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.parentAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ));
        });
  }
}

/// Shown after purchase: same gradient as the Overview progress card.
class _ProActiveCard extends StatelessWidget {
  const _ProActiveCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C7AEA), Color(0xFF7E62E0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C7AEA).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.tr('premium.active_title'),
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'PRO',
                        style: AppTypography.caption.copyWith(
                          color: parentInk,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('premium.active'),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
