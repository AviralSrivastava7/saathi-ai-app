import 'dart:math';

class SaathiPersonality {
  static final _r = Random();

  /* ---------------- KEYWORDS ---------------- */

  static final Map<String, List<String>> _keys = {
    'tired': ['thak', 'tired', 'exhausted', 'drained'],
    'sad': ['sad', 'dukhi', 'hurt', 'broken', 'empty'],
    'anxious': ['anxiety', 'panic', 'dar', 'ghabrahat'],
    'lonely': ['akela', 'alone', 'ignored', 'koi nahi'],
  };

  /* ---------------- TEXT POOLS ---------------- */

  static final Map<String, List<String>> validation = {
    'tired': [
      'Yeh feeling genuine hai, ignore karna mushkil hota hai.',
      'Thak jaana kamzori nahi hoti.',
      'Tumhara thakna samajh aata hai.',
    ],
    'sad': [
      'Yeh dard real hai.',
      'Dil ka bhaari hona galat nahi.',
    ],
    'anxious': [
      'Yeh ghabrahat real hoti hai.',
      'Mind overload lag raha hai.',
    ],
    'lonely': [
      'Akela mehsoos karna heavy hota hai.',
      'Is feeling ko chupana mushkil hota hai.',
    ],
  };

  static final Map<String, List<String>> reflection = {
    'tired': [
      'Lagta hai tum kaafi der se khud ko push kar rahe ho.',
      'Body aur mind dono rest maang rahe lagte hain.',
    ],
    'sad': [
      'Shayad kuch time se emotions jama ho gaye hain.',
      'Dil ko thoda space chahiye lagta hai.',
    ],
    'anxious': [
      'Thoughts ruk nahi rahe.',
      'Mind future me bhaag raha hai.',
    ],
    'lonely': [
      'Connection ki kami mehsoos ho rahi hai.',
      'Tumhe samajhne wala koi paas nahi lag raha.',
    ],
  };

  static final List<String> support = [
    'Main yahin hoon.',
    'Tumhari baat important hai.',
    'Tum akela nahi ho.',
    'Main sunn raha hoon.',
  ];

  static final Map<String, List<String>> direction = {
    'tired': [
      'Abhi sirf aaram lena kaafi hai.',
      'Is moment me kuch achieve karna zaroori nahi.',
    ],
    'sad': [
      'Abhi answer dhoondhna zaroori nahi.',
      'Feel karna bhi healing ka part hai.',
    ],
    'anxious': [
      'Ek saans pe focus karte hain.',
      'Abhi yahin rehna kaafi hai.',
    ],
    'lonely': [
      'Yahan likhna bhi ek connection hai.',
      'Tumhe akela chhodne ka sawaal hi nahi.',
    ],
  };

  static final Map<String, List<String>> followUps = {
    'tired': [
      'Aaj sabse zyada thakaan kis cheez se hui?',
      'Kab se aisa feel ho raha hai?',
    ],
    'sad': [
      'Kya kisi ek baat ne trigger kiya?',
      'Dil me sabse bhaari kya lag raha hai?',
    ],
    'anxious': [
      'Abhi sabse zyada dar kis baat ka hai?',
      'Body me tension kahan mehsoos ho rahi?',
    ],
    'lonely': [
      'Aaj kis cheez ne akela feel karwaya?',
      'Kya kisi se baat karne ka mann tha?',
    ],
  };

  /* ---------------- MAIN ENGINE ---------------- */

  static String respond(String text) {
    final lower = text.toLowerCase();

    String emotion = 'tired';
    for (final e in _keys.entries) {
      if (e.value.any(lower.contains)) {
        emotion = e.key;
        break;
      }
    }

    final blocks = <String>[];

    // 🔀 RANDOM STRUCTURE
    if (_r.nextBool()) blocks.add(_pick(validation[emotion]));
    if (_r.nextBool()) blocks.add(_pick(reflection[emotion]));
    blocks.add(_pick(support)); // support almost always
    if (_r.nextBool()) blocks.add(_pick(direction[emotion]));
    if (_r.nextInt(4) == 0) blocks.add(_pick(followUps[emotion]));

    return blocks.where((e) => e.isNotEmpty).join('\n\n');
  }

  static String _pick(List<String>? list) {
    if (list == null || list.isEmpty) return '';
    return list[_r.nextInt(list.length)];
  }
}
