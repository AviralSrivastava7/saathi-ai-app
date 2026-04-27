import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/zen_aura_background.dart';
import '../../core/widgets/glass_card.dart';

class ThoughtScreen extends StatefulWidget {
  const ThoughtScreen({super.key});

  @override State<ThoughtScreen> createState() => _ThoughtScreenState();
}

class _ThoughtScreenState extends State<ThoughtScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;
  String? _analysis;

  void _analyzeThought() {
    if (_controller.text.isEmpty) return;
    setState(() => _isAnalyzing = true);
    
    // Simulate AI analysis delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysis = "Your thought shows signs of 'All-or-Nothing' thinking. Let's try to find a more balanced perspective.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text(loc.translate('thought_analysis') ?? 'Thought Analysis', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
      ),
      body: ZenAuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('process_thought_desc') ?? 'Describe a thought that\'s bothering you, and we\'ll help you identify cognitive distortions.', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 15, height: 1.6)),
                const SizedBox(height: 32),
                
                // Input GlassCard
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 28,
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 5,
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: loc.translate('type_your_thought') ?? 'Type your thought here...',
                          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
                          border: InputBorder.none,
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeThought,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: _isAnalyzing 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(loc.translate('analyze_now') ?? 'Analyze Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Result GlassCard
                if (_analysis != null)
                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(loc.translate('ai_insight') ?? 'Saathi Insight', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 14)),
                        ]),
                        const SizedBox(height: 18),
                        Text(_analysis!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.5)),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(loc.translate('reframe_thought') ?? 'Help me reframe this', style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
