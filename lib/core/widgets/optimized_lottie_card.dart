import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

class OptimizedLottieCard extends StatefulWidget {
  final String lottieAsset;
  final String title;
  final String subtitle;
  final Color themeColor;
  final VoidCallback onTap;

  const OptimizedLottieCard({
    super.key,
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.onTap,
  });

  @override
  State<OptimizedLottieCard> createState() => _OptimizedLottieCardState();
}

class _OptimizedLottieCardState extends State<OptimizedLottieCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isVisible = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Use an extended loop duration (e.g., 20 seconds) for all animations to ensure psychological calm
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    
    // Play only when strongly visible (offscreen pausing for battery/CPU)
    if (info.visibleFraction > 0.2 && !_isVisible) {
      setState(() => _isVisible = true);
      _controller.repeat();
    } else if (info.visibleFraction <= 0.2 && _isVisible) {
      setState(() => _isVisible = false);
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('lottie_card_\${widget.title}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isHovered = true),
          onTapUp: (_) => setState(() => _isHovered = false),
          onTapCancel: () => setState(() => _isHovered = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutExpo,
            transform: Matrix4.identity()..scale(_isHovered ? 0.96 : 1.0),
            child: Stack(
              children: [
                // Glowing Background Shadow
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _isHovered ? 0.8 : 0.4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: widget.themeColor.withOpacity(0.5),
                            blurRadius: 24,
                            spreadRadius: _isHovered ? 4 : 0,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Card Inner
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.themeColor.withOpacity(0.2),
                        widget.themeColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Backdrop Blur (Glassmorphism)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      
                      // Lottie Animation Container (Top Half)
                      Positioned(
                        top: -20,
                        right: -20,
                        bottom: 60,
                        left: 20,
                        child: RepaintBoundary(
                          child: Lottie.asset(
                            widget.lottieAsset,
                            controller: _controller,
                            options: LottieOptions(
                              enableMergePaths: false, // Performance optimization
                            ),
                            fit: BoxFit.contain,
                            animate: false, // controlled manually
                            onLoaded: (composition) {
                              if (_isVisible) _controller.repeat();
                            },
                          ),
                        ),
                      ),

                      // Bottom Text Content
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
