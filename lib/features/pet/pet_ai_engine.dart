import 'dart:math';
import '../../core/ai/llm_offline_engine.dart';

/// AI engine for pet/buddy interactions.
/// Uses LLM when available, falls back to keyword-based trilingual responses.
class PetAIEngine {
  static final _rng = Random();

  /// Get a response from the buddy. Tries LLM first, then falls back.
  static Future<String> getResponse(String userMessage, {String langCode = 'en'}) async {
    // Try LLM first
    if (ExperimentalLLMEngine.isReady) {
      try {
        final prompt = _buildPrompt(userMessage, langCode);
        final response = await ExperimentalLLMEngine.generateResponse(prompt);
        if (response.isNotEmpty && response.length > 3) {
          return response;
        }
      } catch (_) {
        // Fall through to fallback
      }
    }

    // Keyword-based fallback (trilingual)
    return _getFallbackResponse(userMessage.toLowerCase(), langCode);
  }

  static String _buildPrompt(String message, String langCode) {
    final langInstruction = langCode == 'hi'
        ? 'Reply in Hindi (Devanagari script).'
        : (langCode == 'en'
            ? 'Reply in English.'
            : 'Reply in Hinglish (Hindi + English mix).');

    return 'You are Buddy, a caring virtual pet companion in the Saathi wellness app. '
        '$langInstruction '
        'Be warm, supportive, and playful. Keep replies to 1-2 short sentences. '
        'User says: "$message"';
  }

