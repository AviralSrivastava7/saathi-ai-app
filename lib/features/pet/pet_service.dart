import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../core/storage/mood_storage.dart';


/// Dog personality — affects AI conversation style
enum DogPersonality { calm, naughty, protective }

class PetService extends ChangeNotifier {
  static const String keyHunger = 'pet_hunger';
  static const String keyHappiness = 'pet_happiness';
  static const String keyEnergy = 'pet_energy';
  static const String keyLastUpdated = 'pet_last_updated';
  static const String keyLastVisit = 'pet_last_visit';
  static const String keyFeedCount = 'pet_feed_count';
  static const String keyFeedResetDate = 'pet_feed_reset_date';
  // --- Bonding & Personality ---
  static const String keyBondLevel = 'pet_bond_level';
  static const String keyPersonality = 'pet_personality';
  static const String keyUnlockedAccessories = 'pet_unlocked_accessories';
  static const String keyActiveAccessories = 'pet_active_accessories';
  static const String keyDailyInteractions = 'pet_daily_interactions';
  static const String keyDailyInteractionsDate = 'pet_daily_interactions_date';

  double _hunger = 50.0;
  double _happiness = 50.0;
  double _energy = 50.0;
  DateTime _lastUpdated = DateTime.now();
  DateTime _lastVisit = DateTime.now();
  int _feedCount = 0;
  bool _overFed = false;

  // --- Bonding & Personality State ---
  double _bondLevel = 0.0;
  DogPersonality _personality = DogPersonality.calm;
  List<String> _unlockedAccessories = ['collar']; // collar unlocked by default
  List<String> _activeAccessories = [];
  int _dailyInteractions = 0;

  // Cooldown tracking
  DateTime _lastFeedTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastSleepTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _cooldownDuration = Duration(minutes: 3);

  // User mood integration
  String _userMood = '';
  String get userMood => _userMood;

  double get hunger => _hunger;
  double get happiness => _happiness;
  double get energy => _energy;
  bool get overFed => _overFed;
  int get feedCount => _feedCount;

  // --- Bonding & Personality Getters ---
  double get bondLevel => _bondLevel;
  DogPersonality get personality => _personality;
  List<String> get unlockedAccessories => List.unmodifiable(_unlockedAccessories);
  List<String> get activeAccessories => List.unmodifiable(_activeAccessories);
  int get dailyInteractions => _dailyInteractions;

  /// Bond stage: 0=stranger, 1=acquaintance, 2=friend, 3=best_friend, 4=soulmate
  int get bondStage {
    if (_bondLevel >= 80) return 4;
    if (_bondLevel >= 55) return 3;
    if (_bondLevel >= 30) return 2;
    if (_bondLevel >= 10) return 1;
    return 0;
  }

  String get bondStageKey {
    switch (bondStage) {
      case 4: return 'bond_stage_soulmate';
      case 3: return 'bond_stage_bestfriend';
      case 2: return 'bond_stage_friend';
      case 1: return 'bond_stage_acquaintance';
      default: return 'bond_stage_new';
    }
  }

  /// Personality display name
  String get personalityName {
    switch (_personality) {
      case DogPersonality.calm: return 'Shanti Wala 🧘';
      case DogPersonality.naughty: return 'Masti Khor 😜';
      case DogPersonality.protective: return 'Rakhwala 🛡️';
    }
  }

  Timer? _decayTimer;

  PetService() {
    _loadState();
    _loadUserMood();
    _loadBondingState();
    _decayTimer = Timer.periodic(const Duration(minutes: 1), (_) => _applyDecay());
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }

  /// Composite emotional state of the pet
  PetMood get mood {
    final avg = (_hunger + _happiness + _energy) / 3;
    if (_overFed) return PetMood.overfed;
    if (isLonely) return PetMood.lonely;
    if (_energy < 20) return PetMood.tired;
    if (_hunger < 30) return PetMood.hungry;
    if (avg > 80) return PetMood.ecstatic;
    if (avg > 60) return PetMood.happy;
    if (avg > 40) return PetMood.content;
    return PetMood.sad;
  }

