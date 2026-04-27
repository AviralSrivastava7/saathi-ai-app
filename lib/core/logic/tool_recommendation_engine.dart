import 'package:flutter/material.dart';
import '../storage/mood_storage.dart';
import '../../features/meditation/meditation_screen.dart';
import '../../features/breathing/breathing_screen.dart';
import '../../features/checklist/daily_checklist_screen.dart';
import '../../features/exercises/exercises_screen.dart';
import '../../features/articles/books_reader_screen.dart';

class RecommendedTool {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget screen;

  RecommendedTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class ToolRecommendationEngine {
  static Future<RecommendedTool> getRecommendation() async {
    final lastMood = await MoodStorage.getCurrentMood() ?? 'Neutral';
    
    switch (lastMood) {
      case 'Anxious':
      case 'Stressed':
        return RecommendedTool(
          title: 'rec_calming_breaths',
          description: 'rec_calming_breaths_desc',
          icon: Icons.air,
          color: Colors.teal,
          screen: const BreathingScreen(),
        );
      case 'Sad':
      case 'Lonely':
        return RecommendedTool(
          title: 'rec_daily_affirmations',
          description: 'rec_daily_affirmations_desc',
          icon: Icons.favorite_border,
          color: Colors.pinkAccent,
          screen: const MeditationScreen(), // Fallback or specific AffirmationsScreen if I find it
        );
      case 'Angry':
      case 'Frustrated':
        return RecommendedTool(
          title: 'rec_release_energy',
          description: 'rec_release_energy_desc',
          icon: Icons.fitness_center,
          color: Colors.orange,
          screen: const ExercisesScreen(),
        );
      case 'Happy':
      case 'Excited':
        return RecommendedTool(
          title: 'rec_deep_meditation',
          description: 'rec_deep_meditation_desc',
          icon: Icons.self_improvement,
          color: Colors.indigo,
          screen: const MeditationScreen(),
        );
      case 'Calm':
        return RecommendedTool(
          title: 'rec_peaceful_reading',
          description: 'rec_peaceful_reading_desc',
          icon: Icons.menu_book,
          color: Colors.brown,
          screen: const BooksReaderScreen(),
        );
      default:
        return RecommendedTool(
          title: 'rec_daily_checklist',
          description: 'rec_daily_checklist_desc',
          icon: Icons.check_circle_outline,
          color: Colors.blue,
          screen: const DailyChecklistScreen(),
        );
    }
  }
}
