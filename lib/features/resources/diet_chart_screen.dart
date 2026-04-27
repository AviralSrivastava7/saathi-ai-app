import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class DietChartScreen extends StatelessWidget {
  const DietChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).t('mindful_diet_chart')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: Stack(
          children: [
            // Top Accent Glow
            Positioned(
              top: -120,
              right: -50,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            // Bottom Accent Glow
            Positioned(
              bottom: -150,
              left: -80,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                  'Fuel Your Mind',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your gut and brain are deeply connected. Choose foods that support your mental well-being.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                _buildDietSection(
                  title: 'Stress Relief Diet',
                  subtitle: 'Calm your nervous system',
                  color: AppColors.accentBlue,
                  icon: Icons.spa,
                  foods: [
                    'Dark Chocolate: Increases endorphins and reduces stress hormones.',
                    'Herbal Teas: Chamomile or Green tea for relaxation.',
                    'Leafy Greens: Rich in magnesium to lower cortisol.',
                    'Nuts & Seeds: High in Omega-3 to reduce inflammation.',
                  ],
                ),
                _buildDietSection(
                  title: 'Mood Stability',
                  subtitle: 'Keep your energy balanced',
                  color: AppColors.accentOrange,
                  icon: Icons.wb_sunny,
                  foods: [
                    'Complex Carbs: Oatmeal and brown rice for steady serotonin.',
                    'Protein: Lean meats or legumes for dopamine production.',
                    'Berries: Packed with antioxidants for brain health.',
                    'Fermented Foods: Yogurt or Kimchi for gut-brain axis.',
                  ],
                ),
                _buildDietSection(
                  title: 'Sleep Optimization',
                  subtitle: 'Pre-sleep nutrition guide',
                  color: Colors.indigo,
                  icon: Icons.bedtime,
                  foods: [
                    'Bananas: Contain potassium and magnesium for muscle relaxation.',
                    'Walnuts: A great source of tryptophan and melatonin.',
                    'Warm Milk: Traditional remedy for better sleep onset.',
                    'Cherries: Natural source of melatonin.',
                  ],
                ),
                _buildDietSection(
                  title: 'Focus & Energy',
                  subtitle: 'Sharp mind throughout the day',
                  color: AppColors.accentGreen,
                  icon: Icons.bolt,
                  foods: [
                    'Whole Grains: Sustained energy for the brain.',
                    'Avocados: Healthy fats for brain cell communication.',
                    'Blueberries: May improve short-term memory.',
                    'Water: Crucial for maintaining concentration.',
                  ],
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietSection({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required List<String> foods,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                ...foods.map((food) {
                  final parts = food.split(':');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white24, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                              children: [
                                TextSpan(
                                  text: '${parts[0]}:',
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: parts.length > 1 ? parts[1] : '',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

