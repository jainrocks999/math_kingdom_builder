import 'package:easy_localization/easy_localization.dart';
import 'package:emath_app/features/parent_dashboard/widgets/upgrade_to_pro_card.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/parent_controls_service.dart';
import '../../../core/services/performance_service.dart';
import '../../kingdom/journey_activity_data.dart';
import '../parent_insights.dart';
import 'parent_report_tabs.dart';

/// Daily time limit, activities on/off, child profile, sound and data.
class ParentControlsTab extends StatefulWidget {
  const ParentControlsTab({
    super.key,
    required this.profileSwitcher,
    required this.audioSettings,
    required this.onDataChanged,
  });

  final Widget profileSwitcher;
  final Widget audioSettings;

  /// Called after a change that affects the reports, so they reload.
  final VoidCallback onDataChanged;

  @override
  State<ParentControlsTab> createState() => _ParentControlsTabState();
}

class _ParentControlsTabState extends State<ParentControlsTab> {
  final _controls = ParentControlsService.instance;

  Future<void> _setLimit(int minutes) async {
    await _controls.setDailyLimitMinutes(minutes);
    if (mounted) setState(() {});
    widget.onDataChanged();
  }

  Future<void> _addBonus() async {
    await _controls.addBonusMinutesToday(15);
    if (!mounted) return;
    setState(() {});
    widget.onDataChanged();
    _toast(context.tr('parent_dashboard.controls.bonus_added'));
  }

  Future<void> _resetToday() async {
    await _controls.resetTodayUsage();
    if (!mounted) return;
    setState(() {});
    widget.onDataChanged();
    _toast(context.tr('parent_dashboard.controls.timer_reset'));
  }

  Future<void> _toggleModule(String moduleId, bool enabled) async {
    await _controls.setModuleEnabled(moduleId, enabled);
    if (mounted) setState(() {});
  }

  Future<void> _clearReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('parent_dashboard.controls.clear_title')),
        content: Text(dialogContext.tr('parent_dashboard.controls.clear_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('parent_dashboard.controls.cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE5554A),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              dialogContext.tr('parent_dashboard.controls.clear_confirm'),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await PerformanceService.instance.clear();
    if (!mounted) return;
    widget.onDataChanged();
    _toast(context.tr('parent_dashboard.controls.cleared'));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final limit = _controls.dailyLimitMinutes;
    final bonus = _controls.bonusMinutesToday;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
         ParentSectionTitle('⭐ ${context.tr('premium.section_title')}'),   // ← add
        const UpgradeToProCard(),  
        ParentSectionTitle(
          '⏰ ${context.tr('parent_dashboard.controls.time_title')}',
          subtitle: context.tr('parent_dashboard.controls.time_subtitle'),
        ),
        ParentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ParentControlsService.dailyLimitOptions)
                    ChoiceChip(
                      label: Text(
                        option == 0
                            ? context.tr('parent_dashboard.controls.no_limit')
                            : context.tr(
                                'parent_dashboard.minutes_short',
                                namedArgs: {'count': '$option'},
                              ),
                      ),
                      selected: option == limit,
                      onSelected: (_) => _setLimit(option),
                      selectedColor:
                          AppColors.parentAccent.withValues(alpha: 0.18),
                      labelStyle: AppTypography.bodySmall.copyWith(
                        color: parentInk,
                        fontWeight:
                            option == limit ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                limit == 0
                    ? context.tr(
                        'parent_dashboard.controls.used_today',
                        namedArgs: {
                          'time':
                              formatMinutes(context, _controls.todaySeconds),
                        },
                      )
                    : context.tr(
                        'parent_dashboard.controls.used_of_limit',
                        namedArgs: {
                          'time':
                              formatMinutes(context, _controls.todaySeconds),
                          'limit': '${_controls.effectiveLimitMinutes}',
                        },
                      ),
                style: AppTypography.bodySmall.copyWith(
                  color: parentInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (bonus > 0)
                Text(
                  context.tr(
                    'parent_dashboard.controls.bonus_today',
                    namedArgs: {'count': '$bonus'},
                  ),
                  style: AppTypography.caption.copyWith(color: parentMuted),
                ),
              if (limit > 0) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _addBonus,
                      icon: const Icon(Icons.more_time_rounded),
                      label: Text(
                        context.tr('parent_dashboard.controls.add_15'),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetToday,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(
                        context.tr('parent_dashboard.controls.reset_timer'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        ParentSectionTitle(
          '🎮 ${context.tr('parent_dashboard.controls.activities_title')}',
          subtitle: context.tr('parent_dashboard.controls.activities_subtitle'),
        ),
        ParentCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              for (final activity in journeyActivities)
                SwitchListTile.adaptive(
                  value: _controls.isModuleEnabled(activity.moduleId),
                  onChanged: (enabled) =>
                      _toggleModule(activity.moduleId, enabled),
                  activeTrackColor: AppColors.parentAccent,
                  secondary: Text(
                    activity.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    moduleTitle(context, activity.moduleId),
                    style: AppTypography.bodySmall.copyWith(
                      color: parentInk,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ParentSectionTitle(
          '🧒 ${context.tr('parent_dashboard.child_profile_title')}',
          subtitle: context.tr('parent_dashboard.child_profile_subtitle'),
        ),
        widget.profileSwitcher,
        ParentSectionTitle(
          '🔊 ${context.tr('parent_dashboard.audio_title')}',
          subtitle: context.tr('parent_dashboard.audio_subtitle'),
        ),
        widget.audioSettings,
        ParentSectionTitle(
          '🔐 ${context.tr('parent_dashboard.controls.privacy_title')}',
        ),
        ParentCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE5554A),
                ),
                title: Text(
                  context.tr('parent_dashboard.controls.clear_title'),
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFFE5554A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  context.tr('parent_dashboard.controls.clear_subtitle'),
                  style: AppTypography.caption.copyWith(color: parentMuted),
                ),
                onTap: _clearReport,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
