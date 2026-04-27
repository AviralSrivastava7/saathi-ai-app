

import 'dart:math';

/// Trilingual mood-aware message bank for Buddy.
/// Supports English (en), Hindi (hi), and Hinglish (pa/default).
class BuddyMoodMessages {
  static final _rng = Random();

  /// Get a mood-aware greeting message based on user's logged mood and language.
  static String getMoodGreeting(String? mood, String langCode) {
    final messages = _moodMessages[mood?.toLowerCase() ?? 'neutral'] ?? _moodMessages['neutral']!;
    final langMessages = messages[_langKey(langCode)] ?? messages['hinglish']!;
    return langMessages[_rng.nextInt(langMessages.length)];
  }

  /// Get a recommendation message based on mood.
  static String getRecommendation(String? mood, String langCode) {
    final recs = _recommendations[mood?.toLowerCase() ?? 'neutral'] ?? _recommendations['neutral']!;
    final langRecs = recs[_langKey(langCode)] ?? recs['hinglish']!;
    return langRecs[_rng.nextInt(langRecs.length)];
  }

  /// Get a playful nudge (for notifications / idle moments).
  static String getPlayNudge(String langCode) {
    final nudges = _playNudges[_langKey(langCode)] ?? _playNudges['hinglish']!;
    return nudges[_rng.nextInt(nudges.length)];
  }

  /// Get a welcome back message when user opens the app.
  static String getWelcomeBack(String langCode) {
    final msgs = _welcomeBack[_langKey(langCode)] ?? _welcomeBack['hinglish']!;
    return msgs[_rng.nextInt(msgs.length)];
  }

  static String _langKey(String langCode) {
    switch (langCode) {
      case 'hi': return 'hindi';
      case 'en': return 'english';
      default: return 'hinglish';
    }
  }

  // ──────────────────────────────────────────────
  // MOOD MESSAGES
  // ──────────────────────────────────────────────

