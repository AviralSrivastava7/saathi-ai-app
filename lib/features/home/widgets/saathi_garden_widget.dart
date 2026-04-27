import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/storage/stats_storage.dart';
import '../../../core/storage/mood_storage.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/glass_card.dart';

/// ──────────────────────────────────────────────────────────────
/// SAATHI GARDEN – Progressive Growth based on total mood log count
///
/// Growth stages (based on total mood entries logged):
///   0     → Bare seed in soil (murjhaya / wilted look)
///   1-4   → Tiny sprout with 1-2 small leaves
///   5-9   → Small plant with stem & multiple leaves
///   10-14 → Sapling: thin trunk, small leafy canopy
///   15-19 → Young tree: medium trunk, decent canopy
///   20-24 → Mature tree: full trunk, branches, lush canopy
///   25-29 → Full tree with a few buds appearing
///   30+   → Full tree in bloom with flowers
///
/// The current mood (happy/sad/anxious etc.) affects
/// sky color, particle effects, and overall ambience,
/// but NOT the growth stage.
/// ──────────────────────────────────────────────────────────────

class SaathiGardenWidget extends StatefulWidget {
  const SaathiGardenWidget({super.key});

  @override
  State<SaathiGardenWidget> createState() => _SaathiGardenWidgetState();
}

