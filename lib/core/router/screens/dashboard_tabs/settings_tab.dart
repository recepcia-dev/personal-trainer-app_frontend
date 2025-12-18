import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../providers/app_preferences_provider.dart' hide themeModeProvider;

/// Settings tab - App settings and preferences
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General settings
                  _SectionTitle(title: 'General'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: ref.watch(languageProvider),
                    onTap: () {
                      _showLanguageDialog(context, ref);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Theme',
                    subtitle: _getThemeDisplayName(ref.watch(themeModeProvider)),
                    onTap: () {
                      _showThemeDialog(context, ref);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.security,
                    title: 'Biometric Lock',
                    subtitle: 'Require authentication to open app',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  const SizedBox(height: 32),

                  // Workout settings
                  _SectionTitle(title: 'Workout'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.timer,
                    title: 'Rest Timer',
                    subtitle: 'Default: 60 seconds',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.volume_up,
                    title: 'Sound & Haptics',
                    subtitle: 'Workout completion sounds',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  _SettingsTile(
                    icon: Icons.straighten,
                    title: 'Units',
                    subtitle: 'Metric (kg, cm)',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // Notifications
                  _SectionTitle(title: 'Notifications'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.notifications_active,
                    title: 'Push Notifications',
                    subtitle: 'Workout reminders and updates',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  _SettingsTile(
                    icon: Icons.email,
                    title: 'Email Notifications',
                    subtitle: 'Weekly progress reports',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

                  const SizedBox(height: 32),

                  // Privacy & Security
                  _SectionTitle(title: 'Privacy & Security'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    subtitle: 'View our privacy policy',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.delete,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                    textColor: Colors.red,
                  ),

                  const SizedBox(height: 32),

                  // About
                  _SectionTitle(title: 'About'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.info,
                    title: 'App Version',
                    subtitle: '1.0.0 (Build 1)',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.star,
                    title: 'Rate Us',
                    subtitle: 'Rate us on the App Store',
                    onTap: () {},
                  ),

                  const SizedBox(height: 48),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        _showLogoutDialog(context, ref);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Logout
                ref.read(authProvider.notifier).logout();
                ref.read(authStateProvider.notifier).logout();
                // Router will automatically redirect to login
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion not implemented yet'),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: ref.watch(themeModeProvider),
                onChanged: (ThemeMode? value) async {
                  if (value != null) {
                    await ref.read(themeModeProvider.notifier).setLightMode();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: ref.watch(themeModeProvider),
                onChanged: (ThemeMode? value) async {
                  if (value != null) {
                    await ref.read(themeModeProvider.notifier).setDarkMode();
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System default'),
                value: ThemeMode.system,
                groupValue: ref.watch(themeModeProvider),
                onChanged: (ThemeMode? value) async {
                  if (value != null) {
                    await ref.read(themeModeProvider.notifier).setSystemMode();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: ref.watch(languageProvider),
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Español'),
                value: 'Español',
                groupValue: ref.watch(languageProvider),
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Français'),
                value: 'Français',
                groupValue: ref.watch(languageProvider),
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: textColor != null
              ? textColor!.withOpacity(0.1)
              : theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: textColor ?? theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null
            ? Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              )
            : null),
        onTap: onTap,
      ),
    );
  }
}
