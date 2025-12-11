import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_repository_provider.dart';

part 'auth_state_provider.g.dart';

/// Authentication state provider using Riverpod with async state management
///
/// Manages the complete authentication lifecycle:
/// - Initialization: Loads current authenticated user on app start
/// - sendMagicLink: Initiates passwordless authentication
/// - verifyMagicLink: Validates magic link code and authenticates
/// - authenticateWithBiometric: Device-bound authentication (placeholder for F035)
/// - logout: Clears authentication tokens and session
///
/// State: AsyncValue<dynamic> where the value is:
/// - null: No authenticated user
/// - Trainer: Trainer is authenticated
/// - Client: Client is authenticated
///
/// Usage:
/// ```dart
/// ref.watch(authStateProvider);  // Listen to auth state
/// await ref.read(authStateProvider.notifier).sendMagicLink(email: 'user@example.com');
/// ```
@riverpod
class AuthState extends _$AuthState {
  /// Initialize authentication state by fetching current user
  @override
  Future<dynamic> build() async {
    final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
    final result = await getCurrentUserUseCase.call();

    return result.fold(
      (failure) => null, // No authenticated user or error
      (user) => user,    // Return authenticated user (Trainer or Client)
    );
  }

  /// Initiate passwordless authentication by sending magic link to email
  ///
  /// Sends a time-limited magic link to the user's email address.
  /// User will receive an email with a code to enter in the next step.
  ///
  /// Parameters:
  ///   - email: User's email address
  ///
  /// State transitions:
  ///   - Initial: null (no user yet)
  ///   - Loading: AsyncLoading while sending email
  ///   - Success: AsyncData(null) - keeps null state (user not auth'd yet)
  ///   - Error: AsyncError with Failure
  Future<void> sendMagicLink({required String email}) async {
    state = const AsyncLoading();

    final sendMagicLinkUseCase = ref.watch(sendMagicLinkUseCaseProvider);
    final result = await sendMagicLinkUseCase.call(email: email);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        // Link sent successfully - stay in null state
        // User will verify code in next step
        state = const AsyncData(null);
      },
    );
  }

  /// Verify magic link code and authenticate user
  ///
  /// Called after user enters the verification code from email.
  /// On success, authentication tokens are stored securely.
  ///
  /// Parameters:
  ///   - email: User's email address
  ///   - code: 6-digit verification code from email
  ///
  /// State transitions:
  ///   - Initial: null
  ///   - Loading: AsyncLoading while verifying code
  ///   - Success: AsyncData(Trainer|Client) with authenticated user
  ///   - Error: AsyncError with Failure
  ///
  /// Next step: Call authenticateWithBiometric() for device-bound auth
  Future<void> verifyMagicLink({
    required String email,
    required String code,
  }) async {
    state = const AsyncLoading();

    final verifyMagicLinkUseCase = ref.watch(verifyMagicLinkUseCaseProvider);
    final result = await verifyMagicLinkUseCase.call(email: email, code: code);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (user) {
        // Code verified successfully - user authenticated from server
        state = AsyncData(user);
      },
    );
  }

  /// Authenticate with device-bound biometric or PIN
  ///
  /// Second factor authentication using local biometric (Face ID, Touch ID) or PIN.
  /// Ensures that the token issued by the server is bound to this specific device.
  ///
  /// This is a placeholder implementation. Full implementation in F035 (BiometricAuthService).
  ///
  /// Current state:
  /// - Not yet implemented - throws UnimplementedError
  /// - Will be integrated in F035 with local_auth package
  ///
  /// Throws: UnimplementedError - to be removed in F035
  Future<void> authenticateWithBiometric() async {
    // TODO: Implement in F035 - BiometricAuthService integration
    // This method will:
    // 1. Check if biometric is available on device
    // 2. Prompt user for biometric auth (Face ID, Touch ID, Fingerprint)
    // 3. Fall back to PIN entry if biometric unavailable
    // 4. Bind token to device to prevent reuse on other devices
    throw UnimplementedError(
      'Device-bound biometric authentication will be implemented in F035. '
      'Use BiometricAuthService for biometric/PIN authentication.',
    );
  }

  /// Logout the current user
  ///
  /// Clears authentication tokens from secure storage and resets auth state.
  /// User is returned to unauthenticated state (null).
  ///
  /// State transitions:
  ///   - Initial: Trainer|Client (authenticated)
  ///   - Loading: AsyncLoading while clearing tokens
  ///   - Success: AsyncData(null) - no authenticated user
  ///   - Error: AsyncError with Failure (token clear failed)
  Future<void> logout() async {
    state = const AsyncLoading();

    final logoutUseCase = ref.watch(logoutUseCaseProvider);
    final result = await logoutUseCase.call();

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (_) {
        // Logout successful - clear user state
        state = const AsyncData(null);
      },
    );
  }
}

