import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/ai/saathi_brain.dart';
import '../../core/ai/gemini_service.dart';
import '../../core/ai/model_manager.dart';
import '../../core/ai/llm_offline_engine.dart';
import '../../core/ai/voice_service.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/memory/buddy_memory_service.dart';
import '../ai/model_select_sheet.dart';
import '../../core/localization/app_localizations.dart';
import 'voice_chat_screen.dart';

// ============================================================
// CHAT SCREEN (WRAPPER FOR SAATHI AI)
// ============================================================
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const SaathiAIScreen();
  }
}

// ============================================================
// SAATHI AI SCREEN
// ============================================================
class SaathiAIScreen extends StatefulWidget {
  const SaathiAIScreen({super.key});
  @override
  State<SaathiAIScreen> createState() => _SaathiAIScreenState();
}

class _SaathiAIScreenState extends State<SaathiAIScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _input = TextEditingController();
  bool _loading = false;
  LlmModelConfig? _installedModel;
  String _buddyName = 'Buddy';

  // ── Voice Assistant State ──────────────────────────────
  final VoiceService _voiceService = VoiceService();
  bool _isVoiceListening = false;
  bool _isSpeakerOn = true;
  String _liveTranscript = '';

  static const String _buddyNameKey = 'buddy_display_name';

  @override
  void initState() {
    super.initState();
    ExperimentalLLMEngine.isLoadingNotifier.addListener(_onEngineLoadingChange);
    _checkModelStatus();
    _loadBuddyName();
    SaathiBrain.init();
    GeminiService.init();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    _voiceService.isListeningNotifier.addListener(_onVoiceStateChange);
    _voiceService.isSpeakingNotifier.addListener(_onVoiceStateChange);
    _voiceService.liveTranscript.addListener(_onTranscriptChange);
  }

  void _onVoiceStateChange() {
    if (mounted) {
      setState(() {
        _isVoiceListening = _voiceService.isListening;
        _isSpeakerOn = _voiceService.isTtsEnabled;
      });
    }
  }

  void _onTranscriptChange() {
    if (mounted) {
      setState(() => _liveTranscript = _voiceService.liveTranscript.value);
    }
  }

  Future<void> _loadBuddyName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_buddyNameKey) ?? 'Buddy';
    if (mounted) {
      setState(() => _buddyName = saved);
    }
  }

  Future<void> _saveBuddyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buddyNameKey, name);
    if (mounted) setState(() => _buddyName = name);
  }

  void _onEngineLoadingChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // Save conversation memory when leaving chat
    _saveMemory();
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    _voiceService.isListeningNotifier.removeListener(_onVoiceStateChange);
    _voiceService.isSpeakingNotifier.removeListener(_onVoiceStateChange);
    _voiceService.liveTranscript.removeListener(_onTranscriptChange);
    ExperimentalLLMEngine.isLoadingNotifier
        .removeListener(_onEngineLoadingChange);
    _input.dispose();
    super.dispose();
  }

  Future<void> _saveMemory() async {
    if (_messages.isNotEmpty) {
      await BuddyMemoryService.saveSessionSummary(_messages);
    }
  }

  Future<void> _checkModelStatus() async {
    final active = await ModelManager.getActiveModel();
    if (mounted) setState(() => _installedModel = active);
    if (active != null) {
      ExperimentalLLMEngine.init();
    }
  }

  void _openModelSheet() async {
    final result = await showModalBottomSheet<LlmModelConfig?>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ModelSelectSheet(),
    );
    // Refresh status whether user installed or skipped
    if (mounted) await _checkModelStatus();
    if (result != null && mounted) {
      await ExperimentalLLMEngine.init();
    }
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    _executeSend(text);
  }

  void _executeSend(String text) async {
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });

    final reply = await GeminiService.send(text);
    // Replace any "Saathi" references in reply with buddy name
    final personalizedReply = reply
        .replaceAll('Main Saathi hoon', 'Main $_buddyName hoon')
        .replaceAll('Saathi hoon', '$_buddyName hoon');

    if (mounted) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': personalizedReply,
        });
        _loading = false;
        _checkModelStatus();
      });

      // 🔊 AI speaks the reply aloud (if speaker is on)
      _voiceService.speak(personalizedReply);
    }
  }

  // ── Voice Assistant Methods ────────────────────────────
  void _toggleMic() {
    if (_isVoiceListening) {
      _voiceService.stopListening();
    } else {
      _voiceService.startListening(
        onResult: (finalText) {
          if (finalText.isNotEmpty) {
            setState(() => _liveTranscript = '');
            _input.text = finalText;
            _send();
          }
        },
        onPartial: (partial) {
          setState(() => _liveTranscript = partial);
        },
      );
    }
  }

  void _toggleSpeaker() {
    _voiceService.toggleTts();
    setState(() => _isSpeakerOn = _voiceService.isTtsEnabled);
  }

  // ── Buddy Name Dialog ───────────────────────────────────
  void _showNameDialog() {
    final nameController = TextEditingController(text: _buddyName);
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🦊', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context).t('name_buddy_title'), style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t('name_buddy_desc'),
              style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).t('name_buddy_hint'),
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.3)),
                filled: true,
                fillColor: cs.onSurface.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).t('cancel'), style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                _saveBuddyName(name);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context).t('save_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── UI Components ───────────────────────────────────────

  Widget _buildBrainIndicator() {
    final status = GeminiService.lastSource;
    String label = '$_buddyName\'s Brain Active';
    Color color = Colors.blue;
    IconData icon = Icons.psychology;

    if (status.contains('No Model')) {
      label = AppLocalizations.of(context).t('ready_to_chat', {'val': _buddyName});
      color = AppColors.primaryPurple;
      icon = Icons.bolt;
    } else if (status.contains('gemma')) {
      label = '${AppLocalizations.of(context).t('brain_active')} 🧠';
      color = Colors.green;
      icon = Icons.auto_awesome;
    } else if (status.contains('loading')) {
      label = AppLocalizations.of(context).t('waking_up');
      color = Colors.amber;
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRetry(int assistantMsgIndex) {
    if (assistantMsgIndex <= 0) return;
    String? userText;
    for (int i = assistantMsgIndex - 1; i >= 0; i--) {
      if (_messages[i]['role'] == 'user') {
        userText = _messages[i]['text'];
        break;
      }
    }
    if (userText != null) {
      setState(() {
        _messages.removeAt(assistantMsgIndex);
      });
      _executeSend(userText);
    }
  }

  Widget _buildBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (ExperimentalLLMEngine.isIncompatible ||
        (_installedModel != null &&
         ExperimentalLLMEngine.lastError != null &&
         !ExperimentalLLMEngine.isLoading)) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).t('brain_active_offline'),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                Text(
                  AppLocalizations.of(context).t('engine_update_needed'),
                  style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_installedModel != null) {
                await ModelManager.deleteModel(_installedModel!);
              }
              ExperimentalLLMEngine.reset();
              await _checkModelStatus();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              AppLocalizations.of(context).t('remove_btn'),
              style: TextStyle(fontSize: 11, color: Colors.red.shade300),
            ),
          ),
        ]),
      );
    }

    if (_installedModel != null && ExperimentalLLMEngine.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.amber)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).t('waking_up_time'),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface.withOpacity(0.7)),
            ),
          ),
        ]),
      );
    }

    if (_installedModel != null && ExperimentalLLMEngine.isReady) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.circle, size: 9, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).t('brain_active'),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(0.6)),
          ),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        gradient: LinearGradient(
          colors: [const Color(0xFF6C63FF).withOpacity(0.12), const Color(0xFF48C5B5).withOpacity(0.08)],
        ),
        child: Row(children: [
          const Text('🧠', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).t('make_smarter', {'val': _buddyName}), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                Text(AppLocalizations.of(context).t('install_offline_ai_desc'), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _openModelSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context).t('install_btn'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🦊', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              _buddyName,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🎙️ Voice mode button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF6C63FF).withOpacity(0.2), const Color(0xFF00D9FF).withOpacity(0.2)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.graphic_eq_rounded, color: colorScheme.primary, size: 18),
            ),
            tooltip: 'Voice Mode',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => VoiceChatScreen(buddyName: _buddyName),
                  transitionsBuilder: (_, anim, __, child) {
                    return FadeTransition(opacity: anim, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
          ),
          // Speaker toggle button
          _buildSpeakerToggle(colorScheme),
          // Edit buddy name button
          IconButton(
            icon: Icon(Icons.edit_rounded, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
            tooltip: AppLocalizations.of(context).t('rename_buddy'),
            onPressed: _showNameDialog,
          ),
        ],
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(children: [
            _buildBanner(context),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBrainIndicator(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) {
                    final isEngineLoading = ExperimentalLLMEngine.isLoading;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isEngineLoading)
                              const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.amber),
                              ),
                            if (isEngineLoading) const SizedBox(width: 8),
                            Text(
                              isEngineLoading
                                  ? AppLocalizations.of(context).t('waking_up_time')
                                  : AppLocalizations.of(context).t('thinking'),
                              style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final msg = _messages[i];
                  final isUser = msg['role'] == 'user';
                  return Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 4),
                                child: Text(
                                  _buddyName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(isUser ? 20 : 0),
                                bottomRight: Radius.circular(isUser ? 0 : 20),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width * 0.78),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? colorScheme.primary.withOpacity(0.9)
                                        : (isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.white.withOpacity(0.7)),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                                      bottomRight: Radius.circular(isUser ? 0 : 20),
                                    ),
                                    border: Border.all(
                                      color: isUser
                                          ? Colors.white.withOpacity(0.2)
                                          : (isDark
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.2)),
                                    ),
                                  ),
                                  child: Text(
                                    msg['text']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isUser
                                          ? Colors.white
                                          : colorScheme.onSurface,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!isUser && i > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleRetry(i),
                                  icon: const Icon(Icons.refresh, size: 14, color: Colors.grey),
                                  label: Text(
                                    AppLocalizations.of(context).t('regenerate'),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    minimumSize: const Size(0, 30),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                ),
                              )
                            else if (!isUser)
                              const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // ── Voice Listening Indicator ──────────────────
            if (_isVoiceListening)
              _buildListeningIndicator(colorScheme, isDark),
            // ── Input Bar with Mic + Send ────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Privacy badge
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      AppLocalizations.of(context).t('voice_privacy_badge'),
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurface.withOpacity(0.35),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(children: [
                    // 🎤 Mic Button
                    _buildMicButton(colorScheme, isDark),
                    const SizedBox(width: 10),
                    // Text Input
                    Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 28,
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                        child: TextField(
                          controller: _input,
                          maxLines: null,
                          onSubmitted: (_) => _send(),
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context).t('chat_hint', {'val': _buddyName}),
                            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Send Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: IconButton(
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 🎤 VOICE UI WIDGETS
  // ══════════════════════════════════════════════════════════

  /// Animated Mic button with glow effect when listening
  Widget _buildMicButton(ColorScheme cs, bool isDark) {
    final isActive = _isVoiceListening;
    final micColor = isActive ? Colors.redAccent : const Color(0xFF6C63FF);

    return GestureDetector(
      onTap: _toggleMic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isActive
                ? [Colors.red.shade400, Colors.redAccent]
                : [const Color(0xFF6C63FF), const Color(0xFF48C5B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: micColor.withOpacity(isActive ? 0.5 : 0.3),
              blurRadius: isActive ? 20 : 10,
              spreadRadius: isActive ? 2 : 0,
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// Speaker toggle in AppBar
  Widget _buildSpeakerToggle(ColorScheme cs) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          key: ValueKey(_isSpeakerOn),
          color: _isSpeakerOn
              ? const Color(0xFF6C63FF)
              : cs.onSurface.withOpacity(0.4),
          size: 22,
        ),
      ),
      tooltip: _isSpeakerOn
          ? AppLocalizations.of(context).t('voice_speaker_on')
          : AppLocalizations.of(context).t('voice_speaker_off'),
      onPressed: _toggleSpeaker,
    );
  }

  /// Listening indicator with animated waveform
  Widget _buildListeningIndicator(ColorScheme cs, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withOpacity(0.08),
            const Color(0xFF6C63FF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Animated pulse dot
          _PulsingDot(color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).t('voice_listening'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                if (_liveTranscript.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '"$_liveTranscript"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // Mini waveform
          _MiniWaveform(),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 🔴 PULSING DOT ANIMATION
// ══════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 10 + (_controller.value * 4),
        height: 10 + (_controller.value * 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.6 + (_controller.value * 0.4)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3 * _controller.value),
              blurRadius: 8 * _controller.value,
              spreadRadius: 2 * _controller.value,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 🌊 MINI WAVEFORM ANIMATION
// ══════════════════════════════════════════════════════════
class _MiniWaveform extends StatefulWidget {
  @override
  State<_MiniWaveform> createState() => _MiniWaveformState();
}

class _MiniWaveformState extends State<_MiniWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final offset = (i * 0.15) + (_controller.value * 0.5);
          final height = 8.0 + (sin(offset * 3.14) * 12);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 3,
            height: height.clamp(4.0, 20.0),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  double sin(double x) => (x - x * x * x / 6 + x * x * x * x * x / 120);
}
