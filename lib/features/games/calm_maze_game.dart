// lib/features/games/calm_maze_game.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/localization/app_localizations.dart';

class CalmMazeGame extends StatefulWidget {
  const CalmMazeGame({super.key});

  @override
  State<CalmMazeGame> createState() => _CalmMazeGameState();
}

class _CalmMazeGameState extends State<CalmMazeGame> {
  int _level = 1;
  late int _gridSize;
  late List<List<MazeCell>> _maze;
  late int _playerX;
  late int _playerY;
  bool _isWin = false;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    _gridSize = 5 + (_level * 2); // 7, 9, 11...
    if (_gridSize > 25) _gridSize = 25; // Cap complexity
    _generateMaze();
    _playerX = 0;
    _playerY = 0;
    _isWin = false;
  }

  void _generateMaze() {
    _maze = List.generate(
      _gridSize,
      (y) => List.generate(_gridSize, (x) => MazeCell(x, y)),
    );

    _backtrack(0, 0);
  }

  void _backtrack(int x, int y) {
    _maze[y][x].visited = true;

    final directions = [[0, -1], [0, 1], [-1, 0], [1, 0]];
    directions.shuffle();

    for (final dir in directions) {
      final nx = x + dir[0];
      final ny = y + dir[1];

      if (nx >= 0 && nx < _gridSize && ny >= 0 && ny < _gridSize && !_maze[ny][nx].visited) {
        if (dir[0] == 1) {
          _maze[y][x].right = false;
          _maze[ny][nx].left = false;
        } else if (dir[0] == -1) {
          _maze[y][x].left = false;
          _maze[ny][nx].right = false;
        } else if (dir[1] == 1) {
          _maze[y][x].bottom = false;
          _maze[ny][nx].top = false;
        } else if (dir[1] == -1) {
          _maze[y][x].top = false;
          _maze[ny][nx].bottom = false;
        }
        _backtrack(nx, ny);
      }
    }
  }

  void _move(int dx, int dy) {
    if (_isWin) return;

    final currentCell = _maze[_playerY][_playerX];
    bool canMove = false;

    if (dx == 1 && !currentCell.right) canMove = true;
    if (dx == -1 && !currentCell.left) canMove = true;
    if (dy == 1 && !currentCell.bottom) canMove = true;
    if (dy == -1 && !currentCell.top) canMove = true;

    if (canMove) {
      setState(() {
        _playerX += dx;
        _playerY += dy;

        if (_playerX == _gridSize - 1 && _playerY == _gridSize - 1) {
          _isWin = true;
          _showWinDialog();
        }
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppLocalizations.of(context).t('level_complete'), style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.of(context).t('maze_peace_msg', {'val': '$_level'}),
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _level++;
                _startLevel();
              });
            },
            child: Text(AppLocalizations.of(context).t('next_level'), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).t('back_to_games'), style: const TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDarkMode;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.background : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).t('calm_maze'), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentTeal.withOpacity(0.5)),
                ),
                child: Text(AppLocalizations.of(context).t('level_label', {'val': '$_level'}), style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? AppColors.backgroundGradient 
            : LinearGradient(
                colors: [Colors.teal.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        ),
        child: Column(
          children: [
            const SafeArea(bottom: false, child: SizedBox(height: 10)),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                AppLocalizations.of(context).t('maze_instr'),
                style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    boxShadow: [
                      if (isDark) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellSize = constraints.maxWidth / _gridSize;
                        return Stack(
                          children: [
                            ..._buildMazeWidgets(cellSize, isDark),
                            Positioned(
                              left: (_gridSize - 1) * cellSize,
                              top: (_gridSize - 1) * cellSize,
                              child: SizedBox(
                                width: cellSize,
                                height: cellSize,
                                child: Center(
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: cellSize * 0.8,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: _playerX * cellSize + (cellSize * 0.1),
                              top: _playerY * cellSize + (cellSize * 0.1),
                              child: Container(
                                width: cellSize * 0.8,
                                height: cellSize * 0.8,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryPurple.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlBtn(Icons.keyboard_arrow_up_rounded, () => _move(0, -1)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlBtn(Icons.keyboard_arrow_left_rounded, () => _move(-1, 0)),
                      const SizedBox(width: 20),
                      _buildControlBtn(Icons.keyboard_arrow_down_rounded, () => _move(0, 1)),
                      const SizedBox(width: 20),
                      _buildControlBtn(Icons.keyboard_arrow_right_rounded, () => _move(1, 0)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMazeWidgets(double cellSize, bool isDark) {
    final List<Widget> widgets = [];
    final wallColor = isDark ? Colors.white12 : Colors.black12;

    for (int y = 0; y < _gridSize; y++) {
      for (int x = 0; x < _gridSize; x++) {
        final cell = _maze[y][x];
        if (cell.top) {
          widgets.add(_buildWall(x * cellSize, y * cellSize, cellSize, 2, wallColor));
        }
        if (cell.bottom && y == _gridSize - 1) {
          widgets.add(_buildWall(x * cellSize, (y + 1) * cellSize, cellSize, 2, wallColor));
        }
        if (cell.left) {
          widgets.add(_buildWall(x * cellSize, y * cellSize, 2, cellSize, wallColor));
        }
        if (cell.right && x == _gridSize - 1) {
          widgets.add(_buildWall((x + 1) * cellSize, y * cellSize, 2, cellSize, wallColor));
        }
        if (cell.right && x < _gridSize - 1) {
          widgets.add(_buildWall((x + 1) * cellSize, y * cellSize, 2, cellSize, wallColor));
        }
        if (cell.bottom && y < _gridSize - 1) {
          widgets.add(_buildWall(x * cellSize, (y + 1) * cellSize, cellSize, 2, wallColor));
        }
      }
    }
    return widgets;
  }

  Widget _buildWall(double left, double top, double w, double h, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(width: w, height: h, color: color),
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.backgroundMid,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}

class MazeCell {
  final int x, y;
  bool visited = false;
  bool top = true, right = true, bottom = true, left = true;
  MazeCell(this.x, this.y);
}
