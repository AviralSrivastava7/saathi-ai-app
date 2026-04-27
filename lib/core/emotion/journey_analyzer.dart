import '../storage/journey_storage.dart';

class JourneyAnalyzer {
  static Future<String?> getReflection() async {
    final data = await JourneyStorage.load();
    if (data.length < 3) return null;

    final recent = data.takeLast(3).toList();

    int heavy = 0;
    int ok = 0;

    for (final d in recent) {
      final label = d['moodLabel'].toString().toLowerCase();
      if (label.contains('heavy')) heavy++;
      if (label.contains('ok') || label.contains('theek')) ok++;
    }

    if (heavy == 3) {
      return 'Lag raha hai pichhle kuch din kaafi bhaari rahe hain.\n'
          'Par itna likhna bhi strength hoti hai 💙';
    }

    if (ok >= 2) {
      return 'Pichhle kuch din me thoda balance dikh raha hai 🌱\n'
          'Ye progress hai.';
    }

    return 'Tum dheere-dheere cheezon ko samajh rahe ho.\n'
        'Main notice kar rahi hoon 💫';
  }
}

extension<T> on List<T> {
  Iterable<T> takeLast(int n) => skip(length - n < 0 ? 0 : length - n);
}
