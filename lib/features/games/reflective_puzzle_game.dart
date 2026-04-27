import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class ReflectivePuzzleGame extends StatefulWidget {
  const ReflectivePuzzleGame({super.key});

  @override
  State<ReflectivePuzzleGame> createState() => _ReflectivePuzzleGameState();
}

class _ReflectivePuzzleGameState extends State<ReflectivePuzzleGame> {
  late List<int> _tiles;
  int _moves = 0;
  bool _isWin = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _tiles = List.generate(9, (index) => index);
    _tiles.shuffle();
    while (!_isSolvable(_tiles)) {
      _tiles.shuffle();
    }
    _moves = 0;
    _isWin = false;
  }

  bool _isSolvable(List<int> tiles) {
    int inversions = 0;
    for (int i = 0; i < tiles.length - 1; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] != 0 && tiles[j] != 0 && tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }
    return inversions % 2 == 0;
  }

  void _onTileTap(int index) {
    if (_isWin) return;

    int emptyIndex = _tiles.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        _tiles[emptyIndex] = _tiles[index];
        _tiles[index] = 0;
        _moves++;
        _checkWin();
      });
    }
  }

  bool _isAdjacent(int i, int j) {
    int row1 = i ~/ 3, col1 = i % 3;
    int row2 = j ~/ 3, col2 = j % 3;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
           (col1 == col2 && (row1 - row2).abs() == 1);
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < 8; i++) {
      if (_tiles[i] != i + 1) {
        win = false;
        break;
      }
    }
    if (win && _tiles[8] == 0) {
      _isWin = true;
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(AppLocalizations.of(context).t('puzzle_solved'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(AppLocalizations.of(context).t('puzzle_summary', {'val': '$_moves'}),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _startNewGame());
            },
            child: Text(AppLocalizations.of(context).t('new_game')),
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
        title: Text(AppLocalizations.of(context).t('game_reflective_puzzle'), style: TextStyle(color: colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatCard(AppLocalizations.of(context).t('moves_label'), _moves.toString()),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return _buildTile(index);
                },
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              AppLocalizations.of(context).t('puzzle_instr'),
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildTile(int index) {
    int value = _tiles[index];
    if (value == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.withOpacity(0.4),
              Colors.teal.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
