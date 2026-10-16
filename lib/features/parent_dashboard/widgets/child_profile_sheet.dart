import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/parent_controls_service.dart';
import '../../../core/services/reward_progress_service.dart';
import '../../../data/models/child_profile.dart';
import '../parent_insights.dart';
import 'parent_report_tabs.dart';

const List<String> profileAvatars = [
  '🦁',
  '🐻',
  '🦊',
  '🐼',
  '🐰',
  '🐯',
  '🐨',
  '🐸',
  '🦄',
  '🐵',
  '🐧',
  '🐶',
];

const int _nameIdeaCount = 6;
const int minChildAge = 3;
const int maxChildAge = 8;

/// Recommended starting setup for a child's age.
class AgeSuggestion {
  const AgeSuggestion({
    required this.dailyMinutes,
    required this.enabledModules,
    required this.focusKey,
  });

  final int dailyMinutes;
  final Set<String> enabledModules;

  /// `parent_dashboard.profile.focus.*`
  final String focusKey;
}

AgeSuggestion suggestionForAge(int age) {
  const early = {
    RewardModuleIds.learnNumbers,
    RewardModuleIds.findNumber,
    RewardModuleIds.countObjects,
    RewardModuleIds.traceNumbers,
    RewardModuleIds.matchNumbers,
    RewardModuleIds.patterns,
  };
  if (age <= 4) {
    return const AgeSuggestion(
      dailyMinutes: 15,
      enabledModules: early,
      focusKey: 'early',
    );
  }
  if (age <= 6) {
    return const AgeSuggestion(
      dailyMinutes: 30,
      enabledModules: {
        ...early,
        RewardModuleIds.sequencing,
        RewardModuleIds.addition,
        RewardModuleIds.subtraction,
        RewardModuleIds.miniQuiz,
      },
      focusKey: 'middle',
    );
  }
  return AgeSuggestion(
    dailyMinutes: 45,
    enabledModules: ParentControlsService.moduleRoutes.keys.toSet(),
    focusKey: 'older',
  );
}

/// Turns the age suggestion into the device's parent controls.
Future<void> applyAgeSuggestion(AgeSuggestion suggestion) async {
  final controls = ParentControlsService.instance;
  await controls.setDailyLimitMinutes(suggestion.dailyMinutes);
  for (final moduleId in ParentControlsService.moduleRoutes.keys) {
    await controls.setModuleEnabled(
      moduleId,
      suggestion.enabledModules.contains(moduleId),
    );
  }
}

class ChildProfileResult {
  const ChildProfileResult({
    required this.profile,
    required this.applySuggestion,
  });

  final ChildProfile profile;
  final bool applySuggestion;
}

/// Add or edit a child. Suggests a name, an unused avatar and age-based
/// settings so a parent can finish with one tap.
Future<ChildProfileResult?> showChildProfileSheet(
  BuildContext context, {
  ChildProfile? existing,
  List<ChildProfile> otherProfiles = const [],
}) {
  return showModalBottomSheet<ChildProfileResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChildProfileForm(
      existing: existing,
      otherProfiles: otherProfiles,
    ),
  );
}

/// The add/edit child form. Shown as a bottom sheet by default; with
/// [embedded] it is laid out inline (e.g. the first-run create profile page).
class ChildProfileForm extends StatefulWidget {
  const ChildProfileForm({
    super.key,
    this.existing,
    this.otherProfiles = const [],
    this.embedded = false,
    this.showCancel = true,
    this.onSubmit,
  });

  final ChildProfile? existing;
  final List<ChildProfile> otherProfiles;
  final bool embedded;
  final bool showCancel;

  /// Receives the result. When null the form pops it from its route.
  final ValueChanged<ChildProfileResult>? onSubmit;

  @override
  State<ChildProfileForm> createState() => _ChildProfileFormState();
}

