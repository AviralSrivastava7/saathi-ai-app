import '../config/app_language.dart';

class AppText {
  static String get lang => AppLanguage.instance.current;

  // ---------- COMMON ----------
  static String get notAlone => lang == 'hi'
      ? 'आप अकेले नहीं हैं।'
      : lang == 'hinglish'
          ? 'Aap akele nahi ho.'
          : "You're not alone.";

  // ---------- HOME ----------
  static String get greeting => lang == 'hi'
      ? 'नमस्ते 🌙'
      : lang == 'hinglish'
          ? 'Good evening 🌙'
          : 'Good evening 🌙';

  // ---------- FEED ----------
  static String get breathingTitle => lang == 'hi'
      ? '30 सेकंड की सांस'
      : lang == 'hinglish'
          ? '30 second breathing'
          : '30-second breathing';

  static String get breathingSub => lang == 'hi'
      ? 'मन को शांत करें'
      : lang == 'hinglish'
          ? 'Mind ko shaant karo'
          : 'Slow down your mind';

  static String get writeTitle => lang == 'hi'
      ? 'जो भारी लग रहा है, लिखिए'
      : lang == 'hinglish'
          ? 'Jo heavy lag raha hai, likho'
          : "Write what’s heavy";

  static String get writeSub => lang == 'hi'
      ? 'यहाँ कोई जज नहीं कर रहा'
      : lang == 'hinglish'
          ? 'Yahan koi judge nahi karega'
          : 'No one is judging';

  static String get thoughtTitle => lang == 'hi'
      ? 'आज का विचार'
      : lang == 'hinglish'
          ? 'Aaj ka thought'
          : 'Thought of the day';

  static String get thoughtSub => lang == 'hi'
      ? 'एक हल्की याद'
      : lang == 'hinglish'
          ? 'Ek gentle reminder'
          : 'A gentle reminder';

  static String get tipTitle => lang == 'hi'
      ? 'छोटी सेल्फ-केयर टिप'
      : lang == 'hinglish'
          ? 'Small self-care tip'
          : 'Small self-care tip';

  static String get tipSub => lang == 'hi'
      ? 'आज के लिए'
      : lang == 'hinglish'
          ? 'Aaj ke liye'
          : 'For today';

  // ---------- MOOD ----------
  static String get moodQuestion => lang == 'hi'
      ? 'आज मन कैसा लग रहा है?'
      : lang == 'hinglish'
          ? 'Aaj mann kaisa lag raha hai?'
          : 'How are you feeling today?';

  static String get moodOk => lang == 'hi'
      ? 'ठीक'
      : lang == 'hinglish'
          ? 'Theek'
          : 'Okay';

  static String get moodNormal => lang == 'hi'
      ? 'सामान्य'
      : lang == 'hinglish'
          ? 'Normal'
          : 'Normal';

  static String get moodHeavy => lang == 'hi'
      ? 'भारी'
      : lang == 'hinglish'
          ? 'Heavy'
          : 'Heavy';

  // ---------- JOURNAL ----------
  static String get journalTitle => lang == 'hi'
      ? 'अपना मन लिखिए'
      : lang == 'hinglish'
          ? 'Dil ka likho'
          : 'Write your thoughts';

  static String get journalHint => lang == 'hi'
      ? 'यहाँ लिखना शुरू करें...'
      : lang == 'hinglish'
          ? 'Yahan likhna shuru karo...'
          : 'Start writing here...';

  static String get done => lang == 'hi'
      ? 'हो गया'
      : lang == 'hinglish'
          ? 'Done'
          : 'Done';
}
