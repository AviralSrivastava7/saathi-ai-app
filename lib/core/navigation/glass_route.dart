import 'dart:ui';
import 'package:flutter/material.dart';

class GlassRoute extends PageRouteBuilder {
  final Widget page;

  GlassRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, _, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );

            return Stack(
              children: [
                // 🔥 Glass blur background
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 18 * animation.value,
                    sigmaY: 18 * animation.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.05 * animation.value,
                    ),
                  ),
                ),

                // 🔥 iOS-style slide
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}
