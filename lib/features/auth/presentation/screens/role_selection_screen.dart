import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Role selection screen - first screen of the app.
///
/// User selects their role (Trainer or Client) before logging in.
/// Image-led hero cards with editorial-style layouts following design system.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // --color-bg
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                const _HeaderSection(),
                const SizedBox(height: 48), // space-2xl

                // Role cards
                _RoleCard(
                  imagePath: 'assets/images/trainer.jpg',
                  role: 'Trainer',
                  description: 'Transform lives. Build programs. Track client progress.',
                  onTap: () => context.go('/login?role=trainer'),
                  accentPosition: _AccentPosition.right,
                ),
                const SizedBox(height: 24), // space-lg

                _RoleCard(
                  imagePath: 'assets/images/client.jpg',
                  role: 'Client',
                  description: 'Achieve your goals. Follow expert guidance. Track your journey.',
                  onTap: () => context.go('/login?role=client'),
                  accentPosition: _AccentPosition.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark - minimal fitness icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2C33).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Color(0xFF2D2C33),
            size: 24,
          ),
        ),
        const SizedBox(height: 32), // space-xl

        // Title - Display Large (32px/700)
        const Text(
          'Welcome',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 40 / 32, // line height
            color: Color(0xFF2D2C33), // --color-text
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8), // space-sm

        // Subtitle - Body Large (16px/400)
        const Text(
          'Choose your path to get started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16, // line height
            color: Color(0xFF6B6B6B), // text-secondary
          ),
        ),
      ],
    );
  }
}

enum _AccentPosition { left, right }

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.imagePath,
    required this.role,
    required this.description,
    required this.onTap,
    required this.accentPosition,
  });

  final String imagePath;
  final String role;
  final String description;
  final VoidCallback onTap;
  final _AccentPosition accentPosition;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5), // surface-light
            borderRadius: BorderRadius.circular(16), // radius-lg
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: 0,
              ), // shadow-sm
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback gradient if image not found
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

                // Gradient overlay for text legibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24), // space-lg
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Role badge
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100), // radius-full
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(100), // radius-full
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                widget.role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 14 / 10,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),

                        // CTA button
                        Align(
                          alignment: widget.accentPosition == _AccentPosition.right
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _CTAButton(
                            label: 'Continue as ${widget.role}',
                            isPressed: _isPressed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Accent bar - visual indicator
                Positioned(
                  top: 0,
                  left: widget.accentPosition == _AccentPosition.left ? 0 : null,
                  right: widget.accentPosition == _AccentPosition.right ? 0 : null,
                  child: Container(
                    width: 4,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFB10C0C), // --color-accent
                          Colors.transparent,
                        ],
                      ),
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
}

class _CTAButton extends StatelessWidget {
  const _CTAButton({
    required this.label,
    required this.isPressed,
  });

  final String label;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isPressed
            ? const Color(0xFF980A0A) // Darker red when pressed
            : const Color(0xFFB10C0C), // --color-accent
        borderRadius: BorderRadius.circular(12), // radius-md
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB10C0C).withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
