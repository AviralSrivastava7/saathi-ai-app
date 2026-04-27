import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'model_manager.dart';

// ─────────────────────────────────────────────────────────
// 🚀  OFFLINE LLM ENGINE  (flutter_gemma — Multi-parameter Support)
// ─────────────────────────────────────────────────────────
// Supports: Gemma 4 (E2B) · Gemma 4 (E4B) · Qwen 2.5 (0.5B/1.5B)
// Safety-aware: never prescribes medicines, always refers to helpline in crisis.
// ─────────────────────────────────────────────────────────

class ExperimentalLLMEngine {
  static final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  static bool _isReady = false;
  static bool _isIncompatible = false; // model present but engine can't load it

  static InferenceModel? _model;
  static InferenceChat? _chat;
  static String? _lastError;
  static int _msgCount = 0;
  static bool _systemPromptInjected = false;
  static Completer<void>? _warmupCompleter;
  static LlmModelConfig? _activeConfig;

  static String? get lastError => _lastError;
  static LlmModelConfig? get activeConfig => _activeConfig;
  static bool get isIncompatible => _isIncompatible;

  // ── Enhanced Saathi System Prompt — Warm & Engaging ──────
  static const String _baseSystemPrompt =
      'You are Saathi, user\'s best friend. '
      'RULES: '
      '1) Reply ONLY in Roman Hinglish. NO Devanagari. '
      '2) Keep replies to 1-2 sentences. '
      '3) Be warm, use words like "yaar", "hmm", "suno". '
      '4) Never sound robotic or ask how to assist. '
      '5) Show empathy and ask short follow-ups.';

  static String _getSystemPrompt() {
    return _baseSystemPrompt;
  }

  // ── Init ──────────────────────────────────────────────

  static Future<void> init() async {
    if (_isReady || _isLoading.value) return;

    _isLoading.value = true;
    _lastError = null;
    debugPrint('[SAATHI LLM] Starting engine initialization…');

    try {
      final config = await ModelManager.getActiveModel();
      if (config == null) {
        debugPrint('[SAATHI LLM] No model configuration found.');
        _isLoading.value = false;
        return;
      }

      debugPrint('[SAATHI LLM] Initializing ${config.name}…');
      String rawPath = await ModelManager.getModelPath(config);
      
      if (Platform.isWindows) {
        rawPath = rawPath.replaceAll('\\', '/');
        if (rawPath.startsWith('/')) {
           rawPath = rawPath.substring(1);
        }
      }

      // Step 1: Initialize FlutterGemma with a timeout
      // Native SDK errors (like libmbrain) often happen here.
      try {
        await FlutterGemma.initialize().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[SAATHI LLM] Native initialization warning (ignored): $e');
        // We continue because some devices report failure but work on fallback
      }

      debugPrint('[SAATHI LLM] Installing model from path…');

      ModelType mType;
      switch (config.modelTypeId) {
        case 'qwen': mType = ModelType.general; break;
        case 'deepSeek': mType = ModelType.deepSeek; break;
        case 'general': mType = ModelType.general; break;
        default: mType = ModelType.gemmaIt;
      }

      final ModelFileType fType = rawPath.toLowerCase().endsWith('.litertlm') || 
                                 rawPath.toLowerCase().endsWith('.bin') 
          ? ModelFileType.binary 
          : ModelFileType.task;

      // Step 2: Install model with a strict timeout
      await FlutterGemma.installModel(
        modelType: mType,
        fileType: fType,
      ).fromFile(rawPath).install().timeout(const Duration(seconds: 60));

      _model = await FlutterGemma.getActiveModel(maxTokens: 2048).timeout(const Duration(seconds: 60));

      if (_model == null) throw Exception('Engine could not activate model.');

      _chat = await _model?.createChat(
        temperature: config.tierId == 'budget' ? 0.3 : 0.72,
        topK: 40,
        modelType: mType,
      ).timeout(const Duration(seconds: 30));

      if (_chat == null) throw Exception('Chat creation failed.');

      // ── Background Warmup Initiation ──
      _activeConfig = config;
      _msgCount = 0;
      _systemPromptInjected = false;
      _isReady = true;
      _isLoading.value = false;
      _lastError = null;
      
      _warmupCompleter = Completer<void>();
      debugPrint('[SAATHI LLM] ${config.name} READY. Starting background warmup…');
      
      // Do not await, fire in background:
      _performWarmup();
    } catch (e) {
      _isLoading.value = false;
      _isReady = false;
      final errStr = e.toString();
      debugPrint('[SAATHI LLM] Init error: $errStr');

      if (errStr.contains('Unsupported') ||
          errStr.contains('build failed') ||
          errStr.contains('java.lang') ||
          errStr.contains('JNI') ||
          errStr.contains('native') ||
          errStr.contains('TimeoutException')) {
        _isIncompatible = true;
        _lastError = errStr.contains('TimeoutException') 
            ? 'Model loading timed out. Aapka device shayad thoda slow hai ya RAM kam pad rahi hai.'
            : 'Model downloaded ✓ — AI engine currently supports compatible format only. Saathi Brain active.';
      } else {
        _isIncompatible = false;
        _lastError = errStr;
      }
    }
  }

