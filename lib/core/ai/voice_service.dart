import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 🎤 Saathi Voice Service — 100% Offline & On-Device
/// Handles Speech-to-Text (listening) and Text-to-Speech (speaking)
/// No data leaves the device. Privacy-first architecture.
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // ── Core engines ──────────────────────────────────────────
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  // ── State ─────────────────────────────────────────────────
  bool _sttInitialized = false;
  bool _ttsInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _ttsEnabled = true; // User can toggle AI voice on/off

  // ── Notifiers for UI reactivity ───────────────────────────
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);
  final ValueNotifier<String> liveTranscript = ValueNotifier('');

  // ── Getters ───────────────────────────────────────────────
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isTtsEnabled => _ttsEnabled;
  bool get isSttAvailable => _sttInitialized;

  // ══════════════════════════════════════════════════════════
  // 🎯 INITIALIZATION
  // ══════════════════════════════════════════════════════════

  /// Initialize both STT and TTS engines
  Future<void> init() async {
    await _initSTT();
    await _initTTS();
  }

  Future<void> _initSTT() async {
    try {
      _sttInitialized = await _stt.initialize(
        onError: (error) {
          debugPrint('[VoiceService] STT Error: ${error.errorMsg}');
          _setListening(false);
        },
        onStatus: (status) {
          debugPrint('[VoiceService] STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            _setListening(false);
          }
        },
      );
      debugPrint('[VoiceService] STT initialized: $_sttInitialized');
    } catch (e) {
      debugPrint('[VoiceService] STT init failed: $e');
      _sttInitialized = false;
    }
  }

  Future<void> _initTTS() async {
    try {
      // Set Hindi voice for Indian users
      await _tts.setLanguage('hi-IN');
      await _tts.setSpeechRate(0.45); // Slightly slower for clarity
      await _tts.setPitch(1.05); // Natural pitch
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() {
        _setSpeaking(true);
      });

      _tts.setCompletionHandler(() {
        _setSpeaking(false);
      });

      _tts.setCancelHandler(() {
        _setSpeaking(false);
      });

      _tts.setErrorHandler((msg) {
        debugPrint('[VoiceService] TTS Error: $msg');
        _setSpeaking(false);
      });

      _ttsInitialized = true;
      debugPrint('[VoiceService] TTS initialized: $_ttsInitialized');
    } catch (e) {
      debugPrint('[VoiceService] TTS init failed: $e');
      _ttsInitialized = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🎤 SPEECH-TO-TEXT (User → Text)
  // ══════════════════════════════════════════════════════════

  /// Start listening to user's voice
  /// [onResult] is called with final recognized text when user stops talking
  /// [onPartial] provides live transcription updates
  Future<void> startListening({
    required Function(String finalText) onResult,
    Function(String partialText)? onPartial,
  }) async {
    if (!_sttInitialized) {
      await _initSTT();
      if (!_sttInitialized) {
        debugPrint('[VoiceService] STT not available on this device');
        return;
      }
    }

    // Stop TTS if it's speaking (so mic doesn't pick up AI voice)
    if (_isSpeaking) {
      await stopSpeaking();
    }

    _setListening(true);
    liveTranscript.value = '';

    await _stt.listen(
      onResult: (result) {
        liveTranscript.value = result.recognizedWords;
        onPartial?.call(result.recognizedWords);

        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _setListening(false);
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'hi_IN', // Hindi locale for STT
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    await _stt.stop();
    _setListening(false);
  }

  // ══════════════════════════════════════════════════════════
  // 🔊 TEXT-TO-SPEECH (AI Text → Voice)
  // ══════════════════════════════════════════════════════════

  /// Speak the AI's response text aloud
  Future<void> speak(String text) async {
    if (!_ttsEnabled || !_ttsInitialized) return;
    if (text.isEmpty) return;

    // Clean text for better TTS output
    final cleanText = _cleanForTTS(text);

    await _tts.speak(cleanText);
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
    _setSpeaking(false);
  }

  /// Toggle TTS on/off
  void toggleTts() {
    _ttsEnabled = !_ttsEnabled;
    if (!_ttsEnabled && _isSpeaking) {
      stopSpeaking();
    }
  }

  /// Set TTS enabled/disabled
  void setTtsEnabled(bool enabled) {
    _ttsEnabled = enabled;
    if (!enabled && _isSpeaking) {
      stopSpeaking();
    }
  }

  // ══════════════════════════════════════════════════════════
  // 🧹 HELPERS
  // ══════════════════════════════════════════════════════════

  /// Clean text for natural TTS output
  String _cleanForTTS(String text) {
    return text
        // Remove emojis (TTS can't read them)
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), '')
        // Remove special characters
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('_', ' ')
        // Remove markdown formatting
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        // Clean extra whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _setListening(bool val) {
    _isListening = val;
    isListeningNotifier.value = val;
  }

  void _setSpeaking(bool val) {
    _isSpeaking = val;
    isSpeakingNotifier.value = val;
  }

  /// Dispose resources
  void dispose() {
    _stt.stop();
    _tts.stop();
    isListeningNotifier.dispose();
    isSpeakingNotifier.dispose();
    liveTranscript.dispose();
  }
}
