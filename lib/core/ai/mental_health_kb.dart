/// 📚 Mental Health Knowledge Base — 30+ Topics
/// Each topic has: info, tips, support, exercise responses
class MentalHealthKB {
  /// Detect which topic the message is about
  static String? detectTopic(String t) {
    for (final entry in _topicKeywords.entries) {
      if (entry.value.any((k) => t.contains(k))) return entry.key;
    }
    return null;
  }

  /// Get knowledge for a topic
  static Map<String, dynamic>? get(String topic) => _kb[topic];

  // ════════════════════════════════════════
  // 🔑 TOPIC KEYWORDS
  // ════════════════════════════════════════
  static final Map<String, List<String>> _topicKeywords = {
    'depression': ['depress', 'udaas', 'hopeless', 'koi umeed nahi', 'worth', 'pointless', 'zindagi', 'bekar'],
    'anxiety': ['anxiety', 'anxious', 'ghabra', 'dar lag', 'nervous', 'worry', 'chinta', 'tension', 'restless'],
    'panic_attack': ['panic', 'attack', 'saans nahi', 'breathless', 'dil dhadak', 'heart racing', 'chest pain'],
    'stress': ['stress', 'pressure', 'dabav', 'load', 'zyada kaam', 'overwork', 'overwhelm'],
    'sleep': ['neend', 'sleep', 'insomnia', 'soh nahi', 'jagta', 'nahi soh', 'nind', 'raat ko'],
    'anger': ['gussa', 'angry', 'rage', 'irritat', 'frustrat', 'chidh', 'jhagda'],
    'loneliness': ['akela', 'lonely', 'alone', 'koi nahi', 'nobody', 'isolation', 'connect'],
    'grief': ['grief', 'loss', 'lost someone', 'guzar gaye', 'death', 'kho diya', 'miss karta'],
    'self_esteem': ['confidence', 'self esteem', 'ugly', 'stupid', 'bekar hoon', 'worth', 'useless', 'failure'],
    'overthinking': ['overthink', 'sochta', 'zyada soch', 'dimag', 'thoughts', 'control nahi', 'ruk nahi'],
    'relationship': ['relation', 'partner', 'breakup', 'break up', 'dost', 'friend', 'rishta', 'pyaar', 'love'],
    'burnout': ['burnout', 'burnt out', 'bore', 'motivation', 'mann nahi', 'give up', 'haar', 'thak gaya'],
    'meditation': ['meditat', 'dhyan', 'mindful', 'calm', 'peace', 'shaanti', 'relax'],
    'breathing': ['breath', 'saans', 'pranayam'],
    'journaling': ['journal', 'diary', 'likho', 'likhna', 'writing'],
    'exercise_topic': ['exercise', 'workout', 'walk', 'yoga', 'physical', 'gym', 'body'],
    'self_care': ['self care', 'khud ka', 'apna khayal', 'routine', 'habit'],
    'exam_stress': ['exam', 'padhai', 'study', 'marks', 'result', 'fail', 'test'],
    'body_image': ['body image', 'mota', 'patla', 'weight', 'fat', 'thin', 'look'],
    'ptsd': ['trauma', 'ptsd', 'flashback', 'yaad aati', 'haunt'],
    'ocd': ['ocd', 'obsess', 'compuls', 'baar baar', 'check karna'],
    'social_anxiety': ['social', 'logo se', 'public', 'stage', 'judgement', 'log kya kahenge'],
    'family': ['family', 'gharwale', 'parents', 'maa', 'papa', 'mummy', 'daddy', 'ghar'],
    'work_stress': ['office', 'boss', 'job', 'kaam', 'career', 'salary', 'naukri'],
    'addiction': ['addict', 'phone', 'social media', 'scroll', 'nasha', 'habit'],
    'gratitude': ['grateful', 'shukar', 'thankful', 'gratitude', 'blessed'],
    'forgiveness': ['maaf', 'forgiv', 'grudge', 'let go', 'chod do'],
    'motivation_topic': ['motivat', 'inspire', 'energy', 'kaise shuru', 'start', 'himmat'],
    'crying': ['ro raha', 'rona', 'aansu', 'tears', 'cry'],
  };

