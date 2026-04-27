import 'dart:io';
import 'package:flutter/foundation.dart';
import 'model_manager.dart';

// ─────────────────────────────────────────────────────────
// 🔍  RAM DETECTOR
// ─────────────────────────────────────────────────────────
// Detects available device RAM and recommends the best LLM tier.
// On Android, reads /proc/meminfo. On other platforms, defaults to midRange.
// ─────────────────────────────────────────────────────────

class RamDetector {
  /// Returns total device RAM in GB (best-effort).
  static Future<double> getTotalRamGb() async {
    if (!Platform.isAndroid) return 6.0; // safe default → midRange

    try {
      final result = await File('/proc/meminfo').readAsString();
      for (final line in result.split('\n')) {
        if (line.startsWith('MemTotal:')) {
          // Format: "MemTotal:    3914272 kB"
          final parts = line.split(RegExp(r'\s+'));
          final kbValue = double.tryParse(parts[1]);
          if (kbValue != null) {
            return kbValue / (1024 * 1024); // kB → GB
          }
        }
      }
    } catch (e) {
      debugPrint('[RamDetector] Could not read meminfo: $e');
    }
    return 4.0; // fallback → midRange boundary
  }

  /// Recommends the best LlmTier for this device.
  static Future<LlmTier> recommendTier() async {
    final ramGb = await getTotalRamGb();
    if (ramGb < 4.0) return LlmTier.budget;
    if (ramGb < 6.0) return LlmTier.midRange;
    return LlmTier.highEnd;
  }

  /// Returns the recommended [LlmModelConfig] for this device.
  static Future<LlmModelConfig> recommendedConfig() async {
    final tier = await recommendTier();
    switch (tier) {
      case LlmTier.budget:
        return ModelRegistry.budget;
      case LlmTier.midRange:
        return ModelRegistry.midRange;
      case LlmTier.highEnd:
        return ModelRegistry.highEnd;
    }
  }
}
