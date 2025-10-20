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

class Score extends StatelessWidget {
  const Score({super.key});

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
                Text(currentLocale.value.languageCode == 'en' ? 'Score:' : 'Рахунок:', style: TextStyle(
                  fontFamily: 'RubikMonoOne',
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),),
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
                      for (int i = 0; i < scores.length && i < 10; i++) ...[
                        _buildScoreItem(context, scores, i, lastScore),
                      ],
                    ],
                  ),
                ),
                
                // Закоментований код з двома стовпчиками (можна повернути пізніше)
                /*
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Перший стовпчик (1-5 місця)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < 5 && i < scores.length; i++) ...[
                              _buildScoreItem(context, scores, i, lastScore),
                            ],
                          ],
                        ),
                      ),
                      // Розділювач
                      Container(
                        width: 2,
                        height: 300,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3),
                      ),
                      // Другий стовпчик (6-10 місця)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 5; i < 10 && i < scores.length; i++) ...[
                              _buildScoreItem(context, scores, i, lastScore),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                */
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(currentLocale.value.languageCode == 'en' ? 'Back to Menu' : 'Назад до меню', style: TextStyle(
                    fontFamily: 'RubikMonoOne',
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),)),
              ],
            ),
          ),
        );
      },
    );
  }
}