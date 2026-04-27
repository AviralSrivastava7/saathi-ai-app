// ========================================
// COMPLETE FIXED FILE: mood_mandala_game.dart
// ========================================
// Yeh poora file apne project mein copy-paste kar do:
// lib/features/mindful_games/mood_mandala_game.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/smooth_page_route.dart';

class MoodMandalaGame extends StatefulWidget {
  const MoodMandalaGame({super.key});

  @override
  State<MoodMandalaGame> createState() => _MoodMandalaGameState();
}

class _MoodMandalaGameState extends State<MoodMandalaGame> {
  final List<MandalaArt> _savedMandalas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedMandalas();
  }

  Future<void> _loadSavedMandalas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCount = prefs.getInt('mandala_count') ?? 0;

      for (int i = 0; i < savedCount; i++) {
        final moodValue = prefs.getDouble('mandala_${i}_mood') ?? 0.5;
        final energyValue = prefs.getDouble('mandala_${i}_energy') ?? 0.5;
        final complexityValue =
            prefs.getDouble('mandala_${i}_complexity') ?? 0.5;
        final timestamp = prefs.getString('mandala_${i}_timestamp') ?? '';

        _savedMandalas.add(MandalaArt(
          moodValue: moodValue,
          energyValue: energyValue,
          complexityValue: complexityValue,
          timestamp: timestamp,
        ));
      }
    } catch (e) {
      debugPrint('Error loading mandalas: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveNewMandala(MandalaArt mandala) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('mandala_count') ?? 0;

      await prefs.setDouble('mandala_${currentCount}_mood', mandala.moodValue);
      await prefs.setDouble(
          'mandala_${currentCount}_energy', mandala.energyValue);
      await prefs.setDouble(
          'mandala_${currentCount}_complexity', mandala.complexityValue);
      await prefs.setString(
          'mandala_${currentCount}_timestamp', mandala.timestamp);
      await prefs.setInt('mandala_count', currentCount + 1);

      setState(() => _savedMandalas.add(mandala));
    } catch (e) {
      debugPrint('Error saving mandala: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localization.translate('mood_mandala') ?? 'Mood Mandala'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create New Button
                  _buildCreateNewCard(context, localization),

                  const SizedBox(height: 24),

                  // Saved Mandalas
                  if (_savedMandalas.isNotEmpty) ...[
                    Text(
                      localization.translate('your_mandalas') ??
                          'Your Mandalas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _savedMandalas.length,
                      itemBuilder: (context, index) {
                        return _buildMandalaCard(_savedMandalas[index]);
                      },
                    ),
                  ] else
                    _buildEmptyState(localization),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateNewCard(
      BuildContext context, AppLocalizations? localization) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          smoothPageRoute(page: const MandalaCreator()),
        );

        if (result != null && result is MandalaArt) {
          await _saveNewMandala(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.3), // ✅ FIXED
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2), // ✅ FIXED
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization?.translate('create_new_mandala') ??
                        'Create New Mandala',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localization?.translate('express_your_mood') ??
                        'Express your current mood through art',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), // ✅ FIXED
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMandalaCard(MandalaArt mandala) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          smoothPageRoute(page: MandalaViewer(mandala: mandala)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05), // ✅ FIXED
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), // ✅ FIXED
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                child: CustomPaint(
                  painter: MandalaPainter(
                    moodValue: mandala.moodValue,
                    energyValue: mandala.energyValue,
                    complexityValue: mandala.complexityValue,
                    isPreview: true,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05), // ✅ FIXED
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mandala.timestamp,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7), // ✅ FIXED
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.remove_red_eye,
                    color: Colors.white.withValues(alpha: 0.5), // ✅ FIXED
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? localization) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3), // ✅ FIXED
            ),
            const SizedBox(height: 16),
            Text(
              localization?.translate('no_mandalas_yet') ??
                  'No mandalas created yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), // ✅ FIXED
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localization?.translate('create_first_mandala') ??
                  'Create your first mandala to express your mood',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), // ✅ FIXED
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF9C27B0)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                localization.translate('about_mood_mandala') ??
                    'About Mood Mandala',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          localization.translate('mood_mandala_info') ??
              'Mood Mandala is an interactive art therapy tool. Adjust the sliders to express your current mood, energy level, and desired complexity. The mandala changes in real-time to reflect your emotional state.\n\nThis practice helps in:\n• Emotional awareness\n• Stress relief\n• Creative expression\n• Mindfulness',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localization.translate('got_it') ?? 'Got It',
              style: const TextStyle(color: Color(0xFF9C27B0)),
            ),
          ),
        ],
      ),
    );
  }
}
// ============ PART 2: MANDALA CREATOR (WITH OVERFLOW FIX) ============

