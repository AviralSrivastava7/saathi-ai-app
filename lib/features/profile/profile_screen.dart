import 'package:flutter/material.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/config/app_language.dart';
import '../../core/storage/mood_storage.dart';
import '../../features/journal/services/journal_service.dart';
import '../../core/services/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  late bool _darkMode;
  bool _biometricEnabled = false;
  bool _biometricSupported = false;

  @override
  void initState() {
    super.initState();
    _darkMode = ThemeManager().isDarkMode;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final bioSupported = await BiometricService.isDeviceSupported();
    final bioEnabled = await BiometricService.isEnabled();
    
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _biometricSupported = bioSupported;
      _biometricEnabled = bioEnabled;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('dark_mode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(loc.t('nav_profile'), style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ZenAuraBackground(
        child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 28,
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withOpacity(0.8), colorScheme.primary.withOpacity(0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 36)),
                      const SizedBox(height: 16),
                      Text(loc.t('wellness_companion'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(loc.t('supporting_journey'), style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('activity_stats'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats will be loaded from AppStats
                  FutureBuilder(
                    future: _loadStats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                      }
                      final stats = snapshot.data as Map<String, dynamic>;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  colorScheme,
                                  isDark,
                                  '${stats['streak']}',
                                  loc.t('days_streak'),
                                  Icons.local_fire_department,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  colorScheme,
                                  isDark,
                                  '${stats['meditation']}',
                                  loc.t('meditation_minutes'),
                                  Icons.self_improvement,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  colorScheme,
                                  isDark,
                                  '${stats['journal']}',
                                  loc.t('journal_entries'),
                                  Icons.book,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  colorScheme,
                                  isDark,
                                  '${stats['tasks']}',
                                  loc.t('tasks_completed'),
                                  Icons.check_circle,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.t('settings'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    colorScheme,
                    isDark,
                    loc.t('notifications'),
                    Icons.notifications,
                    _notificationsEnabled,
                    (value) {
                      setState(() => _notificationsEnabled = value);
                      _savePreferences();
                    },
                  ),
                  _buildSwitchTile(
                    colorScheme,
                    isDark,
                    loc.t('dark_mode'),
                    Icons.dark_mode,
                    _darkMode,
                    (value) {
                      setState(() => _darkMode = value);
                      _savePreferences();
                      _changeDarkMode(value, loc);
                    },
                  ),
                  if (_biometricSupported)
                    _buildSwitchTile(
                      colorScheme,
                      isDark,
                      loc.t('biometric_lock'),
                      Icons.fingerprint,
                      _biometricEnabled,
                      (value) async {
                        if (value) {
                          final success = await BiometricService.authenticate(reason: loc.t('bio_reason_enable'));
                          if (!success) return;
                        }
                        await BiometricService.setEnabled(value);
                        setState(() => _biometricEnabled = value);
                      },
                    ),
                  _buildActionTile(
                    colorScheme,
                    isDark,
                    loc.t('change_language'),
                    Icons.language,
                    Colors.teal,
                    () {
                      _showLanguagePicker(loc);
                    },
                  ),
                  _buildActionTile(
                    colorScheme,
                    isDark,
                    loc.t('privacy_policy'),
                    Icons.privacy_tip,
                    Colors.blue,
                    () {
                      _showPrivacyPolicy(loc);
                    },
                  ),
                  _buildActionTile(
                    colorScheme,
                    isDark,
                    loc.t('about'),
                    Icons.info,
                    Colors.orange,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(loc.t('about_saathi')),
                          content: Text(loc.t('about_text')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(loc.t('ok')),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<Map<String, dynamic>> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = await MoodStorage.getMoodStreak();
    
    final journalService = JournalService();
    final journalEntries = await journalService.getAllEntries();
    
    final meditationMinutes = prefs.getInt('saathi_meditation_minutes') ?? 0;

    return {
      'streak': streak,
      'meditation': meditationMinutes,
      'journal': journalEntries.length,
      'tasks': prefs.getInt('saathi_tasks_completed') ?? 0,
    };
  }

  void _changeDarkMode(bool isDark, AppLocalizations loc) {
    ThemeManager().toggleDarkMode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDark ? loc.t('dark_mode_enabled') : loc.t('light_mode_enabled')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLanguagePicker(AppLocalizations loc) {
    final currentLang = AppLanguage.instance.current;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.t('change_language'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _languageTile('English', 'en', currentLang == 'en'),
              _languageTile('हिंदी', 'hi', currentLang == 'hi'),
              _languageTile('Hinglish', 'hn', currentLang == 'hn'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(String name, String code, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: colorScheme.onSurface)),
      trailing: isSelected ? Icon(Icons.check_circle, color: colorScheme.primary) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? colorScheme.primary.withOpacity(0.1) : null,
      onTap: () {
        AppLanguage.instance.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showPrivacyPolicy(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.t('privacy_policy')),
        content: SingleChildScrollView(
          child: Text(loc.t('privacy_policy_text')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.t('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ColorScheme cs, bool isDark, String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface)),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(ColorScheme cs, bool isDark, String title, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: SwitchListTile(
          title: Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
          secondary: Icon(icon, color: cs.onSurface.withOpacity(0.7)),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionTile(ColorScheme cs, bool isDark, String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: cs.onSurface.withOpacity(0.4)),
          onTap: onTap,
        ),
      ),
    );
  }
}
