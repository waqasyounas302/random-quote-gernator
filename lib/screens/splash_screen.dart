import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'quote_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotateAnimation;
  Animation<Offset>? _quoteOffset;
  Animation<Offset>? _generatorOffset;
  Animation<double>? _glowAnimation;
  Animation<double>? _gradientAnimation;
  Animation<double>? _particleAnimation;
  Animation<double>? _textGlowAnimation;
  Animation<double>? _iconBounceAnimation;
  bool _isMounted = false;

  // Particle system
  final List<Particle> _particles = [];
  final Random _random = Random();

  // Modern gradient color palette
  final List<Color> _gradientColors = [
    const Color(0xFF0F2027), // Dark Teal
    const Color(0xFF203A43), // Deep Blue
    const Color(0xFF2C5364), // Ocean Blue
    const Color(0xFF1A1A2E), // Dark Purple
  ];

  // Accent colors for particles
  final List<Color> _particleColors = [
    const Color(0xFF64FFDA), // Turquoise
    const Color(0xFF4FC3F7), // Light Blue
    const Color(0xFFBA68C8), // Light Purple
    const Color(0xFFFFF176), // Light Yellow
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    // Initialize particles
    for (int i = 0; i < 25; i++) {
      _particles.add(Particle(_random));
    }

    // Initialize everything in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        _initializeAnimations();
      }
    });
  }

  void _initializeAnimations() {
    try {
      // Initialize controller
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      );

      // Text glow animation
      _textGlowAnimation =
          TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 40,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.7),
              weight: 30,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.7, end: 1.0),
              weight: 30,
            ),
          ]).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
          );

      // Icon bounce animation
      _iconBounceAnimation =
          TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              weight: 30,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.9),
              weight: 20,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.9, end: 1.0),
              weight: 50,
            ),
          ]).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
            ),
          );

      // Glow animation for icon
      _glowAnimation = TweenSequence<double>(
        [
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.7),
            weight: 30,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.7, end: 1.0),
            weight: 20,
          ),
        ],
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

      // Gradient animation for background shift
      _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
        ),
      );

      // Particle animation
      _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
        ),
      );

      // Fade animation
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
        ),
      );

      // Scale animation with overshoot
      _scaleAnimation =
          TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.2, end: 1.3),
              weight: 40,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.3, end: 0.8),
              weight: 20,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              weight: 40,
            ),
          ]).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
            ),
          );

      // Rotation animation with bounce
      _rotateAnimation =
          TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: -0.4, end: 0.2),
              weight: 50,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.2, end: 0.0),
              weight: 50,
            ),
          ]).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.1, 0.7, curve: Curves.bounceOut),
            ),
          );

      // "QUOTE" comes from left, "GENERATOR" comes from right
      _quoteOffset =
          Tween<Offset>(
            begin: const Offset(-4.0, 0.0), // Start far left
            end: const Offset(-0.5, 0.0), // Move to left half
          ).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
            ),
          );

      _generatorOffset =
          Tween<Offset>(
            begin: const Offset(4.0, 0.0), // Start far right
            end: const Offset(0.5, 0.0), // Move to right half
          ).animate(
            CurvedAnimation(
              parent: _controller!,
              curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
            ),
          );

      // Start animation
      _controller!.forward();

      // Navigate after delay
      Timer(const Duration(seconds: 5), () {
        if (_isMounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const QuoteScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    var curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    );

                    return FadeTransition(
                      opacity: curvedAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.5),
                          end: Offset.zero,
                        ).animate(curvedAnimation),
                        child: child,
                      ),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Animation error: $e');
      // If animations fail, navigate directly after delay
      Timer(const Duration(seconds: 3), () {
        if (_isMounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QuoteScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller ?? Listenable.merge([]),
        builder: (context, child) {
          final gradientValue = _gradientAnimation?.value ?? 0.0;
          final textGlowValue = _textGlowAnimation?.value ?? 0.0;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    _gradientColors[0],
                    _gradientColors[1],
                    gradientValue,
                  )!,
                  Color.lerp(
                    _gradientColors[1],
                    _gradientColors[2],
                    gradientValue,
                  )!,
                  Color.lerp(
                    _gradientColors[2],
                    _gradientColors[3],
                    gradientValue,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                if (_particleAnimation != null) ..._buildParticles(),

                // Animated floating elements
                _buildFloatingElements(),

                // Animated background circles
                Positioned(
                  top: 50 - (100 * (_gradientAnimation?.value ?? 0.0)),
                  right: -100 + (50 * (_gradientAnimation?.value ?? 0.0)),
                  child: Opacity(
                    opacity: 0.15 * (_fadeAnimation?.value ?? 0.0),
                    child: Transform.rotate(
                      angle: (_controller?.value ?? 0.0) * 0.2,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -150 + (100 * (_gradientAnimation?.value ?? 0.0)),
                  left: -100 + (50 * (_gradientAnimation?.value ?? 0.0)),
                  child: Opacity(
                    opacity: 0.1 * (_fadeAnimation?.value ?? 0.0),
                    child: Transform.rotate(
                      angle: -(_controller?.value ?? 0.0) * 0.2,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Quote icon with enhanced animations
                        if (_controller != null &&
                            _scaleAnimation != null &&
                            _fadeAnimation != null &&
                            _rotateAnimation != null)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Multiple glow effects
                              if (_glowAnimation != null)
                                AnimatedBuilder(
                                  animation: _glowAnimation!,
                                  builder: (context, child) {
                                    return Container(
                                      width: 200 + (40 * _glowAnimation!.value),
                                      height:
                                          200 + (40 * _glowAnimation!.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(
                                              0.15 * _glowAnimation!.value,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              if (_iconBounceAnimation != null)
                                AnimatedBuilder(
                                  animation: _iconBounceAnimation!,
                                  builder: (context, child) {
                                    return Container(
                                      width:
                                          160 +
                                          (20 * _iconBounceAnimation!.value),
                                      height:
                                          160 +
                                          (20 * _iconBounceAnimation!.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFF64FFDA).withOpacity(
                                              0.1 * _iconBounceAnimation!.value,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              // Main icon with multiple animations
                              RotationTransition(
                                turns: _rotateAnimation!,
                                child: ScaleTransition(
                                  scale: _scaleAnimation!,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation!,
                                    child: _buildAnimatedQuoteIcon(),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          _buildQuoteIcon(),

                        const SizedBox(height: 50),

                        // Text animation - "QUOTE" and "GENERATOR" come from opposite sides
                        if (_controller != null &&
                            _quoteOffset != null &&
                            _generatorOffset != null)
                          SizedBox(
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // "QUOTE" coming from left
                                Transform.translate(
                                  offset: Offset(
                                    (_quoteOffset!.value.dx *
                                        MediaQuery.of(context).size.width /
                                        10),
                                    0,
                                  ),
                                  child: _buildAnimatedTextWithGlow(
                                    'QUOTE',
                                    textGlowValue,
                                    isLeft: true,
                                  ),
                                ),

                                // "GENERATOR" coming from right
                                Transform.translate(
                                  offset: Offset(
                                    (_generatorOffset!.value.dx *
                                        MediaQuery.of(context).size.width /
                                        10),
                                    0,
                                  ),
                                  child: _buildAnimatedTextWithGlow(
                                    'GENERATOR',
                                    textGlowValue,
                                    isLeft: false,
                                  ),
                                ),

                                // Connection line when they meet
                                if (_controller!.value > 0.65)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: _controller!.value > 0.7
                                            ? 200
                                            : 0,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF64FFDA,
                                              ).withOpacity(
                                                textGlowValue * 0.8,
                                              ),
                                              const Color(
                                                0xFFBA68C8,
                                              ).withOpacity(
                                                textGlowValue * 0.8,
                                              ),
                                              const Color(
                                                0xFF64FFDA,
                                              ).withOpacity(
                                                textGlowValue * 0.8,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildText('QUOTE'),
                              const SizedBox(width: 20),
                              _buildText('GENERATOR'),
                            ],
                          ),

                        const SizedBox(height: 30),

                        // Animated subtitle with typing effect
                        if (_controller != null && _fadeAnimation != null)
                          _buildAnimatedSubtitle()
                        else
                          _buildSubtitle(),

                        const SizedBox(height: 80),

                        // Enhanced loading indicator with animation
                        _buildEnhancedLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: List.generate(8, (index) {
        final value = _controller?.value ?? 0.0;
        final offset = sin(value * pi * 2 + index * 0.5) * 20;

        return Positioned(
          left: (index % 3) * 100 + 50 + offset,
          top:
              (index ~/ 3) * 100 + 100 + cos(value * pi * 2 + index * 0.5) * 20,
          child: Opacity(
            opacity: 0.1 * (_fadeAnimation?.value ?? 0.0),
            child: Transform.rotate(
              angle: value * 0.5 + index * 0.1,
              child: Container(
                width: 30 + sin(value * pi * 2 + index) * 10,
                height: 30 + sin(value * pi * 2 + index) * 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _particleColors[index % _particleColors.length]
                      .withOpacity(0.2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildParticles() {
    final particleValue = _particleAnimation?.value ?? 0.0;
    final controllerValue = _controller?.value ?? 0.0;

    return _particles.map((particle) {
      final opacity = particle.opacity * particleValue;
      final scale = 0.3 + (particle.scale * particleValue * 0.7);
      final x = particle.x * MediaQuery.of(context).size.width;
      final y = particle.y * MediaQuery.of(context).size.height;

      // Add floating motion
      final floatOffset =
          sin(controllerValue * pi * 2 * particle.speed + particle.x * pi) * 10;

      return Positioned(
        left: x + floatOffset,
        top:
            y +
            cos(controllerValue * pi * 2 * particle.speed + particle.y * pi) *
                10,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [particle.color, particle.color.withOpacity(0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: particle.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildAnimatedQuoteIcon() {
    final glowValue = _glowAnimation?.value ?? 0.0;
    final bounceValue = _iconBounceAnimation?.value ?? 0.0;

    return Transform.scale(
      scale: 0.9 + (bounceValue * 0.1),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.3 + (0.1 * glowValue)),
              Colors.transparent,
            ],
            stops: const [0.1, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.4 + (0.3 * glowValue)),
            width: 3 + (2 * glowValue),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64FFDA).withOpacity(0.3 * glowValue),
              blurRadius: 30 * glowValue,
              spreadRadius: 10 * glowValue,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.2 * glowValue),
              blurRadius: 20 * glowValue,
              spreadRadius: 5 * glowValue,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.format_quote_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white.withOpacity(0.15), Colors.transparent],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: const Icon(
          Icons.format_quote_rounded,
          size: 70,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAnimatedTextWithGlow(
    String text,
    double glowValue, {
    required bool isLeft,
  }) {
    final controllerValue = _controller?.value ?? 0.0;
    final textScale = min(1.0, controllerValue * 1.5);
    final glowIntensity = glowValue * (isLeft ? 0.8 : 1.0);

    return Transform.scale(
      scale: 0.8 + (textScale * 0.2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isLeft ? 32 : 28,
          fontWeight: FontWeight.w900,
          letterSpacing: isLeft ? 3 : 2,
          color: Colors.white,
          shadows: [
            Shadow(
              color:
                  (isLeft ? const Color(0xFF64FFDA) : const Color(0xFFBA68C8))
                      .withOpacity(glowIntensity * 0.6),
              blurRadius: 30 * glowIntensity,
              offset: const Offset(0, 0),
            ),
            Shadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(2, 2),
            ),
            Shadow(
              color: Colors.white.withOpacity(0.1 * glowIntensity),
              blurRadius: 5,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    final controllerValue = _controller?.value ?? 0.0;
    final textLength = 28; // "Your Daily Source of Wisdom"
    final visibleLength = (textLength * min(1.0, (controllerValue - 0.6) * 2.5))
        .floor();

    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < textLength; i++)
            AnimatedOpacity(
              opacity: i < visibleLength ? 1.0 : 0.3,
              duration: const Duration(milliseconds: 100),
              child: Text(
                _getSubtitleChar(i),
                style: TextStyle(
                  fontSize: 16,
                  color: i < visibleLength
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSubtitleChar(int index) {
    const subtitle = "Your Daily Source of Wisdom";
    if (index < subtitle.length) {
      return subtitle[index];
    }
    return " ";
  }

  Widget _buildSubtitle() {
    return Text(
      'Your Daily Source of Wisdom',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.8),
        fontWeight: FontWeight.w300,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEnhancedLoadingIndicator() {
    return Column(
      children: [
        // Orbital loading animation
        if (_controller != null)
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                Transform.rotate(
                  angle: (_controller!.value * pi * 2),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF64FFDA).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Inner rotating dots
                ...List.generate(3, (index) {
                  final angle =
                      (_controller!.value * pi * 2) + (index * (2 * pi / 3));
                  final x = cos(angle) * 25;
                  final y = sin(angle) * 25;
                  final dotScale =
                      0.5 + (sin(_controller!.value * pi * 4 + index) * 0.3);

                  return Positioned(
                    left: 50 + x - 6,
                    top: 50 + y - 6,
                    child: Transform.scale(
                      scale: dotScale,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _particleColors[index % _particleColors.length],
                              _particleColors[(index + 1) %
                                  _particleColors.length],
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _particleColors[index %
                                          _particleColors.length]
                                      .withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Center dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          const CircularProgressIndicator(color: Colors.white),

        const SizedBox(height: 30),

        // Loading text with typing effect
        if (_controller != null)
          AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              final loadingText = "Preparing Inspirational Quotes";
              final textProgress = (_controller!.value - 0.3) * 3;
              final visibleChars =
                  (loadingText.length * min(1.0, max(0.0, textProgress)))
                      .floor();

              return Text(
                loadingText.substring(0, visibleChars),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              );
            },
          )
        else
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }
}

class Particle {
  final Random random;
  late double x;
  late double y;
  late double size;
  late Color color;
  late double opacity;
  late double scale;
  late double speed;

  Particle(this.random) {
    x = random.nextDouble();
    y = random.nextDouble();
    size = 3 + random.nextDouble() * 8;
    opacity = 0.15 + random.nextDouble() * 0.25;
    scale = random.nextDouble();
    speed = 0.3 + random.nextDouble() * 0.8;
    final colorIndex = random.nextInt(5);
    color = const [
      Color(0xFF64FFDA),
      Color(0xFF4FC3F7),
      Color(0xFFBA68C8),
      Color(0xFFFFF176),
      Colors.white,
    ][colorIndex];
  }
}
