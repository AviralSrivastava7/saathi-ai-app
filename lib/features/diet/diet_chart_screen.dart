import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

class DietChartScreen extends StatelessWidget {
  const DietChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(loc.t('mindful_diet_chart'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
      ),
      body: ZenAuraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade600, Colors.teal.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(loc.t('fuel_your_mind'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(loc.t('gut_brain_connection'), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _dietSection(context, loc.t('stress_relief_diet'), loc.t('calm_ns'), Colors.blue, Icons.spa, [
                loc.t('diet_dark_choc'),
                loc.t('diet_herbal'),
                loc.t('diet_leafy'),
                loc.t('diet_nuts'),
              ]),
              _dietSection(context, loc.t('mood_stability'), loc.t('energy_balanced'), Colors.orange, Icons.wb_sunny, [
                loc.t('diet_carbs'),
                loc.t('diet_protein'),
                loc.t('diet_berries'),
                loc.t('diet_fermented'),
              ]),
              _dietSection(context, loc.t('sleep_optimization'), loc.t('pre_sleep_nutrition'), Colors.indigo, Icons.bedtime, [
                loc.t('diet_bananas'),
                loc.t('diet_walnuts'),
                loc.t('diet_milk'),
                loc.t('diet_cherries'),
              ]),
              _dietSection(context, loc.t('focus_energy'), loc.t('sharp_mind'), Colors.green, Icons.bolt, [
                loc.t('diet_grains'),
                loc.t('diet_avocados'),
                loc.t('diet_blueberries'),
                loc.t('diet_water'),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dietSection(BuildContext context, String title, String subtitle, Color color, IconData icon, List<String> foods) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.onSurface.withOpacity(0.06)),
            const SizedBox(height: 8),
            ...foods.map((food) {
              final parts = food.split(':');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: color.withOpacity(0.6), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 14, height: 1.5),
                          children: [
                            TextSpan(text: '${parts[0]}:', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                            TextSpan(text: parts.length > 1 ? parts[1] : '', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
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
    );
  }
}
