import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/ai/gemini_service.dart';
import '../../core/ai/voice_service.dart';
import '../../core/ai/llm_offline_engine.dart';
import '../../core/memory/buddy_memory_service.dart';
import '../pet/saathi_dog_avatar.dart';

/// 🎙️ Saathi Voice Chat — Premium "Saathi Wali Feeling"
/// Beautiful full-screen voice interaction with animated pet dog.
/// Features: Memory persistence, conversation context, warm status messages,
/// mini chat transcript, buddy personalization, premium glassmorphism UI.
class VoiceChatScreen extends StatefulWidget {
  final String buddyName;
  const VoiceChatScreen({super.key, this.buddyName = 'Buddy'});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

enum VoiceState { idle, listening, thinking, speaking }

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();

  VoiceState _state = VoiceState.idle;
  String _transcript = '';
  String _aiResponse = '';
  bool _isInitialized = false;
  bool _isLlmReady = false;
  String _llmStatus = 'Initializing...';
  late String _buddyName;

  // ── Conversation History (for context + memory) ──
  final List<Map<String, String>> _conversationHistory = [];
  final ScrollController _transcriptScrollController = ScrollController();

  // ── Warm status messages ──
  final math.Random _random = math.Random();
  int _exchangeCount = 0;
  String _warmStatusMessage = '';
  DateTime? _lastActivityTime;

  // Animation Controllers
  late AnimationController _orbController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _colorController;

  // Animations
  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _fadeAnim;

  // Particle system
  final List<_Particle> _particles = [];

  // ── Warm Hinglish status messages ──
  static const _listeningMessages = [
    'Sun raha hoon... 👂',
    'Bolo bolo, main dhyaan se sun raha hoon...',
    'Hmm, sun raha hoon...',
    'Main yahin hoon, bolo...',
    'Tumhari baat sun raha hoon... 💙',
  ];

  static const _thinkingMessages = [
    'Hmm, soch raha hoon... 🤔',
    'Ruko zara, samajh raha hoon...',
    'Tumhari baat pe soch raha hoon...',
    'Ek second, kuch sochta hoon...',
    'Samajh raha hoon... 💭',
  ];

  static const _speakingMessages = [
    'Tumse kuch kehna hai... 💬',
    'Suno yeh...',
    'Meri baat suno na...',
    'Yeh raha mera jawab... 🌟',
  ];

  static const _idleMessages = [
    'Main yahin hoon, bolo jab mann kare...',
    'Koi baat nahi, jab chahein baat karo 💙',
    'Tap karo aur baat shuru karo...',
    'Baat karna chahte ho? Main yahin hoon...',
  ];

  static const _encouragementMessages = [
    'Baat karte raho, main yahin hoon 💙',
    'Tumse baat karke mujhe bhi acha lagta hai ✨',
    'Kitna acha lag raha hai tumse baat karke!',
    'Main hamesha yahin hoon tumhare liye 🌟',
  ];

