import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Voice states for dog expression changes
enum DogVoiceState { idle, listening, thinking, speaking }

/// 🐕 SAATHI DOG AVATAR — Cute Animated Pet Dog
/// Drawn entirely with CustomPaint — no external assets.
/// Reacts to voice states: ears perk up, mouth talks, tail wags.
class SaathiDogAvatar extends StatefulWidget {
  final double size;
  final DogVoiceState voiceState;
  final double happiness;
  final double energy;
  final double hunger;
  final bool isEating;
  final bool isPlaying;
  final bool isSleeping;
  final Color? glowColor;
  final List<String> activeAccessories;
  final double bondLevel;

  const SaathiDogAvatar({
    super.key,
    this.size = 160,
    this.voiceState = DogVoiceState.idle,
    this.happiness = 80,
    this.energy = 80,
    this.hunger = 80,
    this.isEating = false,
    this.isPlaying = false,
    this.isSleeping = false,
    this.glowColor,
    this.activeAccessories = const [],
    this.bondLevel = 0,
  });

  @override
  State<SaathiDogAvatar> createState() => _SaathiDogAvatarState();
}

class _SaathiDogAvatarState extends State<SaathiDogAvatar>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _tailController;
  late AnimationController _blinkController;
  late AnimationController _mouthController;
  late AnimationController _earController;
  late AnimationController _bounceController;

  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _tailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _earController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _updateAnimationsForState();
    _scheduleNextBlink();
  }

  @override
  void didUpdateWidget(SaathiDogAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voiceState != widget.voiceState) {
      _updateAnimationsForState();
    }
    if ((widget.isEating && !oldWidget.isEating) ||
        (widget.isPlaying && !oldWidget.isPlaying)) {
      _bounceController.forward(from: 0).then((_) {
        if (mounted) _bounceController.reverse();
      });
    }
  }

  void _updateAnimationsForState() {
    switch (widget.voiceState) {
      case DogVoiceState.idle:
        _tailController.duration = const Duration(milliseconds: 600);
        _mouthController.stop();
        _mouthController.value = 0;
        _earController.animateTo(0, duration: const Duration(milliseconds: 400));
        break;
      case DogVoiceState.listening:
        _tailController.duration = const Duration(milliseconds: 500);
        _mouthController.stop();
        _mouthController.value = 0;
        _earController.animateTo(1.0, duration: const Duration(milliseconds: 300));
        break;
      case DogVoiceState.thinking:
        _tailController.duration = const Duration(milliseconds: 800);
        _mouthController.stop();
        _mouthController.value = 0;
        _earController.animateTo(0.5, duration: const Duration(milliseconds: 400));
        break;
      case DogVoiceState.speaking:
        _tailController.duration = const Duration(milliseconds: 300);
        if (!_mouthController.isAnimating) {
          _mouthController.repeat(reverse: true);
        }
        _earController.animateTo(0.3, duration: const Duration(milliseconds: 300));
        break;
    }
    if (!_tailController.isAnimating) {
      _tailController.repeat(reverse: true);
    }
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(
        milliseconds: 2500 + (DateTime.now().millisecond % 2500));
    _blinkTimer = Timer(delay, () async {
      if (!mounted) return;
      if (!widget.isSleeping) {
        setState(() => _isBlinking = true);
        await Future.delayed(const Duration(milliseconds: 130));
        if (mounted) setState(() => _isBlinking = false);
      }
      _scheduleNextBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breatheController.dispose();
    _tailController.dispose();
    _blinkController.dispose();
    _mouthController.dispose();
    _earController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color get _furColor {
    if (widget.energy < 20) return const Color(0xFFC4A882);
    if (widget.happiness > 70) return const Color(0xFFD4915A);
    if (widget.happiness < 30) return const Color(0xFFB8986B);
    return const Color(0xFFCB8A4E);
  }

  Color get _furDarkColor {
    if (widget.energy < 20) return const Color(0xFF9B7D5E);
    if (widget.happiness > 70) return const Color(0xFFB07840);
    return const Color(0xFFA87033);
  }

  Color get _noseTip => const Color(0xFF2D1B0E);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breatheController,
        _tailController,
        _mouthController,
        _earController,
        _bounceController,
      ]),
      builder: (context, _) {
        final breathe = _breatheController.value;
        final floatY = math.sin(breathe * math.pi) * 6;
        final tilt = widget.voiceState == DogVoiceState.listening
            ? math.sin(breathe * math.pi * 2) * 0.06
            : math.sin(breathe * math.pi * 2) * 0.02;

        final bounceScale = widget.isPlaying
            ? 1.0 + math.sin(_bounceController.value * math.pi) * 0.12
            : 1.0;

        return Transform.translate(
          offset: Offset(0, -floatY),
          child: Transform.scale(
            scale: bounceScale,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(tilt),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: _DogPainter(
                    furColor: _furColor,
                    furDarkColor: _furDarkColor,
                    noseColor: _noseTip,
                    tailWag: _tailController.value,
                    breathe: breathe,
                    mouthOpen: _mouthController.value,
                    earPerk: _earController.value,
                    isBlinking: _isBlinking || widget.isSleeping,
                    happiness: widget.happiness,
                    isEating: widget.isEating,
                    voiceState: widget.voiceState,
                    glowColor: widget.glowColor,
                    activeAccessories: widget.activeAccessories,
                    bondLevel: widget.bondLevel,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter that draws an adorable dog face
class _DogPainter extends CustomPainter {
  final Color furColor;
  final Color furDarkColor;
  final Color noseColor;
  final double tailWag;
  final double breathe;
  final double mouthOpen;
  final double earPerk;
  final bool isBlinking;
  final double happiness;
  final bool isEating;
  final DogVoiceState voiceState;
  final Color? glowColor;
  final List<String> activeAccessories;
  final double bondLevel;

  _DogPainter({
    required this.furColor,
    required this.furDarkColor,
    required this.noseColor,
    required this.tailWag,
    required this.breathe,
    required this.mouthOpen,
    required this.earPerk,
    required this.isBlinking,
    required this.happiness,
    required this.isEating,
    required this.voiceState,
    this.glowColor,
    this.activeAccessories = const [],
    this.bondLevel = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.35; // head radius

    // ── Ambient glow behind dog ──
    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor!.withOpacity(0.08 + breathe * 0.04)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.8);
      canvas.drawCircle(Offset(cx, cy), r * 1.3, glowPaint);
    }

    // ── Shadow on ground ──
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.06 + breathe * 0.02)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 1.15),
        width: r * 1.4,
        height: r * 0.3,
      ),
      shadowPaint,
    );

    // ── Tail (behind body) ──
    _drawTail(canvas, cx, cy, r);

    // ── Body (torso) ──
    _drawBody(canvas, cx, cy, r);

    // ── Paws ──
    _drawPaws(canvas, cx, cy, r);

    // ── Ears (behind head for floppy, over head for perked) ──
    _drawEars(canvas, cx, cy, r);

    // ── Head ──
    _drawHead(canvas, cx, cy, r);

    // ── Face features ──
    _drawFace(canvas, cx, cy, r);

    // ── Blush cheeks ──
    if (happiness > 50) {
      _drawBlush(canvas, cx, cy, r);
    }

    // ── Accessories ──
    _drawAccessories(canvas, cx, cy, r);

    // ── Eating animation overlay ──
    if (isEating) {
      _drawEatingEffect(canvas, cx, cy, r);
    }

    // ── Sleeping Zzz ──
    if (isBlinking && voiceState == DogVoiceState.idle) {
      // just closed eyes, handled in _drawFace
    }
  }

  void _drawTail(Canvas canvas, double cx, double cy, double r) {
    final tailAngle = -0.5 + tailWag * 1.0; // wag range
    final tailPaint = Paint()
      ..color = furColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round;

    final tailStart = Offset(cx + r * 0.65, cy + r * 0.3);

    final path = Path();
    path.moveTo(tailStart.dx, tailStart.dy);
    path.quadraticBezierTo(
      tailStart.dx + r * 0.5,
      tailStart.dy - r * 0.3 + math.sin(tailAngle) * r * 0.4,
      tailStart.dx + r * 0.7,
      tailStart.dy - r * 0.6 + math.sin(tailAngle) * r * 0.3,
    );

    canvas.drawPath(path, tailPaint);

    // Tail tip
    final tipPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final tipX = tailStart.dx + r * 0.7;
    final tipY = tailStart.dy - r * 0.6 + math.sin(tailAngle) * r * 0.3;
    canvas.drawCircle(Offset(tipX, tipY), r * 0.08, tipPaint);
  }

  void _drawBody(Canvas canvas, double cx, double cy, double r) {
    // Main body oval
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [
          furColor,
          furDarkColor,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, cy + r * 0.55),
        width: r * 1.8,
        height: r * 1.3,
      ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.55),
        width: r * 1.6,
        height: r * 1.1,
      ),
      bodyPaint,
    );

    // White belly patch
    final bellyPaint = Paint()
      ..color = const Color(0xFFFFF5E6).withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.65),
        width: r * 0.9,
        height: r * 0.7,
      ),
      bellyPaint,
    );
  }

  void _drawPaws(Canvas canvas, double cx, double cy, double r) {
    final pawColor = furDarkColor;
    final pawPaint = Paint()..color = pawColor;
    final padPaint = Paint()..color = const Color(0xFFFFE0C2);

    // Front left paw
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.45, cy + r * 1.0),
        width: r * 0.35,
        height: r * 0.22,
      ),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.45, cy + r * 1.02),
        width: r * 0.22,
        height: r * 0.12,
      ),
      padPaint,
    );

    // Front right paw
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.45, cy + r * 1.0),
        width: r * 0.35,
        height: r * 0.22,
      ),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.45, cy + r * 1.02),
        width: r * 0.22,
        height: r * 0.12,
      ),
      padPaint,
    );
  }

  void _drawEars(Canvas canvas, double cx, double cy, double r) {
    // Ear perk: 0 = floppy, 1 = perked up
    final flopAngle = (1.0 - earPerk) * 0.4;

    // Left ear
    _drawSingleEar(
      canvas, cx, cy, r,
      isLeft: true,
      flopAngle: flopAngle,
    );

    // Right ear
    _drawSingleEar(
      canvas, cx, cy, r,
      isLeft: false,
      flopAngle: flopAngle,
    );
  }

  void _drawSingleEar(Canvas canvas, double cx, double cy, double r,
      {required bool isLeft, required double flopAngle}) {
    final sign = isLeft ? -1.0 : 1.0;
    final earPaint = Paint()..color = furColor;
    final innerEarPaint = Paint()..color = const Color(0xFFFFB8B8).withOpacity(0.6);

    canvas.save();
    canvas.translate(cx + sign * r * 0.55, cy - r * 0.55);
    canvas.rotate(sign * flopAngle);

    // Outer ear
    final earPath = Path();
    earPath.moveTo(0, r * 0.1);
    earPath.quadraticBezierTo(
      sign * r * 0.35, -r * 0.5 - earPerk * r * 0.15,
      sign * r * 0.1, -r * 0.6 - earPerk * r * 0.1,
    );
    earPath.quadraticBezierTo(
      sign * -r * 0.1, -r * 0.35,
      0, r * 0.1,
    );
    canvas.drawPath(earPath, earPaint);

    // Inner ear (pink)
    canvas.scale(0.6);
    canvas.translate(sign * r * 0.05, -r * 0.05);
    canvas.drawPath(earPath, innerEarPaint);

    canvas.restore();
  }

  void _drawHead(Canvas canvas, double cx, double cy, double r) {
    // Main head circle
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        radius: 0.85,
        colors: [
          Color.lerp(furColor, Colors.white, 0.15)!,
          furColor,
          furDarkColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy - r * 0.1), radius: r),
      );

    canvas.drawCircle(Offset(cx, cy - r * 0.1), r, headPaint);

    // White muzzle area
    final muzzlePaint = Paint()
      ..color = const Color(0xFFFFF8F0).withOpacity(0.9);

    final muzzlePath = Path();
    muzzlePath.addOval(Rect.fromCenter(
      center: Offset(cx, cy + r * 0.15),
      width: r * 0.9,
      height: r * 0.65,
    ));
    canvas.drawPath(muzzlePath, muzzlePaint);

    // Forehead patch (darker fur)
    final patchPaint = Paint()
      ..color = furDarkColor.withOpacity(0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - r * 0.45),
        width: r * 0.5,
        height: r * 0.35,
      ),
      patchPaint,
    );

    // Shine / highlight
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.25, cy - r * 0.5),
        width: r * 0.35,
        height: r * 0.2,
      ),
      shinePaint,
    );
  }

  void _drawFace(Canvas canvas, double cx, double cy, double r) {
    // ── Eyes ──
    final eyeY = cy - r * 0.15;
    final eyeSpacing = r * 0.3;

    if (isBlinking) {
      // Closed eyes (sleep / blink)
      final closedPaint = Paint()
        ..color = const Color(0xFF3D2B1F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Left closed eye (arc)
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx - eyeSpacing, eyeY),
          width: r * 0.2,
          height: r * 0.1,
        ),
        0, math.pi, false, closedPaint,
      );
      // Right closed eye
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + eyeSpacing, eyeY),
          width: r * 0.2,
          height: r * 0.1,
        ),
        0, math.pi, false, closedPaint,
      );
    } else {
      // Open eyes
      _drawEye(canvas, cx - eyeSpacing, eyeY, r);
      _drawEye(canvas, cx + eyeSpacing, eyeY, r);
    }

    // ── Nose ──
    final noseY = cy + r * 0.12;
    final nosePaint = Paint()..color = noseColor;
    
    // Rounded triangle nose
    final nosePath = Path();
    nosePath.moveTo(cx, noseY + r * 0.08);
    nosePath.quadraticBezierTo(cx - r * 0.1, noseY - r * 0.02, cx, noseY - r * 0.05);
    nosePath.quadraticBezierTo(cx + r * 0.1, noseY - r * 0.02, cx, noseY + r * 0.08);
    canvas.drawPath(nosePath, nosePaint);

    // Nose highlight
    final noseShine = Paint()
      ..color = Colors.white.withOpacity(0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.02, noseY - r * 0.02),
        width: r * 0.04,
        height: r * 0.03,
      ),
      noseShine,
    );

    // ── Mouth ──
    final mouthY = noseY + r * 0.12;
    _drawMouth(canvas, cx, mouthY, r);
  }

  void _drawEye(Canvas canvas, double ex, double ey, double r) {
    final eyeSize = r * 0.14;

    // White of eye
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ex, ey),
        width: eyeSize * 2.2,
        height: eyeSize * 2.0,
      ),
      whitePaint,
    );

    // Iris
    final irisPaint = Paint()..color = const Color(0xFF4A3520);
    
    // Pupil follows state
    double lookX = 0;
    double lookY = 0;
    if (voiceState == DogVoiceState.thinking) {
      lookY = -eyeSize * 0.3; // look up when thinking
      lookX = math.sin(breathe * math.pi * 2) * eyeSize * 0.15;
    } else if (voiceState == DogVoiceState.listening) {
      lookY = -eyeSize * 0.1;
    }

    canvas.drawCircle(
      Offset(ex + lookX, ey + lookY),
      eyeSize * 0.85,
      irisPaint,
    );

    // Pupil
    final pupilPaint = Paint()..color = const Color(0xFF1A0E06);
    canvas.drawCircle(
      Offset(ex + lookX, ey + lookY),
      eyeSize * 0.5,
      pupilPaint,
    );

    // Eye sparkle
    final sparklePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(
      Offset(ex + lookX - eyeSize * 0.2, ey + lookY - eyeSize * 0.25),
      eyeSize * 0.22,
      sparklePaint,
    );
    canvas.drawCircle(
      Offset(ex + lookX + eyeSize * 0.15, ey + lookY + eyeSize * 0.1),
      eyeSize * 0.1,
      sparklePaint,
    );
  }

  void _drawMouth(Canvas canvas, double cx, double my, double r) {
    if (isEating) {
      // Eating — open/close mouth
      final openAmt = math.sin(breathe * math.pi * 6).abs();
      final mouthPaint = Paint()
        ..color = const Color(0xFFE85D5D)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, my),
          width: r * 0.15 + openAmt * r * 0.1,
          height: r * 0.05 + openAmt * r * 0.12,
        ),
        mouthPaint,
      );
      return;
    }

    if (mouthOpen > 0.05) {
      // Speaking — open mouth
      final openAmount = mouthOpen;

      // Mouth opening
      final mouthPaint = Paint()
        ..color = const Color(0xFFE85D5D).withOpacity(0.9);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, my + openAmount * r * 0.05),
          width: r * 0.2 + openAmount * r * 0.08,
          height: r * 0.04 + openAmount * r * 0.14,
        ),
        mouthPaint,
      );

      // Tongue when mouth is open enough
      if (openAmount > 0.4) {
        final tonguePaint = Paint()..color = const Color(0xFFFF8FA3);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, my + r * 0.1 + openAmount * r * 0.06),
            width: r * 0.1,
            height: r * 0.06 * openAmount,
          ),
          tonguePaint,
        );
      }
    } else {
      // Closed mouth — smile
      final smilePaint = Paint()
        ..color = const Color(0xFF3D2B1F).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      if (happiness > 60) {
        // Happy smile — W shape like a dog
        final smilePath = Path();
        smilePath.moveTo(cx - r * 0.15, my - r * 0.02);
        smilePath.quadraticBezierTo(cx - r * 0.06, my + r * 0.08, cx, my + r * 0.02);
        smilePath.quadraticBezierTo(cx + r * 0.06, my + r * 0.08, cx + r * 0.15, my - r * 0.02);
        canvas.drawPath(smilePath, smilePaint);

        // Tiny tongue sticking out when happy
        if (happiness > 75) {
          final tonguePaint = Paint()..color = const Color(0xFFFF8FA3);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + r * 0.05, my + r * 0.06),
              width: r * 0.06,
              height: r * 0.08,
            ),
            tonguePaint,
          );
        }
      } else {
        // Neutral mouth — simple line
        canvas.drawLine(
          Offset(cx - r * 0.08, my),
          Offset(cx + r * 0.08, my),
          smilePaint,
        );
      }
    }
  }

  void _drawBlush(Canvas canvas, double cx, double cy, double r) {
    final blushPaint = Paint()
      ..color = const Color(0xFFFF6B8A).withOpacity(0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12);

    // Left cheek
    canvas.drawCircle(
      Offset(cx - r * 0.45, cy + r * 0.12),
      r * 0.12,
      blushPaint,
    );
    // Right cheek
    canvas.drawCircle(
      Offset(cx + r * 0.45, cy + r * 0.12),
      r * 0.12,
      blushPaint,
    );
  }

  void _drawEatingEffect(Canvas canvas, double cx, double cy, double r) {
    // Food particle flying up
    final progress = breathe;
    final particlePaint = Paint()
      ..color = Colors.orange.withOpacity(1.0 - progress);

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2.1) + progress * math.pi;
      final px = cx + math.cos(angle) * r * 0.3 * progress;
      final py = cy - r * 0.3 - progress * r * 0.5 + i * r * 0.1;
      canvas.drawCircle(Offset(px, py), r * 0.04 * (1 - progress * 0.5), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DogPainter oldDelegate) {
    return oldDelegate.tailWag != tailWag ||
        oldDelegate.breathe != breathe ||
        oldDelegate.mouthOpen != mouthOpen ||
        oldDelegate.earPerk != earPerk ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.happiness != happiness ||
        oldDelegate.voiceState != voiceState ||
        oldDelegate.isEating != isEating ||
        oldDelegate.bondLevel != bondLevel;
  }

  // ═══════════ ACCESSORIES ═══════════

  void _drawAccessories(Canvas canvas, double cx, double cy, double r) {
    for (final acc in activeAccessories) {
      switch (acc) {
        case 'collar':
          _drawCollar(canvas, cx, cy, r);
          break;
        case 'hat':
          _drawHat(canvas, cx, cy, r);
          break;
        case 'specs':
          _drawSpecs(canvas, cx, cy, r);
          break;
        case 'bowtie':
          _drawBowtie(canvas, cx, cy, r);
          break;
      }
    }
  }

  void _drawCollar(Canvas canvas, double cx, double cy, double r) {
    // Red collar band around neck
    final collarPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;

    final collarY = cy + r * 0.38;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, collarY), width: r * 1.1, height: r * 0.25),
      0.15, math.pi - 0.3, false, collarPaint,
    );

    // Gold tag (circle)
    final tagPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(cx, collarY + r * 0.12), r * 0.06, tagPaint);
    // Tag shine
    canvas.drawCircle(
      Offset(cx - r * 0.015, collarY + r * 0.105),
      r * 0.02,
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  void _drawHat(Canvas canvas, double cx, double cy, double r) {
    final hatY = cy - r * 0.85;

    // Party hat cone
    final hatPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)],
      ).createShader(Rect.fromLTWH(cx - r * 0.25, hatY - r * 0.5, r * 0.5, r * 0.5));

    final hatPath = Path();
    hatPath.moveTo(cx, hatY - r * 0.45);
    hatPath.lineTo(cx - r * 0.25, hatY + r * 0.05);
    hatPath.lineTo(cx + r * 0.25, hatY + r * 0.05);
    hatPath.close();
    canvas.drawPath(hatPath, hatPaint);

    // Hat brim
    final brimPaint = Paint()
      ..color = const Color(0xFFCE93D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04;
    canvas.drawLine(
      Offset(cx - r * 0.3, hatY + r * 0.05),
      Offset(cx + r * 0.3, hatY + r * 0.05),
      brimPaint,
    );

    // Pompom on top
    canvas.drawCircle(
      Offset(cx, hatY - r * 0.47),
      r * 0.05,
      Paint()..color = const Color(0xFFFFEB3B),
    );

    // Stripes on hat
    final stripePaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.4)
      ..strokeWidth = r * 0.02;
    canvas.drawLine(
      Offset(cx - r * 0.08, hatY - r * 0.15),
      Offset(cx + r * 0.15, hatY - r * 0.15),
      stripePaint,
    );
    canvas.drawLine(
      Offset(cx - r * 0.15, hatY - r * 0.0),
      Offset(cx + r * 0.2, hatY - r * 0.0),
      stripePaint,
    );
  }

  void _drawSpecs(Canvas canvas, double cx, double cy, double r) {
    final specY = cy - r * 0.15;
    final specPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035;

    // Left lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.3, specY),
        width: r * 0.32,
        height: r * 0.28,
      ),
      specPaint,
    );

    // Right lens
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.3, specY),
        width: r * 0.32,
        height: r * 0.28,
      ),
      specPaint,
    );

    // Bridge
    canvas.drawLine(
      Offset(cx - r * 0.14, specY - r * 0.02),
      Offset(cx + r * 0.14, specY - r * 0.02),
      specPaint..strokeWidth = r * 0.025,
    );

    // Lens reflection
    final reflPaint = Paint()
      ..color = Colors.white.withOpacity(0.15);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.33, specY - r * 0.04),
        width: r * 0.1,
        height: r * 0.06,
      ),
      reflPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + r * 0.27, specY - r * 0.04),
        width: r * 0.1,
        height: r * 0.06,
      ),
      reflPaint,
    );
  }

  void _drawBowtie(Canvas canvas, double cx, double cy, double r) {
    final btY = cy + r * 0.42;
    final btPaint = Paint()..color = const Color(0xFFE91E63);

    // Left triangle
    final leftPath = Path();
    leftPath.moveTo(cx, btY);
    leftPath.lineTo(cx - r * 0.2, btY - r * 0.08);
    leftPath.lineTo(cx - r * 0.2, btY + r * 0.08);
    leftPath.close();
    canvas.drawPath(leftPath, btPaint);

    // Right triangle
    final rightPath = Path();
    rightPath.moveTo(cx, btY);
    rightPath.lineTo(cx + r * 0.2, btY - r * 0.08);
    rightPath.lineTo(cx + r * 0.2, btY + r * 0.08);
    rightPath.close();
    canvas.drawPath(rightPath, btPaint);

    // Center knot
    canvas.drawCircle(Offset(cx, btY), r * 0.035, Paint()..color = const Color(0xFFC2185B));
  }
}