  static const Map<String, Map<String, List<String>>> _moodMessages = {
    'sad': {
      'english': [
        'Hey, what happened? Let me cheer you up! 💙',
        'I see you\'re feeling down. I\'m right here for you.',
        'Bad days don\'t last forever. Let\'s do something fun!',
        'You\'re stronger than you think. Want to play a game? 🎮',
      ],
      'hindi': [
        'नमस्ते, क्या हुआ? चलो तुम्हारा मन प्रसन्न करते हैं! 💙',
        'मैं देख सकता हूँ कि तुम उदास हो। मैं यहीं तुम्हारे साथ हूँ।',
        'बुरे दिन हमेशा नहीं रहते। चलो कुछ मनोरंजक करते हैं!',
        'तुम अपनी सोच से कहीं अधिक मजबूत हो। क्या कोई खेल खेलना चाहोगे? 🎮',
      ],
      'hinglish': [
        'Kya hua bhai? Aaj sad lagre, aao mood sahi karwata hu! 💙',
        'Are, tension mat le. Main yahaan hu tere saath.',
        'Bure din hamesha nahi rehte. Chal kuch fun karte hain!',
        'Tu bahut strong hai. Kuch khelna hai? 🎮',
      ],
    },
    'happy': {
      'english': [
        'You\'re glowing today! Let\'s keep this energy going! ✨',
        'That smile looks amazing! What made you happy?',
        'Your happiness makes my circuits glow! 🌟',
        'What a wonderful day! Want to celebrate with a game?',
      ],
      'hindi': [
        'आज तुम चमक रहे हो! इस ऊर्जा को बनाए रखते हैं! ✨',
        'यह मुस्कान अद्भुत लग रही है! किस बात ने तुम्हें खुश किया?',
        'तुम्हारी खुशी मेरे दिल को रोशन करती है! 🌟',
        'कितना शानदार दिन है! क्या किसी खेल के साथ उत्सव मनाना चाहोगे?',
      ],
      'hinglish': [
        'Aaj toh bahut khush lagre! Aise hi raho! ✨',
        'Wah! Yeh smile bahut pyaari hai! Kya hua achha?',
        'Teri khushi dekhke mera bhi mood ban gaya! 🌟',
        'Kya badhiya din hai! Kuch khelke celebrate kare?',
      ],
    },
    'anxious': {
      'english': [
        'Take a deep breath. I\'m right here with you. 🌿',
        'Anxiety is tough, but you\'re tougher. Let\'s breathe together.',
        'One step at a time. You\'re doing great. 💪',
        'Want to try a breathing exercise? It really helps!',
      ],
      'hindi': [
        'एक गहरी सांस लो। मैं यहीं तुम्हारे साथ हूँ। 🌿',
        'चिंता कठिन है, लेकिन तुम उससे अधिक साहसी हो। चलो साथ में सांस लेते हैं।',
        'एक बार में एक कदम। तुम बहुत अच्छा कर रहे हो। 💪',
        'क्या श्वसन व्यायाम करना चाहोगे? यह वास्तव में मदद करता है!',
      ],
      'hinglish': [
        'Deep breath lo. Main yahaan hu tumhare saath. 🌿',
        'Tension mat le, sab theek hoga. Saath me breathe karte hain.',
        'Ek step at a time. Tu bahut achha kar raha hai. 💪',
        'Breathing exercise try karoge? Bahut kaam aata hai!',
      ],
    },
    'angry': {
      'english': [
        'Let\'s cool down together. Want to play something? 🎮',
        'I get it, sometimes things are frustrating. I\'m here.',
        'Channel that energy! How about popping some bubbles?',
        'Take a moment. Breathe. You\'ve got this. 🌊',
      ],
      'hindi': [
        'चलो साथ में शांत होते हैं। कुछ खेलना चाहोगे? 🎮',
        'मैं समझ सकता हूँ, कभी-कभी चीजें निराशाजनक होती हैं। मैं यहाँ हूँ।',
        'इस ऊर्जा को सही दिशा दें! बुलबुले फोड़ने के बारे में क्या ख्याल है?',
        'एक क्षण लो। सांस लो। तुम यह कर सकते हो। 🌊',
      ],
      'hinglish': [
        'Chal shaant hote hain saath me. Kuch khelna hai? 🎮',
        'Samajh sakta hu, kabhi kabhi bahut gussa aata hai. Main hu yahaan.',
        'Is energy ko channel kar! Bubbles pop karne ka mann hai?',
        'Ek moment le. Saans le. Tu kar sakta hai. 🌊',
      ],
    },
    'calm': {
      'english': [
        'Nice vibes today! Keep this peace going. 🌿',
        'You\'re radiating calm energy. Beautiful! ☮️',
        'This is the perfect mood. Enjoy it! 🧘',
        'Peaceful mind, powerful you. Want to meditate together?',
      ],
      'hindi': [
        'आज बहुत अच्छा वातावरण है! इस शांति को बनाए रखें। 🌿',
        'तुमसे बहुत शांत ऊर्जा आ रही है। बहुत सुंदर! ☮️',
        'यह एक आदर्श मनःस्थिति है। इसका आनंद लो! 🧘',
        'शांत मन, शक्तिशाली तुम। क्या साथ में ध्यान करना चाहोगे?',
      ],
      'hinglish': [
        'Aaj achha mahaul hai! Aise hi raho! 🌿',
        'Bahut shaant energy aa rahi hai tumse. Beautiful! ☮️',
        'Yeh perfect mood hai. Enjoy karo! 🧘',
        'Shaant mann, powerful tum. Saath me meditate kare?',
      ],
    },
    'neutral': {
      'english': [
        'What\'s on your mind? Tell me! 😊',
        'Hey there! Want to do something fun together?',
        'I\'m here whenever you need me. What\'s up?',
        'Ready for an adventure? Let\'s play! 🎮',
      ],
      'hindi': [
        'तुम्हारे मन में क्या चल रहा है? मुझे बताओ! 😊',
        'नमस्ते! क्या साथ में कुछ मनोरंजक करना चाहोगे?',
        'जब भी तुम्हें मेरी ज़रूरत हो, मैं यहाँ हूँ। क्या खबर है?',
        'साहसिक कार्य के लिए तैयार हो? चलो खेलते हैं! 🎮',
      ],
      'hinglish': [
        'Kya chal raha hai dimaag me? Batao! 😊',
        'Are! Kuch mazedaar karna hai saath me?',
        'Main hamesha yahaan hu. Kya ho raha hai?',
        'Adventure ke liye ready? Chal khelte hain! 🎮',
      ],
    },
  };