  @override
  void initState() {
    super.initState();
    _buddyName = widget.buddyName;
    _warmStatusMessage = _pick(_idleMessages);

    // ── Animation Controllers ──
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _generateParticles();
    _initialize();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 35; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 1.5 + _random.nextDouble() * 3.0,
        speed: 0.2 + _random.nextDouble() * 0.8,
        opacity: 0.08 + _random.nextDouble() * 0.2,
        angle: _random.nextDouble() * math.pi * 2,
      ));
    }
  }

  Future<void> _initialize() async {
    // Load buddy name if not passed
    if (_buddyName == 'Buddy') {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('buddy_display_name');
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() => _buddyName = saved);
      }
    }

    // Initialize voice service
    await _voiceService.init();
    _voiceService.setTtsEnabled(true);
    _voiceService.isSpeakingNotifier.addListener(_onSpeakingChanged);

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _llmStatus = 'Loading AI...';
      });
    }

    // Pre-warm LLM engine
    _prewarmLLM();

    // Auto-start listening immediately — no greeting delay
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _startListening();
    }
  }



  Future<void> _prewarmLLM() async {
    try {
      await GeminiService.ensureReady();
      if (mounted) {
        setState(() {
          _isLlmReady = ExperimentalLLMEngine.isReady;
          _llmStatus = _isLlmReady ? '🧠 Brain Active' : '⚡ $_buddyName Ready';
        });
      }
    } catch (e) {
      debugPrint('[VoiceChatScreen] LLM prewarm error: $e');
      if (mounted) {
        setState(() {
          _isLlmReady = false;
          _llmStatus = '⚡ $_buddyName Ready';
        });
      }
    }
  }

  void _onSpeakingChanged() {
    if (!_voiceService.isSpeaking && _state == VoiceState.speaking && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _state == VoiceState.speaking) {
          HapticFeedback.selectionClick();
          _startListening();
        }
      });
    }
  }

  void _startListening() {
    if (!_isInitialized || !mounted) return;
    _lastActivityTime = DateTime.now();

    setState(() {
      _state = VoiceState.listening;
      _transcript = '';
      _aiResponse = '';
      _warmStatusMessage = _pick(_listeningMessages);
    });
    _fadeController.reset();

    HapticFeedback.lightImpact();

    _voiceService.startListening(
      onResult: (finalText) {
        if (finalText.isNotEmpty && mounted) {
          setState(() => _transcript = finalText);
          _processMessage(finalText);
        } else if (mounted) {
          _startListening();
        }
      },
      onPartial: (partialText) {
        if (mounted) {
          setState(() => _transcript = partialText);
        }
      },
    );
  }

  Future<void> _processMessage(String message) async {
    if (!mounted) return;
    _lastActivityTime = DateTime.now();

    // Add user message to history
    _conversationHistory.add({'role': 'user', 'text': message});

    setState(() {
      _state = VoiceState.thinking;
      _warmStatusMessage = _pick(_thinkingMessages);
    });
    _fadeController.forward();

    try {
      final reply = await GeminiService.sendWithHistory(
        message,
        _conversationHistory,
      );
      if (!mounted) return;

      // Personalize the reply
      final personalizedReply = reply
          .replaceAll('Main Saathi hoon', 'Main $_buddyName hoon')
          .replaceAll('Saathi hoon', '$_buddyName hoon');

      // Add AI response to history
      _conversationHistory.add({'role': 'assistant', 'text': personalizedReply});
      _exchangeCount++;

      setState(() {
        _aiResponse = personalizedReply;
        _state = VoiceState.speaking;
        _isLlmReady = ExperimentalLLMEngine.isReady;
        _llmStatus = _getSourceLabel();
        _warmStatusMessage = _pick(_speakingMessages);
      });
      HapticFeedback.mediumImpact(); // Dog "barks" — haptic feedback
      _fadeController.forward(from: 0);

      // Scroll transcript to bottom
      _scrollTranscriptToBottom();

      // Speak the AI response
      await _voiceService.speak(personalizedReply);
    } catch (e) {
      debugPrint('[VoiceChatScreen] Error: $e');
      if (mounted) {
        setState(() => _state = VoiceState.idle);
      }
    }
  }

  void _scrollTranscriptToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_transcriptScrollController.hasClients) {
        _transcriptScrollController.animateTo(
          _transcriptScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    if (_state == VoiceState.listening) {
      _voiceService.stopListening();
      setState(() {
        _state = VoiceState.idle;
        _warmStatusMessage = _pick(_idleMessages);
      });
    } else if (_state == VoiceState.speaking) {
      _voiceService.stopSpeaking();
      _startListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    // Save conversation memory when leaving
    _saveConversationMemory();
    _voiceService.isSpeakingNotifier.removeListener(_onSpeakingChanged);
    _voiceService.stopListening();
    _voiceService.stopSpeaking();
    _orbController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _colorController.dispose();
    _transcriptScrollController.dispose();
    super.dispose();
  }

  Future<void> _saveConversationMemory() async {
    if (_conversationHistory.isNotEmpty) {
      await BuddyMemoryService.saveSessionSummary(_conversationHistory);
      debugPrint('[VoiceChatScreen] 💾 Conversation memory saved (${_conversationHistory.length} messages)');
    }
  }

  String _getSourceLabel() {
    if (GeminiService.lastSource.contains('gemma')) return '🧠 Brain Active';
    if (GeminiService.lastSource.contains('Saathi Brain')) return '⚡ $_buddyName Brain';
    return '⚡ Offline AI';
  }

  String _pick(List<String> list) => list[_random.nextInt(list.length)];

  /// Map VoiceState → DogVoiceState
  DogVoiceState get _dogState {
    switch (_state) {
      case VoiceState.idle: return DogVoiceState.idle;
      case VoiceState.listening: return DogVoiceState.listening;
      case VoiceState.thinking: return DogVoiceState.thinking;
      case VoiceState.speaking: return DogVoiceState.speaking;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 🎨 BUILD
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        children: [
          // Layer 1: Animated gradient background
          _buildAnimatedBackground(),

          // Layer 2: Floating particles
          _buildParticleField(),

          // Layer 3: Floating ambient orbs
          _buildFloatingOrbs(),

          // Layer 4: Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                const Spacer(flex: 2),
                // ── DOG AVATAR + AURA ──
                _buildDogWithAura(),
                const SizedBox(height: 20),
                _buildStatusText(),
                const SizedBox(height: 6),
                _buildWarmMessage(),
                const SizedBox(height: 16),
                // Conversation transcript panel
                _buildConversationPanel(),
                const Spacer(flex: 1),
                // Encouragement after 3+ exchanges
                if (_exchangeCount >= 3) _buildEncouragementBadge(),
                _buildControls(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dog Avatar with Animated Aura Rings ──
  Widget _buildDogWithAura() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _waveController, _glowController]),
      builder: (context, _) {
        final pulse = _pulseAnim.value;
        final glow = _glowAnim.value;
        final wave = _waveController.value;

        return GestureDetector(
          onTap: _toggleListening,
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow rings
                ..._buildGlowRings(glow, wave),

                // Waveform ring (listening / speaking)
                if (_state == VoiceState.listening || _state == VoiceState.speaking)
                  _buildWaveformRing(wave, 140 * pulse),

                // Ambient aura glow
                Container(
                  width: 200 * pulse,
                  height: 200 * pulse,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getOrbShadowColor().withOpacity(0.12 * glow),
                        _getOrbShadowColor().withOpacity(0.04 * glow),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Dog shadow platform
                Positioned(
                  bottom: 55,
                  child: Container(
                    width: 100 * pulse,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: _getOrbShadowColor().withOpacity(0.15 + glow * 0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── THE DOG ──
                Transform.scale(
                  scale: pulse,
                  child: SaathiDogAvatar(
                    size: 150,
                    voiceState: _dogState,
                    happiness: 80,
                    energy: 80,
                    hunger: 80,
                    glowColor: _getOrbShadowColor(),
                  ),
                ),

                // State indicator badge below dog
                Positioned(
                  bottom: 30,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getOrbShadowColor().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getOrbShadowColor().withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getOrbShadowColor(),
                            boxShadow: [
                              BoxShadow(
                                color: _getOrbShadowColor().withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: _getOrbShadowColor().withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Memory Active Badge ──
  Widget _buildMemoryBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF43E97B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF43E97B).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.memory_rounded, size: 13, color: const Color(0xFF43E97B).withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            'Mujhe hamari pichli baatein yaad hain 🧠',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF43E97B).withOpacity(0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Encouragement badge after 3+ exchanges ──
  Widget _buildEncouragementBadge() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _exchangeCount >= 3 ? 1.0 : 0.0,
        child: Text(
          _pick(_encouragementMessages),
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ── Warm sub-status message ──
  Widget _buildWarmMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        _warmStatusMessage,
        key: ValueKey(_warmStatusMessage),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.35),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  // ── Conversation Transcript Panel (Premium glassmorphism) ──
  Widget _buildConversationPanel() {
    if (_conversationHistory.isEmpty && _transcript.isEmpty) {
      return const SizedBox(height: 80);
    }

    // Show current live state + recent history
    final displayMessages = <Map<String, String>>[];

    // Add last 4 conversation messages
    final startIdx = _conversationHistory.length > 4
        ? _conversationHistory.length - 4
        : 0;
    for (int i = startIdx; i < _conversationHistory.length; i++) {
      displayMessages.add(_conversationHistory[i]);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.builder(
          controller: _transcriptScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: displayMessages.length +
              (_state == VoiceState.listening && _transcript.isNotEmpty ? 1 : 0),
          itemBuilder: (context, i) {
            // Live transcript at the end
            if (i == displayMessages.length) {
              return _buildTranscriptBubble(_transcript, true, isLive: true);
            }

            final msg = displayMessages[i];
            final isUser = msg['role'] == 'user';
            return _buildTranscriptBubble(msg['text'] ?? '', isUser);
          },
        ),
      ),
    );
  }

  Widget _buildTranscriptBubble(String text, bool isUser, {bool isLive = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.55,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? const Color(0xFF6C63FF).withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text(
                '🐕 ',
                style: TextStyle(fontSize: 10),
              ),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  height: 1.3,
                  fontStyle: isLive ? FontStyle.italic : FontStyle.normal,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLive) ...[
              const SizedBox(width: 4),
              _MiniPulse(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Animated gradient background with color morphing ──
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbController, _colorController]),
      builder: (context, _) {
        final t = _orbController.value;
        final ct = _colorController.value;

        final centerX = math.sin(t * math.pi * 2) * 0.4;
        final centerY = math.cos(t * math.pi * 2 * 0.7) * 0.3;
        final hueShift = ct * 30;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(centerX, centerY),
              radius: 1.8,
              colors: _getBackgroundColors(hueShift),
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColors(double hueShift) {
    switch (_state) {
      case VoiceState.idle:
        return [
          HSLColor.fromAHSL(1, 260 + hueShift, 0.35, 0.12).toColor(),
          HSLColor.fromAHSL(1, 265 + hueShift, 0.30, 0.08).toColor(),
          HSLColor.fromAHSL(1, 270, 0.25, 0.04).toColor(),
          const Color(0xFF050510),
        ];
      case VoiceState.listening:
        return [
          HSLColor.fromAHSL(1, 210 + hueShift, 0.45, 0.14).toColor(),
          HSLColor.fromAHSL(1, 220 + hueShift, 0.38, 0.09).toColor(),
          HSLColor.fromAHSL(1, 230, 0.28, 0.05).toColor(),
          const Color(0xFF050510),
        ];
      case VoiceState.thinking:
        return [
          HSLColor.fromAHSL(1, 285 + hueShift, 0.45, 0.14).toColor(),
          HSLColor.fromAHSL(1, 275 + hueShift, 0.38, 0.09).toColor(),
          HSLColor.fromAHSL(1, 265, 0.28, 0.05).toColor(),
          const Color(0xFF050510),
        ];
      case VoiceState.speaking:
        return [
          HSLColor.fromAHSL(1, 155 + hueShift, 0.40, 0.12).toColor(),
          HSLColor.fromAHSL(1, 165 + hueShift, 0.33, 0.08).toColor(),
          HSLColor.fromAHSL(1, 175, 0.25, 0.04).toColor(),
          const Color(0xFF050510),
        ];
    }
  }

  // ── Floating particle field ──
  Widget _buildParticleField() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final t = _orbController.value;

        return CustomPaint(
          size: size,
          painter: _ParticleFieldPainter(
            particles: _particles,
            time: t,
            stateColor: _getOrbShadowColor(),
          ),
        );
      },
    );
  }

  // ── Floating ambient orbs ──
  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbController, _glowController]),
      builder: (context, _) {
        final t = _orbController.value;
        final glow = _glowAnim.value;
        final size = MediaQuery.of(context).size;

        return Stack(
          children: List.generate(6, (i) {
            final angle = (t * math.pi * 2) + (i * math.pi / 3);
            final radiusX = size.width * (0.25 + i * 0.04);
            final radiusY = size.height * (0.15 + i * 0.035);

            final x = size.width / 2 + math.cos(angle) * radiusX;
            final y = size.height / 2 + math.sin(angle * 0.6 + i * 0.3) * radiusY;

            final orbSize = 50.0 + i * 25.0 + glow * 20;
            final opacity = (0.03 + glow * 0.025) * (1.0 - i * 0.08);

            return Positioned(
              left: x - orbSize / 2,
              top: y - orbSize / 2,
              child: Container(
                width: orbSize,
                height: orbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getOrbColor(i).withOpacity(opacity.clamp(0.0, 1.0)),
                      _getOrbColor(i).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getOrbColor(int index) {
    const colors = [
      Color(0xFF7C6AFF),
      Color(0xFF00D9FF),
      Color(0xFFFF8FAB),
      Color(0xFF56D4A0),
      Color(0xFFFFC46B),
      Color(0xFFBB6BD9),
    ];
    return colors[index % colors.length];
  }

  // ── Header with buddy name & memory indicator ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          _glassButton(
            icon: Icons.close_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              _voiceService.stopListening();
              _voiceService.stopSpeaking();
              Navigator.pop(context);
            },
          ),
          // Buddy name & status
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐕 ', style: TextStyle(fontSize: 18)),
                  Text(
                    _buddyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green online dot
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF43E97B),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF43E97B).withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _llmStatus,
                      key: ValueKey(_llmStatus),
                      style: TextStyle(
                        color: _isLlmReady
                            ? const Color(0xFF43E97B).withOpacity(0.8)
                            : Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Volume toggle
          _glassButton(
            icon: _voiceService.isTtsEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            onTap: () {
              setState(() => _voiceService.toggleTts());
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
      ),
    );
  }

  List<Widget> _buildGlowRings(double glow, double wave) {
    return List.generate(4, (i) {
      final ringSize = 180.0 + i * 30.0 + glow * 15 + (i % 2 == 0 ? wave * 8 : 0);
      final opacity = (0.05 - i * 0.01 + glow * 0.02).clamp(0.0, 0.08);
      return Container(
        width: ringSize,
        height: ringSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _getOrbShadowColor().withOpacity(opacity),
            width: 1.0,
          ),
        ),
      );
    });
  }

  Widget _buildWaveformRing(double wave, double orbSize) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: _WaveformPainter(
        progress: wave,
        color: _getOrbShadowColor(),
        isActive: _state == VoiceState.listening || _state == VoiceState.speaking,
      ),
    );
  }

  Color _getOrbShadowColor() {
    switch (_state) {
      case VoiceState.idle:
        return const Color(0xFF7C6AFF);
      case VoiceState.listening:
        return const Color(0xFF00D9FF);
      case VoiceState.thinking:
        return const Color(0xFFBB6BD9);
      case VoiceState.speaking:
        return const Color(0xFF43E97B);
    }
  }

  // ── Status text below dog ──
  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: Text(
        _getStatusText(),
        key: ValueKey(_state),
        style: TextStyle(
          color: _getOrbShadowColor().withOpacity(0.85),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (_state) {
      case VoiceState.idle:
        return 'Tap to start';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.thinking:
        return 'Thinking...';
      case VoiceState.speaking:
        return '$_buddyName bol raha hai...';
    }
  }

  // ── Bottom controls — Premium floating pill style ──
  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // End call button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _voiceService.stopListening();
              _voiceService.stopSpeaking();
              Navigator.pop(context);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4444).withOpacity(0.12),
                border: Border.all(color: const Color(0xFFFF4444).withOpacity(0.3)),
              ),
              child: const Icon(Icons.call_end_rounded, color: Color(0xFFFF4444), size: 22),
            ),
          ),

          // Main mic button — neon glow
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getOrbShadowColor(),
                    _getOrbShadowColor().withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getOrbShadowColor().withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                _state == VoiceState.listening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // Skip button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_state == VoiceState.speaking) {
                _voiceService.stopSpeaking();
                _startListening();
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Icon(Icons.skip_next_rounded, color: Colors.white.withOpacity(0.55), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 💠 MINI PULSE — Live indicator for transcript
// ═══════════════════════════════════════════════════════════

class _MiniPulse extends StatefulWidget {
  @override
  State<_MiniPulse> createState() => _MiniPulseState();
}

class _MiniPulseState extends State<_MiniPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
        width: 6 + (_controller.value * 2),
        height: 6 + (_controller.value * 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00D9FF).withOpacity(0.5 + _controller.value * 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withOpacity(0.3 * _controller.value),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 🎨 WAVEFORM PAINTER
// ═══════════════════════════════════════════════════════════

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isActive;

  _WaveformPainter({
    required this.progress,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Primary waveform
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const waveCount = 72;

    for (int i = 0; i <= waveCount; i++) {
      final angle = (i / waveCount) * math.pi * 2;
      final waveOffset = math.sin(angle * 8 + progress * math.pi * 2) * 12;
      final waveOffset2 = math.cos(angle * 5 + progress * math.pi * 4) * 6;
      final r = radius + waveOffset + waveOffset2;

      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Outer echo wave
    final paint2 = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path2 = Path();
    for (int i = 0; i <= waveCount; i++) {
      final angle = (i / waveCount) * math.pi * 2;
      final waveOffset = math.sin(angle * 6 + progress * math.pi * 3 + 1) * 8;
      final r = radius + 20 + waveOffset;

      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}

// ═══════════════════════════════════════════════════════════
// ✨ PARTICLE FIELD PAINTER
// ═══════════════════════════════════════════════════════════

class _Particle {
  double x, y, size, speed, opacity, angle;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });
}

class _ParticleFieldPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final Color stateColor;

  _ParticleFieldPainter({
    required this.particles,
    required this.time,
    required this.stateColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = time * p.speed;
      final dx = p.x * size.width + math.sin(t * math.pi * 2 + p.angle) * 30;
      final dy = p.y * size.height + math.cos(t * math.pi * 2 * 0.7 + p.angle) * 25;

      // Twinkle effect
      final twinkle = (math.sin(t * math.pi * 6 + p.angle * 3) * 0.5 + 0.5);
      final finalOpacity = (p.opacity * twinkle).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = Color.lerp(Colors.white, stateColor, 0.3)!.withOpacity(finalOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);

      canvas.drawCircle(
        Offset(dx.clamp(0.0, size.width), dy.clamp(0.0, size.height)),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) => true;
}
