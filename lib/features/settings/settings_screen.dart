import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_locale_config.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/audio_settings_service.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/services/parent_pin_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/tts_voice_helper.dart';
import '../../shared/widgets/game_back_button.dart';
import '../../shared/widgets/kid_loading_view.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.showParentControls = false,
  });

  final bool showParentControls;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final FlutterTts _previewTts;
  late final TextEditingController _parentPinController;

  AudioSettingsSnapshot _audioSettings = const AudioSettingsSnapshot(
    musicEnabled: true,
    sfxEnabled: true,
    speechRateMode: 'normal',
  );
  ChildProfileSnapshot? _profiles;

  bool _isLoading = true;
  bool _isPreviewSpeaking = false;
  bool _isSaving = false;
  bool _hasParentPin = false;
  String? _parentPinMessage;
  bool _isParentPinSuccessMessage = false;

  List<AppLocaleDescriptor> get _languageOptions => AppLocaleConfig.descriptors;

  @override
  void initState() {
    super.initState();
    _previewTts = FlutterTts();
    _parentPinController = TextEditingController();
    _bootstrap();
  }

  @override
  void dispose() {
    _previewTts.stop();
    _parentPinController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _configurePreviewTts();
    await _loadSettings();
  }

  Future<void> _configurePreviewTts() async {
    await TtsVoiceHelper.configureSharedAudio(_previewTts);
    await _previewTts.awaitSpeakCompletion(true);
    await TtsVoiceHelper.applyPreferredVoice(
      _previewTts,
      locale: 'en-IN',
      fallbackLocales: const ['en-US', 'en-GB'],
    );
    await _previewTts.setPitch(1.04);
    await _previewTts.setVolume(1.0);
  }

  Future<void> _loadSettings() async {
    final audioSettings = await AudioSettingsService.instance.loadSnapshot();
    final profiles = await ChildProfileService.instance.loadSnapshot();
    final hasParentPin = await ParentPinService.instance.hasPin();
    if (!mounted) return;
    setState(() {
      _audioSettings = audioSettings;
      _profiles = profiles;
      _hasParentPin = hasParentPin;
      _isLoading = false;
    });
  }

  Future<void> _updateMusicEnabled(bool enabled) async {
    await AudioSettingsService.instance.setMusicEnabled(enabled);
    AudioService().setMusicEnabled(enabled);
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
    await _loadSettings();
  }

  Future<void> _speakPreview() async {
    if (_isPreviewSpeaking) {
      await _previewTts.stop();
      if (!mounted) return;
      setState(() => _isPreviewSpeaking = false);
      return;
    }

    final preferredLocale =
        context.locale.languageCode == 'hi' ? 'hi-IN' : 'en-IN';
    final fallbackLocales = context.locale.languageCode == 'hi'
        ? const ['hi-IN', 'en-IN', 'en-US']
        : const ['en-IN', 'en-US', 'en-GB'];
    final previewMessage = context.tr('settings.voice_preview_message');
    await TtsVoiceHelper.applyPreferredVoice(
      _previewTts,
      locale: preferredLocale,
      fallbackLocales: fallbackLocales,
    );
    setState(() => _isPreviewSpeaking = true);
    await TtsVoiceHelper.applyPreferredSpeechRate(
      _previewTts,
      normalRate: 0.42,
      slowRate: 0.3,
    );
    try {
      await _previewTts.stop();
      await _previewTts.speak(previewMessage);
    } finally {
      if (mounted) {
        setState(() => _isPreviewSpeaking = false);
      }
    }
  }

  Future<void> _changeLocale(Locale locale) async {
    if (locale == context.locale) return;
    await context.setLocale(locale);
    if (!mounted) return;
    setState(() {
      _parentPinMessage = null;
      _isParentPinSuccessMessage = false;
    });
  }

  Future<void> _playSuccessPreview() async {
    await AudioService().playSfx('sfx/correct.mp3');
  }

  Future<void> _resetDefaults() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    await AudioSettingsService.instance.setMusicEnabled(true);
    await AudioSettingsService.instance.setSfxEnabled(true);
    await AudioSettingsService.instance.setSpeechRateMode('normal');
    AudioService().setMusicEnabled(true);
    AudioService().setSfxEnabled(true);
    AudioService().setSpeechRate('normal');

    if (!mounted) return;
    setState(() {
      _audioSettings = const AudioSettingsSnapshot(
        musicEnabled: true,
        sfxEnabled: true,
        speechRateMode: 'normal',
      );
      _isSaving = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('settings.reset_success'))),
    );
  }

  Future<void> _saveParentPin() async {
    final pin = _parentPinController.text.trim();
    if (pin.length != 4) {
      setState(() {
        _parentPinMessage = context.tr('settings.parent_pin_invalid');
        _isParentPinSuccessMessage = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _parentPinMessage = null;
      _isParentPinSuccessMessage = false;
    });

    await ParentPinService.instance.setPin(pin);
    _parentPinController.clear();

    if (!mounted) return;
    setState(() {
      _hasParentPin = true;
      _isSaving = false;
      _parentPinMessage = context.tr('settings.parent_pin_updated');
      _isParentPinSuccessMessage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parentBackground,
      body: SafeArea(
        child: _isLoading
            ? KidLoadingView(
                title: context.tr('settings.title'),
                subtitle: context.tr('settings.loading_subtitle'),
                color: AppColors.parentAccent,
                compact: true,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GameBackButton(
                          onTap: () => context.pop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('settings.title'),
                            style: AppTypography.h2.copyWith(
                              color: const Color(0xFF1E1060),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildHeroCard(),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      context.tr('settings.language_title'),
                      context.tr('settings.language_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageCard(),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      context.tr('settings.active_child_title'),
                      context.tr('settings.active_child_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      context.tr('settings.audio_title'),
                      context.tr('settings.audio_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    _buildAudioCard(),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      context.tr('settings.preview_title'),
                      context.tr('settings.preview_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    _buildPreviewCard(),
                    if (widget.showParentControls) ...[
                      const SizedBox(height: 20),
                      _buildSectionHeader(
                        context.tr('settings.parent_controls_title'),
                        context.tr('settings.parent_controls_subtitle'),
                      ),
                      const SizedBox(height: 12),
                      _buildParentControlsCard(),
                    ],
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      context.tr('settings.coming_next_title'),
                      context.tr('settings.coming_next_subtitle'),
                    ),
                    const SizedBox(height: 12),
                    _buildComingSoonCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFF8FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.parentAccent.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.tr('settings.hero_badge'),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.parentAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('settings.hero_title'),
            style: AppTypography.cardTitle.copyWith(
              color: const Color(0xFF1E1060),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('settings.hero_subtitle'),
            style: AppTypography.body.copyWith(
              color: const Color(0xFF546071),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    final currentLocale = context.locale;
    return _SettingsCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _languageOptions.map((option) {
          final isSelected =
              option.locale.languageCode == currentLocale.languageCode;
          return ChoiceChip(
            label: Text(
              '${option.nativeLanguageName} • ${option.languageName}',
            ),
            selected: isSelected,
            onSelected: (_) => _changeLocale(option.locale),
            selectedColor: AppColors.secondary.withValues(alpha: 0.18),
            labelStyle: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF1E1060),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: isSelected ? AppColors.secondary : AppColors.outline,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildProfileCard() {
    final profiles = _profiles;
    if (profiles == null) {
      return const SizedBox.shrink();
    }

    return _SettingsCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(profiles.profiles.length, (index) {
          final profile = profiles.profiles[index];
          final selected = index == profiles.activeIndex;
          return ChoiceChip(
            label: Text('${profile.avatarPath} ${profile.name}'),
            selected: selected,
            onSelected: (_) => _switchProfile(index),
            selectedColor: AppColors.parentAccent.withValues(alpha: 0.18),
            labelStyle: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF1E1060),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected ? AppColors.parentAccent : AppColors.outline,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAudioCard() {
    return _SettingsCard(
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
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return _SettingsCard(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _speakPreview,
              icon: Icon(
                _isPreviewSpeaking
                    ? Icons.stop_circle_outlined
                    : Icons.record_voice_over_rounded,
              ),
              label: Text(
                _isPreviewSpeaking
                    ? context.tr('settings.voice_preview_stop')
                    : context.tr('settings.voice_preview'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.parentAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _playSuccessPreview,
              icon: const Icon(Icons.music_note_rounded),
              label: Text(context.tr('settings.success_sound_preview')),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E1060),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _resetDefaults,
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                _isSaving
                    ? context.tr('settings.resetting')
                    : context.tr('settings.reset_defaults'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.parentAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return _SettingsCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: AppColors.parentAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('settings.coming_next_body'),
              style: AppTypography.body.copyWith(
                color: const Color(0xFF546071),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentControlsCard() {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppColors.parentAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _hasParentPin
                      ? context.tr('settings.parent_pin_active')
                      : context.tr('settings.parent_pin_missing'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: const Color(0xFF1E1060),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _hasParentPin
                ? context.tr('settings.parent_pin_update_hint')
                : context.tr('settings.parent_pin_create_hint'),
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF5A6B7A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _parentPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: _hasParentPin
                  ? context.tr('settings.new_parent_pin')
                  : context.tr('settings.parent_pin'),
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.outline),
              ),
            ),
            onChanged: (_) {
              if (_parentPinMessage != null) {
                setState(() {
                  _parentPinMessage = null;
                  _isParentPinSuccessMessage = false;
                });
              }
            },
          ),
          if (_parentPinMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _parentPinMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: _isParentPinSuccessMessage
                    ? AppColors.gardenGreen
                    : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveParentPin,
              icon: const Icon(Icons.lock_reset_rounded),
              label: Text(
                _hasParentPin
                    ? context.tr('settings.update_parent_pin')
                    : context.tr('settings.save_parent_pin'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.parentAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(color: const Color(0xFF1E1060)),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: const Color(0xFF5A6B7A),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