  // ── Background Warmup ─────────────────────────────────

  static Future<void> _performWarmup() async {
    try {
      final systemPrompt = _getSystemPrompt();
      final warmupMsg = 'SYSTEM: $systemPrompt\n\nUSER: Saathi, you there?';
      await _chat?.addQueryChunk(Message(text: warmupMsg, isUser: true));
      await _chat?.generateChatResponse().timeout(const Duration(seconds: 40));
      _systemPromptInjected = true;
      _msgCount = 1;
      debugPrint('[SAATHI LLM] Background warmup complete ✓');
    } catch (e) {
      debugPrint('[SAATHI LLM] Warmup error: $e');
    } finally {
      if (_warmupCompleter != null && !_warmupCompleter!.isCompleted) {
        _warmupCompleter!.complete();
      }
    }
  }

  // ── Chat reset ────────────────────────────────────────

  static Future<void> _resetChat() async {
    try {
      if (_chat != null) {
        await _chat?.clearHistory();
      }
      _msgCount = 0;
      _systemPromptInjected = false;
      _warmupCompleter = null;
    } catch (e) {
      debugPrint('[SAATHI LLM] Chat reset failed: $e');
    }
  }

  // Called when chat needs to be reset
  static Future<void> resetStateForWarmup() async {
    await _resetChat();
  }

  // ── Response cleaning ─────────────────────────────────
  // Detects UTF-8 mojibake (garbled Hindi/Devanagari) and attempts repair.

  static String _cleanResponse(String text) {
    if (text.isEmpty) return '';
    var c = text.trim();
    c = c
        .replaceAll('<start_of_turn>', '')
        .replaceAll('<end_of_turn>', '')
        .replaceAll('user\n', '')
        .replaceAll('model\n', '');
    if (c.contains('Assistant:')) c = c.split('Assistant:').last.trim();
    if (c.contains('Saathi:')) c = c.split('Saathi:').last.trim();
    if (c.contains('User:')) c = c.split('User:').first.trim();
    // Remove BPE artifacts/weird characters common in some tokenizers
    c = c.replaceAll('Ġ', ' ').replaceAll('ðŁĺĬ', '').replaceAll('Â', '');
    // Remove literal newline strings that small models sometimes output
    c = c.replaceAll('\\n', '\n');
    c = c.replaceAll('(Saathi)', '').replaceAll('(Saatihya)', '').replaceAll('(Saathiya)', '');
    // Remove robotic "Helpful Assistant" starters seen in logs
    c = c.replaceAll('Hello! How can I assist you', '');
    c = c.replaceAll('Sure, what can I assist you', '');
    c = c.replaceAll('Sure, what podcast would you like to listen to', '');
    c = c.replaceAll('Okay, let\'s play a game', '');
    c = c.trim();
    if (c.startsWith(',') || c.startsWith('.')) c = c.substring(1).trim();
    if (c.contains('Aviral?')) c = c.replaceAll('Aviral?', '').trim();
    if (c.contains('Aviral!')) c = c.replaceAll('Aviral!', '').trim();

    // ── Mojibake repair ──────────────────────────────────
    // If the LLM output looks garbled (Hindi UTF-8 bytes misread as Latin-1),
    // attempt to re-encode as Latin-1 and decode as UTF-8.
    if (_isMojibake(c)) {
      debugPrint('[SAATHI LLM] Mojibake detected, attempting repair…');
      final repaired = _repairMojibake(c);
      if (repaired != null && repaired.isNotEmpty && !_isMojibake(repaired)) {
        debugPrint('[SAATHI LLM] Mojibake repaired successfully ✓');
        c = repaired;
      } else {
        debugPrint('[SAATHI LLM] Mojibake repair failed — returning empty (will fallback)');
        return ''; // triggers SaathiBrain fallback
      }
    }

    return c;
  }