class _SaathiGardenWidgetState extends State<SaathiGardenWidget>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _particleController;
  late AnimationController _bloomController;

  int _moodStreak = 0;
  bool _hasLoggedToday = false;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _loadMoodCount();
  }

  Future<void> _loadMoodCount() async {
    final streak = await MoodStorage.getMoodStreak();
    final todayMood = await MoodStorage.loadTodayMood();
    if (mounted) {
      setState(() {
        _moodStreak = streak;
        _hasLoggedToday = todayMood.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _swayController.dispose();
    _particleController.dispose();
    _bloomController.dispose();
    super.dispose();
  }

  /// Compute the "visual day" in the current lifecycle (0-100, then resets)
  int get _visualDay {
    if (!_hasLoggedToday || _moodStreak <= 0) return 0;
    // Cycle resets every 100 days, but visual progress restarts
    return ((_moodStreak - 1) % 100) + 1;
  }

  /// Is the tree in autumn/old phase?
  bool get _isAutumn => _visualDay > 60;

  /// Growth stage: 0-8 based on visual day in lifecycle
  int get _growthStage {
    if (!_hasLoggedToday) return 0;
    final day = _visualDay;
    if (day <= 0) return 0;
    if (day <= 8) return 1;   // sprout
    if (day <= 16) return 2;  // small plant
    if (day <= 25) return 3;  // sapling
    if (day <= 36) return 4;  // young tree
    if (day <= 48) return 5;  // mature tree
    if (day <= 55) return 6;  // budding
    if (day <= 60) return 7;  // full bloom
    return 8;                 // autumn/old tree
  }

  /// Smooth progress within current stage (0.0 - 1.0)
  double get _stageProgress {
    if (!_hasLoggedToday || _moodStreak <= 0) return 0.0;
    final day = _visualDay;
    if (day > 60) {
      // Autumn phase: progress within 61-100
      return ((day - 60) / 40.0).clamp(0.0, 1.0);
    }
    final thresholds = [0, 1, 9, 17, 26, 37, 49, 56, 61];
    final stage = _growthStage;
    if (stage >= 8) return 1.0;
    final low = thresholds[stage];
    final high = thresholds[stage + 1];
    return ((day - low) / (high - low)).clamp(0.0, 1.0);
  }

  /// How many full cycles completed
  int get _completedCycles => _moodStreak > 0 ? ((_moodStreak - 1) ~/ 100) : 0;

  /// Mood-based ambience (affects sky, particles, NOT growth)
  _GardenAmbience _getAmbience() {
    final mood = AppStats.selectedMood.toLowerCase();
    if (mood.contains('happy') || mood.contains('calm')) {
      return _GardenAmbience.sunny;
    } else if (mood.contains('sad')) {
      return _GardenAmbience.rainy;
    } else if (mood.contains('anxious') || mood.contains('angry')) {
      return _GardenAmbience.stormy;
    } else if (mood.contains('neutral')) {
      return _GardenAmbience.cloudy;
    }
    return _GardenAmbience.sunny;
  }

  @override
  Widget build(BuildContext context) {
    final ambience = _getAmbience();
    final stage = _growthStage;
    final loc = AppLocalizations.of(context);

    // Stage display info
    String stageName;
    String stageEmoji;
    double overallProgress;

    switch (stage) {
      case 0:
        stageName = 'Seed';
        stageEmoji = '🌰';
        overallProgress = 0.0;
        break;
      case 1:
        stageName = 'Sprout';
        stageEmoji = '🌱';
        overallProgress = _stageProgress * 0.13;
        break;
      case 2:
        stageName = 'Small Plant';
        stageEmoji = '🌿';
        overallProgress = 0.13 + _stageProgress * 0.12;
        break;
      case 3:
        stageName = 'Sapling';
        stageEmoji = '🪴';
        overallProgress = 0.25 + _stageProgress * 0.12;
        break;
      case 4:
        stageName = 'Young Tree';
        stageEmoji = '🌳';
        overallProgress = 0.37 + _stageProgress * 0.13;
        break;
      case 5:
        stageName = 'Mature Tree';
        stageEmoji = '🌲';
        overallProgress = 0.50 + _stageProgress * 0.12;
        break;
      case 6:
        stageName = 'Budding';
        stageEmoji = '🌼';
        overallProgress = 0.62 + _stageProgress * 0.10;
        break;
      case 7:
        stageName = 'In Full Bloom';
        stageEmoji = '🌸';
        overallProgress = 0.72 + _stageProgress * 0.08;
        break;
      default:
        // Stage 8: Autumn / Old tree
        stageName = '🍂 Autumn (Cycle ${_completedCycles + 1})';
        stageEmoji = '🍁';
        overallProgress = 0.80 + _stageProgress * 0.20;
        break;
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 32,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getSkyColors(ambience),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sky elements
            _buildSkyElements(ambience),

            // Particles
            _buildParticles(ambience),

            // Ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _getGroundColors(stage),
                  ),
                ),
              ),
            ),

            // Grass blades (grow with stage)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _swayController,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(double.infinity, 30),
                    painter: _GrassPainter(
                      sway: _swayController.value,
                      stage: stage,
                    ),
                  );
                },
              ),
            ),

            // The plant/tree (main visual)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_swayController, _bloomController]),
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(180, 160),
                      painter: _PlantPainter(
                        sway: _swayController.value,
                        bloom: _bloomController.value,
                        stage: stage,
                        stageProgress: _stageProgress,
                        totalLogs: _moodStreak,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Info overlay (bottom)
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Stage emoji
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(stageEmoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          loc.t('your_garden_status'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$stageName • ${_hasLoggedToday ? _moodStreak : 0} day streak${_completedCycles > 0 ? ' • Cycle ${_completedCycles + 1}' : ''}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: overallProgress.clamp(0.0, 1.0),
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${(overallProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mood & stage label (top right)
            Positioned(
              top: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  '$stageEmoji $stageName',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────── Sky ────────────

  List<Color> _getSkyColors(_GardenAmbience ambience) {
    switch (ambience) {
      case _GardenAmbience.sunny:
        return [
          const Color(0xFF87CEEB),
          const Color(0xFFE0F7FA),
          const Color(0xFFC8E6C9),
        ];
      case _GardenAmbience.cloudy:
        return [
          const Color(0xFF90CAF9),
          const Color(0xFFB3E5FC),
          const Color(0xFFA5D6A7),
        ];
      case _GardenAmbience.rainy:
        return [
          const Color(0xFF546E7A),
          const Color(0xFF78909C),
          const Color(0xFF90A4AE),
        ];
      case _GardenAmbience.stormy:
        return [
          const Color(0xFF5C6BC0),
          const Color(0xFF7986CB),
          const Color(0xFF9FA8DA),
        ];
    }
  }

  List<Color> _getGroundColors(int stage) {
    if (stage >= 8) {
      // Autumn: warm dry ground
      return [const Color(0xFFBF8040), const Color(0xFF8D6E63)];
    }
    if (stage <= 1) {
      // Dry soil for seed / sprout
      return [const Color(0xFF8D6E63), const Color(0xFF5D4037)];
    } else if (stage <= 3) {
      // Slightly green soil
      return [const Color(0xFF6D4C41), const Color(0xFF4E342E)];
    } else {
      // Rich green ground
      return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    }
  }

  Widget _buildSkyElements(_GardenAmbience ambience) {
    return AnimatedBuilder(
      animation: _bloomController,
      builder: (context, _) {
        final glowSize = 30 + _bloomController.value * 8;
        final isBright = ambience == _GardenAmbience.sunny || ambience == _GardenAmbience.cloudy;
        return Stack(
          children: [
            Positioned(
              top: 14,
              left: 20,
              child: Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBright
                      ? const Color(0xFFFFD54F)
                      : const Color(0xFFCFD8DC),
                  boxShadow: [
                    BoxShadow(
                      color: (isBright
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF90A4AE))
                          .withOpacity(0.4),
                      blurRadius: 20 + _bloomController.value * 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            if (ambience != _GardenAmbience.sunny)
              Positioned(
                top: 20 + _swayController.value * 5,
                right: 30,
                child: _buildCloud(40, 0.3),
              ),
            Positioned(
              top: 10 + _swayController.value * 3,
              right: 80,
              child: _buildCloud(30, 0.2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloud(double width, double opacity) {
    return Container(
      width: width,
      height: width * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width),
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildParticles(_GardenAmbience ambience) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 240),
          painter: _ParticlePainter(
            progress: _particleController.value,
            ambience: ambience,
            stage: _growthStage,
          ),
        );
      },
    );
  }
}

// ──────────── Enums ────────────

enum _GardenAmbience { sunny, cloudy, rainy, stormy }

// ══════════════════════════════════════════════════════════════
// PLANT PAINTER – Draws progressively based on growth stage
// ══════════════════════════════════════════════════════════════

class _PlantPainter extends CustomPainter {
  final double sway;
  final double bloom;
  final int stage;
  final double stageProgress;
  final int totalLogs;

  _PlantPainter({
    required this.sway,
    required this.bloom,
    required this.stage,
    required this.stageProgress,
    required this.totalLogs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height;
    final swayOffset = sin(sway * pi * 2) * 2;

    switch (stage) {
      case 0:
        _drawSeed(canvas, cx, baseY, swayOffset);
        break;
      case 1:
        _drawSprout(canvas, cx, baseY, swayOffset);
        break;
      case 2:
        _drawSmallPlant(canvas, cx, baseY, swayOffset);
        break;
      case 3:
        _drawSapling(canvas, cx, baseY, swayOffset);
        break;
      case 4:
        _drawYoungTree(canvas, cx, baseY, swayOffset);
        break;
      case 5:
        _drawMatureTree(canvas, cx, baseY, swayOffset);
        break;
      case 6:
        _drawMatureTree(canvas, cx, baseY, swayOffset);
        _drawBuds(canvas, cx, baseY, swayOffset);
        break;
      case 7:
        _drawMatureTree(canvas, cx, baseY, swayOffset);
        _drawFlowers(canvas, cx, baseY, swayOffset);
        break;
      case 8:
        // Autumn / Old tree — warm colors + falling leaves
        _drawAutumnTree(canvas, cx, baseY, swayOffset);
        break;
      default:
        _drawMatureTree(canvas, cx, baseY, swayOffset);
        _drawFlowers(canvas, cx, baseY, swayOffset);
        break;
    }
  }

  // ─── Stage 0: Seed ───
  void _drawSeed(Canvas canvas, double cx, double baseY, double sway) {
    // Small mound of soil
    final moundPaint = Paint()..color = const Color(0xFF6D4C41);
    final moundPath = Path();
    moundPath.moveTo(cx - 25, baseY);
    moundPath.quadraticBezierTo(cx, baseY - 12, cx + 25, baseY);
    moundPath.close();
    canvas.drawPath(moundPath, moundPaint);

    // Seed (oval)
    final seedPaint = Paint()
      ..color = const Color(0xFF8D6E63);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, baseY - 8), width: 10, height: 7),
      seedPaint,
    );
    // Seed highlight
    final hlPaint = Paint()
      ..color = const Color(0xFFA1887F).withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 1, baseY - 9), width: 4, height: 3),
      hlPaint,
    );

    // Tiny crack line on seed (showing life about to start)
    final crackPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx, baseY - 11),
      Offset(cx + 2, baseY - 6),
      crackPaint,
    );
  }

  // ─── Stage 1: Tiny Sprout ───
  void _drawSprout(Canvas canvas, double cx, double baseY, double sway) {
    // Soil mound
    final moundPaint = Paint()..color = const Color(0xFF6D4C41);
    final moundPath = Path();
    moundPath.moveTo(cx - 20, baseY);
    moundPath.quadraticBezierTo(cx, baseY - 10, cx + 20, baseY);
    moundPath.close();
    canvas.drawPath(moundPath, moundPaint);

    // Stem (thin, slightly curved)
    final stemHeight = 20 + stageProgress * 15;
    final stemPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, baseY - 5);
    stemPath.quadraticBezierTo(
      cx + sway * 1.5, baseY - stemHeight * 0.5,
      cx + sway * 2, baseY - stemHeight,
    );
    canvas.drawPath(stemPath, stemPaint..style = PaintingStyle.stroke);

    // One or two small leaves
    final topX = cx + sway * 2;
    final topY = baseY - stemHeight;
    _drawSmallLeaf(canvas, topX, topY, sway, isRight: true, scale: 0.6 + stageProgress * 0.4);
    if (stageProgress > 0.5) {
      _drawSmallLeaf(canvas, topX, topY + 8, sway, isRight: false, scale: 0.4 + stageProgress * 0.3);
    }
  }

  // ─── Stage 2: Small Plant ───
  void _drawSmallPlant(Canvas canvas, double cx, double baseY, double sway) {
    final stemHeight = 40 + stageProgress * 20;

    // Thicker stem
    final stemPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(cx, baseY);
    stemPath.quadraticBezierTo(
      cx + sway * 1.2, baseY - stemHeight * 0.5,
      cx + sway * 1.5, baseY - stemHeight,
    );
    canvas.drawPath(stemPath, stemPaint);

    final topX = cx + sway * 1.5;
    final topY = baseY - stemHeight;

    // Multiple leaves along the stem
    _drawSmallLeaf(canvas, topX, topY, sway, isRight: true, scale: 1.0);
    _drawSmallLeaf(canvas, topX, topY + 5, sway, isRight: false, scale: 0.9);
    _drawSmallLeaf(canvas, cx + sway * 0.8, topY + 18, sway, isRight: true, scale: 0.7);
    _drawSmallLeaf(canvas, cx + sway * 0.9, topY + 16, sway, isRight: false, scale: 0.8);
    if (stageProgress > 0.3) {
      _drawSmallLeaf(canvas, cx + sway * 0.5, topY + 28, sway, isRight: true, scale: 0.6);
    }
    if (stageProgress > 0.6) {
      _drawSmallLeaf(canvas, cx + sway * 0.6, topY + 26, sway, isRight: false, scale: 0.5);
    }
  }

  // ─── Stage 3: Sapling ───
  void _drawSapling(Canvas canvas, double cx, double baseY, double sway) {
    final trunkHeight = 55 + stageProgress * 15;

    // Thin woody trunk
    _drawWoodyTrunk(canvas, cx, baseY, trunkHeight, sway, width: 5 + stageProgress * 2);

    final topY = baseY - trunkHeight * 0.7;
    final topX = cx + sway;

    // Small canopy (a few circles)
    const canopyColor1 = Color(0xFF81C784);
    const canopyColor2 = Color(0xFF66BB6A);
    const canopyColor3 = Color(0xFF4CAF50);

    final canopyRadius = 16 + stageProgress * 8;
    canvas.drawCircle(Offset(topX, topY - 8), canopyRadius, Paint()..color = canopyColor3);
    canvas.drawCircle(Offset(topX - 10, topY), canopyRadius * 0.7, Paint()..color = canopyColor2);
    canvas.drawCircle(Offset(topX + 10, topY), canopyRadius * 0.7, Paint()..color = canopyColor2);
    canvas.drawCircle(Offset(topX, topY - 14), canopyRadius * 0.6, Paint()..color = canopyColor1);

    // Shine
    _drawCanopyShine(canvas, topX, topY - 8, canopyRadius);
  }

  // ─── Stage 4: Young Tree ───
  void _drawYoungTree(Canvas canvas, double cx, double baseY, double sway) {
    final trunkHeight = 75 + stageProgress * 15;

    _drawWoodyTrunk(canvas, cx, baseY, trunkHeight, sway, width: 8 + stageProgress * 2);

    final topY = baseY - trunkHeight * 0.6;
    final topX = cx + sway * 0.8;

    // One branch on each side
    final branchPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(topX, topY + 15),
      Offset(topX - 22 + sway, topY + 5),
      branchPaint,
    );
    canvas.drawLine(
      Offset(topX, topY + 12),
      Offset(topX + 24 + sway * 0.5, topY + 2),
      branchPaint,
    );

    // Canopy
    final canopyRadius = 24 + stageProgress * 6;
    _drawLayeredCanopy(canvas, topX, topY - 5, canopyRadius, sway);
  }

  // ─── Stage 5, 6, 7: Mature Tree ───
  void _drawMatureTree(Canvas canvas, double cx, double baseY, double sway) {
    const trunkHeight = 95.0;

    _drawWoodyTrunk(canvas, cx, baseY, trunkHeight, sway, width: 12);

    final topY = baseY - trunkHeight * 0.55;
    final topX = cx + sway * 0.7;

    // Branches
    final branchPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(topX, topY + 15),
      Offset(topX - 28 + sway * 1.2, topY - 2),
      branchPaint,
    );
    canvas.drawLine(
      Offset(topX, topY + 10),
      Offset(topX + 30 + sway * 0.8, topY - 5),
      branchPaint,
    );
    canvas.drawLine(
      Offset(topX, topY + 22),
      Offset(topX - 18 + sway, topY + 8),
      branchPaint..strokeWidth = 2,
    );

    // Lush canopy
    _drawLayeredCanopy(canvas, topX, topY - 10, 36, sway);
  }

  // ─── Stage 6 extra: Buds ───
  void _drawBuds(Canvas canvas, double cx, double baseY, double sway) {
    final topY = baseY - 95 * 0.55;
    final topX = cx + sway * 0.7;

    final budPositions = [
      Offset(topX - 18 + sway, topY - 18),
      Offset(topX + 14 + sway * 0.6, topY - 14),
      Offset(topX - 5 + sway * 0.8, topY - 26),
      Offset(topX + 20 + sway * 0.4, topY - 4),
    ];

    // Only show buds proportional to stageProgress
    final budCount = (budPositions.length * stageProgress).ceil().clamp(1, budPositions.length);

    for (int i = 0; i < budCount; i++) {
      final pos = budPositions[i];
      final budSize = 3.0 + bloom * 1.5;

      // Small round bud
      canvas.drawCircle(
        pos,
        budSize,
        Paint()..color = const Color(0xFFFFCDD2).withOpacity(0.8 + bloom * 0.2),
      );
      // Tiny center
      canvas.drawCircle(
        pos,
        budSize * 0.4,
        Paint()..color = const Color(0xFFF48FB1),
      );
    }
  }

  // ─── Stage 7: Full Flowers ───
  void _drawFlowers(Canvas canvas, double cx, double baseY, double sway) {
    final topY = baseY - 95 * 0.55;
    final topX = cx + sway * 0.7;

    final flowerPositions = [
      Offset(topX - 20 + sway, topY - 22),
      Offset(topX + 15 + sway * 0.7, topY - 16),
      Offset(topX - 8 + sway * 0.9, topY - 30),
      Offset(topX + 22 + sway * 0.5, topY - 6),
      Offset(topX - 25 + sway * 1.1, topY - 4),
      Offset(topX + 5 + sway * 0.8, topY - 35),
      Offset(topX - 14 + sway * 0.7, topY - 10),
      Offset(topX + 10 + sway * 0.4, topY - 28),
    ];

    // Gradually add more flowers as total logs grow beyond 30
    final flowerFraction = (totalLogs >= 30)
        ? ((totalLogs - 30) / 10.0).clamp(0.3, 1.0)
        : 0.3;
    final flowerCount = (flowerPositions.length * flowerFraction).ceil().clamp(2, flowerPositions.length);

    final colors = [
      const Color(0xFFFF80AB),
      const Color(0xFFFFAB91),
      const Color(0xFFCE93D8),
      const Color(0xFFF48FB1),
      const Color(0xFFFFCC80),
      const Color(0xFFEF9A9A),
      const Color(0xFFB39DDB),
      const Color(0xFFFFCDD2),
    ];

    for (int i = 0; i < flowerCount; i++) {
      final pos = flowerPositions[i];
      final petalSize = 3.5 + bloom * 2 + (i % 3);

      // Petals
      for (int j = 0; j < 5; j++) {
        final angle = (j * pi * 2 / 5) + sway * 0.3;
        final px = pos.dx + cos(angle) * petalSize;
        final py = pos.dy + sin(angle) * petalSize;
        canvas.drawCircle(
          Offset(px, py),
          petalSize * 0.55,
          Paint()..color = colors[i % colors.length].withOpacity(0.85),
        );
      }
      // Center
      canvas.drawCircle(
        pos,
        petalSize * 0.3,
        Paint()..color = const Color(0xFFFFD54F),
      );
    }
  }

  // ─── Helper: Small leaf ───
  void _drawSmallLeaf(Canvas canvas, double x, double y, double sway, {required bool isRight, double scale = 1.0}) {
    final leafPaint = Paint()..color = const Color(0xFF66BB6A);
    final darkLeafPaint = Paint()..color = const Color(0xFF43A047);

    final dir = isRight ? 1.0 : -1.0;
    final leafPath = Path();
    leafPath.moveTo(x, y);
    leafPath.quadraticBezierTo(
      x + dir * 12 * scale + sway * 0.5,
      y - 6 * scale,
      x + dir * 18 * scale + sway,
      y + 2 * scale,
    );
    leafPath.quadraticBezierTo(
      x + dir * 12 * scale + sway * 0.5,
      y + 5 * scale,
      x,
      y,
    );
    canvas.drawPath(leafPath, leafPaint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = const Color(0xFF388E3C).withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(x, y),
      Offset(x + dir * 14 * scale + sway * 0.7, y + 1 * scale),
      veinPaint,
    );
  }

  // ─── Helper: Woody trunk ───
  void _drawWoodyTrunk(Canvas canvas, double cx, double baseY, double height, double sway, {double width = 10}) {
    final topY = baseY - height * 0.55;

    final trunkPath = Path();
    trunkPath.moveTo(cx - width / 2, baseY);
    trunkPath.quadraticBezierTo(
      cx - width / 2 + sway * 0.5, baseY - height * 0.3,
      cx - width * 0.2 + sway, topY,
    );
    trunkPath.lineTo(cx + width * 0.2 + sway, topY);
    trunkPath.quadraticBezierTo(
      cx + width / 2 + sway * 0.5, baseY - height * 0.3,
      cx + width / 2, baseY,
    );
    trunkPath.close();

    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.brown.shade700, Colors.brown.shade500, Colors.brown.shade800],
      ).createShader(Rect.fromLTWH(cx - width, topY, width * 2, baseY - topY));
    canvas.drawPath(trunkPath, trunkPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.brown.shade200.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - 2 + sway * 0.3, topY + 10),
      Offset(cx - 1, baseY - 5),
      highlightPaint,
    );
  }

  // ─── Helper: Layered canopy ───
  void _drawLayeredCanopy(Canvas canvas, double cx, double topY, double radius, double sway) {
    final colors = [
      const Color(0xFF66BB6A),
      const Color(0xFF43A047),
      const Color(0xFF2E7D32),
    ];

    // Background layer
    canvas.drawCircle(Offset(cx + sway * 0.6, topY), radius, Paint()..color = colors[2]);
    canvas.drawCircle(Offset(cx - radius * 0.45 + sway * 0.8, topY + 8), radius * 0.75, Paint()..color = colors[2]);
    canvas.drawCircle(Offset(cx + radius * 0.5 + sway * 0.5, topY + 10), radius * 0.7, Paint()..color = colors[2]);

    // Middle layer
    canvas.drawCircle(Offset(cx + sway * 0.7, topY - 5), radius * 0.85, Paint()..color = colors[1]);
    canvas.drawCircle(Offset(cx - radius * 0.35 + sway * 0.9, topY + 3), radius * 0.65, Paint()..color = colors[1]);
    canvas.drawCircle(Offset(cx + radius * 0.4 + sway * 0.5, topY + 5), radius * 0.6, Paint()..color = colors[1]);

    // Top highlight layer
    canvas.drawCircle(Offset(cx + sway * 0.8, topY - 10), radius * 0.7, Paint()..color = colors[0]);
    canvas.drawCircle(Offset(cx - radius * 0.25 + sway, topY - 3), radius * 0.5, Paint()..color = colors[0]);

    // Shine
    _drawCanopyShine(canvas, cx + sway * 0.7, topY - 5, radius * 0.85);
  }

  void _drawCanopyShine(Canvas canvas, double cx, double cy, double radius) {
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      );
    canvas.drawCircle(Offset(cx, cy), radius, shinePaint);
  }

  // ─── Stage 8: Autumn / Old Tree ───
  void _drawAutumnTree(Canvas canvas, double cx, double baseY, double sway) {
    const trunkHeight = 95.0;

    _drawWoodyTrunk(canvas, cx, baseY, trunkHeight, sway, width: 12);

    final topY = baseY - trunkHeight * 0.55;
    final topX = cx + sway * 0.7;

    // Branches (more visible as leaves thin)
    final branchPaint = Paint()
      ..color = Colors.brown.shade700
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(topX, topY + 15),
      Offset(topX - 28 + sway * 1.2, topY - 2),
      branchPaint,
    );
    canvas.drawLine(
      Offset(topX, topY + 10),
      Offset(topX + 30 + sway * 0.8, topY - 5),
      branchPaint,
    );
    canvas.drawLine(
      Offset(topX, topY + 22),
      Offset(topX - 18 + sway, topY + 8),
      branchPaint..strokeWidth = 2,
    );

    // Autumn-colored canopy (orange, red, gold — thinner as progress increases)
    final autumnProgress = stageProgress; // 0=just entered autumn, 1=almost reset
    final canopyOpacity = (1.0 - autumnProgress * 0.6).clamp(0.3, 1.0);
    final radius = 36.0 - autumnProgress * 10; // canopy shrinks as tree ages

    final autumnColors = [
      const Color(0xFFFF8F00), // amber
      const Color(0xFFE65100), // deep orange
      const Color(0xFFBF360C), // brown-red
    ];

    // Background canopy layer
    canvas.drawCircle(
      Offset(topX + sway * 0.6, topY - 10),
      radius,
      Paint()..color = autumnColors[2].withOpacity(canopyOpacity),
    );
    canvas.drawCircle(
      Offset(topX - radius * 0.45 + sway * 0.8, topY - 2),
      radius * 0.75,
      Paint()..color = autumnColors[2].withOpacity(canopyOpacity),
    );
    canvas.drawCircle(
      Offset(topX + radius * 0.5 + sway * 0.5, topY),
      radius * 0.7,
      Paint()..color = autumnColors[2].withOpacity(canopyOpacity),
    );

    // Middle layer
    canvas.drawCircle(
      Offset(topX + sway * 0.7, topY - 15),
      radius * 0.85,
      Paint()..color = autumnColors[1].withOpacity(canopyOpacity * 0.9),
    );
    canvas.drawCircle(
      Offset(topX - radius * 0.35 + sway * 0.9, topY - 7),
      radius * 0.65,
      Paint()..color = autumnColors[0].withOpacity(canopyOpacity * 0.9),
    );

    // Top highlight
    canvas.drawCircle(
      Offset(topX + sway * 0.8, topY - 20),
      radius * 0.6,
      Paint()..color = const Color(0xFFFFCA28).withOpacity(canopyOpacity * 0.7),
    );

    // Falling leaves (animated with sway & bloom)
    final leafColors = [
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFFFEB3B),
      const Color(0xFFE65100),
      const Color(0xFFBF360C),
    ];

    // More leaves fall as autumn progresses
    final leafCount = (3 + autumnProgress * 8).toInt();
    for (int i = 0; i < leafCount; i++) {
      final seed = i * 137.508; // golden angle for distribution
      final fallProgress = ((sway * 2 + i * 0.15 + bloom * 0.5) % 1.0);
      final leafX = topX + sin(seed) * 40 + sway * (i % 3 + 1);
      final leafY = topY - 10 + fallProgress * (baseY - topY + 20);
      final leafSize = 2.5 + (i % 3) * 1.0;
      final leafOpacity = (1.0 - fallProgress * 0.7).clamp(0.15, 0.8);
      final leafRotation = sway * pi + i * 1.2;

      canvas.save();
      canvas.translate(leafX, leafY);
      canvas.rotate(leafRotation);

      final leafPath = Path();
      leafPath.moveTo(0, -leafSize);
      leafPath.quadraticBezierTo(leafSize, 0, 0, leafSize);
      leafPath.quadraticBezierTo(-leafSize, 0, 0, -leafSize);
      canvas.drawPath(
        leafPath,
        Paint()..color = leafColors[i % leafColors.length].withOpacity(leafOpacity),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PlantPainter oldDelegate) =>
      oldDelegate.sway != sway ||
      oldDelegate.bloom != bloom ||
      oldDelegate.stage != stage ||
      oldDelegate.stageProgress != stageProgress ||
      oldDelegate.totalLogs != totalLogs;
}

