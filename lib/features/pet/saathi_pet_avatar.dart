import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class SaathiPetAvatar extends StatefulWidget {
  final double hunger;
  final double happiness;
  final double energy;
  final bool isEating;
  final bool isPlaying;
  final bool isSleeping;

  const SaathiPetAvatar({
    super.key,
    required this.hunger,
    required this.happiness,
    required this.energy,
    required this.isEating,
    required this.isPlaying,
    required this.isSleeping,
  });

  @override
  State<SaathiPetAvatar> createState() => _SaathiPetAvatarState();
}

class _SaathiPetAvatarState extends State<SaathiPetAvatar> with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _blinkController;
  late AnimationController _actionController;
  
  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    
    _breatheController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _actionController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scheduleNextBlink();
  }

  @override
  void didUpdateWidget(SaathiPetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isEating && !oldWidget.isEating) || (widget.isPlaying && !oldWidget.isPlaying)) {
      _actionController.forward(from: 0.0).then((_) {
        if (mounted && widget.isEating) _actionController.reverse();
      });
    }
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2000 + (DateTime.now().millisecond % 3000));
    _blinkTimer = Timer(delay, () async {
      if (!mounted) return;
      if (!widget.isSleeping) {
        setState(() => _isBlinking = true);
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) setState(() => _isBlinking = false);
      }
      _scheduleNextBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breatheController.dispose();
    _blinkController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Color get _bodyColor {
    if (widget.energy < 20) return const Color(0xFF6366F1);
    if (widget.hunger < 30 || widget.happiness < 30) return const Color(0xFFFCA5A5);
    return const Color(0xFFFCD34D); 
  }

  Color get _eyeColor {
    if (widget.energy < 20) return const Color(0xFF818CF8);
    if (widget.hunger < 30 || widget.happiness < 30) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheController, _actionController]),
      builder: (context, child) {
        final scale = 0.95 + (_breatheController.value * 0.05) + (widget.isPlaying ? math.sin(_actionController.value * 3.14) * 0.1 : 0.0);
        final verticalOffset = math.sin(_breatheController.value * 3.14) * 10;
        
        return Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _bodyColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                ),
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: 150,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: _bodyColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 110,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 20,
                              top: widget.isSleeping ? 35 : (_isBlinking ? 35 : 20),
                              child: _buildEye(),
                            ),
                            Positioned(
                              right: 20,
                              top: widget.isSleeping ? 35 : (_isBlinking ? 35 : 20),
                              child: _buildEye(),
                            ),
                            Positioned(
                              bottom: 15,
                              child: _buildMouth(),
                            ),
                          ],
                        ),
                      ),
                      
                      if (widget.happiness > 50 && widget.energy > 30)
                        ...[
                          Positioned(left: 10, top: 70, child: _buildBlush()),
                          Positioned(right: 10, top: 70, child: _buildBlush()),
                        ]
                    ],
                  ),
                ),
                
                if (widget.isEating)
                  Positioned(
                    top: -20 - (_actionController.value * 20),
                    child: Opacity(
                      opacity: 1.0 - _actionController.value,
                      child: const Text('🥕', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  
                if (widget.isPlaying)
                  Positioned(
                    top: -30 - (_actionController.value * 40),
                    child: Opacity(
                      opacity: 1.0 - _actionController.value,
                      child: const Text('💖', style: TextStyle(fontSize: 40)),
                    ),
                  ),

                if (widget.isSleeping)
                  Positioned(
                    top: -30,
                    right: -10,
                    child: Text(AppLocalizations.of(context).t('zzz'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.withOpacity(0.7))),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEye() {
    if (widget.isSleeping || _isBlinking) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 18,
        height: 4,
        decoration: BoxDecoration(
          color: _eyeColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    
    double eyeHeight = 22;
    if (widget.happiness < 40) eyeHeight = 14; 

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 18,
      height: eyeHeight,
      decoration: BoxDecoration(
        color: widget.isEating ? Colors.white : _eyeColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: widget.isEating ? [const BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 2)] : [],
      ),
    );
  }

  Widget _buildMouth() {
    if (widget.isEating) {
      final mouthOpen = math.sin(_actionController.value * 3.14 * 4).abs(); 
      return AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: 12 + (mouthOpen * 8),
        height: 4 + (mouthOpen * 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }
    
    if (widget.happiness > 60) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 12,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
      );
    } else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 10,
        height: 2,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
      );
    }
  }

  Widget _buildBlush() {
    return Container(
      width: 16,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFF43F5E).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.2), blurRadius: 10, spreadRadius: 5)],
      ),
    );
  }
}
