import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Signup role selection screen - allows new users to choose their role.
///
/// Used when signing up for a new account.
/// Flow:
/// 1. User clicks "Crear Cuenta" from login screen
/// 2. User selects "I'm a Trainer" or "I'm a Client"
/// 3. Routes to new SignupEmailScreen with selected role
class SignupRoleSelectionScreen extends StatelessWidget {
  const SignupRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/login')),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'What is your role?',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Choose your role to create your account',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Trainer button
                _RoleButton(
                  icon: Icons.sports,
                  label: "I'm a Trainer",
                  description: 'Manage clients and create workouts',
                  onTap: () => context.go('/signup-email?role=trainer'),
                  backgroundColor: Colors.blue[700]!,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),

                // Client button
                _RoleButton(
                  icon: Icons.person,
                  label: "I'm a Client",
                  description: 'Track workouts and progress',
                  onTap: () => context.go('/signup-email?role=client'),
                  backgroundColor: Colors.green[700]!,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: iconColor.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
