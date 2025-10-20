import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/pages/language.dart';

Future<List<int>> _getScores(int? lastScore) async {
  final prefs = await SharedPreferences.getInstance();
  final scores = prefs.getStringList('scores')?.map(int.parse).toList() ?? [];
  if (lastScore != null) {
    // Видалити всі однакові значення
    scores.removeWhere((s) => s == lastScore);
    scores.add(lastScore);
    scores.sort((a, b) => b.compareTo(a));
    final top10 = scores.take(10).toList();
    await prefs.setStringList('scores', top10.map((e) => e.toString()).toList());
    return top10;
  }
  return scores;
}

Future<int> getBestScore() async {
  final prefs = await SharedPreferences.getInstance();
  final scores = prefs.getStringList('scores')?.map(int.parse).toList() ?? [];
  if (scores.isEmpty) return 0;
  return scores.reduce((a, b) => a > b ? a : b);
}

// Функція для очищення всіх результатів
Future<void> clearAllScores() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('scores');
}

class Score extends StatefulWidget {
  const Score({super.key});

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> {

  Widget _buildScoreItem(BuildContext context, List<int> scores, int index, int? lastScore) {
    final isLast = lastScore != null && scores[index] == lastScore;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: isLast
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            )
          : null,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            '${index + 1}. ${scores[index]}',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 15,
              color: isLast
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.secondary,
              fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastScore = ModalRoute.of(context)?.settings.arguments as int?;
    return FutureBuilder<List<int>>(
      future: _getScores(lastScore),
      builder: (context, snapshot) {
        final scores = snapshot.data ?? [];
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Один стовпчик посередині (поточний варіант)
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Перевіряємо чи список порожній
                      if (scores.isEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 50,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.4),
                              ),
                              SizedBox(height: 15),
                              Text(
                                currentLocale.value.languageCode == 'en' ? 'Play to set your first record!' : 'Зіграйте щоб встановити перший рекорд!',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Показуємо рекорди якщо вони є
                        for (int i = 0; i < scores.length && i < 10; i++) ...[
                          _buildScoreItem(context, scores, i, lastScore),
                        ],
                      ],
                    ],
                  ),
                ),
                // Кнопки в стовпчик
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/game');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(currentLocale.value.languageCode == 'en' ? 'START' : 'СТАРТ', style: TextStyle(
                        fontFamily: 'RubikMonoOne',
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),),
                    ),
                    SizedBox(height: 15),
                    // Кнопка "Назад до меню"
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        currentLocale.value.languageCode == 'en' ? 'Back to Menu' : 'Головне меню', 
                        style: TextStyle(
                          fontFamily: 'RubikMonoOne',
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Кнопка очищення (показуємо тільки якщо є результати)
                    if (scores.isNotEmpty) ...[
                      ElevatedButton(
                        onPressed: () async {
                          // Діалог підтвердження
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              title: Text(
                                currentLocale.value.languageCode == 'en' ? 'Clear all scores?' : 'Очистити всі результати?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontFamily: 'RubikMonoOne',
                                ),
                              ),
                              content: Text(
                                currentLocale.value.languageCode == 'en' 
                                  ? '...\nThis action cannot be undone!\n...' 
                                  : '...\nЦю дію неможливо скасувати!\n...',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5),
                                  fontFamily: 'RussoOne',
                                  fontSize: 20,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(
                                    currentLocale.value.languageCode == 'en' ? 'Cancel' : 'Відмінити',
                                    style: TextStyle(
                                      fontFamily: 'RubikMonoOne',
                                      fontSize: 15
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    currentLocale.value.languageCode == 'en' ? 'Confirm' : 'Підтвердити',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                      fontFamily: 'RubikMonoOne',
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            await clearAllScores();
                            setState(() {}); // Оновлюємо UI
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          currentLocale.value.languageCode == 'en' ? 'Clear' : 'Очистити',
                          style: TextStyle(fontFamily: 'RubikMonoOne', fontSize: 15),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}