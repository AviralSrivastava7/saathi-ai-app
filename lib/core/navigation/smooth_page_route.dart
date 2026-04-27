// COMPLETE: lib/core/navigation/smooth_page_route.dart
import 'package:flutter/material.dart';

/// Professional slide-from-right page transition.
/// Mimics iOS/Instagram: new screen slides in from right, old slides left.
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SmoothPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.85,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            );
          },
        );
}

// Extension for easy navigation
extension SmoothNavigation on BuildContext {
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.push<T>(
      this,
      SmoothPageRoute<T>(page: page),
    );
  }

  Future<T?> pushFade<T>(Widget page) {
    return Navigator.push<T>(
      this,
      FadePageRoute<T>(page: page),
    );
  }

  Future<T?> pushScale<T>(Widget page) {
    return Navigator.push<T>(
      this,
      ScalePageRoute<T>(page: page),
    );
  }
}