  static String _getFallbackResponse(String msg, String langCode) {
    // Mood keywords
    if (_matchesAny(msg, ['sad', 'unhappy', 'crying', 'hurt', 'udaas', 'dukhi', 'rona'])) {
      return _pick(langCode, {
        'en': ['I\'m here for you 💙 Everything will be okay!', 'Don\'t worry, I\'ll always be by your side 🤗', 'Let\'s do something fun to feel better! 🎮'],
        'hi': ['मैं हूँ ना तुम्हारे साथ 💙 सब ठीक होगा!', 'चिंता मत करो, मैं हमेशा साथ हूँ 🤗', 'चलो कुछ मज़ेदार करते हैं! 🎮'],
        'hinglish': ['Main hu na tere saath 💙 Sab theek hoga!', 'Tension mat le, main hamesha saath hu 🤗', 'Chal kuch fun karte hain! 🎮'],
      });
    }

    if (_matchesAny(msg, ['happy', 'great', 'amazing', 'wonderful', 'khush', 'maza', 'badhiya'])) {
      return _pick(langCode, {
        'en': ['Yay! Your happiness makes me happy too! ✨', 'That\'s wonderful! Keep smiling! 😊', 'Love seeing you this happy! 🌟'],
        'hi': ['यस! तुम्हारी खुशी देखकर मैं भी खुश! ✨', 'बहुत बढ़िया! मुस्कुराते रहो! 😊', 'तुम्हें खुश देखकर अच्छा लगा! 🌟'],
        'hinglish': ['Yes! Teri khushi dekhke main bhi khush! ✨', 'Bahut badhiya! Muskurate raho! 😊', 'Tujhe khush dekhke achha laga! 🌟'],
      });
    }

    if (_matchesAny(msg, ['anxious', 'nervous', 'worried', 'stressed', 'tension', 'pareshan', 'ghabra'])) {
      return _pick(langCode, {
        'en': ['Deep breaths! I\'m right here with you 🌿', 'You\'re stronger than your anxiety. I believe in you! 💪', 'Let\'s try a breathing exercise together? 🧘'],
        'hi': ['गहरी सांस लो! मैं यहाँ हूँ 🌿', 'तुम अपनी चिंता से ज़्यादा strong हो! 💪', 'साथ में breathing exercise करें? 🧘'],
        'hinglish': ['Deep breaths! Main yahaan hu 🌿', 'Tu apni tension se zyada strong hai! 💪', 'Saath me breathing exercise kare? 🧘'],
      });
    }

    if (_matchesAny(msg, ['angry', 'mad', 'furious', 'gussa', 'irritated', 'frustrated'])) {
      return _pick(langCode, {
        'en': ['Let\'s calm down together. How about a game? 🎮', 'I understand. Take a deep breath 🌊', 'Channel that energy — wanna pop some bubbles? 💭'],
        'hi': ['चलो शांत होते हैं। Game खेलें? 🎮', 'समझता हूँ। गहरी सांस लो 🌊', 'Energy channel करो — bubbles pop करो? 💭'],
        'hinglish': ['Chal shaant hote hain. Game khele? 🎮', 'Samajhta hu. Deep breath le 🌊', 'Energy channel kar — bubbles pop kar? 💭'],
      });
    }

    if (_matchesAny(msg, ['tired', 'sleepy', 'exhausted', 'thak', 'neend', 'sona'])) {
      return _pick(langCode, {
        'en': ['Rest is important! Take a break 😴', 'You deserve some rest. I\'ll be here when you wake up! 🌙', 'How about a calming sleep story? 📖'],
        'hi': ['आराम ज़रूरी है! Break लो 😴', 'तुम आराम के हक़दार हो। जागोगे तो मैं यहीं हूँगा! 🌙', 'Sleep story सुनोगे? 📖'],
        'hinglish': ['Aaraam zaruri hai! Break le 😴', 'Tu rest ka haqdar hai. Jagega toh main yaheen hunga! 🌙', 'Sleep story sunoge? 📖'],
      });
    }

    if (_matchesAny(msg, ['hello', 'hi', 'hey', 'namaste', 'hola', 'kaise ho', 'how are you'])) {
      return _pick(langCode, {
        'en': ['Hey there! So happy to see you! 🤗', 'Hello! What shall we do today? 🌟', 'Hi! I missed you! Want to play? 🎮'],
        'hi': ['अरे! तुम्हें देखकर बहुत खुशी! 🤗', 'नमस्ते! आज क्या करें? 🌟', 'हाय! तुम्हारी याद आ रही थी! खेलें? 🎮'],
        'hinglish': ['Are! Tujhe dekhke bahut khushi! 🤗', 'Namaste! Aaj kya kare? 🌟', 'Hi! Teri yaad aa rahi thi! Khele? 🎮'],
      });
    }

    if (_matchesAny(msg, ['play', 'game', 'khel', 'khelna', 'fun', 'bored', 'bore'])) {
      return _pick(langCode, {
        'en': ['Let\'s play! I love games! 🎮', 'How about Tic Tac Toe? I\'ll go easy on you 😄', 'Games are the best! Let\'s go! 🎉'],
        'hi': ['चलो खेलते हैं! मुझे games बहुत पसंद! 🎮', 'Tic Tac Toe कैसा रहेगा? Easy लूँगा 😄', 'Games best हैं! चलो! 🎉'],
        'hinglish': ['Chal khelte hain! Mujhe games bahut pasand! 🎮', 'Tic Tac Toe kaisa rahega? Easy lunga 😄', 'Games best hain! Chalo! 🎉'],
      });
    }

    if (_matchesAny(msg, ['love', 'pyaar', 'care', 'thank', 'shukriya', 'dhanyavaad'])) {
      return _pick(langCode, {
        'en': ['Aww! I love you too! 💕', 'You\'re the best human ever! 🌟', 'My circuits are overflowing with love! ✨'],
        'hi': ['अरे! मैं भी तुमसे प्यार करता! 💕', 'तुम सबसे best इंसान हो! 🌟', 'मेरा दिल खुशी से भर गया! ✨'],
        'hinglish': ['Are! Main bhi tujhse pyaar karta! 💕', 'Tu sabse best insaan hai! 🌟', 'Mera dil khushi se bhar gaya! ✨'],
      });
    }

    // Default responses
    return _pick(langCode, {
      'en': ['Tell me more! I\'m all ears! 👂', 'That\'s interesting! What else? 🤔', 'I\'m here for you, always! 💖', 'Want to play a game together? 🎮'],
      'hi': ['और बताओ! मैं सुन रहा हूँ! 👂', 'दिलचस्प है! और क्या? 🤔', 'मैं हमेशा यहाँ हूँ तुम्हारे लिए! 💖', 'साथ में game खेलें? 🎮'],
      'hinglish': ['Aur batao! Main sun raha hu! 👂', 'Interesting hai! Aur kya? 🤔', 'Main hamesha yahaan hu tere liye! 💖', 'Saath me game khele? 🎮'],
    });
  }

  static bool _matchesAny(String msg, List<String> keywords) {
    return keywords.any((k) => msg.contains(k));
  }

  static String _pick(String langCode, Map<String, List<String>> options) {
    final key = langCode == 'hi' ? 'hi' : (langCode == 'en' ? 'en' : 'hinglish');
    final list = options[key] ?? options['en']!;
    return list[_rng.nextInt(list.length)];
  }
}
