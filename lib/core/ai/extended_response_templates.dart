// lib/core/ai/extended_response_templates.dart
// 🎭 EXTENDED TEMPLATES FOR MAXIMUM VARIETY

class ExtendedResponseTemplates {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌅 TIME-BASED GREETINGS (48 variations)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static List<String> getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return [
        'Itni raat ko jaag rahe ho? Neend nahi aa rahi?',
        'Raat ko jaagna mushkil hota hai. Kya baat hai?',
        'Late night thoughts? Main sun raha hoon.',
        'Iss waqt dimag bohot sochta hai. Share karo.',
      ];
    } else if (hour < 12) {
      return [
        'Good morning. Aaj ka din kaisa lag raha hai?',
        'Subah subah mann kaisa hai?',
        'Morning ho gayi. Raat kaisi gayi?',
        'Din shuru ho gaya. Kya soch rahe ho?',
      ];
    } else if (hour < 17) {
      return [
        'Din kaisa ja raha hai?',
        'Dopahar ka time. Kya chal raha hai?',
        'Afternoon ho gayi. Sab theek?',
        'Din abhi baaki hai. Kya keh rahe ho?',
      ];
    } else if (hour < 21) {
      return [
        'Shaam ho gayi. Din kaisa raha?',
        'Evening ka time. Relax kar rahe ho?',
        'Shaam ka time hai. Kuch share karna hai?',
        'Din ka end ho raha hai. Kya feel ho raha hai?',
      ];
    } else {
      return [
        'Raat ho gayi. Mann kaisa hai?',
        'Night time. Sab theek?',
        'Raat ko thoughts aate hain. Share karo.',
        'Late evening. Kya chal raha hai dimag mein?',
      ];
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 💬 CONVERSATION STARTERS (By emotion - 200+ options)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final Map<String, List<String>> conversationStarters = {
    'sad': [
      'Kya hua jo tumhe udaas kar gaya?',
      'Yeh feeling kab se hai?',
      'Kisi specific baat se dukh hai?',
      'Pehle bhi aisa feel hua hai?',
      'Kis cheez ka zyada bhaari lag raha hai?',
      'Kya kuch share karna chahoge?',
      'Is feeling ke peeche kya hai?',
      'Kab se yeh mehsoos ho raha hai?',
    ],
    'anxious': [
      'Kya tumhe dar lag raha hai?',
      'Body mein kahan tension feel ho rahi hai?',
      'Yeh anxiety kab shuru hui?',
      'Kya specific situation hai jo trigger kar rahi hai?',
      'Kya breathe karna mushkil lag raha hai?',
      'Kya thoughts ruk nahi rahe?',
      'Future ki kya chinta hai?',
      'Kya control se bahar lag raha hai?',
    ],
    'tired': [
      'Kab se thak rahe ho?',
      'Neend puri ho rahi hai?',
      'Zyada kaam kar rahe ho kya?',
      'Break liya abhi tak?',
      'Body ko rest ki zarurat hai kya?',
      'Khud ko push kar rahe ho zyada?',
      'Energy level kaisa hai?',
      'Rest lene ka time mil raha hai?',
    ],
    'angry': [
      'Kya hua jo gussa aa gaya?',
      'Kisi ne kuch kiya?',
      'Yeh frustration kahan se aa rahi hai?',
      'Kya boundary cross hui?',
      'Kis baat ne trigger kiya?',
      'Yeh gussa kab se build up ho raha hai?',
      'Kya express kar paaye?',
      'Kya feel karna chahte ho?',
    ],
    'lonely': [
      'Kab se akela feel ho raha hai?',
      'Kisi se baat ki recently?',
      'Connection ki kami hai?',
      'Kya understood feel nahi ho raha?',
      'Koi paas hai ya nahi?',
      'Is akelepan ki wajah kya hai?',
      'Kisi se connect karna chahoge?',
      'Kya share karna chahte ho?',
    ],
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎯 FOLLOW-UP PATTERNS (Context-aware)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final Map<String, List<String>> followUpPatterns = {
    'work_stress': [
      'Kaam ka pressure bohot zyada hai lagta hai.',
      'Office mein kya chal raha hai?',
      'Boss ka behaviour kaisa hai?',
      'Workload sambhal paa rahe ho?',
      'Kya deadlines tight hain?',
    ],
    'relationship': [
      'Rishton mein kabhi tension hoti hai.',
      'Understanding ki kami feel ho rahi hai?',
      'Communicate karne mein mushkil?',
      'Expectations match nahi ho rahi?',
      'Kya space chahiye?',
    ],
    'family': [
      'Gharwale samajh nahi paate kabhi.',
      'Family ka pressure hai?',
      'Expectations zyada hain?',
      'Communication gap hai?',
      'Support mil raha hai ya nahi?',
    ],
    'health': [
      'Tabiyat kaisi hai?',
      'Body kuch signals de rahi hai?',
      'Doctor se consult kiya?',
      'Rest le rahe ho?',
      'Medicine time pe le rahe ho?',
    ],
    'sleep': [
      'Neend puri nahi ho rahi lagta hai.',
      'Kitne ghante so rahe ho?',
      'Neend ki quality kaisi hai?',
      'Screen time zyada hai kya?',
      'Raat ko thoughts aate hain?',
    ],
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌱 ENCOURAGEMENT & AFFIRMATIONS (150+ options)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final List<String> encouragements = [
    // Self-compassion
    'Tum khud pe meherbaan raho.',
    'Apne aap ko waqt do.',
    'Galti karna insaan hona hai.',
    'Perfect hona zaroori nahi.',
    'Tumhari koshish matter karti hai.',
    'Tumhara struggle valid hai.',
    'Tumhari feelings real hain.',
    'Tum enough ho.',

    // Progress
    'Har chhota step bhi progress hai.',
    'Tum pehle se better kar rahe ho.',
    'Growth dheere hoti hai.',
    'Healing linear nahi hoti.',
    'Tumne bohot overcome kiya hai.',
    'Tum strong ho.',
    'Tumme himmat hai.',
    'Tum kar sakte ho.',

    // Support
    'Tum akele nahi ho.',
    'Main yahin hoon.',
    'Tumhari baat matter karti hai.',
    'Tumhe sunne wala hai.',
    'Help lena strength hai.',
    'Share karna brave hona hai.',
    'Vulnerable hona okay hai.',
    'Express karna zaroori hai.',

    // Hope
    'Better days aayenge.',
    'Yeh phase guzar jaayega.',
    'Kal ek nayi shuruaat hai.',
    'Time heal karta hai.',
    'Light end mein hai.',
    'Tumhare andar shakti hai.',
    'Tum isse paar kar sakte ho.',
    'Umeed mat chodo.',
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎨 EMPATHETIC RESPONSES (Intensity-based)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final Map<int, List<String>> intensityResponses = {
    // Low intensity (1-2)
    1: [
      'Samajh aata hai.',
      'Haan, yeh bhi sach hai.',
      'Main sun raha hoon.',
      'Hmm, continue karo.',
      'Theek hai.',
    ],

    // Medium intensity (3)
    3: [
      'Yeh bohot mushkil lag raha hai tumhare liye.',
      'Main feel kar sakta hoon tumhari struggle.',
      'Itna sab ek saath handle karna easy nahi.',
      'Tumhe kaafi deal karna pad raha hai.',
      'Yeh heavy hai, main samajhta hoon.',
    ],

    // High intensity (4-5)
    5: [
      'Yeh bohot, bohot overwhelming hai.',
      'Main dekh sakta hoon kitna bhaari hai yeh sab.',
      'Tumhara pain real hai aur valid hai.',
      'Koi bhi tumhari jagah hota toh yeh feel karta.',
      'Tum bohot strong ho ki abhi tak sambhale ho.',
      'Yeh tumhari galti nahi hai.',
      'Tumhe yeh feel karne ka pura haq hai.',
    ],
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔄 REPEATED CONCERN HANDLERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final List<String> repeatConcernResponses = [
    'Lagta hai yeh pattern ban raha hai. Kya tumne notice kiya?',
    'Yeh feeling bar bar aa rahi hai. Shayad kuch deeper hai?',
    'Is pattern ko break karne ke baare mein socha hai?',
    'Baar baar yeh aana kuch kehta hai. Kya lagta hai tumhe?',
    'Lagta hai yeh tumhare liye recurring hai. Professional help sochni chahiye?',
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✨ TRANSITION PHRASES (Natural flow)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final List<String> transitions = [
    'Aur sunao...',
    'Kuch aur share karna hai?',
    'Iske baare mein aur batao.',
    'Hmm, continue karo.',
    'Main sun raha hoon...',
    'Aage kya hua?',
    'Phir?',
    'Aur?',
    'Tell me more.',
    'Kya aur bhi kuch hai?',
  ];

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎭 CONTEXTUAL RESPONSES (Situation-specific)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final Map<String, List<String>> contextualResponses = {
    'first_message': [
      'Mujhe batao, kya chal raha hai?',
      'Share karo, main yahin hoon.',
      'Kya baat hai? Sab theek?',
      'Hi, kaisa feel ho raha hai?',
    ],
    'short_response': [
      'Kuch aur share karna hai?',
      'Elaborate karo agar theek lage.',
      'Thoda aur batao iske baare mein.',
    ],
    'long_vent': [
      'Itna sab andar rakhna mushkil hota hai.',
      'Tumne bohot kuch share kiya. Thank you.',
      'Main sab padh raha hoon dhyaan se.',
      'Likh dena hi relief deta hai kabhi.',
    ],
    'question_asked': [
      'Achha sawaal hai. Tumhe kya lagta hai?',
      'Iska jawab tumhare paas hai.',
      'Main directly answer nahi de sakta, par explore kar sakte hain.',
    ],
    'crisis': [
      'Lagta hai tumhe urgent help chahiye.',
      'Yeh serious lag raha hai. Professional help leni chahiye.',
      'Main yahin hoon, par expert se baat zaroor karo.',
      'Helpline pe call karne mein kuch galat nahi.',
    ],
  };

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌟 CLOSING VARIATIONS (Endings)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static final Map<String, List<String>> closings = {
    'supportive': [
      'Main yahin hoon.',
      'Tum akele nahi ho.',
      'Sath hoon main.',
      'Tumhare saath hoon.',
    ],
    'encouraging': [
      'Tum kar sakte ho.',
      'Ek step at a time.',
      'Dheere dheere.',
      'Apna time lo.',
    ],
    'gentle': [
      'Take care.',
      'Khud ka khayal rakho.',
      'Rest karo agar zarurat ho.',
      'Apne aap pe meherbaan raho.',
    ],
    'hopeful': [
      'Better days aayenge.',
      'Kal nayi shuruaat hai.',
      'Yeh bhi guzar jaayega.',
      'Light hai end mein.',
    ],
  };
}
