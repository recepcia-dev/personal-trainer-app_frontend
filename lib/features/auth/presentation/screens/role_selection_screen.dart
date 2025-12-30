import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Role selection screen - first screen of the app.
///
/// User selects their role (Trainer or Client) before logging in.
/// Single unified card with full image and horizontal divider.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;

  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Card animation controller
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Card animations: fade in + slide up
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    _cardSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    // Start card animation
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // --color-bg
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Single unified role selection card
              Expanded(
                child: FadeTransition(
                  opacity: _cardFadeAnimation,
                  child: SlideTransition(
                    position: _cardSlideAnimation,
                    child: _UnifiedRoleCard(
                      imagePath: 'assets/images/full-trainer-client.jpg',
                      onTrainerTap: () => context.go('/login?role=trainer'),
                      onClientTap: () => context.go('/login?role=client'),
                    ),
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

class _UnifiedRoleCard extends StatelessWidget {
  const _UnifiedRoleCard({
    required this.imagePath,
    required this.onTrainerTap,
    required this.onClientTap,
  });

  final String imagePath;
  final VoidCallback onTrainerTap;
  final VoidCallback onClientTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2D2C33).withOpacity(0.2),
                        const Color(0xFF2D2C33).withOpacity(0.4),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Horizontal divider line in the middle
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                height: 1,
                color: const Color(0xFFD0D0D0), // Neutral gray
              ),
            ),
          ),

          // Trainer button - top right
          Positioned(
            top: 24,
            right: 24,
            child: _RoleButton(
              label: 'Continuar como Entrenador',
              onTap: onTrainerTap,
            ),
          ),

          // Client button - bottom right
          Positioned(
            bottom: 24,
            right: 24,
            child: _RoleButton(
              label: 'Continuar como Cliente',
              onTap: onClientTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatefulWidget {
  const _RoleButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_RoleButton> createState() => _RoleButtonState();
}

class _RoleButtonState extends State<_RoleButton> with TickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<Offset> _arrowSlideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Arrow slides right on hover
    _arrowSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0)).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _arrowController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _arrowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // Dark background
            border: Border.all(
              color: const Color(0xFFFF66C4), // Primary Pink
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12), // radius-md
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: Color(0xFFFF66C4), // Primary Pink text
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              SlideTransition(
                position: _arrowSlideAnimation,
                child: const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Color(0xFFFF66C4), // Primary Pink icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
