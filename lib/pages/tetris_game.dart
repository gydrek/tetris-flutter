import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'package:tetris/pages/buttons.dart';
import 'package:tetris/pages/language.dart';
import 'package:tetris/pages/score.dart';

// Віджет для прев’ю наступного блока
class NextBlockPreviewWidget extends StatelessWidget {
  final Tetromino nextBlock;
  const NextBlockPreviewWidget({required this.nextBlock, super.key});

  @override
  Widget build(BuildContext context) {
  const int previewSize = 4;
  const double cellSize = 20;
    return Container(
      width: cellSize * previewSize,
      height: cellSize * previewSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.blueGrey, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(previewSize, (y) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(previewSize, (x) {
              final filled = nextBlock.shape[y][x] != 0;
              return Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: filled ? nextBlock.color : Colors.transparent,
                  border: filled ? Border.all(color: Theme.of(context).colorScheme.surface.withOpacity(0.3)) : null,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

// Основний віджет для арени + UI
class TetrisBoard extends StatefulWidget {
  final TetrisGame tetrisGame;
  const TetrisBoard({super.key, required this.tetrisGame});

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}


class _TetrisBoardState extends State<TetrisBoard> {
  // Використовуємо тільки widget.tetrisGame
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    widget.tetrisGame.onUpdateUI = () {
      // Перевіряємо чи поточний рахунок перевищує рекорд
      if (widget.tetrisGame.score > bestScore) {
        bestScore = widget.tetrisGame.score;
      }
      setState(() {});
    };
  }

  Future<void> _loadBestScore() async {
    final best = await getBestScore(); // Використовуємо функцію з score.dart
    setState(() {
      bestScore = best;
    });
  }

  // Мапа: назва кнопки → іконка, логіка, holdable
  Map<String, dynamic> getButtonConfig(TetrisGame game) {
    return {
      'none1': {
        'icon': Icons.circle_outlined,
        'onPressed': () {},
        'holdable': false,
      },
      'none2': {
        'icon': Icons.circle_outlined,
        'onPressed': () {},
        'holdable': false,
      },
      'Pause': {
        'icon': game.isPaused ? Icons.play_circle : Icons.pause_circle_outline_outlined,
        'onPressed': () {
          game.togglePause();
          setState(() {});
        },
        'holdable': false,
      },
      'Down': {
        'icon': Icons.arrow_circle_down_outlined,
        'onPressed': () {
          game.moveDown();
        },
        'holdable': true,
      },
      'Left': {
        'icon': Icons.arrow_circle_left_outlined,
        'onPressed': () {
          game.moveLeft();
        },
        'holdable': true,
      },
      'Right': {
        'icon': Icons.arrow_circle_right_outlined,
        'onPressed': () {
          game.moveRight();
        },
        'holdable': true,
      },
      'Rotate': {
        'icon': Icons.refresh_outlined,
        'onPressed': () {
          game.rotateCurrentBlock();
        },
        'holdable': false,
      },
      'HardDrop': {
        'icon': Icons.keyboard_double_arrow_down_outlined,
        'onPressed': () {
          game.hardDrop();
        },
        'holdable': false,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final double cellSize = 22;
    final double arenaWidth = widget.tetrisGame.cols * cellSize;
    final double arenaHeight = widget.tetrisGame.rows * cellSize;
    final buttonOrder = widget.tetrisGame.buttonOrder;
    final config = getButtonConfig(widget.tetrisGame);
    // Розбиваємо на 2 рядки по 4 кнопки
    final firstRow = buttonOrder.take(4).toList();
    final secondRow = buttonOrder.skip(4).take(4).toList();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: arenaWidth,
                    height: arenaHeight,
                    child: GameWidget(game: widget.tetrisGame),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Column(
                children: [
                  Text(
                    currentLocale.value.languageCode == 'en' ? 'Best' : 'Рекорд',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'PressStart2P',
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Щоб відрізнялося від поточного рахунку
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('$bestScore', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold,
                    color: Colors.orange, // Щоб відрізнялося від поточного рахунку
                  )),
                  SizedBox(height: 30),
                  Text(currentLocale.value.languageCode == 'en' ? 'Next' : 'Далі', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: NextBlockPreviewWidget(nextBlock: widget.tetrisGame.nextBlock),
                  ),
                  SizedBox(height: 30),
                  Text(currentLocale.value.languageCode == 'en' ? 'Score' : 'Рахунок', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('${widget.tetrisGame.score}', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text(currentLocale.value.languageCode == 'en' ? 'Level' : 'Рівень', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('${(widget.tetrisGame.score ~/ 1000) + 1}', style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'PressStart2P',
                    fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final btn in firstRow)
                MoveButtonWidget(
                  icon: config[btn]['icon'],
                  onPressed: config[btn]['onPressed'],
                  holdable: config[btn]['holdable'],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final btn in secondRow)
                MoveButtonWidget(
                  icon: config[btn]['icon'],
                  onPressed: config[btn]['onPressed'],
                  holdable: config[btn]['holdable'],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class Tetromino {
  List<List<int>> shape;
  int x;
  int y;
  Color color;

  Tetromino({
    required this.shape,
    required this.x,
    required this.y,
    required this.color,
  });
}

// основний клас гри
class TetrisGame extends FlameGame {
  int get level => (score ~/ 1000) + 1;

  void updateFallDelay() {
    // Мінімальна затримка 0.1, стартова 1.0, зменшується на 0.1 за кожен level
    fallDelay = (1.0 - (level - 1) * 0.1).clamp(0.1, 1.0);
  }
  final Color arenaColor;
  final Color blockColor;
  final List<String> buttonOrder;
  TetrisGame({
    required this.arenaColor,
    required this.blockColor,
    required this.buttonOrder,
  });
  
  @override
  void update(double dt) {
    if (!isPaused && !isGameOver) {
      _fallTimer += dt;
      if (_fallTimer >= fallDelay) {
        moveDown();
        _fallTimer = 0;
      }
    }
    super.update(dt);
  }
  double _fallTimer = 0;
  double fallDelay = 1.0; // секунда між падінням


  final int cols = 10;
  final int rows = 20;
  late List<List<int>> field;
  late Tetromino currentBlock;
  late Tetromino nextBlock = getRandomTetromino();
  int score = 0;
  bool isGameOver = false;
  bool isPaused = false;
  VoidCallback? onUpdateUI;
  VoidCallback? onGameOver;


  void moveLeft() {
    if (isPaused) return;
    if (canMove(-1, 0)) {
      currentBlock.x -= 1;
      if (onUpdateUI != null) onUpdateUI!();
    }
  }

  void moveRight() {
    if (isPaused) return;
    if (canMove(1, 0)) {
      currentBlock.x += 1;
      if (onUpdateUI != null) onUpdateUI!();
    }
  }

  bool canMove(int dx, int dy, [List<List<int>>? shape]) {
    shape ??= currentBlock.shape;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) {
          int newX = currentBlock.x + x + dx;
          int newY = currentBlock.y + y + dy;
          if (newX < 0 || newX >= cols || newY >= rows) return false;
          if (newY >= 0 && field[newY][newX] != 0) return false;
        }
      }
    }
    return true;
  }

  void moveDown() {
    if (isPaused || isGameOver) return;
    if (canMove(0, 1)) {
      currentBlock.y += 1;
    } else {
      bakeBlock();
      clearLines();
      // Перевірква кінця гри після фіксації фігури та очищення ліній
          if (field[0].any((cell) => cell != 0)) {
            isGameOver = true;
            if (onGameOver != null) onGameOver!();
            return;
          }
      currentBlock = nextBlock;
      nextBlock = getRandomTetromino();
    }
    if (onUpdateUI != null) onUpdateUI!();
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  // Моментальне падіння фігури (hard drop)
  void hardDrop() {
    if (isPaused) return;
    while (canMove(0, 1)) {
      currentBlock.y += 1;
    }
    bakeBlock();
    clearLines();
    // Перевірква кінця гри після фіксації фігури та очищення ліній
        if (field[0].any((cell) => cell != 0)) {
          isGameOver = true;
          if (onGameOver != null) onGameOver!();
          return;
        }
  currentBlock = nextBlock;
    nextBlock = getRandomTetromino();
    if (onUpdateUI != null) onUpdateUI!();
  }

  int getGhostY() {
    int ghostY = currentBlock.y;
    while (true) {
      bool canGo = true;
      for (int y = 0; y < currentBlock.shape.length; y++) {
        for (int x = 0; x < currentBlock.shape[y].length; x++) {
          if (currentBlock.shape[y][x] != 0) {
            int newX = currentBlock.x + x;
            int newY = ghostY + y + 1;
            if (newY >= rows || (newY >= 0 && field[newY][newX] != 0)) {
              canGo = false;
              break;
            }
          }
        }
        if (!canGo) break;
      }
      if (!canGo) break;
      ghostY++;
    }
    return ghostY;
  }

  // Обертає матрицю 4x4 на 90 градусів за годинниковою стрілкою
  List<List<int>> rotateMatrix(List<List<int>> matrix) {
    int n = matrix.length;
    List<List<int>> rotated = List.generate(n, (_) => List.filled(n, 0));
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        rotated[x][n - 1 - y] = matrix[y][x];
      }
    }
    return rotated;
  }

  // Обертає поточну фігуру, якщо це можливо
  void rotateCurrentBlock() {
    if (isPaused) return;
    List<List<int>> rotated = rotateMatrix(currentBlock.shape);
    int originalX = currentBlock.x;
    List<int> kicks = [0, 1, -1, 2, -2];
    for (int dx in kicks) {
      currentBlock.x = originalX + dx;
      if (canMove(0, 0, rotated)) {
        currentBlock.shape = rotated;
        return;
      }
    }
  currentBlock.x = originalX; // Повертаємо назад, якщо не вдалося
  }

  final List<Map<String, dynamic>> tetrominoTypes = [
    {
      'shape': [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [1, 1, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 1, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [0, 0, 1, 1],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [1, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
    {
      'shape': [
        [0, 0, 0, 0],
        [1, 1, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 0],
      ],
      'x': 3,
      'y': 0,
    },
  ];

  Tetromino getRandomTetromino() {
    final random = Random();
    final base = tetrominoTypes[random.nextInt(tetrominoTypes.length)];
    List<List<int>> shape = (base['shape'] as List<List<int>>)
        .map((row) => List<int>.from(row)).toList();
    int minX = getMinX(shape);
    int maxX = getMaxX(shape);
    int startX = ((cols - (maxX - minX + 1)) ~/ 2) - minX;
    if (startX + minX < 0) startX = -minX;
    if (startX + maxX >= cols) startX = cols - maxX - 1;
    return Tetromino(
      shape: shape,
      x: startX,
      y: -1,
      color: blockColor,
    );
  }

  @override
  Future<void> onLoad() async {
  await super.onLoad();
  field = List.generate(rows, (_) => List.filled(cols, 0));
  currentBlock = getRandomTetromino();
  nextBlock = getRandomTetromino();
  if (onUpdateUI != null) onUpdateUI!();
  }

  int getMinX(List<List<int>> shape) {
    for (int x = 0; x < shape[0].length; x++) {
      for (int y = 0; y < shape.length; y++) {
        if (shape[y][x] != 0) return x;
      }
    }
    return 0;
  }

  int getMaxX(List<List<int>> shape) {
    for (int x = shape[0].length - 1; x >= 0; x--) {
      for (int y = 0; y < shape.length; y++) {
        if (shape[y][x] != 0) return x;
      }
    }
    return shape[0].length - 1;
  }

  void bakeBlock() {
    for (int y = 0; y < currentBlock.shape.length; y++) {
      for (int x = 0; x < currentBlock.shape[y].length; x++) {
        if (currentBlock.shape[y][x] != 0) {
          int fieldY = currentBlock.y + y;
          int fieldX = currentBlock.x + x;
          if (fieldY >= 0 && fieldY < rows && fieldX >= 0 && fieldX < cols) {
            field[fieldY][fieldX] = 1;
          }
        }
      }
    }
  }

  void clearLines() {
    int linesCleared = 0;
      for (int y = field.length - 1; y >= 0; y--) {
        if (field[y].every((cell) => cell != 0)) {
          field.removeAt(y);
          field.insert(0, List.filled(cols, 0));
          linesCleared++;
          y++; // Перевірити цей рядок знову після видалення
        }
      }
  score += linesCleared * 100;
  updateFallDelay();
  if (onUpdateUI != null) onUpdateUI!();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

  double cellSize = 22;
  double arenaWidth = cols * cellSize;
  double arenaHeight = rows * cellSize;
  double offsetX = (size.x - arenaWidth) / 2;
  double offsetY = (size.y - arenaHeight) / 2;

    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, arenaWidth, arenaHeight),
      Paint()..color = arenaColor,
    );

    Paint mainBorderPaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(offsetX, offsetY, arenaWidth, arenaHeight),
      mainBorderPaint,
    );

    // Малюємо поле
    for (int y = 0; y < field.length; y++) {
      for (int x = 0; x < field[y].length; x++) {
        if (field[y][x] != 0) {
          final rect = Rect.fromLTWH(
            offsetX + x * cellSize,
            offsetY + y * cellSize,
            cellSize,
            cellSize,
          );
          final rrect = RRect.fromRectAndRadius(rect, Radius.circular(3));
          canvas.drawRRect(rrect, Paint()..color = currentBlock.color);
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = arenaColor.withOpacity(0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }


    // Малюємо поточну фігуру
    for (int y = 0; y < currentBlock.shape.length; y++) {
      for (int x = 0; x < currentBlock.shape[y].length; x++) {
        if (currentBlock.shape[y][x] != 0) {
          final rect = Rect.fromLTWH(
            offsetX + (currentBlock.x + x) * cellSize,
            offsetY + (currentBlock.y + y) * cellSize,
            cellSize,
            cellSize,
          );
          final rrect = RRect.fromRectAndRadius(rect, Radius.circular(3));
          canvas.drawRRect(rrect, Paint()..color = currentBlock.color);
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = arenaColor.withOpacity(0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }

    // Малюємо "привид" фігури
    int ghostY = getGhostY();
    for (int y = 0; y < currentBlock.shape.length; y++) {
      for (int x = 0; x < currentBlock.shape[y].length; x++) {
        if (currentBlock.shape[y][x] != 0) {
          final rect = Rect.fromLTWH(
            offsetX + (currentBlock.x + x) * cellSize,
            offsetY + (ghostY + y) * cellSize,
            cellSize,
            cellSize,
          );
          final rrect = RRect.fromRectAndRadius(rect, Radius.circular(3));
          canvas.drawRRect(rrect, Paint()..color = currentBlock.color.withOpacity(0.3));
          canvas.drawRRect(
            rrect,
            Paint()
              ..color = arenaColor.withOpacity(0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }

    // Якщо гра на паузі, малюємо затемнення і текст
    if (isPaused) {
      canvas.drawRect(
        Rect.fromLTWH(offsetX, offsetY, arenaWidth, arenaHeight),
        Paint()..color = Colors.black.withOpacity(0.5),
      );

      // Малюємо текст "Paused"
      final textPainter = TextPainter(
        text: TextSpan(
          text: currentLocale.value.languageCode == 'en' ? 'Pause' : 'Пауза',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bungee',
            shadows: [Shadow(blurRadius: 8, color: Colors.black)],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offsetX + (arenaWidth - textPainter.width) / 2,
          offsetY + (arenaHeight - textPainter.height) / 2,
        ),
      );
    }
  }
}