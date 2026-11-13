import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/presentation/widgets/settings_tiles.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
  });
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _contactEmail = String.fromEnvironment('CONTACT_EMAIL');
  static const _privacyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  bool _busy = false;
  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorSave)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _permissionDenied() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.notificationPermissionRequired)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(settingsNotifierProvider);
    final ads = ref.watch(adsControllerProvider).asData?.value;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l10n.settings)),
      bottomNavigationBar: MainBottomNav(
        currentIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
      body: state.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(settingsNotifierProvider),
            child: Text(l10n.retry),
          ),
        ),
        data: (settings) => AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: EdgeInsets.only(bottom: 16),
            children: [
              SettingsSectionHeader(title: l10n.generalSettings),
              SettingsSection(
                children: [
                  SettingsNavTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.theme,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          switch (settings.themeMode) {
                            ThemeMode.dark => l10n.darkTheme,
                            ThemeMode.light => l10n.lightTheme,
                            ThemeMode.system => l10n.systemTheme,
                          },
                          style: TextStyle(
                            color: context.palette.cream,
                            fontSize: 13,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    onTap: () async {
                      final mode = await showDialog<ThemeMode>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: Text(l10n.theme),
                          children: ThemeMode.values
                              .map(
                                (mode) => ListTile(
                                  title: Text(switch (mode) {
                                    ThemeMode.dark => l10n.darkTheme,
                                    ThemeMode.light => l10n.lightTheme,
                                    ThemeMode.system => l10n.systemTheme,
                                  }),
                                  trailing: mode == settings.themeMode
                                      ? Icon(Icons.check)
                                      : null,
                                  onTap: () => Navigator.pop(context, mode),
                                ),
                              )
                              .toList(),
                        ),
                      );
                      if (mode != null && mounted) {
                        await _run(() => notifier.setTheme(mode));
                      }
                    },
                  ),
                  SettingsToggleTile(
                    icon: Icons.volume_up_outlined,
                    title: l10n.sound,
                    value: settings.soundEnabled,
                    onChanged: (value) => _run(() => notifier.setSound(value)),
                  ),
                  SettingsToggleTile(
                    icon: Icons.vibration,
                    title: l10n.vibration,
                    value: settings.vibrationEnabled,
                    onChanged: (value) => _run(() async {
                      await notifier.setVibration(enabled: value);
                      ref
                          .read(homeNotifierProvider.notifier)
                          .syncVibration(enabled: value);
                    }),
                  ),
                ],
              ),
              SettingsSectionHeader(title: l10n.reminders),
              SettingsSection(
                children: [
                  SettingsToggleTile(
                    icon: Icons.notifications_none_outlined,
                    title: l10n.dailyReminder,
                    value: settings.reminderEnabled,
                    onChanged: (value) => _run(() async {
                      final changed = await notifier.setReminder(
                        enabled: value,
                      );
                      if (!changed && mounted) _permissionDenied();
                    }),
                  ),
                  SettingsNavTile(
                    icon: Icons.alarm_outlined,
                    title: l10n.reminderTime,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: context.palette.cream,
                            fontSize: 13,
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: settings.reminderHour,
                          minute: settings.reminderMinute,
                        ),
                      );
                      if (time != null && mounted) {
                        await _run(() async {
                          final changed = await notifier.setReminder(
                            hour: time.hour,
                            minute: time.minute,
                          );
                          if (!changed && mounted) _permissionDenied();
                        });
                      }
                    },
                  ),
                ],
              ),
              SettingsSectionHeader(title: l10n.application),
              SettingsSection(
                children: [
                  SettingsNavTile(
                    icon: Icons.info_outline,
                    title: l10n.about,
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: '1.0.0',
                      children: [Text(l10n.appDescription)],
                    ),
                  ),
                  SettingsNavTile(
                    icon: Icons.lock_outline,
                    title: l10n.privacyPolicy,
                    onTap: _privacy,
                  ),
                  if (_contactEmail.isNotEmpty)
                    SettingsNavTile(
                      icon: Icons.mail_outline,
                      title: l10n.contactUs,
                      onTap: () => _run(() async {
                        final uri = Uri(scheme: 'mailto', path: _contactEmail);
                        if (!await launchUrl(uri)) {
                          throw StateError('mail unavailable');
                        }
                      }),
                    ),
                  SettingsNavTile(
                    icon: Icons.language_outlined,
                    title: l10n.language,
                    onTap: () async {
                      final locale = await showDialog<Locale>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: Text(l10n.language),
                          children: AppLocales.supported
                              .map(
                                (locale) => SimpleDialogOption(
                                  child: Text(switch (locale.languageCode) {
                                    'en' => l10n.languageEnglish,
                                    'ar' => l10n.languageArabic,
                                    _ => l10n.languageTurkish,
                                  }),
                                  onPressed: () =>
                                      Navigator.pop(context, locale),
                                ),
                              )
                              .toList(),
                        ),
                      );
                      if (locale != null && mounted) {
                        await _run(() => notifier.setLocale(locale));
                      }
                    },
                  ),
                  if (ads?.privacyOptionsRequired == true)
                    SettingsNavTile(
                      icon: Icons.privacy_tip_outlined,
                      title: l10n.privacyOptions,
                      onTap: () => _run(
                        () => ref
                            .read(adsControllerProvider.notifier)
                            .showPrivacyOptions(),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.favorite_border,
                  color: context.palette.gold,
                  size: 22,
                ),
              ),
              SizedBox(height: 9),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.peacefulLife,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.palette.softGold,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _privacy() async {
    final url = _privacyUrl;
    if (url.isNotEmpty) {
      await _run(() async {
        if (!await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        )) {
          throw StateError('URL unavailable');
        }
      });
      return;
    }
    if (!mounted) return;
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyPolicy),
        content: SingleChildScrollView(child: Text(l10n.privacySummary)),
        actions: [
          TextButton(
            onPressed: () => _run(() async {
              if (!await launchUrl(
                Uri.parse('https://policies.google.com/privacy'),
                mode: LaunchMode.externalApplication,
              )) {
                throw StateError('URL unavailable');
              }
            }),
            child: Text(l10n.googlePrivacy),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
