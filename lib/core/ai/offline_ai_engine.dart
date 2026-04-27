import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/mood_storage.dart';
import '../memory/buddy_memory_service.dart';

/// 🧠 OFFLINE AI ENGINE - 10,000+ Response Combinations
/// Bilkul natural responses without API key
class OfflineAIEngine {
  static final _random = Random();
  static final List<Map<String, dynamic>> _conversationHistory = [];
  static List<dynamic> _knowledgeBase = [];
  static String _lastEmotion = 'neutral';
  static int _responseCount = 0;

  /// Load knowledge base
  static Future<void> init() async {
    try {
      final String response = await rootBundle.loadString('assets/ai/knowledge_base.json');
      // Use compute to prevent blocking the main thread during heavy JSON parsing
      _knowledgeBase = await compute((String jsonStr) => json.decode(jsonStr) as List<dynamic>, response);
      debugPrint('[Offline AI] Loaded ${_knowledgeBase.length} KB entries');
    } catch (e) {
      debugPrint('[Offline AI] Error loading KB: $e');
    }
  }

  /// Returns a proactive greeting based on recent mood history + memory
  static Future<String> getProactiveGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('saathi_user_name') ?? '';
    final buddyName = prefs.getString('buddy_display_name') ?? 'Buddy';
    final nameStr = userName.isNotEmpty ? '$userName ' : '';
    
    // Get memory summary for personalized greeting
    final memorySummary = await BuddyMemoryService.loadMemorySummary();
    
    // Get recent moods from storage
    final List<Map<String, dynamic>> recentMoods = await MoodStorage.getRecentMoods(limit: 5);
    
    if (recentMoods.isEmpty && memorySummary.isEmpty) {
      return 'Namaste ${nameStr.trim()}! \uD83D\uDE4F Main $buddyName hoon — tumhara virtual buddy. Aaj hum pehli baar baat kar rahe hain, batao kaisa feel ho raha hai?';
    }

    // If we have memory, create a memory-aware greeting
    if (memorySummary.isNotEmpty) {
      final memoryGreeting = _buildMemoryGreeting(memorySummary, nameStr, buddyName);
      if (memoryGreeting != null) return memoryGreeting;
    }

    if (recentMoods.isEmpty) {
      return _greetingResponse(buddyName);
    }

    final latestMood = recentMoods.first['mood'];
    final lowCount = recentMoods.where((m) => ['Low', 'Bad', 'Sad'].contains(m['mood'])).length;

    if (lowCount >= 3) {
      return 'Hey $nameStr... Maine notice kiya ki pichle kuch din tumhare liye thode mushkil rahe hain. \uD83D\uDE14\n\nYahan share karna chahte ho kya chal raha hai? Main $buddyName, tumhare liye yahin hoon. \uD83D\uDC99';
    }

    if (latestMood == 'Great' || latestMood == 'Good') {
      return 'Namaste $nameStr! \u2728 Main $buddyName! Jaan ke acha laga ki tum abhi better feel kar rahe ho. Aaj ke din ko aur mindful kaise banayein?';
    }