// ══════════════════════════════════════════════════════════════
// GRASS PAINTER – Adapts to growth stage
// ══════════════════════════════════════════════════════════════

class _GrassPainter extends CustomPainter {
  final double sway;
  final int stage;

  _GrassPainter({required this.sway, required this.stage});

  @override
  void paint(Canvas canvas, Size size) {
    // Grass color adapts to stage
    Color grassColor;
    int bladeCount;
    if (stage >= 8) {
      // Autumn grass — dry/golden
      grassColor = const Color(0xFFBF8040);
      bladeCount = 20;
    } else if (stage <= 1) {
      grassColor = Colors.brown.shade400;
      bladeCount = 8;
    } else if (stage <= 3) {
      grassColor = Colors.green.shade700;
      bladeCount = 18;
    } else {
      grassColor = Colors.green.shade600;
      bladeCount = 30;
    }

    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rng = Random(42);
    for (int i = 0; i < bladeCount; i++) {
      final x = rng.nextDouble() * size.width;
      final h = 8 + rng.nextDouble() * 15;
      final swayAmount = sin(sway * pi * 2 + i * 0.5) * 3;
      paint.color = grassColor.withOpacity(0.3 + rng.nextDouble() * 0.4);
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + swayAmount, size.height - h),
        paint,
      );
    }

    // Small flowers in grass for higher stages
    if (stage >= 5) {
      final flowerPaint = Paint();
      for (int i = 0; i < (stage >= 7 ? 5 : 3); i++) {
        final fx = rng.nextDouble() * size.width;
        flowerPaint.color = [
          const Color(0xFFFFEB3B),
          const Color(0xFFFF80AB),
          const Color(0xFFCE93D8),
          const Color(0xFFFFAB91),
          const Color(0xFF80DEEA),
        ][i % 5].withOpacity(0.7);
        canvas.drawCircle(Offset(fx, size.height - 3), 2.5, flowerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrassPainter oldDelegate) =>
      oldDelegate.sway != sway || oldDelegate.stage != stage;
}

// ══════════════════════════════════════════════════════════════
// PARTICLE PAINTER – Mood-based ambience effects
// ══════════════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final double progress;
  final _GardenAmbience ambience;
  final int stage;

  _ParticlePainter({
    required this.progress,
    required this.ambience,
    required this.stage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);

    // Sparkles for sunny + high growth stage
    if (ambience == _GardenAmbience.sunny && stage >= 4) {
      _drawSparkles(canvas, size, rng);
    }
    // Rain for sad mood
    if (ambience == _GardenAmbience.rainy) {
      _drawRain(canvas, size, rng);
    }
    // Wind leaves for stormy
    if (ambience == _GardenAmbience.stormy) {
      _drawWindParticles(canvas, size, rng);
    }
    // Floating petals for high growth flowers
    if (stage >= 7) {
      _drawFloatingPetals(canvas, size, rng);
    }
    // Butterflies for mature stages
    if (stage >= 5 && ambience == _GardenAmbience.sunny) {
      _drawButterfly(canvas, size, rng);
    }
  }

  void _drawSparkles(Canvas canvas, Size size, Random rng) {
    final sparkPaint = Paint();
    for (int i = 0; i < 10; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height * 0.6;
      final y = baseY + sin(progress * pi * 2 + i) * 10;
      final r = 1.5 + sin(progress * pi * 2 + i * 0.7).abs() * 2;
      final opacity = (0.3 + sin(progress * pi * 2 + i * 1.3).abs() * 0.5).clamp(0.0, 1.0);
      sparkPaint.color = const Color(0xFFFFD54F).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, sparkPaint);
    }
  }

  void _drawRain(Canvas canvas, Size size, Random rng) {
    final rainPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = (rng.nextDouble() * size.height + progress * size.height * 2 + i * 15) % size.height;
      canvas.drawLine(
        Offset(x, startY),
        Offset(x - 2, startY + 8),
        rainPaint,
      );
    }
  }

  void _drawWindParticles(Canvas canvas, Size size, Random rng) {
    final leafPaint = Paint()..color = const Color(0xFFFF8A65).withOpacity(0.5);
    for (int i = 0; i < 6; i++) {
      final x = (rng.nextDouble() * size.width + progress * size.width * 0.5 + i * 30) % size.width;
      final y = rng.nextDouble() * size.height * 0.7 + sin(progress * pi * 2 + i) * 15;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 4),
        leafPaint,
      );
    }
  }

  void _drawFloatingPetals(Canvas canvas, Size size, Random rng) {
    for (int i = 0; i < 6; i++) {
      final x = (rng.nextDouble() * size.width + progress * size.width * 0.3 + i * 40) % size.width;
      final y = (rng.nextDouble() * size.height * 0.8 + progress * size.height * 0.5 + i * 20) % (size.height * 0.8);
      final opacity = (0.3 + sin(progress * pi * 2 + i * 0.9).abs() * 0.4).clamp(0.0, 0.7);
      final petalColor = [
        const Color(0xFFFF80AB),
        const Color(0xFFFFCDD2),
        const Color(0xFFF8BBD0),
        const Color(0xFFCE93D8),
        const Color(0xFFFFAB91),
        const Color(0xFFFFCC80),
      ][i % 6].withOpacity(opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * pi * 2 + i);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 5, height: 3),
        Paint()..color = petalColor,
      );
      canvas.restore();
    }
  }

  void _drawButterfly(Canvas canvas, Size size, Random rng) {
    final bx = size.width * 0.3 + sin(progress * pi * 2) * 30;
    final by = size.height * 0.25 + cos(progress * pi * 2 * 0.7) * 15;
    final wingFlap = sin(progress * pi * 8).abs(); // rapid flutter

    final wingPaint = Paint()..color = const Color(0xFFFFAB40).withOpacity(0.6);
    final bodyPaint = Paint()..color = const Color(0xFF5D4037);

    // Wings
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx - 4, by), width: 6, height: 4 * wingFlap + 2),
      wingPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx + 4, by), width: 6, height: 4 * wingFlap + 2),
      wingPaint,
    );
    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx, by), width: 2, height: 5),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ambience != oldDelegate.ambience ||
      oldDelegate.stage != stage;
}
