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
import 'package:go_router/go_router.dart';

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

  // Create single instance of secure storage to avoid sync issues
  // Configure with proper iOS options to prevent silent keychain failures
  const secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  debugPrint('');
  debugPrint('═══════════════════════════════════════════════════════════════');
  debugPrint('🔐 [main_dev.dart] INITIALIZING DEV MODE');
  debugPrint('═══════════════════════════════════════════════════════════════');
  debugPrint('📦 [main_dev.dart] Created FlutterSecureStorage instance');

  // Initialize token provider with same storage instance
  debugPrint('🔐 [main_dev.dart] Initializing token provider...');
  _initializeTokenProvider(secureStorage);
  debugPrint('✅ [main_dev.dart] Token provider initialized');
  debugPrint('📍 [main_dev.dart] DioClient.isTokenProviderInitialized: ${DioClient.isTokenProviderInitialized}');
  debugPrint('═══════════════════════════════════════════════════════════════');
  debugPrint('');

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

  // Seed dummy data if enabled (use same storage instance)
  await DevDataSeeder.seedAll(secureStorage);

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
/// Uses the same FlutterSecureStorage instance as DevDataSeeder to avoid sync issues
void _initializeTokenProvider(FlutterSecureStorage storage) {
  DioClient.tokenProvider = _SimpleTokenProvider(storage);
}

/// Simple implementation of TokenProvider that reads from secure storage
class _SimpleTokenProvider implements TokenProvider {
  final FlutterSecureStorage _storage;

  _SimpleTokenProvider(this._storage);

  @override
  Future<String?> getAccessToken() async {
    try {
      debugPrint('🔐 [_SimpleTokenProvider] Reading accessToken from secure storage...');
      final token = await _storage.read(key: 'accessToken');

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ [_SimpleTokenProvider] accessToken found (${token.length} chars)');
        debugPrint('   Preview: ${token.substring(0, 30)}...');
      } else {
        debugPrint('❌ [_SimpleTokenProvider] accessToken is NULL or EMPTY');
        debugPrint('   Value: ${token == null ? "null" : "empty string"}');
      }

      return token;
    } catch (e) {
      debugPrint('❌ [_SimpleTokenProvider] Exception reading accessToken: $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      debugPrint('🔐 [_SimpleTokenProvider] Reading refreshToken from secure storage...');
      final token = await _storage.read(key: 'refreshToken');

      if (token != null && token.isNotEmpty) {
        debugPrint('✅ [_SimpleTokenProvider] refreshToken found (${token.length} chars)');
      } else {
        debugPrint('❌ [_SimpleTokenProvider] refreshToken is NULL or EMPTY');
      }

      return token;
    } catch (e) {
      debugPrint('❌ [_SimpleTokenProvider] Exception reading refreshToken: $e');
      return null;
    }
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    debugPrint('🔐 [_SimpleTokenProvider] Saving tokens to secure storage...');
    try {
      await _storage.write(key: 'accessToken', value: accessToken);
      debugPrint('✅ [_SimpleTokenProvider] accessToken saved (${accessToken.length} chars)');

      await _storage.write(key: 'refreshToken', value: refreshToken);
      debugPrint('✅ [_SimpleTokenProvider] refreshToken saved (${refreshToken.length} chars)');
    } catch (e) {
      debugPrint('❌ [_SimpleTokenProvider] Exception saving tokens: $e');
      rethrow;
    }
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

  String _getRoleName(DevRoleEnum role) {
    switch (role) {
      case DevRoleEnum.trainer:
        return 'trainer';
      case DevRoleEnum.client:
        return 'client';
      case DevRoleEnum.admin:
        return 'admin';
      case DevRoleEnum.notAuthenticated:
        return 'not authenticated';
    }
  }

  String _getTokenPreview(DevRoleEnum role) {
    switch (role) {
      case DevRoleEnum.trainer:
        final token = DevTokens.trainerAccessToken;
        return token.length > 20 ? '${token.substring(0, 20)}...' : token;
      case DevRoleEnum.client:
        final token = DevTokens.clientAccessToken;
        return token.length > 20 ? '${token.substring(0, 20)}...' : token;
      case DevRoleEnum.admin:
        final token = DevTokens.adminAccessToken;
        return token.length > 20 ? '${token.substring(0, 20)}...' : token;
      case DevRoleEnum.notAuthenticated:
        return 'No token';
    }
  }

  void _navigateToDashboard(BuildContext context, DevRoleEnum role) {
    switch (role) {
      case DevRoleEnum.trainer:
        GoRouter.of(context).go('/trainer/dashboard');
        break;
      case DevRoleEnum.client:
        GoRouter.of(context).go('/client/dashboard');
        break;
      case DevRoleEnum.admin:
        GoRouter.of(context).go('/admin/dashboard');
        break;
      case DevRoleEnum.notAuthenticated:
        GoRouter.of(context).go('/role-selection');
        break;
    }
  }

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
                  '🛠️ DevDataSeeder',
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
            const SizedBox(height: 8),
            // Current role status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: currentRole != DevRoleEnum.notAuthenticated
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Current Role: ${_getRoleName(currentRole)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (currentRole != DevRoleEnum.notAuthenticated) ...[
              const SizedBox(height: 4),
              Text(
                'Token: ${_getTokenPreview(currentRole)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Role section
            const Text(
              'Switch Role',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _RoleButton(
              label: '👨‍🏫 Trainer',
              isActive: currentRole == DevRoleEnum.trainer,
              onPressed: () async {
                await ref.read(devRoleProvider.notifier).selectTrainer();
                if (context.mounted) {
                  _navigateToDashboard(context, DevRoleEnum.trainer);
                }
              },
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '👤 Client',
              isActive: currentRole == DevRoleEnum.client,
              onPressed: () async {
                await ref.read(devRoleProvider.notifier).selectClient();
                if (context.mounted) {
                  _navigateToDashboard(context, DevRoleEnum.client);
                }
              },
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '👨‍💼 Admin',
              isActive: currentRole == DevRoleEnum.admin,
              onPressed: () async {
                await ref.read(devRoleProvider.notifier).selectAdmin();
                if (context.mounted) {
                  _navigateToDashboard(context, DevRoleEnum.admin);
                }
              },
            ),
            const SizedBox(height: 6),
            _RoleButton(
              label: '🚫 Not Auth',
              isActive: currentRole == DevRoleEnum.notAuthenticated,
              onPressed: () async {
                await ref.read(devRoleProvider.notifier).selectNotAuthenticated();
                if (context.mounted) {
                  _navigateToDashboard(context, DevRoleEnum.notAuthenticated);
                }
              },
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