class MandalaCreator extends StatefulWidget {
  const MandalaCreator({super.key});

  @override
  State<MandalaCreator> createState() => _MandalaCreatorState();
}

class _MandalaCreatorState extends State<MandalaCreator> {
  double _moodValue = 0.5; // 0 = sad, 1 = happy
  double _energyValue = 0.5; // 0 = calm, 1 = energetic
  double _complexityValue = 0.5; // 0 = simple, 1 = complex

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text(localization.translate('create_mandala') ?? 'Create Mandala'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final mandala = MandalaArt(
                moodValue: _moodValue,
                energyValue: _energyValue,
                complexityValue: _complexityValue,
                timestamp: _getFormattedDate(),
              );
              Navigator.pop(context, mandala);
            },
          ),
        ],
      ),
      // ✅✅✅ OVERFLOW FIX STARTS HERE ✅✅✅
      body: SafeArea(
        // ✅ ADDED: SafeArea wrapper
        child: Column(
          children: [
            // ✅ FIXED: Mandala Preview with CONSTRAINED HEIGHT
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.45, // ✅ Fixed 45% height
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: AspectRatio(
                    // ✅ ADDED: Maintains square shape
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: MandalaPainter(
                        moodValue: _moodValue,
                        energyValue: _energyValue,
                        complexityValue: _complexityValue,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ✅ FIXED: Controls with Expanded and ScrollView
            Expanded(
              // ✅ Takes remaining space
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.05), // ✅ FIXED: withOpacity
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  // ✅ ADDED: Scrollable controls
                  child: Column(
                    children: [
                      _buildSlider(
                        label: localization.translate('mood') ?? 'Mood',
                        value: _moodValue,
                        leftLabel: localization.translate('sad') ?? 'Sad',
                        rightLabel: localization.translate('happy') ?? 'Happy',
                        color: const Color(0xFFFF6B6B),
                        icon: Icons.mood,
                        onChanged: (value) =>
                            setState(() => _moodValue = value),
                      ),

                      const SizedBox(height: 24),

                      _buildSlider(
                        label: localization.translate('energy') ?? 'Energy',
                        value: _energyValue,
                        leftLabel: localization.translate('calm') ?? 'Calm',
                        rightLabel:
                            localization.translate('energetic') ?? 'Energetic',
                        color: const Color(0xFF4ECDC4),
                        icon: Icons.bolt,
                        onChanged: (value) =>
                            setState(() => _energyValue = value),
                      ),

                      const SizedBox(height: 24),

                      _buildSlider(
                        label: localization.translate('complexity') ??
                            'Complexity',
                        value: _complexityValue,
                        leftLabel: localization.translate('simple') ?? 'Simple',
                        rightLabel:
                            localization.translate('complex') ?? 'Complex',
                        color: const Color(0xFF9C27B0),
                        icon: Icons.auto_awesome,
                        onChanged: (value) =>
                            setState(() => _complexityValue = value),
                      ),

                      const SizedBox(height: 16), // ✅ Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ✅✅✅ OVERFLOW FIX ENDS HERE ✅✅✅
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required String leftLabel,
    required String rightLabel,
    required Color color,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.3), // ✅ FIXED
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2), // ✅ FIXED
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), // ✅ FIXED
                fontSize: 12,
              ),
            ),
            Text(
              rightLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), // ✅ FIXED
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}

// ============ MANDALA VIEWER ============
class MandalaViewer extends StatelessWidget {
  final MandalaArt mandala;

  const MandalaViewer({super.key, required this.mandala});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(mandala.timestamp),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: AspectRatio(
            // ✅ ADDED: Maintains square shape
            aspectRatio: 1,
            child: CustomPaint(
              painter: MandalaPainter(
                moodValue: mandala.moodValue,
                energyValue: mandala.energyValue,
                complexityValue: mandala.complexityValue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ MANDALA DATA MODEL ============
class MandalaArt {
  final double moodValue;
  final double energyValue;
  final double complexityValue;
  final String timestamp;

  MandalaArt({
    required this.moodValue,
    required this.energyValue,
    required this.complexityValue,
    required this.timestamp,
  });
}
// ============ PART 3: MANDALA PAINTER (WITH ALL FIXES) ============

class MandalaPainter extends CustomPainter {
  final double moodValue;
  final double energyValue;
  final double complexityValue;
  final bool isPreview;

  MandalaPainter({
    required this.moodValue,
    required this.energyValue,
    required this.complexityValue,
    this.isPreview = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Mood-based color
    final color = Color.lerp(
      const Color(0xFF6C63FF), // Sad color (purple-blue)
      const Color(0xFFFFD700), // Happy color (gold)
      moodValue,
    )!;

    // Complexity determines layers
    final layers = (3 + (complexityValue * 5)).toInt();

    // Energy determines rotation and spacing
    final rotation = energyValue * pi / 6;

    for (int layer = layers; layer > 0; layer--) {
      final layerRadius = radius * (layer / layers);
      final layerOpacity = 0.3 + (0.7 * (layer / layers));

      // Number of petals based on energy
      final petals = (6 + (energyValue * 6)).toInt();

      for (int i = 0; i < petals; i++) {
        final angle = (2 * pi * i / petals) + rotation;

        // Petal shape
        final path = Path();
        final petalLength = layerRadius * 0.8;
        final petalWidth = layerRadius * 0.3;

        path.moveTo(center.dx, center.dy);

        final controlPoint1 = Offset(
          center.dx + cos(angle - 0.3) * petalLength,
          center.dy + sin(angle - 0.3) * petalLength,
        );

        final controlPoint2 = Offset(
          center.dx + cos(angle + 0.3) * petalLength,
          center.dy + sin(angle + 0.3) * petalLength,
        );

        final endPoint = Offset(
          center.dx + cos(angle) * petalLength,
          center.dy + sin(angle) * petalLength,
        );

        path.quadraticBezierTo(
          controlPoint1.dx,
          controlPoint1.dy,
          endPoint.dx,
          endPoint.dy,
        );

        path.quadraticBezierTo(
          controlPoint2.dx,
          controlPoint2.dy,
          center.dx,
          center.dy,
        );

        // ✅ FIXED: withOpacity instead of withValues
        final paint = Paint()
          ..color = color.withValues(alpha: layerOpacity) // ✅ FIXED
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, paint);

        // Petal outline
        // ✅ FIXED: withOpacity instead of withValues
        final outlinePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2) // ✅ FIXED
          ..style = PaintingStyle.stroke
          ..strokeWidth = isPreview ? 1 : 2;

        canvas.drawPath(path, outlinePaint);
      }

      // Inner circles
      // ✅ FIXED: withOpacity instead of withValues
      final circlePaint = Paint()
        ..color = color.withValues(alpha: layerOpacity * 0.5) // ✅ FIXED
        ..style = PaintingStyle.stroke
        ..strokeWidth = isPreview ? 1 : 2;

      canvas.drawCircle(center, layerRadius * 0.5, circlePaint);
    }

    // Center circle
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.1, centerPaint);
  }

  @override
  bool shouldRepaint(MandalaPainter oldDelegate) {
    return oldDelegate.moodValue != moodValue ||
        oldDelegate.energyValue != energyValue ||
        oldDelegate.complexityValue != complexityValue;
  }
}
