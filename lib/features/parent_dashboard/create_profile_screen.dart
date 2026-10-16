import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/child_profile_service.dart';
import '../../shared/widgets/adaptive_hub_scaffold.dart';
import '../../shared/widgets/celebration_bear.dart';
import '../../shared/widgets/top_snackbar.dart';
import 'widgets/child_profile_sheet.dart';

/// Shown whenever no child profile exists: on a fresh install after
/// onboarding, and after a parent removes the last profile. The app cannot
/// be used until a profile is created.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool _saving = false;

  Future<void> _save(ChildProfileResult result) async {
    if (_saving) return;
    setState(() => _saving = true);
    await ChildProfileService.instance.addProfile(result.profile);
    if (result.applySuggestion) {
      await applyAgeSuggestion(suggestionForAge(result.profile.age ?? 5));
    }
    if (!mounted) return;
    TopSnackbar.hide(immediate: true);
    context.go(AppRoutes.home);
  }

  void _showProfileRequired() {
    TopSnackbar.show(
      context,
      message: context.tr('create_profile.back_blocked'),
      color: AppColors.parentAccent,
      softColor: const Color(0xFFEAF0FF),
      icon: Icons.child_care_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // A profile is required, so there is nowhere to go back to.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || ChildProfileService.instance.hasProfiles) return;
        _showProfileRequired();
      },
      child: AdaptiveHubScaffold(
        showBanner: false,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const CelebrationBear(size: 104),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('create_profile.title'),
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: const Color(0xFF1A1060),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('create_profile.subtitle'),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF1A1060),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outline, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AbsorbPointer(
                      absorbing: _saving,
                      child: ChildProfileForm(
                        embedded: true,
                        showCancel: false,
                        onSubmit: _save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
