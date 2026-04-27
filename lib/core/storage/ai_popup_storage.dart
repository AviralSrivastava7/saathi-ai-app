import 'package:shared_preferences/shared_preferences.dart';

class AIPopupStorage {
  static const _aiPopupKey = 'ai_popup_shown';
  // New keys for multi-LLM model picker
  static const _modelPopupKey = 'seen_model_popup';
  static const _selectedTierKey = 'selected_llm_tier';

  // ── Legacy AI popup (Connect AI sheet) ───────────────
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_aiPopupKey) ?? false);
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiPopupKey, true);
  }

  // ── Model picker popup ────────────────────────────────

  /// Whether the first-run model picker has been shown yet.
  static Future<bool> hasSeenModelPopup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_modelPopupKey) ?? false;
  }

  /// Mark the model picker popup as shown (regardless of choice).
  static Future<void> markModelPopupShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_modelPopupKey, true);
  }

  /// Get the selected LLM tier id ('budget' / 'midRange' / 'highEnd'), or null.
  static Future<String?> getSelectedTierId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTierKey);
  }

  /// Save the selected LLM tier id.
  static Future<void> saveSelectedTierId(String tierId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTierKey, tierId);
  }
}