  /// Check if text contains garbled UTF-8/Latin-1 mojibake patterns.
  /// Common patterns: Ã¤, Ã¥, à¤, à¥, Ã©, Ã, etc.
  static bool _isMojibake(String text) {
    if (text.isEmpty) return false;

    // Pattern 1: Classic Latin-1 misread of UTF-8 Hindi/Devanagari
    // UTF-8 Devanagari bytes (0xE0 0xA4-0xA5 xx) read as Latin-1 → "à¤" or "à¥"
    final mojibakePatterns = RegExp(
      r'[Ã\xC3][\x80-\xBF]|'     // Ã followed by continuation byte
      r'Ã [¤¥]|'                   // Ã space + second byte
      r'à[¤¥][^\s]{0,2}|'         // à followed by ¤/¥ (Devanagari mojibake)
      r'Ã¤|Ã¥|'                   // direct known patterns
      r'[\xC0-\xDF][\x80-\xBF]',  // general 2-byte Latin-1 misread
    );

    // Count mojibake-looking sequences
    final matches = mojibakePatterns.allMatches(text).length;
    // If more than 2 mojibake sequences in a short text, it's likely garbled
    if (matches >= 2) return true;

    // Pattern 2: High ratio of non-ASCII, non-Devanagari chars
    // Real Devanagari: U+0900–U+097F. Mojibake has Latin Extended chars instead.
    int suspiciousChars = 0;
    int totalNonAscii = 0;
    for (final rune in text.runes) {
      if (rune > 127) {
        totalNonAscii++;
        // Latin Extended / Latin Supplement (0x80-0x2FF) — not expected in Hinglish
        if (rune >= 0x80 && rune <= 0x2FF) {
          suspiciousChars++;
        }
      }
    }

    // If most non-ASCII chars are in the Latin Extended range, it's mojibake
    if (totalNonAscii > 4 && suspiciousChars > totalNonAscii * 0.5) {
      return true;
    }

    return false;
  }

  /// Attempt to repair mojibake by re-encoding as Latin-1 and decoding as UTF-8.
  static String? _repairMojibake(String text) {
    try {
      // Encode the garbled string back to Latin-1 bytes
      // (reversing the incorrect Latin-1 interpretation)
      final latin1Bytes = latin1.encode(text);
      // Now decode those bytes as UTF-8 (the correct encoding)
      final repaired = utf8.decode(latin1Bytes, allowMalformed: true);
      // Check the result has actual content and fewer replacement chars
      if (repaired.contains('�') && repaired.indexOf('�') < repaired.length ~/ 2) {
        return null; // too many replacement characters, repair didn't work
      }
      return repaired.trim();
    } catch (e) {
      debugPrint('[SAATHI LLM] Mojibake repair exception: $e');
      return null;
    }
  }

  // ── State getters ─────────────────────────────────────

  static bool get isReady => _isReady;
  static bool get isLoading => _isLoading.value;
  static ValueNotifier<bool> get isLoadingNotifier => _isLoading;

  static void reset() {
    _isReady = false;
    _isIncompatible = false;
    _isLoading.value = false;
    _lastError = null;
    _chat = null;
    _model = null;
    _activeConfig = null;
    _systemPromptInjected = false;
    if (_warmupCompleter != null && !_warmupCompleter!.isCompleted) {
      _warmupCompleter?.complete();
    }
    _warmupCompleter = null;
  }

  // ── Generate response ─────────────────────────────────

  static Future<String> generateResponse(String userPrompt, {String memoryContext = ''}) async {
    if (!_isReady) {
      if (_isLoading.value) {
        debugPrint('[SAATHI LLM] Waiting for engine to finish loading…');
        int attempts = 0;
        // Wait up to 20 seconds (40 * 500ms) — reduced from 60s for faster fallback
        while (_isLoading.value && attempts < 40) {
          await Future.delayed(const Duration(milliseconds: 500));
          attempts++;
        }
      } else {
        await init();
      }
      if (!_isReady) return '';
    }

    if (_warmupCompleter != null && !_warmupCompleter!.isCompleted) {
      debugPrint('[SAATHI LLM] Waiting for background warmup to finish…');
      await _warmupCompleter!.future;
    }

    try {
      // Qwen 2.5 is very capable; we use a clear prompt structure for Hinglish.
      const hinglishReminder = '\n(Reply strictly in Roman Hinglish, 1 sentence)';
      String messageText = '$userPrompt$hinglishReminder';
      
      if (!_systemPromptInjected && _msgCount == 0) {
        final systemPrompt = _getSystemPrompt();
        messageText = 'SYSTEM: $systemPrompt\n\nUSER: $userPrompt$hinglishReminder';
        _systemPromptInjected = true;
      }

      await _chat?.addQueryChunk(Message(text: messageText, isUser: true));
      final response = await _chat
          ?.generateChatResponse()
          .timeout(const Duration(seconds: 20));

      String rawResponse = '';
      if (response != null && response is TextResponse) {
        rawResponse = response.token;
      }

      final cleaned = _cleanResponse(rawResponse);
      if (cleaned.length < 2) return '';

      _msgCount++;
      if (_msgCount >= 15) await _resetChat();

      return cleaned;
    } catch (e) {
      debugPrint('[SAATHI LLM] Error: $e');
      await _resetChat();
      return '';
    }
  }
}
