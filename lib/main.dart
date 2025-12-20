import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/app_constants.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize token provider BEFORE anything else
  _initializeTokenProvider();

  // Only load .env on native platforms (mobile/desktop)
  // Web uses hardcoded localhost:8000
  if (!kIsWeb) {
    try {
      await AppConstants.load();
    } catch (e) {
      debugPrint('Failed to load app constants: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(),
        ),
      ],
      child: const PersonalTrainerApp(),
    ),
  );
}

/// Initialize the token provider before the app runs
/// This ensures DioClient has access to tokens from the very beginning
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

class PersonalTrainerApp extends ConsumerWidget {
  const PersonalTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Personal Trainer App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
