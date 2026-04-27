import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import 'zen_aura_background.dart';
import 'glass_card.dart';

/// 🔒 BIOMETRIC GATE — Reusable Auth Wrapper
/// Wraps any screen that needs biometric protection.
/// If user has enabled biometric lock, shows a lock screen first.
/// On successful auth, reveals the child screen.
/// Matches Zen aesthetic with ZenAuraBackground + GlassCard.
class BiometricGate extends StatefulWidget {
  final Widget child;
  final String sectionName;

  const BiometricGate({
    super.key,
    required this.child,
    this.sectionName = 'this section',
  });

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticated = false;
  bool _isChecking = true;
  bool _authFailed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkAndAuthenticate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAndAuthenticate() async {
    final shouldAuth = await BiometricService.shouldAuthenticate();

    if (!shouldAuth) {
      // Biometric lock not enabled or device doesn't support it
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
      return;
    }

    // Try to authenticate
    await _performAuth();
  }

  Future<void> _performAuth() async {
    if (mounted) setState(() => _isChecking = false);

    final success = await BiometricService.authenticate(
      reason: '${widget.sectionName} access karne ke liye verify karein 🔐',
    );

    if (mounted) {
      setState(() {
        _isAuthenticated = success;
        _authFailed = !success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If already authenticated, show the child directly
    if (_isAuthenticated) {
      return widget.child;
    }

    // Still checking or showing lock screen
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ZenAuraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock Icon with pulse animation
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(32),
                      borderRadius: 100,
                      child: Icon(
                        _authFailed
                            ? Icons.lock_outline_rounded
                            : (_isChecking
                                ? Icons.fingerprint_rounded
                                : Icons.fingerprint_rounded),
                        size: 64,
                        color: _authFailed
                            ? Colors.red.withOpacity(0.7)
                            : colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isChecking ? 'Verifying...' : '🔒 Protected Section',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _authFailed
                        ? 'Authentication nahi ho payi.\nDubara try karo ya back jao.'
                        : '${widget.sectionName} access karne ke liye\napni identity verify karein.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Privacy badge
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43E97B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF43E97B).withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded,
                            color: Color(0xFF43E97B), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Data sirf aapke phone par hai',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF43E97B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action buttons
                  if (!_isChecking) ...[
                    // Retry / Unlock button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _performAuth,
                        icon: const Icon(Icons.fingerprint_rounded,
                            color: Colors.white, size: 22),
                        label: Text(
                          _authFailed ? 'Dubara Try Karein' : 'Unlock Karein',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Go Back button
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: colorScheme.onSurface.withOpacity(0.5)),
                      label: Text(
                        'Wapas Jao',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Loading indicator
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary.withOpacity(0.6)),
                      strokeWidth: 2.5,
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