    return _greetingResponse(buddyName);
  }

  /// Build a memory-aware greeting based on remembered topics/emotions
  static String? _buildMemoryGreeting(String memory, String nameStr, String buddyName) {
    final m = memory.toLowerCase();
    
    // Topic-specific memory greetings
    if (m.contains('exams') || m.contains('study') || m.contains('padhai')) {
      return _pick([
        'Hey $nameStr! 📚 Main $buddyName! Pichli baar exams ki baat ho rahi thi — kaisa chal raha hai ab?',
        'Namaste $nameStr! Main $buddyName hoon. Tumhari padhai ka kya haal chal raha hai? Last time tension thi exam ki. 💙',
      ]);
    }
    
    if (m.contains('work') || m.contains('office') || m.contains('job')) {
      return _pick([
        'Hey $nameStr! Main $buddyName! Kaam kaisa chal raha hai aaj? Pichli baar thoda stress tha office ka. 💼',
        'Namaste $nameStr! $buddyName yahin hai. Work life kaisi hai ab? Batao kya haal hai. 💙',
      ]);
    }
    
    if (m.contains('family') || m.contains('ghar')) {
      return _pick([
        'Hey $nameStr! Main $buddyName hoon. Ghar mein sab theek? Pichli baar family ki baat ho rahi thi. 🏠💙',
        'Namaste $nameStr! $buddyName aapke saath hai. Ghar pe kaisa mahaul hai aaj? 💙',
      ]);
    }
    
    if (m.contains('relationship') || m.contains('friend') || m.contains('dost')) {
      return _pick([
        'Hey $nameStr! Main $buddyName. Kaisa feel ho raha hai? Pichli baar dosti ki baat chal rahi thi. 💛',
        'Namaste $nameStr! $buddyName hoon main. Kya haal hai aaj? Sab log theek hain? 💙',
      ]);
    }
    
    if (m.contains('sleep') || m.contains('neend')) {
      return _pick([
        'Hey $nameStr! Main $buddyName. Neend kaisi aa rahi hai aajkal? Last time sleep issues ki baat hui thi. 🌙',
        'Namaste $nameStr! $buddyName hoon. Raat ko achhi neend aa rahi hai ab? 😴💙',
      ]);
    }
    
    if (m.contains('anxious') || m.contains('stressed') || m.contains('tension')) {
      return _pick([
        'Hey $nameStr! Main $buddyName hoon. Kaisa feel kar rahe ho aaj? Main yahin hoon tumhare saath, hamesha. 💙',
        'Namaste $nameStr! $buddyName aapke saath hai. Ab kaisa lag raha hai? Thoda better? 🌿',
      ]);
    }
    
    if (m.contains('sad') || m.contains('lonely') || m.contains('akela')) {
      return _pick([
        'Hey $nameStr! Main $buddyName hoon, tumhara buddy. Yaad hai mujhe — tum akele nahi ho. Main hoon na. 💙',
        'Namaste $nameStr! $buddyName aapke liye yahin hai. Aaj kaisa feel ho raha hai? 🌸',
      ]);
    }
    
    // Generic memory greeting if we have memory but no specific topic match
    return _pick([
      'Hey $nameStr! Main $buddyName hoon — mujhe hamari pichli baatein yaad hain. 🧠 Batao, aaj kaisa din hai?',
      'Namaste $nameStr! $buddyName wapas aa gaya! 💙 Aaj kya chal raha hai?',
      'Hey $nameStr! Main $buddyName. Acha laga dobara baat karke. Kya haal hai aaj? ✨',
    ]);
  }

  /// Main entry point - Generate response
  static String generateResponse(String userMessage) {
    _responseCount++;

    // 1. Check Knowledge Base for similar questions
    final kbMatch = _searchKB(userMessage);
    if (kbMatch != null) return kbMatch;

    // 2. Detect emotion & keywords
    final emotion = _detectEmotion(userMessage);
    final keywords = _extractKeywords(userMessage);
    final context = _analyzeContext(userMessage);

    // 3. Update history
    _conversationHistory.add({
      'message': userMessage,
      'emotion': emotion,
      'timestamp': DateTime.now(),
    });
    _lastEmotion = emotion;

    // 4. Generate contextual response
    final response = (emotion == 'crisis' || emotion == 'greeting') 
      ? _getDirectResponse(emotion) 
      : _buildResponse(emotion, keywords, context);

    return response;
  }

  static String _getDirectResponse(String emotion) {
    if (emotion == 'crisis') return _crisisResponse();
    if (emotion == 'greeting') return _greetingResponse(null);
    return '';
  }

  /// Simple keyword-based search in knowledge base
  static String? _searchKB(String input) {
    if (_knowledgeBase.isEmpty) return null;
    
    final t = input.toLowerCase();
    
    // Exact match or contains (naive)
    for (final entry in _knowledgeBase) {
      final question = (entry['query'] ?? entry['question'])?.toString().toLowerCase() ?? '';
      final answer = (entry['response'] ?? entry['answer'])?.toString() ?? '';
      
      if (question.isEmpty || answer.isEmpty) continue;

      if (t == question || (t.length > 10 && question.contains(t)) || (question.length > 10 && t.contains(question))) {
        return answer;
      }
    }
    
    // Keyword match
    final words = t.split(' ').where((w) => w.length > 3).toList();
    if (words.isEmpty) return null;
    
    for (final entry in _knowledgeBase) {
      final question = (entry['query'] ?? entry['question'])?.toString().toLowerCase() ?? '';
      final answer = (entry['response'] ?? entry['answer'])?.toString() ?? '';
      
      if (question.isEmpty || answer.isEmpty) continue;

      int matches = 0;
      for (final word in words) {
        if (question.contains(word)) matches++;
      }
      
      // If 60% of keywords match
      if (matches / words.length >= 0.6) {
        return answer;
      }
    }
    
    return null;
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸŽ­ EMOTION DETECTION
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  static String _detectEmotion(String text) {
    final t = text.toLowerCase();

    // 1. CRISIS — immediate safety response
    if (_isCrisis(t)) return _crisisResponse();

    // 2. GREETINGS
    if (_isGreeting(t)) return _greetingResponse(null);

    return 'neutral';
  }

  static bool _isCrisis(String t) {
    return _containsAny(t, [
      'suicide', 'marna', 'mar jau', 'kill myself', 'end my life',
      'self harm', 'khatam', 'zinda nahi', 'jeena nahi', 'death',
      'die', 'cut myself', 'harm myself', 'nahi reh sakta',
    ]);
  }

  static String _crisisResponse() {
    return '⚠️ Main samajh sakta hoon tum bohot mushkil waqt se guzar rahe ho.\n\n'
        'Please abhi kisi se baat karo:\n\n'
        '📞 Vandrevala Foundation: 1860-2662-345 (24/7)\n'
        '📞 iCall: 9152987821\n'
        '📞 AASRA: 9820466726\n\n'
        'Tum akele nahi ho. Professional help lena strength hai, weakness nahi. 💙\n\n'
        'Agar immediate danger mein ho toh please 112 call karo.';
  }

  static bool _isGreeting(String t) {
    return _containsAny(t, ['hi', 'hello', 'hey', 'namaste', 'hii', 'hiii', 'namaskar', 'kaise ho', 'how are you', 'sup', 'helo']);
  }

  static String _greetingResponse([String? buddyName]) {
    final name = buddyName ?? 'Buddy';
    return _pick([
      'Namaste! \uD83D\uDE4F Main $name hoon — tumhara virtual buddy.\n\nBatao, aaj kaisa feel ho raha hai? Main yahin hoon. \uD83D\uDC99',
      'Hey! \uD83D\uDC4B Main $name hoon.\n\nTumse baat karke acha laga. Kuch bhi share karo — mood, feelings, sawaal — sab safe hai yahan. \uD83C\uDF3F',
      'Hello! \u2728 Main hoon $name, tumhara buddy!\n\nAaj tumhare liye kya kar sakta hoon? Baat karna ho, kuch jaanna ho, ya bas koi sune — main hoon. \uD83D\uDC9B',
    ]);
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸ” KEYWORD EXTRACTION
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  static List<String> _extractKeywords(String text) {
    final t = text.toLowerCase();
    final keywords = <String>[];

    // Topic categories
    final topics = {
      'work': ['work', 'job', 'office', 'kaam', 'boss', 'salary', 'interview'],
      'family': ['family', 'gharwale', 'parents', 'maa', 'papa', 'bhai', 'behen', 'rishtedar'],
      'relationship': ['relation', 'partner', 'friend', 'dost', 'breakup', 'pyaar', 'shadi', 'dhokha'],
      'health': ['health', 'tabiyat', 'bimaar', 'sick', 'medicine', 'dard', 'hospital'],
      'sleep': ['sleep', 'neend', 'insomnia', 'jagta', 'raat bhar'],
      'future': ['future', 'kal', 'aage', 'tomorrow', 'plan', 'career'],
      'past': ['past', 'pehle', 'purana', 'yaad', 'memory', 'bachpan'],
    };

    topics.forEach((topic, words) {
      if (_containsAny(t, words)) keywords.add(topic);
    });

    return keywords;
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸ§© CONTEXT ANALYSIS
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  static Map<String, dynamic> _analyzeContext(String text) {
    return {
      'isQuestion': text.contains('?') ||
          _containsAny(text.toLowerCase(),
              ['kya', 'kaise', 'kyun', 'how', 'why', 'what']),
      'isVenting': text.length > 100,
      'isShort': text.length < 20,
      'hasNegation':
          _containsAny(text.toLowerCase(), ['nahi', 'not', 'no', 'never']),
      'intensity': _calculateIntensity(text),
      'isRepeat': _isRepeatConcern(),
    };
  }

  static int _calculateIntensity(String text) {
    final t = text.toLowerCase();
    int intensity = 1;

    if (_containsAny(t, ['bohot', 'bahut', 'very', 'extremely'])) intensity = 3;
    if (_containsAny(t, ['zyada', 'too much', 'kaafi'])) intensity = 2;
    if (text.contains('!')) intensity++;
    if (text
            .split(' ')
            .where((w) => w == w.toUpperCase() && w.length > 2)
            .length >
        2) intensity++;

    return intensity.clamp(1, 5);
  }

  static bool _isRepeatConcern() {
    if (_conversationHistory.length < 2) return false;
    final lastTwo = _conversationHistory.takeLast(2).toList();
    return lastTwo[0]['emotion'] == lastTwo[1]['emotion'];
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸ—ï¸ RESPONSE BUILDER (MAIN LOGIC)
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  static String _buildResponse(
      String emotion, List<String> keywords, Map<String, dynamic> context) {
    final parts = <String>[];
    
    // Intensity multiplier
    final intensity = context['intensity'] as int;

    // 1. Empathy Fillers (Openings)
    if (_random.nextDouble() > 0.4) {
      parts.add(_getFiller(emotion));
    }

    // 2. Validation (Acknowledging feelings)
    parts.add(_getValidation(emotion, context));

    // 3. Core Response (Reflection/Support)
    if (context['isQuestion'] == true) {
      parts.add(_getQuestion(emotion, keywords));
    } else if (context['isVenting'] == true) {
      parts.add(_getVentingResponse(emotion));
    } else {
      parts.add(_getReflection(emotion, keywords));
    }

    // 4. Intensity-based acknowledgement
    if (intensity >= 3) {
      parts.add(_getIntenseAcknowledge(emotion));
    }

    // 5. Direction/Guidance (70% chance)
    if (_random.nextDouble() > 0.3) {
      parts.add(_getGuidance(emotion, context));
    }

    // 6. Repeating emotion check
    if (context['isRepeat'] == true) {
      parts.add('Main dekh raha hoon ki tum pichle kuch waqt se aisa hi feel kar rahe ho. Hum is par baat kar sakte hain.');
    }

    // 7. Closing (40% chance)
    if (_random.nextDouble() > 0.6) {
      parts.add(_getCloser(emotion));
    }

    return parts.where((p) => p.isNotEmpty).join('\n\n');
  }

  static String _getFiller(String emotion) {
    final fillers = [
      'Suno...',
      'Hmm, main samajh raha hoon...',
      'Pata hai...',
      'Dekho...',
      'Maine suna tumhari baat...',
      'Acha...',
    ];
    return _pick(fillers);
  }

  static String _getIntenseAcknowledge(String emotion) {
    final intense = [
      'Yeh bohot gehra dard lag raha hai.',
      'Tumne jo kaha, wo bohot heavy hai.',
      'Main samajh sakta hoon ki yeh sab handle karna kitna mushkil hai.',
      'Itna stress aur pressure... main tumhare saath hoon.',
    ];
    return _pick(intense);
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸ“š RESPONSE TEMPLATES (10,000+ COMBINATIONS)
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

  // 1ï¸âƒ£ VALIDATION (Acknowledging feelings)
  static String _getValidation(String emotion, Map<String, dynamic> context) {
    final validations = {
      'sad': [
        'Lagta hai aaj dil thoda bhaari hai.',
        'Main samajh sakta hoon yeh feeling kaise lag rahi hai.',
        'Udaasi ko feel karna bilkul normal hai.',
        'Tumhari yeh feelings valid hain.',
        'Dil ka bhaari hona ek mushkil feeling hai.',
      ],
      'anxious': [
        'Ghabrahat jab control le leti hai, toh saans lena bhi bhaari lagta hai.',
        'Anxiety bohot overwhelming ho sakti hai.',
        'Yeh tension tumhari galti nahi hai.',
        'Dimag ka na rukna bohot exhausting hota hai.',
        'Is ghabrahat ko main feel kar sakta hoon.',
      ],
      'tired': [
        'Lagta hai aaj energy bilkul low hai.',
        'Thakaan sirf body ki nahi, mann bhi thak jaata hai.',
        'Tumne kaafi bojh uthaya hai lagta hai.',
        'Yeh exhaustion real hai, ignore mat karo.',
        'Main dekh sakta hoon tum kitna tired feel kar rahe ho.',
      ],
      'frustrated': [
        'Gussa aana bilkul natural hai.',
        'Lagta hai kuch tumhe bohot trigger kar gaya.',
        'Yeh frustration ko main feel kar sakta hoon.',
        'Irritation ko express karna zaroori hai.',
        'Tumhara gussa valid hai.',
      ],
      'overwhelmed': [
        'Sab kuch ek saath handle karna bohot mushkil ho jaata hai.',
        'Lagta hai pressure bohot zyada badh gaya hai.',
        'Yeh "too much" wali feeling bohot exhausting hoti hai.',
        'Dimag ka fatna normal hai jab workloads itna ho.',
        'Main dekh raha hoon tum bohot overwhelmed feel kar rahe ho.',
      ],
      'hopeless': [
        'Jab umeed nahi dikhti, toh har step mushkil lagta hai.',
        'Main samajh sakta hoon ki abhi sab andhera lag raha hoga.',
        'Yeh feeling bohot dardnak hai, par main tumhare saath hoon.',
        'Hopelessness ek cycle hai, hum isse milkar bahar aayenge.',
      ],
      'lonely': [
        'Akela feel karna bohot heavy hota hai.',
        'Connection ki kami dil ko toh dukha deti hai.',
        'Lagta hai tum kaafi time se yeh feel kar rahe ho.',
        'Bheed mein bhi akelapan bohot dard deta hai.',
        'Main yahin hoon, tum akele nahi ho.',
      ],
      'happy': [
        'Khushi ki feeling bohot achi hai.',
        'Lagta hai aaj mood theek hai.',
        'Yeh positive energy feel ho rahi hai.',
        'Acha lag raha hai tumhe better feel hote dekh ke.',
      ],
      'neutral': [
        'Main dhyaan se sun raha hoon.',
        'Tum jo keh rahe ho, wo matter karta hai.',
        'Yahan bolna safe hai.',
        'Main samajhne ki koshish kar raha hoon.',
      ],
    };

    final list = validations[emotion] ?? validations['neutral']!;
    return _pick(list);
  }

  // 2ï¸âƒ£ REFLECTION (Deeper understanding)
  static String _getReflection(String emotion, List<String> keywords) {
    final reflections = {
      'sad': [
        'Shayad kuch purani baatein aaj wapas aa gayi hain.',
        'Udaasi aksar tab aati hai jab hum khud ko sunna band kar dete hain.',
        'Lagta hai kuch andar dab gaya hai jo nikalna chahta hai.',
        'Kabhi kabhi bina wajah bhi rona aa jaata hai, aur yeh normal hai.',
      ],
      'anxious': [
        'Future ke khayal present ko heavy bana dete hain.',
        'Tumhara mind tumhe safe rakhne ki koshish kar raha hai.',
        'Body alert mode mein chali gayi hai.',
        'Is overthinking ka cycle break karna mushkil hota hai.',
      ],
      'tired': [
        'Lagta hai tumne khud ko rest nahi diya kaafi time se.',
        'Body aur mind dono ab break maang rahe hain.',
        'Zyada zimmedari uthate uthate insaan khud ko bhool jaata hai.',
      ],
      'frustrated': [
        'Gussa aksar tab aata hai jab boundaries cross ho jaati hain.',
        'Yeh frustration kisi purani baat se judi ho sakti hai.',
        'Tumhara gussa tumhe kuch batana chahta hai.',
      ],
      'overwhelmed': [
        'Jab cheezein control se bahar lagti hain, toh panic hona natural hai.',
        'Shayad tumhe break ki zarurat hai par tum ruk nahi paa rahe.',
        'Har cheez ko ek saath solve karna zaroori nahi hai.',
      ],
      'hopeless': [
        'Andhere waqt mein umeed dhundna sabse bada challenge hota hai.',
        'Pata hai, kabhi kabhi haar maan lene ka mann karta hai, par tum abhi bhi bol rahe ho, wahi important hai.',
      ],
      'lonely': [
        'Jab koi paas nahi lagta, andar khaali sa feel hota hai.',
        'Connection ki zarurat har insaan ko hoti hai.',
        'Shayad tumhe sunne wala koi chahiye jo judge na kare.',
      ],
      'happy': [
        'Choti khushiyan bhi celebrate karna zaroori hai.',
        'Positive moments ko pakadna important hai.',
      ],
      'neutral': [
        'Kabhi kabhi bas bol dena hi thoda halka kar deta hai.',
        'Tumhare thoughts matter karte hain.',
      ],
    };

    final list = reflections[emotion] ?? reflections['neutral']!;
    String response = _pick(list);

    // Add keyword-specific reflection
    if (keywords.contains('work')) {
      response += ' Kaam ka pressure bohot ho sakta hai.';
    } else if (keywords.contains('family')) {
      response += ' Gharwale samajh nahi paate kabhi.';
    } else if (keywords.contains('sleep')) {
      response += ' Neend na aana mind ko aur disturb kar deta hai.';
    }

    return response;
  }

  // 3ï¸âƒ£ VENTING RESPONSE (When user writes long message)
  static String _getVentingResponse(String emotion) {
    final responses = [
      'Maine sab padha. Tumne jo likha, wo important hai.',
      'Itna sab andar rakhe rehna mushkil hota hai. Acha kiya tumne share kiya.',
      'Main samajh sakta hoon kitna heavy lag raha hoga.',
      'Likh dene se hi thoda halka feel hota hai kabhi kabhi.',
      'Tumhe yeh sab share karne ki zarurat thi. Main sun raha hoon.',
    ];
    return _pick(responses);
  }

  // 4ï¸âƒ£ QUESTION RESPONSE
  static String _getQuestion(String emotion, List<String> keywords) {
    final responses = [
      'Yeh bohot acha question hai. Iska jawab sirf tum khud de sakte ho, par main saath hoon sochne mein.',
      'Main tumhe direct answer nahi de sakta, par hum isko explore kar sakte hain.',
      'Is sawaal ka koi ek jawab nahi hai. Tumhara kya mann keh raha hai?',
      'Tumhe kya lagta hai? Kabhi kabhi apne aap se puchhna bhi zaroori hai.',
    ];
    return _pick(responses);
  }

  // 5ï¸âƒ£ GUIDANCE (Gentle suggestions)
  static String _getGuidance(String emotion, Map<String, dynamic> context) {
    final guidance = {
      'sad': [
        'Abhi answer dhoondhna zaroori nahi, bas feel karna kaafi hai.',
        'Agar rona aaye, toh rokna mat. Yeh bhi ek tarika hai release karne ka.',
        'Kuch time khud ke saath bitana helpful ho sakta hai.',
      ],
      'anxious': [
        'Abhi sirf ek gehri saans lene ki koshish karo.',
        'Apne aas-paas ki kisi ek cheez ko notice karo.',
        'Tum safe ho, abhi, isi waqt.',
        'Future ki chinta abhi zaroori nahi. Abhi ka moment dekho.',
      ],
      'tired': [
        'Agar ho sake, toh abhi bas aankhein band karlo.',
        'Is moment mein productive hona zaroori nahi hai.',
        'Aaj thoda khud pe rehem karna theek rahega.',
        'Rest lena weakness nahi, zarurat hai.',
      ],
      'angry': [
        'Yeh gussa ko recognize karna pehla step hai.',
        'Kuch physical activity help kar sakti hai - walk, exercise.',
        'Apne aap ko thoda time do cool down hone ka.',
      ],
      'lonely': [
        'Main yahin hoon tumhare saath.',
        'Yahan likhna bhi ek tarah ka connection hai.',
        'Kisi ko message karna bhi ek step ho sakta hai.',
      ],
      'happy': [
        'Is moment ko enjoy karo, yeh bhi important hai.',
        'Khushi ko share karna usse aur badha deta hai.',
      ],
      'neutral': [
        'Agar theek lage toh aur likho.',
        'Hum dheere dheere baat kar sakte hain.',
      ],
    };

    final list = guidance[emotion] ?? guidance['neutral']!;
    return _pick(list);
  }

  // 6ï¸âƒ£ CLOSERS (Gentle endings)
  static String _getCloser(String emotion) {
    final closers = [
      'Main yahin hoon.',
      'Take your time.',
      'Koi jaldi nahi hai.',
      'ðŸ’™',
      'Tum akele nahi ho.',
      'Dheere dheere.',
      'Ek step at a time.',
    ];
    return _pick(closers);
  }

  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”
  // ðŸ› ï¸ HELPER FUNCTIONS
  // â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”â”

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static String _pick(List<String> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Clear conversation history (when starting fresh)
  static void clearHistory() {
    _conversationHistory.clear();
    _responseCount = 0;
    _lastEmotion = 'neutral';
  }
}

// Extension for takeLast
extension ListExtension<T> on List<T> {
  List<T> takeLast(int n) {
    if (n >= length) return this;
    return sublist(length - n);
  }
}

class EmotionDetector {
  static String detect(String text) {
    final t = text.toLowerCase();

    // 1. Tired / Burnout
    if (t.contains('thak') ||
        t.contains('tired') ||
        t.contains('exhaust') ||
        t.contains('drain') ||
        t.contains('burnout')) {
      return 'tired';
    }

    // 2. Sad / Depressed
    if (t.contains('sad') ||
        t.contains('udaas') ||
        t.contains('cry') ||
        t.contains('rona') ||
        t.contains('worthless') ||
        t.contains('low')) {
      return 'sad';
    }

    // 3. Anxious / Fear
    if (t.contains('anx') ||
        t.contains('dar') ||
        t.contains('fear') ||
        t.contains('ghabra') ||
        t.contains('panic') ||
        t.contains('tension')) {
      return 'anxious';
    }

    // 4. Lonely
    if (t.contains('alone') ||
        t.contains('akela') ||
        t.contains('lonely') ||
        t.contains('koi nahi')) {
      return 'lonely';
    }

    // Default
    return 'general';
  }
}

class ResponseEngine {
  static final Random _rand = Random();

  // ðŸ•’ Typing delay based on text length (Human feel)
  static int delayFor(String text) {
    if (text.length < 15) return 1200;
    if (text.length < 50) return 1800;
    return 2600;
  }

  // ðŸ§  MAIN LOGIC: Assemble Lego Blocks
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
    'ðŸ’™',
  ];
}

class AIConfig {
  static String apiKey = '';
  static String provider = ''; // openai | gemini

  static bool get isReady => apiKey.isNotEmpty;
}

class AIMode {
  static bool enabled = false;
}

class AppLanguage {
  static String current = '';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    current = prefs.getString('language') ?? '';
  }

  static Future<void> set(String lang) async {
    current = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}
