import 'dart:math';
import 'package:flutter/material.dart';

class ZenAuraBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const ZenAuraBackground({super.key, required this.child, this.colors});

  @override
  State<ZenAuraBackground> createState() => _ZenAuraBackgroundState();
}

class _ZenAuraBackgroundState extends State<ZenAuraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Brighter, more visible default colors — same in both themes
    final defaultColors = [
      const Color(0xFF6366F1).withOpacity(isDark ? 0.30 : 0.20), // Indigo
      const Color(0xFF14B8A6).withOpacity(isDark ? 0.25 : 0.18), // Teal
      const Color(0xFF8B5CF6).withOpacity(isDark ? 0.30 : 0.20), // Purple
      const Color(0xFFF43F5E).withOpacity(isDark ? 0.18 : 0.12), // Rose
    ];

    // Solid base gradient so background is NEVER plain dark/plain white
    final baseGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep navy
              Color(0xFF1A1040), // Purple-tinted dark
              Color(0xFF0D1B2A), // Blue-tinted dark
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F0FF), // Soft lavender
              Color(0xFFE8FFF8), // Mint tint
              Color(0xFFF5F0FF), // Light purple
            ],
          );

    return RepaintBoundary(
      child: Stack(
        children: [
          // 1. Solid base gradient — always visible
          Container(decoration: BoxDecoration(gradient: baseGradient)),
          // 2. Animated color blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return RepaintBoundary(
                child: CustomPaint(
                  painter: _AuraPainter(
                    progress: _controller.value,
                    colors: widget.colors ?? defaultColors,
                  ),
                  child: Container(),
                ),
              );
            },
          ),
          // 3. Subtle glass overlay
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.10)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _AuraPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    for (int i = 0; i < colors.length; i++) {
      final angle = (progress * 2 * pi) + (i * pi / 2);
      final x = size.width / 2 + cos(angle) * size.width * 0.35;
      final y = size.height / 2 + sin(angle * 1.5) * size.height * 0.25;

      canvas.drawCircle(
        Offset(x, y),
        250 + (sin(progress * 2 * pi) * 50),
        paint..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
