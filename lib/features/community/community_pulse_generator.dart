import 'dart:math';

/// 🌍 COMMUNITY PULSE GENERATOR
/// Generates a "Sense of Presence" based on time-of-day and global wellness trends.
/// 100% Offline & Private. No data leaves the device.
class CommunityPulseGenerator {
  static final Random _random = Random();

  /// Gets a realistic count of "Mindful Saathis" based on local time.
  static int getMindfulCount() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Base population factor (Simulated global Saathi users)
    const int basePopulation = 5000;
    
    // Time-of-day multiplier (Wellness apps peak in morning and night)
    double timeMultiplier;
    if (hour >= 6 && hour <= 9) {
      timeMultiplier = 0.8 + (_random.nextDouble() * 0.4); // Morning Peak (8 AM)
    } else if (hour >= 21 && hour <= 23) {
      timeMultiplier = 0.9 + (_random.nextDouble() * 0.3); // Night Peak (Journaling time)
    } else if (hour >= 0 && hour <= 5) {
      timeMultiplier = 0.1 + (_random.nextDouble() * 0.2); // Late Night (Low)
    } else {
      timeMultiplier = 0.4 + (_random.nextDouble() * 0.3); // Daytime (Steady)
    }

    return (basePopulation * timeMultiplier).toInt();
  }

  /// Gets a random mood distribution string for the community pulse.
  static String getMoodTrend() {
    final trends = [
      'Peaceful',
      'Hopeful',
      'Mindful',
      'Resting',
      'Grateful',
      'Focusing',
    ];
    return trends[_random.nextInt(trends.length)];
  }
}
