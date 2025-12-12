import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../providers/auth_state_provider.dart';

/// Magic link verification screen for passwordless authentication.
///
/// Users enter the 6-digit code they received via email.
/// On success, the app navigates to device-bound authentication (biometric/PIN).
class MagicLinkVerificationScreen extends ConsumerStatefulWidget {
  const MagicLinkVerificationScreen({required this.email, super.key});

  final String email;

  @override
  ConsumerState<MagicLinkVerificationScreen> createState() =>
      _MagicLinkVerificationScreenState();
}

class _MagicLinkVerificationScreenState
    extends ConsumerState<MagicLinkVerificationScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _autoVerifyAttempted = false;
  String? _codeErrorMessage;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Start countdown timer for resending magic link
  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  /// Verify the entered code
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        _codeErrorMessage = 'Code must be 6 digits';
      });
      return;
    }

    setState(() {
      _codeErrorMessage = null;
    });

    await ref.read(authStateProvider.notifier).verifyMagicLink(
          email: widget.email,
          code: code,
        );
  }

  /// Resend magic link to user's email
  Future<void> _resendMagicLink() async {
    if (_resendCountdown > 0) {
      return;
    }

    await ref
        .read(authStateProvider.notifier)
        .sendMagicLink(email: widget.email);

    _startResendCountdown();

    if (mounted) {
      _showSuccessMessage(context, 'Magic link resent to ${widget.email}');
    }
  }

  /// Extract error message from failure object
  String _getErrorMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen for verification success/error
    ref.listen<AsyncValue<dynamic>>(
      authStateProvider,
      (previous, next) {
        next.whenData((user) {
          if (user != null && _autoVerifyAttempted) {
            // Success: User verified and authenticated
            _showSuccessMessage(context, 'Verification successful!');

            // TODO: Navigate to BiometricAuthScreen (F032) when implemented
            // For now, navigate directly to dashboard
            if (mounted) {
              context.go('/dashboard');
            }
          }
        });

        next.maybeWhen(
          error: (error, stack) {
            final errorMsg = _getErrorMessage(error);
            setState(() {
              _autoVerifyAttempted = false;
              _codeErrorMessage = errorMsg;
            });
            _showErrorMessage(context, errorMsg);
          },
          orElse: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 32),
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit code to\n${widget.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                // Code input field
                TextField(
                  controller: _codeController,
                  enabled: !authState.isLoading,
                  autofocus: true,
                  obscureText: true,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    hintText: '000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _codeErrorMessage,
                    errorMaxLines: 2,
                  ),
                  onChanged: (value) {
                    // Auto-verify when code is complete
                    if (value.length == 6 && !_autoVerifyAttempted) {
                      setState(() => _autoVerifyAttempted = true);
                      _verifyCode();
                    } else if (value.length < 6) {
                      setState(() => _autoVerifyAttempted = false);
                    }
                  },
                  onSubmitted: (_) {
                    if (!authState.isLoading && !_autoVerifyAttempted) {
                      _verifyCode();
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Verify button or loading indicator
                if (authState.isLoading)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Verifying code...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _verifyCode,
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
                    child: const Text(
                      'Verify Code',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 24),

                // Resend link button with countdown
                Center(
                  child: TextButton(
                    onPressed: _resendCountdown > 0 ? null : _resendMagicLink,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend link (${_resendCountdown}s)'
                          : 'Resend link',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show success message to user
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show error message to user
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
