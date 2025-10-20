import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/pages/language.dart';
import 'package:tetris/pages/tetris_game.dart';
import 'dart:async';


class Game extends StatefulWidget {
  final List<String> buttonOrder;
  const Game({super.key, required this.buttonOrder});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  TetrisGame? tetrisGame;

  // Автоматично зберігає результат у SharedPreferences
  Future<void> _saveScoreToStorage(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('scores')?.map(int.parse).toList() ?? [];
    
    // Видаляємо дублікати того ж результату
    scores.removeWhere((s) => s == score);
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Сортуємо від більшого до меншого
    
    final top10 = scores.take(10).toList(); // Зберігаємо тільки топ-10
    await prefs.setStringList('scores', top10.map((e) => e.toString()).toList());
  }

  // Ініціалізація tetrisGame тільки в build

  @override
  Widget build(BuildContext context) {
    tetrisGame ??= TetrisGame(
      arenaColor: Theme.of(context).colorScheme.surface,
      blockColor: Theme.of(context).colorScheme.primary,
      buttonOrder: widget.buttonOrder,
    );
    tetrisGame!.onGameOver = _showGameOverDialog;

    return Scaffold(
      body: SafeArea(
        child: TetrisBoard(tetrisGame: tetrisGame!),
      ),
    );
  }

  void _showGameOverDialog() async {
    await Future.delayed(const Duration(milliseconds: 30)); // невелика затримка для коректного рендеру
    
    // Автоматично зберігаємо результат при Game Over
    await _saveScoreToStorage(tetrisGame!.score);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(20),
          //   side: BorderSide(color: Theme.of(context).colorScheme.onPrimaryContainer, width: 3),
          // ),
          title: Text(currentLocale.value.languageCode == 'en' ? 'Game Over' : 'Кінець гри',
            style: TextStyle(
              fontFamily: 'RubikMonoOne',
              fontSize: 25,
              color: Theme.of(context).colorScheme.secondary
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            currentLocale.value.languageCode == 'en' ? 'Your score: ${tetrisGame!.score}' : 'Ваш рахунок: ${tetrisGame!.score}',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      tetrisGame = TetrisGame(
                        arenaColor: Theme.of(context).colorScheme.surface,
                        blockColor: Theme.of(context).colorScheme.primary,
                        buttonOrder: ['none1', 'none2', 'Pause', 'Down', 'Left', 'Right', 'Rotate', 'HardDrop',]
                      );
                      tetrisGame!.onGameOver = _showGameOverDialog;
                      tetrisGame!.onUpdateUI = () => setState(() {});
                    });
                    tetrisGame!.onUpdateUI?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    textAlign: TextAlign.center,
                    currentLocale.value.languageCode == 'en' ? 'Replay' : 'Спробувати ще раз',
                    style: TextStyle(
                      fontFamily: 'RubikMonoOne',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/score', arguments: tetrisGame!.score);
                  },
                  child: Text(
                    currentLocale.value.languageCode == 'en' ? 'Scoreboard' : 'Таблиця рекордів',
                    style: TextStyle(
                      fontFamily: 'RubikMonoOne',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/', arguments: tetrisGame!.score);
                  },
                  child: Text(
                    currentLocale.value.languageCode == 'en' ? 'Back to Menu' : 'Головне меню',
                    style: TextStyle(
                      fontFamily: 'RubikMonoOne',
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}