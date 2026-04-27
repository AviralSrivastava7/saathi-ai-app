import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/config/app_language.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_toast.dart';
import 'pet_service.dart';
import 'buddy_mood_messages.dart';
import 'buddy_games_screen.dart';
import 'saathi_dog_avatar.dart';
import '../chat/voice_chat_screen.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  // Core breathing / idle animation
  late AnimationController _breatheController;
  // Bounce when tapped
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;
  // Action feedback (feed / play / sleep)
  late AnimationController _actionController;
  late Animation<double> _actionAnim;
  // Glow pulse
  late AnimationController _glowController;
  // Floating particles
  late AnimationController _particleController;
  // Eye blink
  Timer? _blinkTimer;
  bool _isBlinking = false;
  // Action state
  String _currentAction = ''; // 'feed', 'play', 'sleep', ''
  // Floating emojis
  final List<_FloatingEmoji> _floatingEmojis = [];
  // Buddy name
  String _buddyName = 'Buddy';

  static const String _buddyNameKey = 'buddy_display_name';
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _loadBuddyName();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _actionAnim = CurvedAnimation(parent: _actionController, curve: Curves.easeOutBack);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scheduleNextBlink();
  }

  Future<void> _loadBuddyName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _buddyName = prefs.getString(_buddyNameKey) ?? 'Buddy');
    }
  }

  Future<void> _saveBuddyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_buddyNameKey, name);
    if (mounted) setState(() => _buddyName = name);
  }

  void _showRenameDialog(AppLocalizations loc) {
    _nameController.text = _buddyName;
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(loc.t('name_your_buddy')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.t('name_buddy_desc'), style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: loc.t('name_buddy_hint'),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.t('cancel'))),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                _saveBuddyName(_nameController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text(loc.t('save_btn')),
          ),
        ],
      ),
    );
  }

  void _scheduleNextBlink() {
    if (!mounted) return;
    final delay = Duration(milliseconds: 2000 + (math.Random().nextInt(3000)));
    _blinkTimer = Timer(delay, () async {
      if (!mounted) return;
      setState(() => _isBlinking = true);
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) setState(() => _isBlinking = false);
      _scheduleNextBlink();
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _breatheController.dispose();
    _bounceController.dispose();
    _actionController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _triggerAction(String action, PetService petService) {
    final loc = AppLocalizations.of(context);
    final cooldown = petService.getCooldown(action);
    if (cooldown > 0) {
      final mins = cooldown ~/ 60;
      final secs = cooldown % 60;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('wait_cooldown').replaceAll('{min}', mins.toString()).replaceAll('{sec}', secs.toString()))),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _currentAction = action);

    String message = '';
    if (action == 'feed') {
      petService.feed();
      _spawnFloatingEmojis(['🍎', '🥕', '🍖', '🍰']);
      message = loc.t('buddy_happy_feed');
    } else if (action == 'play') {
      petService.play();
      _spawnFloatingEmojis(['💖', '⭐', '🎾', '✨']);
      message = loc.t('buddy_happy_play');
    } else {
      petService.sleep();
      _spawnFloatingEmojis(['💤', '🌙', '☁️', '⭐']);
      message = loc.t('buddy_happy_sleep');
    }

    _bounceController.forward(from: 0);
    _actionController.forward(from: 0);

    AnimatedToast.show(
      context,
      message: message,
      emoji: action == 'feed' ? '🐶' : (action == 'play' ? '🎉' : '😴'),
      accentColor: action == 'feed'
          ? Colors.orange
          : (action == 'play' ? Colors.pink : Colors.indigo),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _currentAction = '');
    });
  }

  void _spawnFloatingEmojis(List<String> emojis) {
    final random = math.Random();
    for (int i = 0; i < 6; i++) {
      _floatingEmojis.add(_FloatingEmoji(
        emoji: emojis[random.nextInt(emojis.length)],
        x: -60.0 + random.nextDouble() * 120,
        startTime: DateTime.now().add(Duration(milliseconds: i * 120)),
        duration: const Duration(milliseconds: 1800),
      ));
    }
    setState(() {});
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _floatingEmojis.removeWhere((e) =>
            DateTime.now().difference(e.startTime) > e.duration + const Duration(milliseconds: 500));
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) {
        final svc = PetService();
        svc.recordVisit();
        return svc;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _buddyName,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
              tooltip: loc.t('rename_buddy'),
              onPressed: () => _showRenameDialog(loc),
            ),
          ],
        ),
        body: ZenAuraBackground(
          child: Consumer<PetService>(
            builder: (context, petService, _) {
              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildMoodMessage(petService, colorScheme),
                      const SizedBox(height: 12),
                      _buildStatusBars(petService, colorScheme),
                      const SizedBox(height: 16),
                      _build3DPet(petService),
                      const SizedBox(height: 16),
                      _buildActionButtons(petService),
                      const SizedBox(height: 16),
                      _buildBondSection(petService, colorScheme),
                      const SizedBox(height: 12),
                      _buildAccessoriesCloset(petService, colorScheme),
                      const SizedBox(height: 12),
                      _buildBottomButtons(petService, colorScheme),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBars(PetService petService, ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _animatedStatItem(loc.t('stat_hunger'), petService.hunger, Icons.restaurant_rounded, Colors.orange)),
          Expanded(child: _animatedStatItem(loc.t('stat_happy'), petService.happiness, Icons.favorite_rounded, Colors.pink)),
          Expanded(child: _animatedStatItem(loc.t('stat_energy'), petService.energy, Icons.bolt_rounded, Colors.indigo)),
        ],
      ),
    );
  }

  Widget _animatedStatItem(String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        // Animated icon with scale on value change
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        // Animated progress bar
        SizedBox(
          width: 54,
          height: 6,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, _) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: animVal.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.6)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Animated value text
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animVal, _) {
            return Text(
              '${animVal.toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
      ],
    );
  }

  // ────── 3D Pet Character ──────
  Widget _build3DPet(PetService petService) {
    final loc = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheController, _bounceController, _glowController, _particleController]),
      builder: (context, _) {
        final breatheValue = _breatheController.value;
        final floatY = math.sin(breatheValue * math.pi) * 12;
        final tiltX = math.sin(breatheValue * math.pi * 2) * 0.03;
        final scale = _bounceAnim.value;

        // Dynamic glow color based on mood
        final glowColor = petService.happiness > 70
            ? Color.lerp(Colors.purple, Colors.pink, _glowController.value)!
            : (petService.happiness > 30
                ? Color.lerp(Colors.orange, Colors.amber, _glowController.value)!
                : Color.lerp(Colors.blue, Colors.indigo, _glowController.value)!);

        return GestureDetector(
          onTap: () {
            _bounceController.forward(from: 0);
            HapticFeedback.lightImpact();
          },
          child: SizedBox(
            width: 280,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Ambient Glow ──
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.15 + _glowController.value * 0.1),
                          blurRadius: 80 + _glowController.value * 20,
                          spreadRadius: 30 + _glowController.value * 10,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Shadow on ground ──
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08 + breatheValue * 0.04),
                          blurRadius: 25 + breatheValue * 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Floating Emojis ──
                ..._buildFloatingEmojis(),

                // ── 3D Pet Body ──
                Transform.translate(
                  offset: Offset(0, -floatY),
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateX(tiltX)
                        ..rotateZ(tiltX * 0.5),
                      child: _buildPetBody(petService, glowColor),
                    ),
                  ),
                ),

                // ── Action Overlay ──
                if (_currentAction.isNotEmpty)
                  _buildActionOverlay(),

                // ── Speech Bubble ──
                Positioned(
                  top: 10 + floatY * 0.3,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        loc.t(petService.speechTextKey, {'val': petService.speechTextArg}),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),

                // ── Pet Name Badge ──
                Positioned(
                  bottom: 30 + floatY * 0.3,
                  child: Transform.scale(
                    scale: scale,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      borderRadius: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            petService.moodEmoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(_buddyName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: -0.3)),
                        ],
                      ),
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

  Widget _buildPetBody(PetService petService, Color glowColor) {
    return SaathiDogAvatar(
      size: 160,
      voiceState: DogVoiceState.idle,
      happiness: petService.happiness,
      energy: petService.energy,
      hunger: petService.hunger,
      isEating: _currentAction == 'feed',
      isPlaying: _currentAction == 'play',
      isSleeping: _currentAction == 'sleep',
      glowColor: glowColor,
      activeAccessories: petService.activeAccessories,
      bondLevel: petService.bondLevel,
    );
  }

  Widget _buildActionOverlay() {
    return AnimatedBuilder(
      animation: _actionController,
      builder: (context, _) {
        return Positioned(
          top: 10 - _actionAnim.value * 50,
          child: Opacity(
            opacity: (1.0 - _actionAnim.value).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.5 + _actionAnim.value * 0.8,
              child: Text(
                _currentAction == 'feed'
                    ? '🍎'
                    : (_currentAction == 'play' ? '💖' : '🌙'),
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingEmojis() {
    final now = DateTime.now();
    return _floatingEmojis.map((e) {
      final elapsed = now.difference(e.startTime);
      if (elapsed.isNegative) return const SizedBox.shrink();
      final progress = (elapsed.inMilliseconds / e.duration.inMilliseconds).clamp(0.0, 1.0);
      final opacity = progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3);

      return Positioned(
        left: 140 + e.x,
        top: 80 - progress * 120,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.5 + progress * 0.5,
            child: Text(e.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      );
    }).toList();
  }

  // ────── Mood-Aware Message ──────
  Widget _buildMoodMessage(PetService petService, ColorScheme cs) {
    final langCode = AppLanguage.instance.current;
    final userMood = petService.userMood;
    final message = userMood.isNotEmpty
        ? BuddyMoodMessages.getMoodGreeting(userMood, langCode)
        : BuddyMoodMessages.getWelcomeBack(langCode);
    final recommendation = userMood.isNotEmpty
        ? BuddyMoodMessages.getRecommendation(userMood, langCode)
        : null;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🦊', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                ),
              ),
            ],
          ),
          if (recommendation != null) ...[        
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: cs.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(recommendation, style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 12))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ────── Action Buttons ──────
  Widget _buildActionButtons(PetService petService) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _animatedActionButton(loc.t('btn_feed'), () => _triggerAction('feed', petService), Icons.cake_rounded, Colors.orange, '🍎', petService.canFeed)),
        const SizedBox(width: 10),
        Expanded(child: _animatedActionButton(loc.t('btn_play'), () => _triggerAction('play', petService), Icons.sports_tennis_rounded, Colors.pink, '🎾', petService.canPlay)),
        const SizedBox(width: 10),
        Expanded(child: _animatedActionButton(loc.t('btn_rest'), () => _triggerAction('sleep', petService), Icons.bedtime_rounded, Colors.indigo, '🌙', petService.canSleep)),
      ],
    );
  }

  Widget _animatedActionButton(String label, VoidCallback onTap, IconData icon, Color color, String emoji, bool isReady) {
    return _TapBounceWidget(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 22,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(isReady ? 0.2 : 0.06), color.withOpacity(isReady ? 0.05 : 0.02)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isReady ? color : color.withOpacity(0.3), size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: isReady ? color : color.withOpacity(0.3))),
            if (!isReady)
              Text('⏳', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ────── Bond Level Section ──────
  Widget _buildBondSection(PetService petService, ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    final bondPercent = (petService.bondLevel / 100).clamp(0.0, 1.0);
    final bondColor = petService.bondStage >= 3
        ? const Color(0xFFE040FB)
        : (petService.bondStage >= 2
            ? const Color(0xFFFF7043)
            : const Color(0xFF42A5F5));

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                loc.t('bond_level'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bondColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bondColor.withOpacity(0.3)),
                ),
                child: Text(
                  loc.t(petService.bondStageKey),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: bondColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated bond bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: bondPercent),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Stack(
                    children: [
                      Container(color: cs.onSurface.withOpacity(0.06)),
                      FractionallySizedBox(
                        widthFactor: val,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [bondColor, bondColor.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${petService.bondLevel.toStringAsFixed(1)} / 100',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.5)),
              ),
              Text(
                loc.t('interactions_today', petService.dailyInteractions),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────── Accessories Closet ──────
  Widget _buildAccessoriesCloset(PetService petService, ColorScheme cs) {
    final loc = AppLocalizations.of(context);
    final accessories = PetService.accessoryThresholds.entries.toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👔', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                loc.t('closet'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                loc.t('worn_count', petService.activeAccessories.length),
                style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.4), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: accessories.map((entry) {
              final name = entry.key;
              final threshold = entry.value;
              final isUnlocked = petService.unlockedAccessories.contains(name);
              final isActive = petService.activeAccessories.contains(name);
              final emoji = PetService.accessoryEmoji(name);
              final displayName = loc.t(PetService.accessoryNameKey(name));

              return Expanded(
                child: GestureDetector(
                  onTap: isUnlocked
                      ? () {
                          petService.toggleAccessory(name);
                          HapticFeedback.lightImpact();
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cs.primary.withOpacity(0.15)
                          : (isUnlocked
                              ? cs.onSurface.withOpacity(0.04)
                              : cs.onSurface.withOpacity(0.02)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? cs.primary.withOpacity(0.5)
                            : (isUnlocked
                                ? cs.onSurface.withOpacity(0.1)
                                : cs.onSurface.withOpacity(0.05)),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isUnlocked ? emoji : '🔒',
                          style: TextStyle(
                            fontSize: 22,
                            color: isUnlocked ? null : cs.onSurface.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? cs.primary
                                : (isUnlocked
                                    ? cs.onSurface.withOpacity(0.7)
                                    : cs.onSurface.withOpacity(0.3)),
                          ),
                        ),
                        if (!isUnlocked)
                          Text(
                            loc.t('bond_unlock', threshold.toInt()),
                            style: TextStyle(
                              fontSize: 8,
                              color: cs.onSurface.withOpacity(0.3),
                            ),
                          ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }




  // ────── Bottom Buttons (Games + Voice + Chat) ──────
  Widget _buildBottomButtons(PetService petService, ColorScheme colorScheme) {
    return Row(
      children: [
        // Games button
        Expanded(
          child: _TapBounceWidget(
            onTap: () => Navigator.push(context, smoothPageRoute(page: BuddyGamesScreen(petService: petService))),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFF59E0B), const Color(0xFFF59E0B).withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).t('games'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // 🎙️ Voice mode button
        Expanded(
          child: _TapBounceWidget(
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const VoiceChatScreen(),
                transitionsBuilder: (_, anim, __, child) {
                  return FadeTransition(opacity: anim, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF6C63FF), const Color(0xFF00D9FF).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Voice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Chat button
        Expanded(
          flex: 2,
          child: _TapBounceWidget(
            onTap: () => Navigator.pushNamed(context, '/chat'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).t('talk_to_buddy'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tap Bounce Widget ──
class _TapBounceWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapBounceWidget({required this.child, required this.onTap});

  @override
  State<_TapBounceWidget> createState() => _TapBounceWidgetState();
}

class _TapBounceWidgetState extends State<_TapBounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ── Floating Emoji Data ──
class _FloatingEmoji {
  final String emoji;
  final double x;
  final DateTime startTime;
  final Duration duration;

  _FloatingEmoji({
    required this.emoji,
    required this.x,
    required this.startTime,
    required this.duration,
  });
}
