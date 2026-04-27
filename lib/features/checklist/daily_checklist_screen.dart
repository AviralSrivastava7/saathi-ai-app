import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/stats_storage.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';

class DailyChecklistScreen extends StatefulWidget {
  const DailyChecklistScreen({super.key});

  @override
  State<DailyChecklistScreen> createState() => _DailyChecklistScreenState();
}

class _DailyChecklistScreenState extends State<DailyChecklistScreen> {
  List<ChecklistItem> _items = [];
  final List<ChecklistItem> _defaultItems = [
    ChecklistItem(emoji: '💧', titleKey: 'drink_water', subtitleKey: 'drink_water_sub', color: AppColors.accentBlue),
    ChecklistItem(emoji: '🧘', titleKey: 'meditate_action', subtitleKey: 'meditate_sub', color: AppColors.primaryPurple),
    ChecklistItem(emoji: '✍️', titleKey: 'journal_action', subtitleKey: 'journal_sub', color: AppColors.accentTeal),
    ChecklistItem(emoji: '🚶', titleKey: 'exercise_action', subtitleKey: 'exercise_sub', color: AppColors.accentGreen),
    ChecklistItem(emoji: '🙏', titleKey: 'gratitude_action', subtitleKey: 'gratitude_sub', color: AppColors.warning),
    ChecklistItem(emoji: '📱', titleKey: 'screen_break', subtitleKey: 'screen_break_sub', color: AppColors.error),
    ChecklistItem(emoji: '☀️', titleKey: 'sunlight', subtitleKey: 'sunlight_sub', color: AppColors.star),
    ChecklistItem(emoji: '😴', titleKey: 'sleep_schedule', subtitleKey: 'sleep_schedule_sub', color: Colors.indigoAccent),
  ];

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final customStrings = prefs.getStringList('custom_checklist_items') ?? [];
    setState(() {
      _items = List.from(_defaultItems);
      for (var s in customStrings) {
        final parts = s.split('|');
        if (parts.length >= 2) {
          _items.add(ChecklistItem(titleKey: parts[0], subtitleKey: parts[1], emoji: parts.length > 2 ? parts[2] : '✨', color: parts.length > 3 ? Color(int.parse(parts[3])) : AppColors.primaryPurple, isCustom: true));
        }
      }
    });
    for (int i = 0; i < _items.length; i++) {
      final key = '${today}_item_${_items[i].titleKey}';
      final isChecked = prefs.getBool(key) ?? false;
      setState(() { _items[i].isCompleted = isChecked; });
    }
  }

  Future<void> _toggleItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final key = '${today}_item_${_items[index].titleKey}';
    setState(() { _items[index].isCompleted = !_items[index].isCompleted; });
    await prefs.setBool(key, _items[index].isCompleted);
    if (_items[index].isCompleted) {
      await StatsStorage.saveTaskCompleted();
      await WeeklyActivityStorage.incrementTodayActivity();
    }
  }

  void _addCustomItem(String title, String subtitle) async {
    final prefs = await SharedPreferences.getInstance();
    final customStrings = prefs.getStringList('custom_checklist_items') ?? [];
    final newItem = '$title|$subtitle|✨|${AppColors.primaryPurple.value}';
    customStrings.add(newItem);
    await prefs.setStringList('custom_checklist_items', customStrings);
    _loadChecklist();
  }

  void _removeCustomItem(int index) async {
    if (!_items[index].isCustom) return;
    final prefs = await SharedPreferences.getInstance();
    final customStrings = prefs.getStringList('custom_checklist_items') ?? [];
    customStrings.removeWhere((s) => s.startsWith(_items[index].titleKey));
    await prefs.setStringList('custom_checklist_items', customStrings);
    _loadChecklist();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  int get _completedCount => _items.where((item) => item.isCompleted).length;
  double get _progress => _items.isEmpty ? 0 : _completedCount / _items.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(loc.t('checklist'), style: TextStyle(color: theme.appBarTheme.titleTextStyle?.color)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: theme.appBarTheme.iconTheme?.color), onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(loc.t('add_activity'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Dismissible(
                      key: Key(item.titleKey + index.toString()),
                      direction: item.isCustom ? DismissDirection.endToStart : DismissDirection.none,
                      onDismissed: (direction) => _removeCustomItem(index),
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.redAccent)),
                      child: _buildChecklistItem(item, index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        gradient: LinearGradient(colors: [AppColors.primaryPurple.withOpacity(0.8), AppColors.primaryPurple.withOpacity(0.4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.t('todays_progress'), style: AppTextStyles.headingLarge.copyWith(fontSize: 22, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('$_completedCount ${loc.t('of')} ${_items.length} ${loc.t('completed')}', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  ],
                ),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Text('${(_progress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: _progress, minHeight: 10, backgroundColor: Colors.white.withOpacity(0.15), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final displayedTitle = item.isCustom ? item.titleKey : loc.t(item.titleKey);
    final displayedSubtitle = item.isCustom ? item.subtitleKey : loc.t(item.subtitleKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        opacity: item.isCompleted ? 0.2 : 0.08,
        color: item.isCompleted ? item.color : null,
        border: item.isCompleted ? Border.all(color: item.color.withOpacity(0.5), width: 1.5) : null,
        child: InkWell(
          onTap: () => _toggleItem(index),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: item.isCompleted ? item.color : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: item.isCompleted ? item.color : Colors.white24, width: 2)),
                  child: item.isCompleted ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                ),
                const SizedBox(width: 16),
                Text(item.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(displayedTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface, decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
                  Text(displayedSubtitle, style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6))),
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.t('add_activity'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: titleController, autofocus: true, decoration: InputDecoration(hintText: loc.t('add_task'), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              TextField(controller: subtitleController, decoration: InputDecoration(hintText: loc.t('buddy_name_hint'), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.t('cancel'), style: const TextStyle(color: Colors.white60))),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () { if (titleController.text.isNotEmpty) { _addCustomItem(titleController.text, subtitleController.text); Navigator.pop(context); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(loc.t('add_task'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChecklistItem {
  final String emoji, titleKey, subtitleKey;
  final Color color;
  bool isCompleted;
  final bool isCustom;
  ChecklistItem({required this.emoji, required this.titleKey, required this.subtitleKey, required this.color, this.isCompleted = false, this.isCustom = false});
}
