import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────
// 📦  LLM MODEL CONFIG
// ─────────────────────────────────────────────────────────

enum LlmTier { budget, midRange, highEnd }

class LlmModelConfig {
  final LlmTier tier;
  final String tierId;      // storage key: 'budget' / 'midRange' / 'highEnd'
  final String name;
  final String shortName;   // for UI badge
  final String ramLabel;
  final String sizeLabel;
  final String emoji;
  final String description;
  final String fileName;
  final String downloadUrl;
  final int minSizeBytes;
  final String modelTypeId; // 'qwen' / 'deepSeek' / 'gemmaIt' → maps to flutter_gemma ModelType

  const LlmModelConfig({
    required this.tier,
    required this.tierId,
    required this.name,
    required this.shortName,
    required this.ramLabel,
    required this.sizeLabel,
    required this.emoji,
    required this.description,
    required this.fileName,
    required this.downloadUrl,
    required this.minSizeBytes,
    required this.modelTypeId,
  });
}

// ─────────────────────────────────────────────────────────
// 📚  MODEL REGISTRY
// ─────────────────────────────────────────────────────────

class ModelRegistry {
  static LlmModelConfig get budget {
    if (Platform.isWindows) {
      return const LlmModelConfig(
        tier: LlmTier.budget,
        tierId: 'budget',
        name: 'Llama 3.2 (1B)',
        shortName: 'Llama 1B',
        ramLabel: '3–4 GB RAM',
        sizeLabel: '~850 MB',
        emoji: '🦙',
        description: 'Meta ka naya smart model. Hinglish aur fast offline chat ke liye best.',
        fileName: 'Llama-3.2-1B-Instruct_q8.litertlm',
        downloadUrl: 'https://huggingface.co/litert-community/Llama-3.2-1B-Instruct/resolve/main/Llama-3.2-1B-Instruct_q8.litertlm',
        modelTypeId: 'general',
        minSizeBytes: 700 * 1024 * 1024,
      );
    }
    return const LlmModelConfig(
      tier: LlmTier.budget,
      tierId: 'budget',
      name: 'Llama 3.2 (1B)',
      shortName: 'Llama 1B',
      ramLabel: '2–4 GB RAM',
      sizeLabel: '~850 MB',
      emoji: '🦙',
      description: 'Meta ka naya smart model. Hinglish aur fast offline chat ke liye best.',
      fileName: 'Llama-3.2-1B-Instruct_q8.task',
      downloadUrl: 'https://huggingface.co/litert-community/Llama-3.2-1B-Instruct/resolve/main/Llama-3.2-1B-Instruct_q8.task',
      modelTypeId: 'general',
      minSizeBytes: 700 * 1024 * 1024,
    );
  }

  static LlmModelConfig get midRange {
    return const LlmModelConfig(
      tier: LlmTier.midRange,
      tierId: 'midRange',
      name: 'Gemma 4 (E2B)',
      shortName: 'Gemma E2B',
      ramLabel: '4–8 GB RAM',
      sizeLabel: '~2.4 GB',
      emoji: '🧠',
      description: 'Google ka "Effective Parameter" model. Fast aur samajhdar binary version.',
      fileName: 'gemma-4-E2B-it.litertlm',
      downloadUrl: 'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
      modelTypeId: 'gemmaIt',
      minSizeBytes: 2400 * 1024 * 1024,
    );
  }

  static LlmModelConfig get highEnd {
    return const LlmModelConfig(
      tier: LlmTier.highEnd,
      tierId: 'highEnd',
      name: 'Gemma 4 (E4B)',
      shortName: 'Gemma E4B',
      ramLabel: '8–12+ GB RAM',
      sizeLabel: '~3.4 GB',
      emoji: '🚀',
      description: 'Top-tier multimodal binary intelligence. Sabse smart offline AI.',
      fileName: 'gemma-4-E4B-it.litertlm',
      downloadUrl: 'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      modelTypeId: 'gemmaIt',
      minSizeBytes: 3200 * 1024 * 1024,
    );
  }

  static List<LlmModelConfig> get all => [budget, midRange, highEnd];

  static LlmModelConfig byTierId(String tierId) {
    return all.firstWhere(
      (m) => m.tierId == tierId,
      orElse: () => midRange,
    );
  }
}

// ─────────────────────────────────────────────────────────
// ⚙️  MODEL MANAGER
// ─────────────────────────────────────────────────────────

class ModelManager {
  static const _selectedTierKey = 'selected_llm_tier';
  static final Dio _dio = Dio();

  // ── Preference helpers ────────────────────────────────

  static Future<void> saveSelectedTier(LlmModelConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTierKey, config.tierId);
  }

  static Future<LlmModelConfig?> getSelectedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final tierId = prefs.getString(_selectedTierKey);
    if (tierId == null) return null;
    return ModelRegistry.byTierId(tierId);
  }

  // ── Path helpers ──────────────────────────────────────

  static Future<String> getModelPath(LlmModelConfig config) async {
    final dir = await getApplicationSupportDirectory();
    final modelsDir = Directory(p.join(dir.path, 'models'));
    if (!modelsDir.existsSync()) {
      await modelsDir.create(recursive: true);
    }
    return p.join(modelsDir.path, config.fileName);
  }

  // ── Presence check ────────────────────────────────────

  static Future<bool> isModelPresent(LlmModelConfig config) async {
    final path = await getModelPath(config);
    final file = File(path);
    if (!file.existsSync()) return false;
    final size = await file.length();
    if (size < config.minSizeBytes) {
      // Too small — probably corrupt / partial
      return false;
    }
    return true;
  }

  /// Returns the currently selected model if it is downloaded, else null.
  static Future<LlmModelConfig?> getActiveModel() async {
    final config = await getSelectedConfig();
    if (config == null) return null;
    final present = await isModelPresent(config);
    return present ? config : null;
  }

  // ── Download ──────────────────────────────────────────

  static Future<void> startDownload({
    required LlmModelConfig config,
    required Function(double progress) onProgress,
    required Function(String localPath) onComplete,
    required Function(dynamic error) onError,
  }) async {
    final localPath = await getModelPath(config);
    final tempPath = '$localPath.tmp';

    try {
      await _dio.download(
        config.downloadUrl,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      await File(tempPath).rename(localPath);
      await saveSelectedTier(config);
      onComplete(localPath);
    } catch (e) {
      // Clean up partial temp file
      try {
        final tmp = File(tempPath);
        if (tmp.existsSync()) tmp.deleteSync();
      } catch (_) {}
      onError(e);
    }
  }

  static Future<void> deleteModel(LlmModelConfig config) async {
    final path = await getModelPath(config);
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }
}
