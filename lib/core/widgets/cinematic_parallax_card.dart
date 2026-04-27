import 'package:flutter/material.dart';

/// A cinematic card that takes a 4K high-resolution image and applies a 
/// slow, subtle scaling (breathing/parallax) effect to make it feel alive.
class CinematicParallaxCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color themeColor;
  final VoidCallback onTap;

  const CinematicParallaxCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.onTap,
  });

  @override
  State<CinematicParallaxCard> createState() => _CinematicParallaxCardState();
}

class _CinematicParallaxCardState extends State<CinematicParallaxCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // 10 seconds per cycle for a very slow, premium cinematic float
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Subtle scale from 1.0 to 1.15
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. The highly detailed 4K image with slow zoom animation
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    // Use high filter quality for the zoom effect to look 4K sharp
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.themeColor.withOpacity(0.4),
                            widget.themeColor.withOpacity(0.15),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: widget.themeColor.withOpacity(0.6),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Cinematic vignette & gradient overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        (isDark ? const Color(0xFF0F172A) : Colors.black).withOpacity(0.05),
                        (isDark ? const Color(0xFF0F172A) : Colors.black).withOpacity(0.4),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. A subtle colored glow from the theme color at the bottom
              Positioned(
                bottom: -20,
                left: -20,
                right: -20,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        widget.themeColor.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),

              // 4. Text Content (Title & Subtitle)
              Positioned(
                bottom: 16,
                left: 14,
                right: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.2,
                        color: Colors.white.withOpacity(0.85),
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