  /// Minutes since last visit
  int get minutesSinceLastVisit {
    return DateTime.now().difference(_lastVisit).inMinutes;
  }

  /// Is pet lonely? (>6 hours since last visit)
  bool get isLonely => minutesSinceLastVisit > 360;

  // Cooldown checks
  bool get canFeed => DateTime.now().difference(_lastFeedTime) > _cooldownDuration;
  bool get canPlay => DateTime.now().difference(_lastPlayTime) > _cooldownDuration;
  bool get canSleep => DateTime.now().difference(_lastSleepTime) > _cooldownDuration;

  int getCooldown(String action) {
    switch (action) {
      case 'feed': return feedCooldownRemaining.inSeconds;
      case 'play': return playCooldownRemaining.inSeconds;
      case 'sleep': return sleepCooldownRemaining.inSeconds;
      default: return 0;
    }
  }

  Duration get feedCooldownRemaining {
    final remaining = _cooldownDuration - DateTime.now().difference(_lastFeedTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }
  Duration get playCooldownRemaining {
    final remaining = _cooldownDuration - DateTime.now().difference(_lastPlayTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }
  Duration get sleepCooldownRemaining {
    final remaining = _cooldownDuration - DateTime.now().difference(_lastSleepTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Speech bubble key based on mood
  String get speechTextKey {
    switch (mood) {
      case PetMood.ecstatic: return 'speech_ecstatic';
      case PetMood.happy: return 'speech_happy';
      case PetMood.content: return 'speech_content';
      case PetMood.lonely: return 'speech_lonely';
      case PetMood.hungry: return 'speech_hungry';
      case PetMood.tired: return 'speech_tired';
      case PetMood.overfed: return 'speech_overfed';
      case PetMood.sad: return 'speech_sad';
    }
  }

  /// Argument for speech bubble if any
  String get speechTextArg {
    if (mood == PetMood.lonely) {
      return (minutesSinceLastVisit ~/ 60).toString();
    }
    return '';
  }

  /// Emoji for current mood
  String get moodEmoji {
    switch (mood) {
      case PetMood.ecstatic: return '🤩';
      case PetMood.happy: return '😊';
      case PetMood.content: return '😌';
      case PetMood.lonely: return '😢';
      case PetMood.hungry: return '😋';
      case PetMood.tired: return '😴';
      case PetMood.overfed: return '🤢';
      case PetMood.sad: return '😔';
    }
  }

  Future<void> _loadUserMood() async {
    _userMood = await MoodStorage.loadTodayMood();
    notifyListeners();
  }

  /// Refresh user mood (call when pet screen opens)
  Future<void> refreshUserMood() async {
    _userMood = await MoodStorage.loadTodayMood();
    notifyListeners();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    _hunger = prefs.getDouble(keyHunger) ?? 50.0;
    _happiness = prefs.getDouble(keyHappiness) ?? 50.0;
    _energy = prefs.getDouble(keyEnergy) ?? 50.0;

    final lastUpdatedStr = prefs.getString(keyLastUpdated);
    if (lastUpdatedStr != null) {
      _lastUpdated = DateTime.parse(lastUpdatedStr);
      _calculateOfflineDecay();
    } else {
      _lastUpdated = DateTime.now();
      _saveState();
    }

    // Load last visit
    final lastVisitStr = prefs.getString(keyLastVisit);
    if (lastVisitStr != null) {
      _lastVisit = DateTime.parse(lastVisitStr);
    }

    // Load feed count (reset daily)
    final today = DateTime.now().toString().split(' ')[0];
    final savedFeedDate = prefs.getString(keyFeedResetDate) ?? '';
    if (savedFeedDate == today) {
      _feedCount = prefs.getInt(keyFeedCount) ?? 0;
    } else {
      _feedCount = 0;
      await prefs.setString(keyFeedResetDate, today);
      await prefs.setInt(keyFeedCount, 0);
    }

    _overFed = _feedCount >= 8 && _hunger > 95;

    // Mark this visit
    _lastVisit = DateTime.now();
    await prefs.setString(keyLastVisit, _lastVisit.toIso8601String());

    notifyListeners();
  }

  void _calculateOfflineDecay() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated).inMinutes;

    if (difference > 0) {
      // Slower offline decay
      final decayAmount = difference * 0.08;

      _hunger = (_hunger - decayAmount).clamp(0.0, 100.0);
      _happiness = (_happiness - decayAmount).clamp(0.0, 100.0);
      _energy = (_energy - decayAmount).clamp(0.0, 100.0);

      _lastUpdated = now;
      _saveState();
      notifyListeners();
    }
  }

  void _applyDecay() {
    // Faster real-time decay so stats don't stay maxed
    _hunger = (_hunger - 0.4).clamp(0.0, 100.0);
    _happiness = (_happiness - 0.25).clamp(0.0, 100.0);
    _energy = (_energy - 0.3).clamp(0.0, 100.0);
    _lastUpdated = DateTime.now();
    _overFed = false; // Overfed state clears over time
    _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyHunger, _hunger);
    await prefs.setDouble(keyHappiness, _happiness);
    await prefs.setDouble(keyEnergy, _energy);
    await prefs.setString(keyLastUpdated, _lastUpdated.toIso8601String());
  }

  void feed() {
    if (!canFeed) return;
    _lastFeedTime = DateTime.now();
    _feedCount++;
    _saveFeedCount();

    if (_feedCount >= 8 && _hunger > 90) {
      _overFed = true;
      _happiness = (_happiness - 5.0).clamp(0.0, 100.0);
    } else {
      _hunger = (_hunger + 12.0).clamp(0.0, 100.0);
      _happiness = (_happiness + 3.0).clamp(0.0, 100.0);
      _overFed = false;
    }
    addBondPoints(1.5); // Feeding builds bond
    _saveState();
    notifyListeners();
  }

  void play() {
    if (!canPlay) return;
    _lastPlayTime = DateTime.now();
    if (_energy > 10) {
      _happiness = (_happiness + 10.0).clamp(0.0, 100.0);
      _energy = (_energy - 5.0).clamp(0.0, 100.0);
      _hunger = (_hunger - 3.0).clamp(0.0, 100.0);
      addBondPoints(2.0); // Playing builds strong bond
      _saveState();
      notifyListeners();
    }
  }

  void sleep() {
    if (!canSleep) return;
    _lastSleepTime = DateTime.now();
    _energy = (_energy + 15.0).clamp(0.0, 100.0);
    addBondPoints(1.0); // Caring enough to let them sleep
    _saveState();
    notifyListeners();
  }

  /// Boost from playing buddy games
  void buddyGameBoost() {
    _happiness = (_happiness + 8.0).clamp(0.0, 100.0);
    _energy = (_energy + 3.0).clamp(0.0, 100.0);
    _saveState();
    notifyListeners();
  }

  /// Record a visit (called when pet screen opens)
  void recordVisit() async {
    _lastVisit = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastVisit, _lastVisit.toIso8601String());
    // Being visited makes pet happier
    if (isLonely) {
      _happiness = (_happiness + 8.0).clamp(0.0, 100.0);
    }
    addBondPoints(0.5); // Just visiting builds bond
    await refreshUserMood();
    notifyListeners();
  }