  static const Map<String, Map<String, List<String>>> _recommendations = {
    'sad': {
      'english': ['Want to try breathing exercises? They work wonders! 🌿', 'How about some calming music? 🎵', 'Let\'s play a game to lift your mood! 🎮'],
      'hindi': ['क्या श्वसन व्यायाम करना चाहोगे? यह चमत्कार की तरह काम करता है! 🌿', 'शांत संगीत सुनकर कैसा लगेगा? 🎵', 'चलो मन प्रसन्न करने के लिए एक खेल खेलते हैं! 🎮'],
      'hinglish': ['Breathing exercise try karoge? Bahut kaam aata hai! 🌿', 'Calm music sunna hai? 🎵', 'Chal game khelte hain mood lift karne! 🎮'],
    },
    'happy': {
      'english': ['How about a fun game to keep the energy high? 🎮', 'Want to journal this happy moment? 📝', 'Share this joy — try an affirmation! ✨'],
      'hindi': ['ऊर्जा को बनाए रखने के लिए एक मज़ेदार खेल कैसा रहेगा? 🎮', 'क्या इस सुखद क्षण को दैनिकी में लिखना चाहोगे? 📝', 'इस खुशी को साझा करें — एक प्रतिज्ञान (Affirmation) आजमाएं! ✨'],
      'hinglish': ['Ek fun game kaisa rahega? 🎮', 'Is khushi ko journal me likhna hai? 📝', 'Affirmation try karo, aur khushi badhegi! ✨'],
    },
    'anxious': {
      'english': ['Try the 5-4-3-2-1 grounding exercise! 🧘', 'Deep breathing can really help right now. 🌿', 'Want to listen to some calming sounds? 🎵'],
      'hindi': ['5-4-3-2-1 ग्राउंडिंग व्यायाम आजमाएं! 🧘', 'गहरी सांस लेना अभी वास्तव में मदद कर सकता है। 🌿', 'क्या कुछ शांत ध्वनियाँ सुनना चाहोगे? 🎵'],
      'hinglish': ['5-4-3-2-1 grounding exercise try karo! 🧘', 'Deep breathing abhi bahut help karega. 🌿', 'Calming sounds sunna hai? 🎵'],
    },
    'angry': {
      'english': ['Pop some thought bubbles? Great stress relief! 💭', 'Try the muscle relaxation exercise! 💪', 'A quick walk or stretch can help. How about a game?'],
      'hindi': ['कुछ विचार बुलबुले फोड़ें? तनाव से राहत के लिए बढ़िया है! 💭', 'मांसपेशियों को आराम देने वाले व्यायाम का प्रयास करें! 💪', 'एक छोटी सैर या कसरत मदद कर सकती है। खेल के बारे में क्या ख्याल है?'],
      'hinglish': ['Thought bubbles pop karo? Stress relief! 💭', 'Muscle relaxation try karo! 💪', 'Walk ya stretch karo. Ya game kheloge?'],
    },
    'calm': {
      'english': ['Perfect time for meditation! 🧘', 'Want to try some mindful games? 🎮', 'How about reading a wellness article? 📖'],
      'hindi': ['ध्यान लगाने का यह सही समय है! 🧘', 'क्या कुछ माइंडफुल खेल खेलना चाहोगे? 🎮', 'कल्याणकारी लेख पढ़ने के बारे में क्या विचार है? 📖'],
      'hinglish': ['Meditation ka perfect time! 🧘', 'Mindful games try karna hai? 🎮', 'Wellness article padhna hai? 📖'],
    },
    'neutral': {
      'english': ['How about exploring a new tool? 🛠️', 'Want to play a game with me? 🎮', 'Try logging your mood to track your journey! 📊'],
      'hindi': ['क्या किसी नए उपकरण को आज़माना चाहोगे? 🛠️', 'क्या मेरे साथ एक खेल खेलोगे? 🎮', 'अपनी यात्रा पर नज़र रखने के लिए अपनी मनःस्थिति दर्ज करें! 📊'],
      'hinglish': ['Koi naya tool explore karna hai? 🛠️', 'Mere saath game kheloge? 🎮', 'Mood log karo journey track karne! 📊'],
    },
  };

  static const Map<String, List<String>> _playNudges = {
    'english': [
      'Buddy misses you! Come play! 🐾',
      'Time to play with Buddy! 🎮',
      'Buddy wants to say hi! Come visit! 💕',
      'A quick game can brighten your day! 🌟',
      'Buddy is waiting for you! Let\'s have fun! 🎉',
    ],
    'hindi': [
      'आपका साथी आपको याद कर रहा है! आओ खेलें! 🐾',
      'साथी के साथ खेलने का समय! 🎮',
      'आपका साथी नमस्ते कहना चाहता है! मिलें! 💕',
      'एक त्वरित खेल आपके दिन को रोशन कर सकता है! 🌟',
      'आपका साथी इंतज़ार कर रहा है! चलो मज़ा करते हैं! 🎉',
    ],
    'hinglish': [
      'Buddy ko teri yaad aa rahi hai! Aao khelo! 🐾',
      'Buddy ke saath khelne ka time! 🎮',
      'Buddy hi bolna chahta hai! Aao! 💕',
      'Ek quick game din bana dega! 🌟',
      'Buddy intezaar kar raha hai! Let\'s have fun! 🎉',
    ],
  };

  static const Map<String, List<String>> _welcomeBack = {
    'english': [
      'You\'re back! I missed you! 💕',
      'Welcome back! Ready for some fun? 🎮',
      'Hey! Great to see you again! 🌟',
      'Yay! My favorite human is here! ✨',
    ],
    'hindi': [
      'तुम वापस आ गए! मुझे तुम्हारी याद आ रही थी! 💕',
      'वापस स्वागत है! क्या कुछ मनोरंजन के लिए तैयार हो? 🎮',
      'नमस्ते! तुम्हें फिर से देखकर बहुत खुशी हुई! 🌟',
      'वाह! मेरा पसंदीदा इंसान यहाँ है! ✨',
    ],
    'hinglish': [
      'Wapas aa gaye! Mujhe teri yaad aa rahi thi! 💕',
      'Welcome back! Fun ke liye ready? 🎮',
      'Are! Tumhe dekhke bahut khushi hui! 🌟',
      'Yes! Mera favorite insaan aa gaya! ✨',
    ],
  };
}
