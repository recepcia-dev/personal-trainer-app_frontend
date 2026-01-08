/// Development entry point for rapid UI/UX iteration
///
/// Usage: flutter run -t lib/main_dev.dart
///
/// Features:
/// - Mock authentication (no backend dependency)
/// - Pre-seeded dummy data
/// - Enhanced logging
/// - Dev toolbar for quick navigation
///
/// Configuration: Edit lib/core/dev/dev_config.dart to enable/disable features

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/app_constants.dart';
import 'core/dev/dev_config.dart';
import 'core/dev/mock_providers.dart';
import 'core/dev/seed_dev_data.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print dev configuration
  DevConfig.printDevConfig();
  printDevDataGuide();

  // Initialize token provider
  _initializeTokenProvider();

  // Initialize theme provider to load saved theme preference
  final themeNotifier = ThemeModeNotifier();
  await themeNotifier.initialize();

  // Load environment constants
  if (!kIsWeb) {
    try {
      await AppConstants.load();
    } catch (e) {
      debugPrint('Failed to load app constants: $e');
    }
  }

  // Seed dummy data if enabled
  await DevDataSeeder.seedAll();

  runApp(
    ProviderScope(
      overrides: [
        // Theme provider with initialized notifier
        themeModeProvider.overrideWith(
          (ref) => themeNotifier,
        ),
        // Add mock auth provider override if enabled
        ...getDevProviderOverrides(),
      ],
      child: const _DevPersonalTrainerApp(),
    ),
  );
}

/// Initialize the token provider before the app runs
void _initializeTokenProvider() {
  DioClient.tokenProvider = _SimpleTokenProvider(const FlutterSecureStorage());
}

/// Simple implementation of TokenProvider that reads from secure storage
class _SimpleTokenProvider implements TokenProvider {
  final FlutterSecureStorage _storage;

  _SimpleTokenProvider(this._storage);

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: 'accessToken');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refreshToken');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }
}

/// Development app with optional dev toolbar
class _DevPersonalTrainerApp extends ConsumerWidget {
  const _DevPersonalTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Personal Trainer App (DEV)',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Wrap with dev toolbar if enabled
        if (DevConfig.devToolbarEnabled) {
          return _DevToolbar(child: child!);
        }
        return child!;
      },
    );
  }
}

/// Optional dev toolbar for quick navigation and role switching
class _DevToolbar extends StatefulWidget {
  final Widget child;

  const _DevToolbar({required this.child});

  @override
  State<_DevToolbar> createState() => _DevToolbarState();
}

class _DevToolbarState extends State<_DevToolbar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!DevConfig.devToolbarEnabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        // Dev toolbar overlay
        Positioned(
          bottom: 20,
          right: 20,
          child: _AnimatedDevToolbar(
            isExpanded: _isExpanded,
            onToggle: () => setState(() => _isExpanded = !_isExpanded),
          ),
        ),
      ],
    );
  }
}

/// Animated dev toolbar UI
class _AnimatedDevToolbar extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AnimatedDevToolbar({
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 280 : 60,
      height: isExpanded ? 320 : 60,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isExpanded
          ? _DevToolbarExpanded(onToggle: onToggle)
          : _DevToolbarCollapsed(onToggle: onToggle),
    );
  }
}

/// Expanded dev toolbar with controls
class _DevToolbarExpanded extends ConsumerWidget {
  final VoidCallback onToggle;

  const _DevToolbarExpanded({required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(devRoleProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  '🛠️ DEV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onToggle,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Role section
            const Text(
              'Auth Role',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _RoleButton(
              label: '👨‍🏫 Trainer',
              isActive: currentRole == DevRoleEnum.trainer,
              onPressed: () => ref.read(devRoleProvider.notifier).selectTrainer(),
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '👤 Client',
              isActive: currentRole == DevRoleEnum.client,
              onPressed: () => ref.read(devRoleProvider.notifier).selectClient(),
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '👨‍💼 Admin',
              isActive: currentRole == DevRoleEnum.admin,
              onPressed: () => ref.read(devRoleProvider.notifier).selectAdmin(),
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '🚫 Not Auth',
              isActive: currentRole == DevRoleEnum.notAuthenticated,
              onPressed: () => ref.read(devRoleProvider.notifier).selectNotAuthenticated(),
            ),
            const SizedBox(height: 12),
            // Actions section
            const Text(
              'Actions',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: '🔄 Reseed Data',
              onPressed: () async {
                await DevDataSeeder.reseedAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data reseeded')),
                  );
                }
              },
            ),
            const SizedBox(height: 6),
            _ActionButton(
              label: '🗑️ Clear Data',
              onPressed: () async {
                await DevDataSeeder.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data cleared')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Collapsed dev toolbar (just icon)
class _DevToolbarCollapsed extends StatelessWidget {
  final VoidCallback onToggle;

  const _DevToolbarCollapsed({required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: const Center(
        child: Text(
          '🛠️',
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

/// Role selection button
class _RoleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[700],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Action button
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
