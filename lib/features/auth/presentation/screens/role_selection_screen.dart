import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Role selection screen - first screen of the app.
///
/// User selects their role (Trainer or Client) before logging in.
/// Image-led hero cards with editorial-style layouts following design system.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _card1Controller;
  late AnimationController _card2Controller;

  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _card1FadeAnimation;
  late Animation<Offset> _card1SlideAnimation;
  late Animation<double> _card2FadeAnimation;
  late Animation<Offset> _card2SlideAnimation;

  @override
  void initState() {
    super.initState();

    // Header animation controller
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Card animation controllers with staggered timing
    _card1Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _card2Controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Header animations: fade in + slide up
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    // Card 1 animations: fade in + slide up
    _card1FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _card1Controller, curve: Curves.easeOut),
    );

    _card1SlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _card1Controller, curve: Curves.easeOut),
    );

    // Card 2 animations: fade in + slide up (with delay)
    _card2FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _card2Controller, curve: Curves.easeOut),
    );

    _card2SlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _card2Controller, curve: Curves.easeOut),
    );

    // Start animations sequentially
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _card1Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _card2Controller.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _card1Controller.dispose();
    _card2Controller.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with fade-in and slide-up animation
              FadeTransition(
                opacity: _headerFadeAnimation,
                child: SlideTransition(
                  position: _headerSlideAnimation,
                  child: const _HeaderSection(),
                ),
              ),
              const SizedBox(height: 48), // space-2xl

              // Role cards side-by-side
              Expanded(
                child: Row(
                  children: [
                    // First role card with staggered animation
                    Flexible(
                      flex: 1,
                      child: FadeTransition(
                        opacity: _card1FadeAnimation,
                        child: SlideTransition(
                          position: _card1SlideAnimation,
                          child: _RoleCard(
                            imagePath: 'assets/images/trainer.jpg',
                            role: 'Trainer',
                            description:
                                'Transform lives. Build programs. Track client progress.',
                            onTap: () => context.go('/login?role=trainer'),
                            accentPosition: _AccentPosition.right,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24), // space-lg for horizontal gap

                    // Second role card with staggered animation
                    Flexible(
                      flex: 1,
                      child: FadeTransition(
                        opacity: _card2FadeAnimation,
                        child: SlideTransition(
                          position: _card2SlideAnimation,
                          child: _RoleCard(
                            imagePath: 'assets/images/client.jpg',
                            role: 'Client',
                            description:
                                'Achieve your goals. Follow expert guidance. Track your journey.',
                            onTap: () => context.go('/login?role=client'),
                            accentPosition: _AccentPosition.left,
                          ),
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

class _RoleCardState extends State<_RoleCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _elevationController;
  late Animation<double> _shadowAnimation;
  late AnimationController _imageZoomController;
  late Animation<double> _imageZoomAnimation;
  late AnimationController _badgeFloatController;
  late Animation<Offset> _badgeFloatAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

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

    // Shadow elevation animation
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _elevationController, curve: Curves.easeOut),
    );

    // Image zoom animation
    _imageZoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _imageZoomAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _imageZoomController, curve: Curves.easeOut),
    );

    // Badge floating animation - continuous loop
    _badgeFloatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _badgeFloatAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -0.08))
            .animate(
      CurvedAnimation(parent: _badgeFloatController, curve: Curves.easeInOut),
    );
    // Make it loop back and forth
    _badgeFloatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _elevationController.dispose();
    _imageZoomController.dispose();
    _badgeFloatController.dispose();
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

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _elevationController.forward();
    _imageZoomController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _elevationController.reverse();
    _imageZoomController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _shadowAnimation,
            builder: (context, child) {
              // Interpolate between shadow-sm and shadow-md
              final shadowBlur =
                  4.0 + (_shadowAnimation.value * 4.0); // 4 to 8
              final shadowOffset = _shadowAnimation.value * 2.0; // 0 to 2
              final shadowOpacity =
                  0.1 + (_shadowAnimation.value * 0.05); // 0.1 to 0.15

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5), // surface-light
                  borderRadius: BorderRadius.circular(16), // radius-lg
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(shadowOpacity),
                      offset: Offset(0, shadowOffset),
                      blurRadius: shadowBlur,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background image with zoom on hover
                      Positioned.fill(
                        child: ClipRect(
                          child: ScaleTransition(
                            scale: _imageZoomAnimation,
                            alignment: Alignment.center,
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
                              // Role badge with floating animation
                              SlideTransition(
                                position: _badgeFloatAnimation,
                                child: ClipRRect(
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
                                Color(0xFFFF66C4), // Primary Pink
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CTAButton extends StatefulWidget {
  const _CTAButton({
    required this.label,
    required this.isPressed,
  });

  final String label;
  final bool isPressed;

  @override
  State<_CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<_CTAButton> with TickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<Offset> _arrowSlideAnimation;
  late AnimationController _glowPulseController;
  late Animation<double> _glowPulseAnimation;
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

    // Glow pulse animation - continuous loop
    _glowPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowPulseAnimation = Tween<double>(begin: 0.2, end: 0.4).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );
    _glowPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _glowPulseController.dispose();
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
      child: AnimatedBuilder(
        animation: _glowPulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isPressed
                  ? const Color(0xFFE63BA0) // Primary Pink (pressed/darker shade)
                  : const Color(0xFFFF66C4), // Primary Pink
              borderRadius: BorderRadius.circular(12), // radius-md
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF66C4)
                      .withOpacity(_glowPulseAnimation.value),
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
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                SlideTransition(
                  position: _arrowSlideAnimation,
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
