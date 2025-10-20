import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:tetris/main.dart';
import 'package:tetris/pages/language.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentLocale.value.languageCode == 'en' ? 'TETRIS' : 'ТЕТРІС', style: TextStyle(
              fontFamily: 'RubikMonoOne',
              fontSize: 65,
              color: Theme.of(context).colorScheme.primary,
            ),),
            SizedBox(height: 30),
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
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/score');
              },
              child: Text(currentLocale.value.languageCode == 'en' ? 'Score' : 'Результати', style: TextStyle(
                fontFamily: 'PressStart2P',
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Theme.of(context).colorScheme.secondary,
              ),)),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeToggleButton(),
          SizedBox(height: 15),
          LanguageToggleButton(),
          SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary, size: 35),
          ),
        ],
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode.value == ThemeMode.dark;
    return FloatingActionButton(
      heroTag: 'mode_night_light',
      onPressed: () async {
        final newIsDark = !isDark;
        themeMode.value = newIsDark ? ThemeMode.dark : ThemeMode.light;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkTheme', newIsDark);
      },
      backgroundColor: isDark ? Color.fromARGB(255, 83, 83, 83) : Color.fromARGB(255, 29, 29, 29),
      child: Icon(
        isDark ? Icons.wb_sunny_rounded : Icons.mode_night_rounded,
        color: isDark ? Colors.yellow : Colors.white,
        size: 35,
      ),
    );
  }
}

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'language',
      onPressed: () {
        Navigator.pushNamed(context, '/language');
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Icon(Icons.language_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 35),
    );
  }
}