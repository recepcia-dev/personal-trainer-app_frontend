import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/auth/biometric_auth_service.dart';

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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking biometric availability: $e';
        });
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
        if (mounted) {
          _showSuccessMessage('Authentication successful!');

          // Navigate to dashboard after successful authentication
          if (mounted) {
            context.go('/dashboard');
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
        backgroundColor: Colors.red[600],
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
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isAuthenticating,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Identity'),
          elevation: 0,
          automaticallyImplyLeading: !_isAuthenticating,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'One More Step',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    'Use biometric to complete login',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Biometric availability status
                  if (!_biometricAvailable)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Biometric not available. Please use PIN.',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 14,
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
                            'Available methods:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _availableBiometrics
                                .map((biometric) => Chip(
                                      avatar: Icon(
                                        _getBiometricIcon(biometric),
                                        size: 18,
                                      ),
                                      label: Text(
                                        _getBiometricName(biometric),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                    // Error message if any
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Retry counter
                    if (_retryCount > 0)
                      Text(
                        'Attempts: $_retryCount / $_maxRetries',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _retryCount >= _maxRetries
                                  ? Colors.red[600]
                                  : Colors.grey[600],
                            ),
                      ),
                    const SizedBox(height: 32),

                    // Authenticate button
                    ElevatedButton.icon(
                      onPressed: _isAuthenticating ||
                              _retryCount >= _maxRetries
                          ? null
                          : _authenticateWithBiometric,
                      icon: _isAuthenticating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isAuthenticating
                            ? 'Authenticating...'
                            : 'Authenticate',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Info text
                  Text(
                    'Your session is protected by device-bound authentication.\nYou can only use this session on this device.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
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