  // ════════════════════════════════════════
  // 📖 KNOWLEDGE BASE
  // ════════════════════════════════════════
  static final Map<String, Map<String, dynamic>> _kb = {
    'depression': {
      'info': [
        'Depression ek real medical condition hai — yeh sirf "udaas hona" nahi hai. 🧠\n\n'
        'Ismein ho sakta hai:\n'
        '• Lagatar udaasi ya khaalipan\n'
        '• Kisi cheez mein interest na lagna\n'
        '• Thakaan, neend mein problem\n'
        '• Concentrate karne mein mushkil\n'
        '• Khud ko worthless feel karna\n\n'
        'Yaad rakhna: Depression tumhari galti NAHI hai. Yeh ek illness hai jisme help milti hai. Professional se baat karna bohot zaroori hai.',
      ],
      'tips': [
        'Depression se deal karne ke tarike:\n\n'
        '1. 💬 Kisi se baat karo — friend, family, ya counselor\n'
        '2. 🚶 Chhoti walk lo — 10 min bhi kaafi hai\n'
        '3. ☀️ Sunlight mein time bitao — mood improve hota hai\n'
        '4. 📝 Journal likho — feelings bahar aati hain\n'
        '5. 🛏️ Sleep routine fix karo — roz same time soh kar utho\n'
        '6. 🍎 Healthy khana khao — body-mind connected hai\n\n'
        'Aur sabse important: professional help lena strength hai. 💙',
      ],
      'support': [
        'Agar tum depression feel kar rahe ho — main sun raha hoon. 💙\n\n'
        'Yeh feelings bohot real aur heavy hain. Par yaad rakhna:\n'
        '• Tum akele nahi ho — bahut log isse guzarte hain\n'
        '• Yeh permanent nahi hai — better hona possible hai\n'
        '• Help maangna brave hona hai\n\n'
        'Abhi ek chhota step lo: kisi apne ko batao kaise feel ho raha hai.',
      ],
      'exercise': [
        'Abhi try karo — 5-4-3-2-1 Grounding:\n\n'
        '👀 5 cheezein dekho apne aas paas\n'
        '✋ 4 cheezein chuo\n'
        '👂 3 aawazein suno\n'
        '👃 2 cheezein sungho\n'
        '👅 1 cheez chakkho\n\n'
        'Yeh tumhe present moment mein laata hai aur dark thoughts se break deta hai. 🌿',
      ],
    },

    'anxiety': {
      'info': [
        'Anxiety ek natural response hai danger ke liye — par jab yeh zyada ho jaaye toh problem banti hai. 🧠\n\n'
        'Signs:\n'
        '• Dil tez dhadakna\n'
        '• Zyada paseena\n'
        '• Restlessness\n'
        '• Concentrate na kar paana\n'
        '• "Kuch bura hone wala hai" wala feeling\n\n'
        'Anxiety treatable hai — breathing techniques, therapy, aur lifestyle changes se better hota hai.',
      ],
      'tips': [
        'Anxiety manage karne ke tarike:\n\n'
        '1. 🫁 Deep breathing — 4-7-8 technique (4 sec in, 7 hold, 8 out)\n'
        '2. 🧊 Cold water face pe maaro — vagus nerve activate hota hai\n'
        '3. 📵 News/social media break lo\n'
        '4. 🏃 Physical activity karo — anxiety ki energy burn hoti hai\n'
        '5. ✍️ "Worry list" likho — dimag se paper pe lao\n'
        '6. 🎵 Calming music suno\n\n'
        'Yaad rakhna: Anxiety future ke baare mein sochti hai. Abhi, is waqt — tum safe ho. 💙',
      ],
      'support': [
        'Anxiety bohot overwhelming lag sakti hai — main samajhta hoon. 🌿\n\n'
        'Tumhara dar real hai, par danger real nahi hai. Body overreact kar rahi hai.\n\n'
        'Abhi ek gehri saans lo. Slowly. Main yahin hoon.\n\n'
        'Tum is se guzar sakte ho — pehle bhi kiya hai. 💙',
      ],
      'exercise': [
        'Abhi try karo — Box Breathing:\n\n'
        '⬆️ 4 second saans andar lo\n'
        '➡️ 4 second roko\n'
        '⬇️ 4 second bahar chodo\n'
        '⬅️ 4 second roko\n\n'
        '🔄 3-5 baar repeat karo.\n\n'
        'Yeh nervous system ko calm karta hai. Fark feel hoga. 🌊',
      ],
    },

    'panic_attack': {
      'info': [
        'Panic attack ek sudden intense fear ka episode hai — body "fight or flight" mode mein aa jaati hai. 🧠\n\n'
        'Symptoms: dil tez dhadakna, saans na aana, chest pain, dizziness, haat kaampna.\n\n'
        'Important: Panic attack se koi marta nahi. Yeh scary hai par dangerous nahi. Usually 10-20 min mein khatam ho jaata hai.',
      ],
      'tips': [
        'Panic attack ke waqt:\n\n'
        '1. 🫁 Slowly breathe — 4 sec in, 4 sec out\n'
        '2. 🧊 Kuch thanda pakdo — ice cube, cold water\n'
        '3. 🦶 Apne pair zameen pe feel karo\n'
        '4. 🗣️ Khud se bolo: "Yeh panic hai, yeh guzar jaayega"\n'
        '5. 👀 Kisi ek cheez pe focus karo\n\n'
        'Yaad rakhna: Yeh GUZAR JAAYEGA. Hamesha guzarta hai. 💙',
      ],
      'exercise': [
        'ABHI karo — STAR Technique:\n\n'
        '⭐ S - Stop (ruko)\n'
        '⭐ T - Take a breath (saans lo)\n'
        '⭐ A - Acknowledge (bolo: "yeh panic hai, khatam hoga")\n'
        '⭐ R - Re-ground (paanch cheezein gino apne aas paas)\n\n'
        'Tum safe ho. Yeh guzar jaayega. 💙',
      ],
    },

    'stress': {
      'info': [
        'Stress body ka natural response hai challenges ke liye. Thoda stress normal hai, par chronic stress health ko nuksaan karta hai. 🧠\n\n'
        'Effects: headache, neend na aana, irritability, focus na hona, muscles mein tension.\n\n'
        'Good news: stress management seekhna possible hai!',
      ],
      'tips': [
        'Stress manage karne ke tarike:\n\n'
        '1. 📋 Prioritize karo — sab kuch urgent nahi hai\n'
        '2. 🚶 Break lo har 90 min mein\n'
        '3. 🧘 5 min meditation daily\n'
        '4. 📵 Screen time limit karo raat ko\n'
        '5. 💬 Kisi se baat karo — bottle up mat karo\n'
        '6. 🎯 "No" kehna seekho — boundaries zaroori hain\n\n'
        'Ek baar mein sab kuch solve nahi hoga. Ek step at a time. 🌿',
      ],
    },

    'sleep': {
      'info': [
        'Neend mental health ke liye sabse zaroori hai. 🌙\n\n'
        'Adult ko 7-9 hours chahiye. Kam neend se: mood swings, anxiety, concentration problems, aur immunity weak hoti hai.\n\n'
        'Insomnia ke reasons: stress, screen time, irregular schedule, caffeine.',
      ],
      'tips': [
        'Better sleep ke tarike:\n\n'
        '1. 📵 Phone band karo sone se 1 hour pehle\n'
        '2. 🌡️ Room thoda cool rakho\n'
        '3. ⏰ Roz same time soh kar utho — weekends bhi\n'
        '4. ☕ Shaam 4 baje ke baad chai/coffee mat piyo\n'
        '5. 📖 Bed pe sirf sona — phone ya kaam mat karo\n'
        '6. 🧘 Sone se pehle deep breathing karo\n'
        '7. 🌿 Lavender ya chamomile try karo\n\n'
        'Sleep hygiene follow karo — 2 hafton mein fark dikhega. 🌙',
      ],
      'exercise': [
        'Abhi try karo — Body Scan for Sleep:\n\n'
        '1. Lait jaao comfortably\n'
        '2. Aankhein band karo\n'
        '3. Pairo se start karo — feel karo aur relax karo\n'
        '4. Dheere dheere upar aao — legs, stomach, chest, arms, face\n'
        '5. Har part ko imagine karo ki woh heavy ho raha hai\n\n'
        'Yeh technique body ko sleep mode mein laati hai. 🌙',
      ],
    },

    'overthinking': {
      'tips': [
        'Overthinking rokne ke tarike:\n\n'
        '1. ⏰ "Worry time" set karo — sirf 15 min sochne ka\n'
        '2. ✍️ Thoughts likho — dimag se paper pe lao\n'
        '3. 🏃 Physical activity karo — body ko busy karo\n'
        '4. 🎵 Music laga do — thoughts break hoti hain\n'
        '5. 🧠 Khud se poocho: "Kya main isko control kar sakta/sakti hoon?"\n'
        '   - Haan → action lo\n'
        '   - Nahi → chhodo, focus shift karo\n\n'
        'Thoughts sirf thoughts hain — facts nahi. 💙',
      ],
      'support': [
        'Zyada sochna bohot exhausting hai. 🌿\n\n'
        'Tumhara dimag tumhe protect karna chahta hai — par zyada planning kar raha hai.\n\n'
        'Ek kaam karo abhi: apne aas paas ek cheez choose karo aur usko 30 second tak observe karo. Color, shape, texture.\n\n'
        'Yeh alag sa lagega par yeh overthinking ka cycle todta hai. 💙',
      ],
    },

    'self_esteem': {
      'tips': [
        'Self-esteem improve karne ke tarike:\n\n'
        '1. 🪞 Roz ek acha quality likho apni\n'
        '2. 🚫 Comparison band karo — social media limit karo\n'
        '3. 🎯 Chhote goals set karo aur achieve karo\n'
        '4. 💬 Apne aap se waise baat karo jaise apne best friend se karte ho\n'
        '5. 📝 "I am enough" — roz 3 baar bolo\n\n'
        'Tum perfect nahi ho — koi nahi hai. Par tum ENOUGH zaroor ho. 💛',
      ],
      'support': [
        'Suno — tum jo feel kar rahe ho, woh tumhari reality nahi hai. 💙\n\n'
        'Depression aur low self-esteem tumhe lies batate hain:\n'
        '"Tum bekar ho" — JHOOTH\n'
        '"Koi tumhe nahi chahta" — JHOOTH\n'
        '"Tum fail ho" — JHOOTH\n\n'
        'Tum try kar rahe ho — aur yeh BOHOT hai. 🌟',
      ],
    },

    'grief': {
      'support': [
        'Loss ka dard sabse heavy hota hai. 💙\n\n'
        'Grief ke 5 stages hain: denial, anger, bargaining, depression, acceptance. Yeh order mein nahi aate — aage peeche hote hain.\n\n'
        'Tumhara dard valid hai. Time lagta hai. Apne aap ko grieve karne do.\n\n'
        'Jab tayaar lage toh kisi se baat karo — sharing helps.',
      ],
      'tips': [
        'Grief ke saath jeena:\n\n'
        '1. 💬 Feelings share karo — bottle up mat karo\n'
        '2. 📝 Memory journal likho — achhi yaadein save karo\n'
        '3. 🕯️ Unke memory ko honor karo apne tarike se\n'
        '4. 🤝 Support group join karo\n'
        '5. ⏰ Apne aap ko time do — healing linear nahi hai\n\n'
        'Yaad rakhna: Move on ka matlab bhoolna nahi hai. 🌿',
      ],
    },

    'relationship': {
      'tips': [
        'Relationships mein:\n\n'
        '1. 💬 Communication — open aur honest baat karo\n'
        '2. 👂 Sunna seekho — bina judge kiye\n'
        '3. 🚧 Boundaries set karo — dono ki zarurat hai\n'
        '4. ❤️ Quality time do — phones hatao\n'
        '5. 🪞 Pehle khud se healthy rishta banao\n\n'
        'Agar koi relationship toxic hai — distance lena okay hai. 💙',
      ],
      'support': [
        'Relationships complicated hoti hain. 🌿\n\n'
        'Agar dard ho raha hai: tumhari feelings valid hain. Koi bhi tumhe yeh nahi batata ki kya feel karna hai.\n\n'
        'Breakup ho ya misunderstanding — time aur patience chahiye. Par sabse pehle: apna khayal rakhoo. 💙',
      ],
    },

    'burnout': {
      'tips': [
        'Burnout recovery ke tarike:\n\n'
        '1. 🛑 Pehle accept karo ki burnout ho gaya hai\n'
        '2. 📆 Ek din OFF lo — guilt-free\n'
        '3. 📋 Sab kuch delegate karo jo ho sake\n'
        '4. 🌳 Nature mein time bitao\n'
        '5. 🎯 Priorities re-evaluate karo\n'
        '6. 💤 Sleep ko priority do\n\n'
        'Burnout ka cure "aur push karna" nahi hai — REST hai. 🌙',
      ],
    },

    'meditation': {
      'tips': [
        'Meditation start karne ka easy tarika:\n\n'
        '1. 🧘 Comfortable baitho — chair pe bhi chalega\n'
        '2. ⏰ Sirf 5 min se shuru karo\n'
        '3. 🫁 Saans pe focus karo — andar... bahar...\n'
        '4. 🧠 Thoughts aayengi — judge mat karo, wapas saans pe aao\n'
        '5. 📅 Roz same time karo — habit banao\n\n'
        'Meditation ka goal "kuch na sochna" NAHI hai. Goal hai: observe karna without reacting. 🌿',
      ],
      'exercise': [
        'Abhi karo — 2 Min Meditation:\n\n'
        '1. Aankhein band karo ✨\n'
        '2. 3 gehri saans lo\n'
        '3. Ab normally breathe karo\n'
        '4. Bas saans ko feel karo — naak mein thandi hawa, chest expand hona\n'
        '5. Thoughts aayein toh judge mat karo, wapas saans pe aao\n'
        '6. 2 min baad dheere se aankhein kholo\n\n'
        'Done! Tumne abhi meditation kar li. Easy tha na? 🧘',
      ],
    },

    'breathing': {
      'exercise': [
        'Breathing Exercises:\n\n'
        '🫁 **4-7-8 Technique (Best for calming)**\n'
        '• 4 sec saans andar\n'
        '• 7 sec roko\n'
        '• 8 sec dheere se bahar\n'
        '• 3 baar repeat\n\n'
        '🫁 **Box Breathing (Best for anxiety)**\n'
        '• 4 sec in → 4 sec hold → 4 sec out → 4 sec hold\n'
        '• 4 baar repeat\n\n'
        '🫁 **Belly Breathing (Best for stress)**\n'
        '• Haath pet pe rakho\n'
        '• Saans lo — pet bahar jaaye\n'
        '• Saans chodo — pet andar jaaye\n'
        '• 5 min karo\n\n'
        'Breathing sabse fast anxiety relief hai. Try karo abhi! 💙',
      ],
    },

    'journaling': {
      'tips': [
        'Journaling kaise karein:\n\n'
        '1. 📝 Roz 5 min likho — zyada nahi chahiye\n'
        '2. 🎯 Prompts use karo:\n'
        '   • "Aaj main kaise feel kar raha/rahi hoon?"\n'
        '   • "Kis cheez ne mujhe trigger kiya?"\n'
        '   • "Ek acha moment aaj ka?"\n'
        '3. ✏️ Spelling/grammar ki chinta mat karo\n'
        '4. 🔒 Yeh tumhara private space hai\n'
        '5. 🌟 Gratitude journal bhi try karo — 3 achi cheezein roz\n\n'
        'Likhna emotions ko process karne ka sabse powerful tarika hai. 💛',
      ],
    },

    'exam_stress': {
      'tips': [
        'Exam stress se deal karna:\n\n'
        '1. 📅 Timetable banao — chhote chunks mein padho\n'
        '2. ⏰ Pomodoro technique: 25 min padho, 5 min break\n'
        '3. 🚫 Doosron se compare mat karo\n'
        '4. 💤 Neend mat sacrifice karo — neend mein memory consolidate hoti hai\n'
        '5. 🧘 Exam se pehle 5 min deep breathing\n'
        '6. 🍎 Healthy khao — junk food se brain fog hota hai\n\n'
        'Exams important hain par tumhari health ZYADA important hai. 💙',
      ],
      'support': [
        'Exam ka pressure bohot heavy hota hai — main samajhta hoon. 🌿\n\n'
        'Par yaad rakhna: marks tumhari value DEFINE nahi karte. Tum marks se zyada ho.\n\n'
        'Abhi bas ek subject, ek chapter, ek page pe focus karo. Sab ek saath nahi hoga.\n\n'
        'Tum kar sakte ho. Belief rakho. 💛',
      ],
    },

    'social_anxiety': {
      'tips': [
        'Social anxiety se deal karna:\n\n'
        '1. 🐾 Chhote steps lo — ek person se baat karo pehle\n'
        '2. 🧠 Yaad rakhna: log utna nahi soch rahe tumhare baare mein jitna tum sochte ho\n'
        '3. 📝 Pehle se prepare karo — conversation topics socho\n'
        '4. 🫁 Social situation se pehle deep breathing\n'
        '5. 🎯 Apni "safe person" identify karo events mein\n'
        '6. 🏆 Har small win celebrate karo\n\n'
        'Social anxiety se recover hona possible hai. Dheere dheere. 💙',
      ],
    },

    'self_care': {
      'tips': [
        'Self-care routine banao:\n\n'
        '☀️ **Morning:**\n'
        '• Paani piyo\n'
        '• 5 min stretching\n'
        '• Healthy breakfast\n\n'
        '🌤️ **During Day:**\n'
        '• Breaks lo\n'
        '• Nature mein time bitao\n'
        '• Kisi se baat karo\n\n'
        '🌙 **Night:**\n'
        '• Screen off 1 hr before bed\n'
        '• Journal likho\n'
        '• Grateful cheezein socho\n\n'
        'Self-care selfish nahi hai — yeh ZAROORI hai. 💛',
      ],
    },

    'family': {
      'tips': [
        'Family issues handle karna:\n\n'
        '1. 💬 "I feel..." se baat shuru karo, blame mat karo\n'
        '2. 🚧 Boundaries set karo — respectfully\n'
        '3. 👂 Unka perspective samjhne ki koshish karo\n'
        '4. 🏠 Space lo jab zarurat ho — theek hai\n'
        '5. 📞 Agar ghar pe baat nahi ho rahi toh trusted adult se baat karo\n\n'
        'Family se disagreement hona normal hai. Tum galat nahi ho. 💙',
      ],
    },

    'work_stress': {
      'tips': [
        'Work stress manage karna:\n\n'
        '1. 📋 Task list banao — prioritize karo\n'
        '2. 🚫 "No" kehna seekho — overcommit mat karo\n'
        '3. ⏰ Work hours define karo — baad mein band\n'
        '4. 🤝 Help maango jab zarurat ho\n'
        '5. 🚶 Lunch break mein walk lo\n'
        '6. 🏠 Work-life boundary maintain karo\n\n'
        'Kaam zaroori hai, par tumhari health ZYADA zaroori hai. 🌿',
      ],
    },

    'addiction': {
      'tips': [
        'Phone/social media addiction:\n\n'
        '1. ⏰ Screen time tracker on karo\n'
        '2. 📵 Notifications off karo — batch mein dekho\n'
        '3. 🛏️ Bedroom mein phone mat lo\n'
        '4. 📚 Phone ki jagah book/hobby try karo\n'
        '5. 🎯 "Phone-free" time set karo daily\n'
        '6. 🧠 Jab phone uthane ka mann kare — 5 sec ruko aur poocho "kyun?"\n\n'
        'Digital detox se mental clarity aati hai. 💙',
      ],
    },

    'gratitude': {
      'exercise': [
        'Gratitude Exercise — Abhi karo:\n\n'
        '📝 3 cheezein likho jinke liye tum aaj grateful ho:\n\n'
        '1. ________________________\n'
        '2. ________________________\n'
        '3. ________________________\n\n'
        'Yeh chhoti cheezein ho sakti hain: chai ka cup, kisi ki smile, ya bas aaj ka din.\n\n'
        'Research kehta hai: daily gratitude depression 25% reduce karta hai. 🌟',
      ],
    },

    'crying': {
      'support': [
        'Rona weakness nahi hai — yeh release hai. 💧\n\n'
        'Science kehta hai: crying se stress hormones bahar aate hain, endorphins release hoti hain, aur emotional pain kam hota hai.\n\n'
        'Toh agar rona aa raha hai — rokna mat. Let it flow.\n\n'
        'Tumhare aansu tumhari strength hain. Main yahin hoon. 💙',
      ],
    },

    'motivation_topic': {
      'tips': [
        'Motivation laane ke tarike:\n\n'
        '1. 🎯 Bohot chhota goal set karo — "sirf 5 min"\n'
        '2. 🏆 Har step celebrate karo\n'
        '3. 📱 Inspirational content dekho\n'
        '4. 🤝 Accountability partner dhundho\n'
        '5. 🧠 "I don\'t feel like it" ke baad bhi start karo — momentum aata hai\n\n'
        'Motivation action SE aati hai, action SE PEHLE nahi. Pehle shuru karo, fir feel hoga. 🔥',
      ],
      'support': [
        'Mann nahi lag raha? Hota hai. 🌿\n\n'
        'Motivation roz nahi milti — aur yeh normal hai. Successful log discipline pe chalte hain, motivation pe nahi.\n\n'
        'Abhi sirf itna karo: ek chhoti si cheez. Paani piyo. Ek walk lo. Ek page padho.\n\n'
        'Chhote steps se bada safar hota hai. 💛',
      ],
    },

    'forgiveness': {
      'support': [
        'Maaf karna mushkil hai — par zaruri hai. 🌿\n\n'
        'Forgiveness doosre ke liye nahi, TUMHARE liye hai. Grudge rakhna khud ko poison dena hai.\n\n'
        'Maaf karne ka matlab "theek hai" kehna nahi hai. Matlab hai: "Main is bojh ko chhod raha hoon."\n\n'
        'Dheere dheere hoga. Ek din mein nahi. Par hoga. 💙',
      ],
    },

    'body_image': {
      'support': [
        'Tumhara body tumhara ghar hai — usse pyaar karo. 💛\n\n'
        'Social media pe jo dikhta hai woh 99% edited hai. Real bodies perfect nahi hoti — aur yeh beautiful hai.\n\n'
        'Tumhari value tumhare weight, shape, ya looks se DEFINE nahi hoti.\n\n'
        'Ek kaam karo: aaj apne body ko ek compliment do. Seriously. 🌟',
      ],
    },

    'exercise_topic': {
      'tips': [
        'Mental health ke liye exercise:\n\n'
        '1. 🚶 Daily 30 min walk — sabse easy aur effective\n'
        '2. 🧘 Yoga — body + mind dono ke liye\n'
        '3. 💃 Dance — mood instantly improve hota hai\n'
        '4. 🏃 Running — anxiety ki energy burn hoti hai\n'
        '5. 💪 Strength training — confidence badhta hai\n\n'
        'Exercise se serotonin, dopamine, aur endorphins release hote hain — yeh natural antidepressants hain! 🌟',
      ],
    },
  };
}
