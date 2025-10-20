import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/pages/game.dart';
import 'package:tetris/pages/start.dart';
import 'package:tetris/pages/score.dart';
import 'package:tetris/pages/settings.dart';
import 'package:tetris/pages/language.dart';

final themeMode = ValueNotifier(ThemeMode.light);
Future<List<String>> loadButtonOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final defaultButtons = [
    'none1',
    'none2',
    'Pause',
    'Down',
    'Left',
    'Right',
    'Rotate',
    'HardDrop',
  ];
  final savedOrder = prefs.getStringList('buttonOrder');
  if (savedOrder == null) return defaultButtons;
  // Додаємо нові кнопки з defaultButtons
  final updatedOrder = List<String>.from(savedOrder);
  for (final btn in defaultButtons) {
    if (!updatedOrder.contains(btn)) {
      updatedOrder.add(btn);
    }
  }
  updatedOrder.removeWhere((btn) => !defaultButtons.contains(btn));
  return updatedOrder;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;
  themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  
  // Завантаження мови (підтримувані: uk, en, de, fr, es, pl)
  final savedLang = prefs.getString('language') ?? 'en';
  currentLocale.value = Locale(savedLang);
  runApp(
    ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, mode, _) => ValueListenableBuilder(
        valueListenable: currentLocale,
        builder: (context, locale, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF85C2FF),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(30, 58, 95, 1),
            brightness: Brightness.dark,
          ),
        ),
          themeMode: mode,
          locale: locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English (основна)
            Locale('uk'), // Українська
            // Locale('de'), // Deutsch
            // Locale('fr'), // Français
            // Locale('es'), // Español
            // Locale('pl'), // Polski
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Якщо мова підтримується - повертаємо її
            if (supportedLocales.any((supportedLocale) => 
                supportedLocale.languageCode == locale?.languageCode)) {
              return locale;
            }
            // Інакше повертаємо англійську за замовчуванням
            return const Locale('en');
          },
          initialRoute: '/',
          routes: {
            '/': (context) => Start(),
            '/game': (context) => FutureBuilder<List<String>>(
              future: loadButtonOrder(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Game(buttonOrder: snapshot.data!);
                } else {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
            '/score': (context) => Score(),
            '/settings': (context) => SettingsPage(),
            '/language': (context) => LanguagePage(),
          },
        ),
      ),
    ),
  );
}