  Future<void> _saveFeedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    await prefs.setString(keyFeedResetDate, today);
    await prefs.setInt(keyFeedCount, _feedCount);
  }

  // ═══════════════════════════════════════════
  // BONDING & PERSONALITY SYSTEM
  // ═══════════════════════════════════════════

  Future<void> _loadBondingState() async {
    final prefs = await SharedPreferences.getInstance();
    _bondLevel = prefs.getDouble(keyBondLevel) ?? 0.0;
    
    final personalityStr = prefs.getString(keyPersonality) ?? 'calm';
    _personality = DogPersonality.values.firstWhere(
      (p) => p.name == personalityStr,
      orElse: () => DogPersonality.calm,
    );

    final unlockedJson = prefs.getString(keyUnlockedAccessories);
    if (unlockedJson != null) {
      _unlockedAccessories = List<String>.from(jsonDecode(unlockedJson));
    }
    if (!_unlockedAccessories.contains('collar')) {
      _unlockedAccessories.add('collar');
    }

    final activeJson = prefs.getString(keyActiveAccessories);
    if (activeJson != null) {
      _activeAccessories = List<String>.from(jsonDecode(activeJson));
    }

    // Daily interactions reset
    final today = DateTime.now().toString().split(' ')[0];
    final savedDate = prefs.getString(keyDailyInteractionsDate) ?? '';
    if (savedDate == today) {
      _dailyInteractions = prefs.getInt(keyDailyInteractions) ?? 0;
    } else {
      _dailyInteractions = 0;
      await prefs.setString(keyDailyInteractionsDate, today);
      await prefs.setInt(keyDailyInteractions, 0);
    }

    // Auto-unlock accessories based on bond level
    _checkAccessoryUnlocks();
    notifyListeners();
  }

  Future<void> _saveBondingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyBondLevel, _bondLevel);
    await prefs.setString(keyPersonality, _personality.name);
    await prefs.setString(keyUnlockedAccessories, jsonEncode(_unlockedAccessories));
    await prefs.setString(keyActiveAccessories, jsonEncode(_activeAccessories));
    await prefs.setInt(keyDailyInteractions, _dailyInteractions);
    await prefs.setString(keyDailyInteractionsDate, DateTime.now().toString().split(' ')[0]);
  }

  /// Increase bond from interaction (feed, play, sleep, chat)
  void addBondPoints(double points) {
    _bondLevel = (_bondLevel + points).clamp(0.0, 100.0);
    _dailyInteractions++;
    _checkAccessoryUnlocks();
    _saveBondingState();
    notifyListeners();
  }

  /// Set dog personality (persists)
  void setPersonality(DogPersonality p) {
    _personality = p;
    _saveBondingState();
    notifyListeners();
  }

  /// Toggle an accessory on/off
  void toggleAccessory(String accessory) {
    if (!_unlockedAccessories.contains(accessory)) return;
    if (_activeAccessories.contains(accessory)) {
      _activeAccessories.remove(accessory);
    } else {
      _activeAccessories.add(accessory);
    }
    _saveBondingState();
    notifyListeners();
  }

  /// Check and auto-unlock accessories at bond thresholds
  void _checkAccessoryUnlocks() {
    // collar: always unlocked
    if (_bondLevel >= 20 && !_unlockedAccessories.contains('hat')) {
      _unlockedAccessories.add('hat');
    }
    if (_bondLevel >= 45 && !_unlockedAccessories.contains('specs')) {
      _unlockedAccessories.add('specs');
    }
    if (_bondLevel >= 70 && !_unlockedAccessories.contains('bowtie')) {
      _unlockedAccessories.add('bowtie');
    }
  }

  /// Available accessories with their unlock requirements  
  static const Map<String, double> accessoryThresholds = {
    'collar': 0,
    'hat': 20,
    'specs': 45,
    'bowtie': 70,
  };

  /// Emoji for accessory display
  static String accessoryEmoji(String accessory) {
    switch (accessory) {
      case 'collar': return '📿';
      case 'hat': return '🎩';
      case 'specs': return '👓';
      case 'bowtie': return '🎀';
      default: return '✨';
    }
  }

  /// Translation key for accessory name
  static String accessoryNameKey(String accessory) {
    switch (accessory) {
      case 'collar': return 'acc_collar';
      case 'hat': return 'acc_hat';
      case 'specs': return 'acc_specs';
      case 'bowtie': return 'acc_bowtie';
      default: return accessory;
    }
  }
}

enum PetMood {
  ecstatic,
  happy,
  content,
  lonely,
  hungry,
  tired,
  overfed,
  sad,
}
