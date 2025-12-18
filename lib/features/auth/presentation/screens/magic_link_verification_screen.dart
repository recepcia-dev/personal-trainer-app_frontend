import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/admin_model.dart';
import '../../data/models/client_model.dart';
import '../../data/models/trainer_model.dart';
import '../providers/auth_state_provider.dart';

/// Verification screen - user enters code from email.
///
/// Simple flow:
/// 1. User enters 6-digit code
/// 2. Code is verified
/// 3. Navigate directly to appropriate dashboard
class MagicLinkVerificationScreen extends ConsumerStatefulWidget {
  const MagicLinkVerificationScreen({
    required this.email,
    this.code,
    super.key,
  });

  final String email;
  final String? code;

  @override
  ConsumerState<MagicLinkVerificationScreen> createState() =>
      _MagicLinkVerificationScreenState();
}

class _MagicLinkVerificationScreenState
    extends ConsumerState<MagicLinkVerificationScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _resendCountdown = 60;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();

    // Auto-fill code if provided via deep link
    if (widget.code != null && widget.code!.length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _codeController.text = widget.code!;
        _verifyCode();
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'Code must be 6 digits');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final user = await ref.read(authStateProvider.notifier).verifyMagicLink(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (user != null) {
      // Navigate to appropriate dashboard
      if (user is AdminModel) {
        context.go('/admin/dashboard');
      } else if (user is TrainerModel) {
        context.go('/trainer/dashboard');
      } else if (user is ClientModel) {
        context.go('/client/dashboard');
      } else {
        context.go('/trainer/dashboard'); // fallback
      }
    } else {
      setState(() => _errorMessage = 'Invalid code. Please try again.');
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0) return;

    final success = await ref.read(authStateProvider.notifier).sendMagicLink(widget.email);

    if (mounted) {
      _startResendCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Code resent to ${widget.email}' : 'Failed to resend code'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
        title: const Text('Verify Code'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Header
              Text(
                'Check your email',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to\n${widget.email}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Code input
              TextField(
                controller: _codeController,
                enabled: !_isLoading,
                autofocus: true,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  letterSpacing: 8,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _errorMessage,
                ),
                onChanged: (value) {
                  // Auto-verify when complete
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
                onSubmitted: (_) => _verifyCode(),
              ),
              const SizedBox(height: 24),

              // Verify button
              FilledButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify Code', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),

              // Resend button
              Center(
                child: TextButton(
                  onPressed: _resendCountdown > 0 ? null : _resendCode,
                  child: Text(
                    _resendCountdown > 0
                        ? 'Resend code (${_resendCountdown}s)'
                        : 'Resend code',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
