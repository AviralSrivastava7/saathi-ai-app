import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/ai/model_manager.dart';
import '../../core/ai/ram_detector.dart';
import '../../core/storage/ai_popup_storage.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/localization/app_localizations.dart';

// ─────────────────────────────────────────────────────────
// 🧠  MODEL SELECT SHEET
// ─────────────────────────────────────────────────────────
// Shows 3 LLM model cards based on RAM tiers.
// User picks one → download starts inline in that card.
// Skip → uses existing Saathi Brain (rule-based).
// ─────────────────────────────────────────────────────────

class ModelSelectSheet extends StatefulWidget {
  const ModelSelectSheet({super.key});

  @override
  State<ModelSelectSheet> createState() => _ModelSelectSheetState();
}

class _ModelSelectSheetState extends State<ModelSelectSheet> {
  LlmTier? _recommendedTier;
  // Per-model download state
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _isComplete = {};
  String? _errorTierId;

  @override
  void initState() {
    super.initState();
    _detectRam();
  }

  Future<void> _detectRam() async {
    final tier = await RamDetector.recommendTier();
    if (mounted) setState(() => _recommendedTier = tier);
  }

  void _startDownload(LlmModelConfig config) {
    if (_isDownloading[config.tierId] == true) return;
    setState(() {
      _isDownloading[config.tierId] = true;
      _downloadProgress[config.tierId] = 0.0;
      _errorTierId = null;
    });

    ModelManager.startDownload(
      config: config,
      onProgress: (p) {
        if (mounted) setState(() => _downloadProgress[config.tierId] = p);
      },
      onComplete: (_) async {
        await AIPopupStorage.saveSelectedTierId(config.tierId);
        if (mounted) {
          setState(() {
            _isDownloading[config.tierId] = false;
            _isComplete[config.tierId] = true;
          });
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.of(context).pop(config);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${config.emoji} ${config.name} ready! Offline AI ab active hai ✨'),
                backgroundColor: const Color(0xFF1A8C5B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _isDownloading[config.tierId] = false;
            _errorTierId = config.tierId;
          });
        }
      },
    );
  }

  Future<void> _skip() async {
    await AIPopupStorage.markModelPopupShown();
    if (mounted) Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return GlassCard(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // ── Header ──────────────────────────────────────
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF48C5B5)]).createShader(bounds),
            child: Text(loc.t('saathi_brain_install'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 8),
          Text(
            'Apne phone ke hisaab se ek AI model choose karein.\nPoori tarah offline kaam karta hai — koi data share nahi.',
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Model Cards ──────────────────────────────────
          ...ModelRegistry.all.map(
            (config) => _ModelCard(
              config: config,
              isRecommended: _recommendedTier == config.tier,
              progress: _downloadProgress[config.tierId],
              isDownloading: _isDownloading[config.tierId] == true,
              isComplete: _isComplete[config.tierId] == true,
              hasError: _errorTierId == config.tierId,
              isDark: isDark,
              onTap: () => _startDownload(config),
            ),
          ),
          const SizedBox(height: 8),

          // ── Skip button ──────────────────────────────────
          TextButton(
            onPressed: _skip,
            child: Text(loc.t('brain_later'), style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.45))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 🃏  MODEL CARD
// ─────────────────────────────────────────────────────────

class _ModelCard extends StatelessWidget {
  final LlmModelConfig config;
  final bool isRecommended;
  final double? progress;
  final bool isDownloading;
  final bool isComplete;
  final bool hasError;
  final VoidCallback onTap;
  final bool isDark;

  const _ModelCard({
    required this.config,
    required this.isRecommended,
    required this.progress,
    required this.isDownloading,
    required this.isComplete,
    required this.hasError,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF48C5B5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final cardBg = isDark ? const Color(0xFF1C2340) : const Color(0xFFF5F7FF);
    final borderColor = isRecommended
        ? const Color(0xFF6C63FF)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: (isDownloading || isComplete) ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row ──────────────────────────────
                Row(
                  children: [
                    // Emoji badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(config.emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + ram label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                config.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isRecommended) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: gradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Best for you',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${config.ramLabel}  ·  ${config.sizeLabel}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action widget (button / tick / progress indicator)
                    _buildAction(gradient),
                  ],
                ),

                // ── Description ───────────────────────────
                if (!isDownloading && !isComplete)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 54),
                    child: Text(
                      config.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.45,
                      ),
                    ),
                  ),

                // ── Progress bar ──────────────────────────
                if (isDownloading) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor:
                        const Color(0xFF6C63FF).withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6C63FF)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Downloading… ${((progress ?? 0) * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6C63FF)),
                  ),
                ],

                // ── Error ─────────────────────────────────
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 54),
                    child: Text(
                      '⚠️ Download failed. Check internet aur retry karein.',
                      style: TextStyle(
                          fontSize: 11, color: Colors.red.shade400),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(LinearGradient gradient) {
    if (isComplete) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          value: progress,
          color: const Color(0xFF6C63FF),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Install',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
