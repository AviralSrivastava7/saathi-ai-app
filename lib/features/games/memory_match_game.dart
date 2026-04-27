import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/localization/app_localizations.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  final List<String> _emojis = [
    '🌸', '🍃', '🌊', '🌙', '🌞', '🦋', '🍄', '🏔️',
    '🌸', '🍃', '🌊', '🌙', '🌞', '🦋', '🍄', '🏔️',
  ];
  
  late List<bool> _cardFlipped;
  late List<bool> _cardMatched;
  int? _firstSelectedIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _pairsFound = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _emojis.shuffle();
    _cardFlipped = List.generate(16, (index) => false);
    _cardMatched = List.generate(16, (index) => false);
    _firstSelectedIndex = null;
    _isProcessing = false;
    _moves = 0;
    _pairsFound = 0;
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cardFlipped[index] || _cardMatched[index]) return;

    setState(() {
      _cardFlipped[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _moves++;
      _isProcessing = true;
      
      if (_emojis[_firstSelectedIndex!] == _emojis[index]) {
        _cardMatched[_firstSelectedIndex!] = true;
        _cardMatched[index] = true;
        _pairsFound++;
        _firstSelectedIndex = null;
        _isProcessing = false;

        if (_pairsFound == 8) {
          _showWinDialog();
        }
      } else {
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _cardFlipped[_firstSelectedIndex!] = false;
              _cardFlipped[index] = false;
              _firstSelectedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(AppLocalizations.of(context).t('great_job'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(AppLocalizations.of(context).t('memory_win_msg', {'val': '$_moves'}),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _startNewGame());
            },
            child: Text(AppLocalizations.of(context).t('play_again')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).t('back_to_games')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('game_memory_match'), style: TextStyle(color: colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: () => setState(() => _startNewGame()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(AppLocalizations.of(context).t('moves_label'), _moves.toString()),
                  _buildStatCard(AppLocalizations.of(context).t('pairs_label'), '$_pairsFound/8'),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    bool isVisible = _cardFlipped[index] || _cardMatched[index];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isVisible ? Colors.purple.withOpacity(0.12) : Colors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVisible ? Colors.purple.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isVisible
                ? Text(_emojis[index], key: ValueKey('emoji_$index'), style: const TextStyle(fontSize: 32))
                : Icon(Icons.help_outline_rounded, key: ValueKey('back_$index'), color: Colors.white24, size: 32),
          ),
        ),
      ),
    );
  }
}
