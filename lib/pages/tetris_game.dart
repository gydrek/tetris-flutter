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
                  border: filled ? Border.all(color: Theme.of(context).colorScheme.surface.withOpacity(0.4)) : null,
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
      // Робимо асинхронний виклик setState щоб уникнути помилки під час build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Перевіряємо чи поточний рахунок перевищує рекорд
          if (widget.tetrisGame.score > bestScore) {
            bestScore = widget.tetrisGame.score;
          }
          setState(() {});
        }
      });
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
      // Обробка затримки очищення рядків
      if (isClearingLines) {
        _lineClearTimer += dt;
        if (_lineClearTimer >= lineClearDelay) {
          // Завершуємо процес очищення і спавним новий блок
          _finishLineClear();
        }
        return; // Не обробляємо падіння під час очищення
      }
      
      // Обробка затримки фіксації блоку
      if (isBlockLocking) {
        _blockLockTimer += dt;
        if (_blockLockTimer >= blockLockDelay) {
          // Завершуємо процес фіксації і спавним новий блок
          _finishBlockLock();
        }
        return; // Не обробляємо падіння під час фіксації
      }
      
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
  bool isClearingLines = false; // Новий стан для процесу очищення рядків
  bool isBlockLocking = false; // Новий стан для затримки фіксації блоку
  double _lineClearTimer = 0;
  double _blockLockTimer = 0;
  final double lineClearDelay = 0.05; // Затримка в секундах для очищення рядків
  final double blockLockDelay = 0.05; // Затримка в секундах для фіксації блоку
  VoidCallback? onUpdateUI;
  VoidCallback? onGameOver;

  // Безпечний асинхронний виклик оновлення UI
  void _safeUpdateUI() {
    if (onUpdateUI != null) {
      // Використовуємо Future.microtask для асинхронного виклику
      Future.microtask(() => onUpdateUI!());
    }
  }


  void moveLeft() {
    if (isPaused || isClearingLines || isBlockLocking) return;
    if (canMove(-1, 0)) {
      currentBlock.x -= 1;
      _safeUpdateUI();
    }
  }

  void moveRight() {
    if (isPaused || isClearingLines || isBlockLocking) return;
    if (canMove(1, 0)) {
      currentBlock.x += 1;
      _safeUpdateUI();
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
    if (isPaused || isGameOver || isClearingLines || isBlockLocking) return;
    if (canMove(0, 1)) {
      currentBlock.y += 1;
    } else {
      bakeBlock();
      int linesCleared = clearLines();
      
      // Якщо рядки були очищені, запускаємо затримку очищення
      if (linesCleared > 0) {
        isClearingLines = true;
        _lineClearTimer = 0;
        return; // Не спавним новий блок відразу
      }
      
      // Якщо рядки не очищалися, запускаємо затримку фіксації
      isBlockLocking = true;
      _blockLockTimer = 0;
      return; // Не спавним новий блок відразу
    }
    _safeUpdateUI();
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  // Завершення процесу очищення рядків та спавн нового блоку
  void _finishLineClear() {
    isClearingLines = false;
    _lineClearTimer = 0;
    
    // Перевірка кінця гри
    if (field[0].any((cell) => cell != 0)) {
      isGameOver = true;
      if (onGameOver != null) onGameOver!();
      return;
    }
    
    currentBlock = nextBlock;
    nextBlock = getRandomTetromino();
    _safeUpdateUI();
  }

  // Завершення процесу фіксації блоку та спавн нового блоку
  void _finishBlockLock() {
    isBlockLocking = false;
    _blockLockTimer = 0;
    
    // Перевірка кінця гри
    if (field[0].any((cell) => cell != 0)) {
      isGameOver = true;
      if (onGameOver != null) onGameOver!();
      return;
    }
    
    currentBlock = nextBlock;
    nextBlock = getRandomTetromino();
    _safeUpdateUI();
  }

  // Моментальне падіння фігури (hard drop)
  void hardDrop() {
    if (isPaused || isClearingLines || isBlockLocking) return;
    while (canMove(0, 1)) {
      currentBlock.y += 1;
    }
    bakeBlock();
    int linesCleared = clearLines();
    
    // Якщо рядки були очищені, запускаємо затримку очищення
    if (linesCleared > 0) {
      isClearingLines = true;
      _lineClearTimer = 0;
      return; // Не спавним новий блок відразу
    }
    
    // Якщо рядки не очищалися, запускаємо затримку фіксації
    isBlockLocking = true;
    _blockLockTimer = 0;
    _safeUpdateUI();
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
    if (isPaused || isClearingLines || isBlockLocking) return;
    
    List<List<int>> rotated = rotateMatrix(currentBlock.shape);
    int originalX = currentBlock.x;
    int originalY = currentBlock.y;
    
    // Перевіряємо і виправляємо позицію якщо фігура виходить за верхній край
    int topOffset = _getTopOffset(rotated, originalX, originalY);
    if (topOffset > 0) {
      currentBlock.y = originalY + topOffset;
    }
    
    // Спочатку пробуємо обернути на місці (з можливим зміщенням вниз)
    if (canMove(0, 0, rotated)) {
      currentBlock.shape = rotated;
      return;
    }
    
    // Якщо не можемо обернути на місці, використовуємо wall kick
    List<int> kicks = _getWallKicks(currentBlock.shape, rotated);
    
    for (int dx in kicks) {
      currentBlock.x = originalX + dx;
      if (canMove(0, 0, rotated)) {
        currentBlock.shape = rotated;
        return;
      }
    }
    
    // Якщо горизонтальні зміщення не працюють, пробуємо додаткові вертикальні
    currentBlock.x = originalX; // Повертаємо X назад
    for (int dy in [1, 2]) { // Тільки вниз, оскільки вгору вже перевірили
      currentBlock.y = originalY + topOffset + dy;
      if (canMove(0, 0, rotated)) {
        currentBlock.shape = rotated;
        return;
      }
    }
    
    // Повертаємо позицію назад, якщо не вдалося
    currentBlock.x = originalX;
    currentBlock.y = originalY;
  }

  // Обчислюємо наскільки потрібно зсунути фігуру вниз, щоб вона не виходила за верхній край
  int _getTopOffset(List<List<int>> shape, int x, int y) {
    int minY = rows; // Початкове значення більше за можливе
    
    for (int shapeY = 0; shapeY < shape.length; shapeY++) {
      for (int shapeX = 0; shapeX < shape[shapeY].length; shapeX++) {
        if (shape[shapeY][shapeX] != 0) {
          int fieldY = y + shapeY;
          if (fieldY < minY) {
            minY = fieldY;
          }
        }
      }
    }
    
    // Якщо мінімальний Y менше 0, потрібно зсунути вниз
    return minY < 0 ? -minY : 0;
  }

  // Отримуємо wall kicks залежно від типу фігури
  List<int> _getWallKicks(List<List<int>> originalShape, List<List<int>> rotatedShape) {
    // Перевіряємо чи це лінійна фігура (I-tetromino)
    bool isLinePiece = _isLinePiece(originalShape);
    
    if (isLinePiece) {
      // Для лінійної фігури використовуємо більші зміщення
      return [1, -1, 2, -2];
    } else {
      // Для інших фігур використовуємо мінімальні зміщення
      return [1, -1];
    }
  }

  // Перевіряємо чи це лінійна фігура (I-tetromino)
  bool _isLinePiece(List<List<int>> shape) {
    int blockCount = 0;
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) blockCount++;
      }
    }
    
    // Лінійна фігура має 4 блоки в ряд
    if (blockCount != 4) return false;
    
    // Перевіряємо чи всі блоки в одному рядку або одній колонці
    List<int> rows = [];
    List<int> cols = [];
    
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] != 0) {
          rows.add(y);
          cols.add(x);
        }
      }
    }
    
    // Всі в одному рядку або всі в одній колонці
    return (rows.toSet().length == 1) || (cols.toSet().length == 1);
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
  _safeUpdateUI();
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

  int clearLines() {
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
  _safeUpdateUI();
  return linesCleared;
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


    // Малюємо поточну фігуру (тільки якщо не очищаємо рядки і не фіксуємо блок)
    if (!isClearingLines && !isBlockLocking) {
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
    }

    // Малюємо "привид" фігури (тільки якщо не очищаємо рядки і не фіксуємо блок)
    if (!isClearingLines && !isBlockLocking) {
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
            fontSize: 40,
            fontFamily: 'RubikMonoOne',
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
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