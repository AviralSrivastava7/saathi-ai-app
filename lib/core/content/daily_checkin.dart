// lib/core/content/daily_checkin.dart
class DailyCheckIn {
  static String message() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Aaj bas dheere-dheere chalo.';
    }

    if (hour < 18) {
      return 'Main yahin hoon 💙\nThoda sa break le sakte ho.';
    }

    return 'Aaj ka din kaisa gaya?\nLikho agar mann ho 🌙';
  }
}
