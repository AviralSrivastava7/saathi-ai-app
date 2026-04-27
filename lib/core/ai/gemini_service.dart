import 'package:flutter/foundation.dart';
import 'model_manager.dart';
import 'saathi_brain.dart';
import 'llm_offline_engine.dart';

/// 🤖 Saathi AI Service — Fully Offline
/// LLM Engine (primary) → SaathiBrain (ONLY if no model downloaded)
/// Now includes memory context from past conversations.
class GeminiService {
  static String lastSource = 'offline';

  static void init() {}

  /// Pre-warm the LLM engine so it's ready before first message.
  /// Call this when voice chat opens to avoid fallback to SaathiBrain.
  static Future<void> ensureReady() async {
    final activeModel = await ModelManager.getActiveModel();
    if (activeModel == null) {
      debugPrint('[GeminiService] No model downloaded — SaathiBrain will be used');
      return;
    }
    if (ExperimentalLLMEngine.isIncompatible) {
      debugPrint('[GeminiService] Model incompatible — SaathiBrain will be used');
      return;
    }
    if (ExperimentalLLMEngine.isReady) {
      debugPrint('[GeminiService] LLM engine already ready ✓');
      return;
    }
    // Trigger init and wait for it
    debugPrint('[GeminiService] Pre-warming LLM engine…');
    await ExperimentalLLMEngine.init();
    debugPrint('[GeminiService] Init complete. Ready=${ExperimentalLLMEngine.isReady}');

    if (ExperimentalLLMEngine.isReady) {
      // Warmup disabled to avoid blocking immediate chats.
    }
  }

  /// Send message — priority: LLM Engine → SaathiBrain (only when no model)
  static Future<String> send(String message) async {
    lastSource = 'offline';

    // Removed memory loading to speed up the process
    final memoryContext = '';

    final activeModel = await ModelManager.getActiveModel();

    // ── NO MODEL DOWNLOADED → SaathiBrain is the only option ──────────
    if (activeModel == null) {
      lastSource = 'offline (Saathi Brain – No Model)';
      debugPrint('[GeminiService] No model downloaded → using SaathiBrain');
      return SaathiBrain.reply(message);
    }

    // ── MODEL DOWNLOADED ──────────────────────────────────────────────

    // Always capture name if user introduces themselves
    SaathiBrain.checkForName(message);

    // 1. If engine is INCOMPATIBLE → SaathiBrain
    if (ExperimentalLLMEngine.isIncompatible) {
      lastSource = 'offline (Saathi Brain – Model Incompatible)';
      debugPrint('[GeminiService] Model incompatible → using SaathiBrain');
      return SaathiBrain.reply(message);
    }

    // 2. If model is DOWNLOADED but engine is NOT ready yet (Loading) 
    //    We WAIT for it instead of falling back immediately.
    if (!ExperimentalLLMEngine.isReady) {
      // If it's not even loading, trigger init
      if (!ExperimentalLLMEngine.isLoading) {
        ExperimentalLLMEngine.init(); // fire-and-forget init
      }
      
      // We will let generateResponse handle the waiting internally
      lastSource = 'gemma_loading'; 
    }

    // 3. Engine is READY (or we are waiting for it) → attempt to use it
    //    With retry logic for empty responses (mojibake cleanup failures)
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        debugPrint('[GeminiService] LLM attempt ${attempt + 1}/2…');
        // Pass memory context to the LLM engine
        var llmReply = await ExperimentalLLMEngine.generateResponse(
          message,
          memoryContext: memoryContext,
        );
        if (llmReply.isNotEmpty) {
          lastSource = 'gemma';
          debugPrint('[GeminiService] ✅ LLM response received (${llmReply.length} chars)');
          SaathiBrain.checkForName(llmReply);
          return llmReply;
        }
        debugPrint('[GeminiService] ⚠️ LLM returned empty on attempt ${attempt + 1}');
        // Small delay before retry
        if (attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        debugPrint('[GeminiService] AI Engine error on attempt ${attempt + 1}: $e');
        // Don't retry on exception — likely a deeper issue
        break;
      }
    }

    // 4. Fallback to SaathiBrain ONLY if LLM fails or is not present
    lastSource = 'offline (Saathi Brain)';
    debugPrint('[GeminiService] ❌ LLM failed → falling back to SaathiBrain');
    return SaathiBrain.reply(message);
  }

  static bool get isOnline => false;

  static void resetChat() {
    ExperimentalLLMEngine.resetStateForWarmup();
  }

  /// Send message WITH conversation context for multi-turn voice chat.
  /// OPTIMIZED: Only sends a brief recap of last 3 messages since the LLM
  /// engine already maintains its own internal chat history via addQueryChunk.
  /// This avoids double-counting and keeps prompts short for faster responses.
  static Future<String> sendWithHistory(
    String message,
    List<Map<String, String>> history,
  ) async {
    lastSource = 'offline';

    // Removed memory loading and brief context (summary) to speed up response time significantly.
    final memoryContext = '';
    String briefContext = '';
    final fullMemory = '';

    final activeModel = await ModelManager.getActiveModel();

    // ── NO MODEL DOWNLOADED → SaathiBrain ──────────
    if (activeModel == null) {
      lastSource = 'offline (Saathi Brain – No Model)';
      return SaathiBrain.reply(message);
    }

    SaathiBrain.checkForName(message);

    if (ExperimentalLLMEngine.isIncompatible) {
      lastSource = 'offline (Saathi Brain – Model Incompatible)';
      return SaathiBrain.reply(message);
    }

    if (!ExperimentalLLMEngine.isReady) {
      if (!ExperimentalLLMEngine.isLoading) {
        ExperimentalLLMEngine.init();
      }
      lastSource = 'gemma_loading';
    }

    try {
      var llmReply = await ExperimentalLLMEngine.generateResponse(
        message,
        memoryContext: fullMemory,
      );
      if (llmReply.isNotEmpty) {
        lastSource = 'gemma';
        SaathiBrain.checkForName(llmReply);
        return llmReply;
      }
    } catch (e) {
      debugPrint('[GeminiService] sendWithHistory error: $e');
    }

    lastSource = 'offline (Saathi Brain)';
    return SaathiBrain.reply(message);
  }
}

