import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/audio_settings_service.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/services/parent_controls_service.dart';
import '../../core/services/performance_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/responsive_layout.dart';
import '../../shared/widgets/game_back_button.dart';
import '../../shared/widgets/kid_loading_view.dart';
import '../../shared/widgets/bottom_banner_layout.dart';
import 'parent_insights.dart';
import '../../data/models/child_profile.dart';
import 'widgets/child_profile_sheet.dart';
import 'widgets/parent_controls_tab.dart';
import 'widgets/parent_report_tabs.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isLoading = true;

  RewardProgressSnapshot? _progress;
  PerformanceReport? _report;
  ChildProfileSnapshot? _profiles;
  AudioSettingsSnapshot _audioSettings = const AudioSettingsSnapshot(
    musicEnabled: true,
    sfxEnabled: true,
    speechRateMode: 'normal',
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// The Parent Zone opens straight to the dashboard (no PIN).
  Future<void> _bootstrap() async {
    await _loadDashboardData();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadDashboardData() async {
    final progress = await RewardProgressService.instance.loadSnapshot();
    final report = await PerformanceService.instance.loadReport();
    final profiles = await ChildProfileService.instance.loadSnapshot();
    final audioSettings = await AudioSettingsService.instance.loadSnapshot();
    await ParentControlsService.instance.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _report = report;
      _profiles = profiles;
      _audioSettings = audioSettings;
    });
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  Future<void> _updateMusicEnabled(bool enabled) async {
    await AudioSettingsService.instance.setMusicEnabled(enabled);
    if (!enabled) {
      await AppAudioService.instance.stopBackgroundMusic();
    }
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: enabled,
        sfxEnabled: _audioSettings.sfxEnabled,
        speechRateMode: _audioSettings.speechRateMode,
      );
    });
  }

  Future<void> _updateSfxEnabled(bool enabled) async {
    await AudioSettingsService.instance.setSfxEnabled(enabled);
    AudioService().setSfxEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: _audioSettings.musicEnabled,
        sfxEnabled: enabled,
        speechRateMode: _audioSettings.speechRateMode,
      );
    });
  }

  Future<void> _updateSpeechRateMode(String mode) async {
    await AudioSettingsService.instance.setSpeechRateMode(mode);
    AudioService().setSpeechRate(mode);
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: _audioSettings.musicEnabled,
        sfxEnabled: _audioSettings.sfxEnabled,
        speechRateMode: mode,
      );
    });
  }

  Future<void> _switchProfile(int index) async {
    await ChildProfileService.instance.setActiveProfileIndex(index);
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parentBackground,
      body: ScreenBannerHost(
        child: SafeArea(
          child: AdaptiveContentWidth(
            child: _isLoading
                ? KidLoadingView(
                    title: context.tr('parent_dashboard.title'),
                    subtitle: context.tr('parent_dashboard.loading_subtitle'),
                    color: AppColors.parentAccent,
                    compact: true,
                  )
                : _buildDashboard(),
          ),
        ),
      ),
    );
  }

  String get _childName {
    final profiles = _profiles;
    if (profiles == null || profiles.profiles.isEmpty) {
      return context.tr('parent_dashboard.your_child');
    }
    return profiles.activeProfile.name;
  }

  Future<void> _practice(String moduleId) async {
    final activity = activityFor(moduleId);
    if (activity == null) return;
    await context.push(activity.route);
    await _loadDashboardData();
  }

  Widget _buildDashboard() {
    final progress = _progress;
    final report = _report;
    if (progress == null || report == null) {
      return KidLoadingView(
        title: context.tr('parent_dashboard.title'),
        subtitle: context.tr('parent_dashboard.loading_subtitle'),
        color: AppColors.parentAccent,
        compact: true,
      );
    }
    final controls = ParentControlsService.instance;
    final usage = controls.usagePerDay();
    final tips = buildParentTips(
      context,
      report: report,
      progress: progress,
      usageSecondsPerDay: usage,
      dailyLimitMinutes: controls.dailyLimitMinutes,
      childName: _childName,
    );

    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (tabContext) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GameBackButton(onTap: _goBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('parent_dashboard.zone_title'),
                          style: AppTypography.h2.copyWith(
                            color: parentInk,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          context.tr('parent_dashboard.header_subtitle'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: parentMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('parent_dashboard.refresh'),
                    onPressed: _loadDashboardData,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.parentAccent,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outline),
              ),
              child: TabBar(
                isScrollable: false,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.parentAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: parentInk,
                labelPadding: EdgeInsets.zero,
                labelStyle: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                tabs: [
                  _tab(Icons.dashboard_rounded, 'overview'),
                  _tab(Icons.insights_rounded, 'reports'),
                  _tab(Icons.lightbulb_rounded, 'tips'),
                  _tab(Icons.tune_rounded, 'controls'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ParentOverviewTab(
                    childName: _childName,
                    progress: progress,
                    report: report,
                    usageSecondsPerDay: usage,
                    limitMinutes: controls.effectiveLimitMinutes,
                    onOpenReports: () =>
                        DefaultTabController.of(tabContext).animateTo(1),
                  ),
                  ParentReportsTab(
                    progress: progress,
                    report: report,
                    onPractice: _practice,
                  ),
                  ParentTipsTab(tips: tips, onPractice: _practice),
                  ParentControlsTab(
                    profileSwitcher: _buildProfileSwitcher(),
                    audioSettings: _buildSettingsSection(),
                    onDataChanged: _loadDashboardData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(IconData icon, String key) {
    return Tab(
      height: 52,
      iconMargin: const EdgeInsets.only(bottom: 2),
      icon: Icon(icon, size: 20),
      child: Text(
        context.tr('parent_dashboard.tabs.$key'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _addProfile() async {
    final profiles = _profiles?.profiles ?? const <ChildProfile>[];
    final result = await showChildProfileSheet(
      context,
      otherProfiles: profiles,
    );
    if (result == null) return;
    await ChildProfileService.instance.addProfile(result.profile);
    await _afterProfileSaved(result);
  }

  Future<void> _editProfile(int index) async {
    final profiles = _profiles?.profiles ?? const <ChildProfile>[];
    if (index >= profiles.length) return;
    final result = await showChildProfileSheet(
      context,
      existing: profiles[index],
      otherProfiles: [
        for (var i = 0; i < profiles.length; i++)
          if (i != index) profiles[i],
      ],
    );
    if (result == null) return;
    await ChildProfileService.instance.updateProfile(index, result.profile);
    await _afterProfileSaved(result);
  }

  Future<void> _afterProfileSaved(ChildProfileResult result) async {
    if (result.applySuggestion) {
      await applyAgeSuggestion(suggestionForAge(result.profile.age ?? 5));
    }
    await _loadDashboardData();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            context.tr(
              result.applySuggestion
                  ? 'parent_dashboard.profile.saved_with_suggestion'
                  : 'parent_dashboard.profile.saved',
              namedArgs: {'name': result.profile.name},
            ),
          ),
        ),
      );
  }

  Future<void> _deleteProfile(int index) async {
    final profiles = _profiles?.profiles ?? const <ChildProfile>[];
    if (profiles.length <= 1 || index >= profiles.length) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          dialogContext.tr(
            'parent_dashboard.profile.delete_title',
            namedArgs: {'name': profiles[index].name},
          ),
        ),
        content: Text(dialogContext.tr('parent_dashboard.profile.delete_body')),
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
            child: Text(dialogContext.tr('parent_dashboard.profile.delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ChildProfileService.instance.deleteProfile(index);
    await _loadDashboardData();
  }

  Widget _buildProfileSwitcher() {
    final profiles = _profiles;
    if (profiles == null) {
      return const SizedBox.shrink();
    }
    final canDelete = profiles.profiles.length > 1;

    return ParentCard(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
      child: Column(
        children: [
          for (var index = 0; index < profiles.profiles.length; index++)
            _ProfileTile(
              profile: profiles.profiles[index],
              active: index == profiles.activeIndex,
              onSelect: () => _switchProfile(index),
              onEdit: () => _editProfile(index),
              onDelete: canDelete ? () => _deleteProfile(index) : null,
            ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addProfile,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(context.tr('parent_dashboard.profile.add_child')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.parentAccent,
                  side: const BorderSide(color: AppColors.parentAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _audioSettings.musicEnabled,
                onChanged: _updateMusicEnabled,
                title: Text(context.tr('common.music')),
                subtitle: Text(context.tr('settings.music_subtitle')),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _audioSettings.sfxEnabled,
                onChanged: _updateSfxEnabled,
                title: Text(context.tr('common.sound_effects')),
                subtitle: Text(context.tr('settings.sfx_subtitle')),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('common.speech_rate'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: const Color(0xFF1E1060),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'normal',
                    label: Text(context.tr('common.normal')),
                  ),
                  ButtonSegment<String>(
                    value: 'slow',
                    label: Text(context.tr('common.slow')),
                  ),
                ],
                selected: {_audioSettings.speechRateMode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  _updateSpeechRateMode(selection.first);
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push('${AppRoutes.settings}?source=parent');
                    await _loadDashboardData();
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label:
                      Text(context.tr('parent_dashboard.open_full_settings')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.parentAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.active,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final ChildProfile profile;
  final bool active;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onSelect,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selected: active,
      selectedTileColor: AppColors.parentAccent.withValues(alpha: 0.08),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.parentAccent.withValues(alpha: 0.12),
          border: Border.all(
            color: active ? AppColors.parentAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(profile.avatarPath, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(
        profile.name,
        style: AppTypography.bodyStrong.copyWith(color: parentInk),
      ),
      subtitle: Text(
        [
          if (profile.age != null)
            context.tr(
              'parent_dashboard.profile.age_years',
              namedArgs: {'count': '${profile.age}'},
            ),
          if (active) context.tr('parent_dashboard.profile.playing_now'),
        ].join(' · '),
        style: AppTypography.caption.copyWith(color: parentMuted),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.tr('parent_dashboard.profile.edit_title'),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, color: AppColors.parentAccent),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: context.tr('parent_dashboard.profile.delete'),
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE5554A),
              ),
            ),
        ],
      ),
    );
  }
}