class _ChildProfileFormState extends State<ChildProfileForm> {
  late final TextEditingController _nameController;
  late String _avatar;
  late int _age;
  late bool _applySuggestion;
  bool _nameInitialized = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _age = existing?.age ?? 5;
    // New children get the suggested setup by default.
    _applySuggestion = _isNew;
    final used = widget.otherProfiles.map((p) => p.avatarPath).toSet();
    _avatar = existing?.avatarPath ??
        profileAvatars.firstWhere(
          (avatar) => !used.contains(avatar),
          orElse: () => profileAvatars.first,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill a suggested name for a new child (needs translations).
    if (!_nameInitialized && _isNew) {
      _nameInitialized = true;
      _nameController.text = _nameIdeas().first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> _nameIdeas() {
    final taken = widget.otherProfiles.map((p) => p.name).toSet();
    final ideas = [
      for (var i = 1; i <= _nameIdeaCount; i++)
        context.tr('parent_dashboard.profile.name_idea_$i'),
    ];
    final free = ideas.where((name) => !taken.contains(name)).toList();
    return free.isEmpty ? ideas : free;
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final result = ChildProfileResult(
      profile: ChildProfile(name: name, avatarPath: _avatar, age: _age),
      applySuggestion: _applySuggestion,
    );
    final onSubmit = widget.onSubmit;
    if (onSubmit != null) {
      onSubmit(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = suggestionForAge(_age);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.parentAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(_avatar, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                context.tr(
                  _isNew
                      ? 'parent_dashboard.profile.add_title'
                      : 'parent_dashboard.profile.edit_title',
                ),
                style: AppTypography.h3.copyWith(color: parentInk),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _label(context.tr('parent_dashboard.profile.name')),
        TextField(
          controller: _nameController,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.parentBackground,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('parent_dashboard.profile.name_ideas'),
          style: AppTypography.caption.copyWith(color: parentMuted),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final idea in _nameIdeas().take(4))
              ActionChip(
                label: Text(idea),
                onPressed: () => setState(
                  () => _nameController.text = idea,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _label(context.tr('parent_dashboard.profile.avatar')),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final avatar in profileAvatars)
              InkWell(
                onTap: () => setState(() => _avatar = avatar),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: avatar == _avatar
                        ? AppColors.parentAccent.withValues(alpha: 0.16)
                        : AppColors.parentBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: avatar == _avatar
                          ? AppColors.parentAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _label(context.tr('parent_dashboard.profile.age')),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var age = minChildAge; age <= maxChildAge; age++)
              ChoiceChip(
                label: Text(
                  context.tr(
                    'parent_dashboard.profile.age_years',
                    namedArgs: {'count': '$age'},
                  ),
                ),
                selected: age == _age,
                onSelected: (_) => setState(() => _age = age),
                selectedColor: AppColors.parentAccent.withValues(alpha: 0.18),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _SuggestionCard(
          age: _age,
          suggestion: suggestion,
          apply: _applySuggestion,
          onApplyChanged: (value) => setState(() => _applySuggestion = value),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (widget.showCancel) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: parentInk,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.tr('parent_dashboard.controls.cancel'),
                    style: AppTypography.bodyStrong.copyWith(
                      color: parentInk,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _nameController.text.trim().isEmpty ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.parentAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  context.tr(
                    _isNew
                        ? 'parent_dashboard.profile.add_button'
                        : 'parent_dashboard.profile.save_button',
                  ),
                  style: AppTypography.bodyStrong.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (widget.embedded) return form;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: form,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: parentInk,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.age,
    required this.suggestion,
    required this.apply,
    required this.onApplyChanged,
  });

  final int age;
  final AgeSuggestion suggestion;
  final bool apply;
  final ValueChanged<bool> onApplyChanged;

  @override
  Widget build(BuildContext context) {
    final games = ParentControlsService.moduleRoutes.keys
        .where(suggestion.enabledModules.contains)
        .map((moduleId) => moduleTitle(context, moduleId))
        .toList();
    final shown = games.take(math.min(games.length, 6)).join(', ');
    final more = games.length - math.min(games.length, 6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.premiumGold.withValues(alpha: 0.6)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✨ ${context.tr('parent_dashboard.profile.suggested_title', namedArgs: {
                    'age': '$age'
                  })}',
              style: AppTypography.bodyStrong.copyWith(color: parentInk),
            ),
            const SizedBox(height: 6),
            Text(
              context
                  .tr('parent_dashboard.profile.focus.${suggestion.focusKey}'),
              style: AppTypography.bodySmall.copyWith(color: parentInk),
            ),
            const SizedBox(height: 8),
            Text(
              '⏰ ${context.tr('parent_dashboard.profile.suggested_time', namedArgs: {
                    'minutes': '${suggestion.dailyMinutes}'
                  })}',
              style: AppTypography.bodySmall.copyWith(
                color: parentInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '🎮 $shown${more > 0 ? ' +$more' : ''}',
              style: AppTypography.bodySmall.copyWith(color: parentInk),
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              value: apply,
              onChanged: (value) => onApplyChanged(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.parentAccent,
              title: Text(
                context.tr('parent_dashboard.profile.apply_suggested'),
                style: AppTypography.bodySmall.copyWith(
                  color: parentInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
