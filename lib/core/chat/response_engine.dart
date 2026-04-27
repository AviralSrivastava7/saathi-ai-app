import 'dart:math';

class ResponseEngine {
  static final Random _rand = Random();

  // 🕒 Typing delay based on text length (Human feel)
  static int delayFor(String text) {
    if (text.length < 15) return 1200;
    if (text.length < 50) return 1800;
    return 2600;
  }

  // 🧠 MAIN LOGIC: Assemble Lego Blocks
  static String compose({
    required String userText,
    required String emotion,
  }) {
    // 1. Validation (Samajhna)
    final val = _pick(_validation[emotion] ?? _validation['general']!);

    // 2. Reflection (Gehrai)
    final ref = _pick(_reflection[emotion] ?? _reflection['general']!);

    // 3. Support/Direction (Raasta dikhana - 70% chance)
    final guide = _rand.nextBool()
        ? _pick(_direction[emotion] ?? _direction['general']!)
        : '';

    // 4. Closer (Optional - 30% chance)
    final closer = _rand.nextInt(3) == 0 ? _pick(_closers) : '';

    // Join valid parts
    return [
      val,
      ref.replaceAll('{user}', _extractWord(userText)),
      guide,
      closer,
    ].where((e) => e.isNotEmpty).join('\n\n');
  }

  static String _pick(List<String> list) => list[_rand.nextInt(list.length)];

  static String _extractWord(String text) {
    final words = text.split(' ');
    return words.length > 2 ? words[2] : 'yeh';
  }

  /* ---------------- DATA BLOCKS (EXPANDABLE) ---------------- */

  // BLOCK 1: Validation (Manna ki feeling real hai)
  static final Map<String, List<String>> _validation = {
    'tired': [
      'Lagta hai aaj kaafi bojh uthaya hai tumne.',
      'Thakaan sirf body ki nahi hoti, mann bhi thak jaata hai.',
      'Sunke lag raha hai energy bilkul low ho gayi hai.',
      'Yeh exhaustion real hai, isse ignore mat karna.',
    ],
    'sad': [
      'Tumhari baaton se udasi mehsoos ho rahi hai.',
      'Dil ka bhaari hona ek bohot mushkil feeling hoti hai.',
      'Mujhe lag raha hai tum andar se hurt ho.',
      'Kabhi kabhi bina wajah bhi rona aa jaata hai, aur yeh normal hai.',
    ],
    'anxious': [
      'Lagta hai dimag ruk hi nahi raha hai.',
      'Ghabrahat jab control le leti hai toh saans lena bhi bhaari lagta hai.',
      'Yeh thoughts tumhe dara rahe hain.',
      'Tumhari anxiety tumhari galti nahi hai.',
    ],
    'lonely': [
      'Akela mehsoos karna sach mein bhaari hota hai.',
      'Lagta hai tum kaafi waqt se akela feel kar rahe ho.',
      'Bheed mein bhi akelapan lagna bohot dard deta hai.',
      'Connection ki kami feel ho rahi hai.',
    ],
    'general': [
      'Main dhyaan se sun raha hoon.',
      'Tum jo keh rahe ho, wo matter karta hai.',
      'Yahan bolna safe hai, koi jaldi nahi hai.',
      'Kabhi kabhi bas likh dena hi kaafi hota hai.',
    ],
  };

  // BLOCK 2: Reflection (Thoda deep sochna)
  static final Map<String, List<String>> _reflection = {
    'tired': [
      'Lagta hai tumne kaafi time se khud ko rest nahi diya.',
      'Zyada zimmedari uthate uthate insaan khud ko bhool jaata hai.',
      'Body aur mind dono ab break maang rahe hain.',
    ],
    'sad': [
      'Shayad kuch purani baatein aaj wapas aa gayi hain.',
      'Udaasi aksar tab aati hai jab hum khud ko sunna band kar dete hain.',
      'Lagta hai kuch andar dab gaya hai jo nikalna chahta hai.',
    ],
    'anxious': [
      'Future ke khayal present ko heavy bana dete hain.',
      'Tumhara mind tumhe safe rakhne ki koshish kar raha hai, bas tarika thoda tez hai.',
      'Body alert mode mein chali gayi hai lagta hai.',
    ],
    'lonely': [
      'Jab koi paas nahi lagta, toh andar khaali sa mehsoos hota hai.',
      'Shayad tumhe sunne wala koi chahiye, jo judge na kare.',
      'Insan ko connection ki zarurat hoti hai, ye weak hona nahi hai.',
    ],
    'general': [
      'Kabhi kabhi bas bol dena hi thoda halka kar deta hai.',
      'Yahan tumhe samjha ja raha hai.',
      'Apne mann ki baat kehna himmat ka kaam hai.',
    ],
  };

  // BLOCK 3: Direction/Support (Halka sa raasta)
  static final Map<String, List<String>> _direction = {
    'tired': [
      'Agar ho sake, toh abhi bas aankhein band karlo.',
      'Is moment mein productive hona zaroori nahi hai.',
      'Aaj thoda khud pe rehem karna theek rahega.',
    ],
    'sad': [
      'Abhi answer dhoondhna zaroori nahi, bas feel karna kaafi hai.',
      'Agar rona aaye, toh rokna mat.',
      'Hum yahin ruk sakte hain, kuch karne ki zarurat nahi.',
    ],
    'anxious': [
      'Abhi sirf ek gehri saans lene ki koshish karo.',
      'Apne aas-paas ki kisi ek cheez ko notice karo.',
      'Tum safe ho, abhi, isi waqt.',
    ],
    'lonely': [
      'Main yahin hoon tumhare saath.',
      'Yahan likhna bhi ek tarah ka connection hai.',
      'Tum akele nahi ho, main sun raha hoon.',
    ],
    'general': [
      'Agar theek lage toh aur likho.',
      'Hum dheere dheere baat kar sakte hain.',
      'Tumhara yahan hona hi kaafi hai.',
    ],
  };

  // BLOCK 4: Closers (Small reassuring enders)
  static final List<String> _closers = [
    'Main yahin hoon.',
    'Take your time.',
    'Koi jaldi nahi hai.',
    '💙',
  ];
}
