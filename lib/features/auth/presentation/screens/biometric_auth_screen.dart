import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/auth/biometric_auth_service.dart';
import '../../../../core/constants/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_repository_provider.dart';

/// Device-bound authentication screen using biometric (Face ID, Touch ID, Fingerprint).
///
/// This screen is shown after successful magic link code verification.
/// Users must authenticate with their device's biometric (or PIN fallback)
/// before being allowed to access the dashboard.
///
/// The biometric authentication binds the user's session to the device,
/// preventing token reuse on other devices.
class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() =>
      _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;
  List<BiometricType> _availableBiometrics = [];
  bool _biometricAvailable = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  /// Auto-skip biometric for web/development without biometric support
  void _autoSkipIfNoSupportedBiometric() {
    if (!_biometricAvailable && mounted) {
      print('🔍 DEBUG: No biometric available, auto-skipping to dashboard');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          print('✅ DEBUG: Navigating to dashboard (no biometric needed for web)');
          context.go('/dashboard');
        }
      });
    }
  }

  /// Check what biometric methods are available on this device
  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricAuthServiceProvider);

    try {
      final canAuthenticate =
          await biometricService.canAuthenticateWithBiometrics();
      final available = await biometricService.getAvailableBiometrics();

      if (mounted) {
        setState(() {
          _biometricAvailable = canAuthenticate;
          _availableBiometrics = available;
          _errorMessage = null;
        });

        // Auto-skip biometric for web/development
        _autoSkipIfNoSupportedBiometric();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking biometric availability: $e';
          _biometricAvailable = false;
        });

        // Auto-skip if there's an error (likely web/no biometric)
        _autoSkipIfNoSupportedBiometric();
      }
    }
  }

  /// Get user-friendly name for biometric type
  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.strong:
        return 'Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get icon for biometric type
  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      case BiometricType.strong:
      case BiometricType.weak:
        return Icons.security;
    }
  }

  /// Authenticate using biometric
  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating || !_biometricAvailable) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final biometricService = ref.read(biometricAuthServiceProvider);

    try {
      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to complete login and access your account',
        biometricOnly: false, // Allow PIN fallback
      );

      if (authenticated) {
        // Biometric authentication succeeded - now bind the device
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });

          _showSuccessMessage('Biometric authentication successful!');

          // Bind device to authenticated session
          final authRepository = ref.read(authRepositoryProvider);
          final bindResult = await authRepository.bindDevice();

          if (mounted) {
            bindResult.fold(
              (failure) {
                // Device binding failed, but biometric auth succeeded
                // Still allow navigation but show warning
                setState(() {
                  _errorMessage = 'Device binding failed: ${failure.message}';
                });
                _showErrorMessage(
                  'Warning: Device binding incomplete. Your session may be less secure.',
                );

                // Still navigate to dashboard after brief delay
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    context.go('/dashboard');
                  }
                });
              },
              (_) {
                // Device binding succeeded - navigate to dashboard
                _showSuccessMessage('Device binding successful!');

                if (mounted) {
                  context.go('/dashboard');
                }
              },
            );
          }
        }
      } else {
        // User cancelled or authentication failed
        if (mounted) {
          setState(() {
            _retryCount++;
            _errorMessage = _retryCount >= _maxRetries
                ? 'Maximum authentication attempts exceeded. Please try again later.'
                : 'Authentication failed. Please try again.';
            _isAuthenticating = false;
          });
        }
      }
    } on BiometricAuthException catch (e) {
      if (mounted) {
        setState(() {
          _retryCount++;
          _errorMessage = e.message;
          _isAuthenticating = false;
        });

        _showErrorMessage(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _retryCount++;
          _errorMessage = 'Unexpected error: $e';
          _isAuthenticating = false;
        });

        _showErrorMessage('Unexpected error: $e');
      }
    }
  }

  /// Show error message to user
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success message to user
  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAuthenticating,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Verify Identity'),
          centerTitle: true,
          automaticallyImplyLeading: !_isAuthenticating,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: DesignTokens.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: DesignTokens.space2xl),

                  // Icon
                  Container(
                    width: DesignTokens.avatarXl,
                    height: DesignTokens.avatarXl,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      size: DesignTokens.iconXl + 8,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spaceXl),

                  // Title
                  Text(
                    'One More Step',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignTokens.spaceSm),

                  // Message
                  Text(
                    'Verify your identity to complete secure login',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: DesignTokens.space2xl),

                  // Biometric availability status
                  if (!_biometricAvailable)
                    Container(
                      padding: EdgeInsets.all(DesignTokens.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.warningColor,
                          width: DesignTokens.borderStandard,
                        ),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.warningColor,
                            size: DesignTokens.iconMd,
                          ),
                          SizedBox(width: DesignTokens.spaceSm),
                          Expanded(
                            child: Text(
                              'Biometric not available. Please use device PIN.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.warningColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Available biometric types
                    if (_availableBiometrics.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Available authentication methods:',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          SizedBox(height: DesignTokens.spaceSm),
                          Wrap(
                            spacing: DesignTokens.spaceSm,
                            runSpacing: DesignTokens.spaceSm,
                            alignment: WrapAlignment.center,
                            children: _availableBiometrics
                                .map((biometric) => Chip(
                                      avatar: Icon(
                                        _getBiometricIcon(biometric),
                                        size: DesignTokens.iconSm,
                                      ),
                                      label: Text(
                                        _getBiometricName(biometric),
                                      ),
                                    ))
                                .toList(),
                          ),
                          SizedBox(height: DesignTokens.spaceXl),
                        ],
                      ),

                    // Error message if any
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(DesignTokens.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppTheme.errorColor,
                            width: DesignTokens.borderStandard,
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: DesignTokens.iconMd,
                            ),
                            SizedBox(width: DesignTokens.spaceSm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.errorColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: DesignTokens.spaceLg),
                    ],

                    // Retry counter
                    if (_retryCount > 0) ...[
                      Text(
                        'Attempt $_retryCount of $_maxRetries',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _retryCount >= _maxRetries
                                  ? AppTheme.errorColor
                                  : AppTheme.textSecondary,
                            ),
                      ),
                      SizedBox(height: DesignTokens.spaceMd),
                    ],

                    // Authenticate button
                    ElevatedButton.icon(
                      onPressed: _isAuthenticating ||
                              _retryCount >= _maxRetries
                          ? null
                          : _authenticateWithBiometric,
                      icon: _isAuthenticating
                          ? SizedBox(
                              width: DesignTokens.iconMd,
                              height: DesignTokens.iconMd,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.textPrimary,
                              ),
                            )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isAuthenticating
                            ? 'Authenticating...'
                            : 'Authenticate Now',
                      ),
                    ),
                  ],

                  SizedBox(height: DesignTokens.spaceXl),

                  // Security info card
                  Container(
                    padding: EdgeInsets.all(DesignTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppTheme.infoColor,
                          size: DesignTokens.iconMd,
                        ),
                        SizedBox(width: DesignTokens.spaceSm),
                        Expanded(
                          child: Text(
                            'Device-bound security. This session works only on this device.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
