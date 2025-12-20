import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                  const SizedBox(height: 32),

                  // Payments & Subscription
                  _SectionTitle(title: 'Payments & Subscription'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.credit_card,
                    title: 'Subscription Plan',
                    subtitle: 'Manage your subscription',
                    onTap: () {
                      // TODO: Navigate to subscription management screen
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.receipt_long,
                    title: 'Payment History',
                    subtitle: 'View past payments and invoices',
                    onTap: () {
                      // TODO: Navigate to payment history screen
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.account_balance,
                    title: 'Billing Information',
                    subtitle: 'Update payment methods',
                    onTap: () {
                      // TODO: Navigate to billing information screen
                    },
                  ),

                  const SizedBox(height: 32),

                  // Account
                  _SectionTitle(title: 'Account'),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.delete,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: () {
                      _showDeleteAccountDialog(context);
                    },
                    textColor: Colors.red,
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
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
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
