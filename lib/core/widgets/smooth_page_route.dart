import 'package:flutter/material.dart';

/// Professional slide-from-right page transition.
/// Mimics iOS/Instagram: new screen slides in from right, old slides left.
/// Fast, snappy, buttery smooth.
Route<T> smoothPageRoute<T>({required Widget page}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // New screen slides in from right
      final slideIn = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation);

      // Subtle fade for polish
      final fadeIn = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(curvedAnimation);

      return SlideTransition(
        position: slideIn,
        child: FadeTransition(
          opacity: fadeIn,
          child: child,
        ),
      );
    },
  );
}
