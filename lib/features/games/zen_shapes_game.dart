import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class ZenShapesGame extends StatefulWidget {
  const ZenShapesGame({super.key});

  @override
  State<ZenShapesGame> createState() => _ZenShapesGameState();
}

class _ZenShapesGameState extends State<ZenShapesGame> with TickerProviderStateMixin {
  final List<ZenShape> _activeShapes = [];
  int _score = 0;
  late Timer _spawnTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _startSpawning();
  }

  void _startSpawning() {
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          _activeShapes.add(ZenShape(
            id: DateTime.now().millisecondsSinceEpoch,
            x: _random.nextDouble(),
            y: -0.2, // Start above screen
            size: 40 + _random.nextDouble() * 40,
            color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withOpacity(0.6),
            type: ShapeType.values[_random.nextInt(ShapeType.values.length)],
            speed: 0.005 + _random.nextDouble() * 0.01,
          ));
        });
        _updateShapes();
      }
    });
  }

  void _updateShapes() {
    const fps = 60;
    Timer.periodic(const Duration(milliseconds: 1000 ~/ fps), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        for (int i = _activeShapes.length - 1; i >= 0; i--) {
          _activeShapes[i].y += _activeShapes[i].speed;
          if (_activeShapes[i].y > 1.2) {
            _activeShapes.removeAt(i);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _spawnTimer.cancel();
    super.dispose();
  }

  void _onShapeTap(ZenShape shape) {
    setState(() {
      _activeShapes.removeWhere((s) => s.id == shape.id);
      _score += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('game_zen_shapes'), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Floating Shapes
          ..._activeShapes.map((shape) => _buildShapeWidget(shape)),

          // Score Overlay
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                AppLocalizations.of(context).t('harmony_label', {'val': '$_score'}),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Instructions
          if (_score == 0)
            Center(
              child: Text(
                AppLocalizations.of(context).t('zen_shapes_instr'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShapeWidget(ZenShape shape) {
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      left: shape.x * size.width - (shape.size / 2),
      top: shape.y * size.height,
      child: GestureDetector(
        onTap: () => _onShapeTap(shape),
        child: Container(
          width: shape.size,
          height: shape.size,
          decoration: BoxDecoration(
            color: shape.color,
            shape: shape.type == ShapeType.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: shape.type == ShapeType.square ? BorderRadius.circular(12) : null,
            boxShadow: [
              BoxShadow(
                color: shape.color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: shape.type == ShapeType.triangle
              ? CustomPaint(painter: TrianglePainter(shape.color))
              : null,
        ),
      ),
    );
  }
}

enum ShapeType { circle, square, triangle }

class ZenShape {
  final int id;
  final double x;
  double y;
  final double size;
  final Color color;
  final ShapeType type;
  final double speed;

  ZenShape({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.type,
    required this.speed,
  });
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
