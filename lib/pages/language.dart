import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentLocale = ValueNotifier<Locale>(const Locale('en'));

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final List<Map<String, dynamic>> languages = [
    {
      'code': 'en',
      'name': 'English',
      'flag': '🇺🇸',
      'locale': const Locale('en'),
    },
    {
      'code': 'uk',
      'name': 'Українська',
      'flag': '🇺🇦',
      'locale': const Locale('uk'),
    },
    // {
    //   'code': 'de',
    //   'name': 'Deutsch',
    //   'flag': '🇩🇪',
    //   'locale': const Locale('de'),
    // },
    // {
    //   'code': 'fr',
    //   'name': 'Français',
    //   'flag': '🇫🇷',
    //   'locale': const Locale('fr'),
    // },
    // {
    //   'code': 'es',
    //   'name': 'Español',
    //   'flag': '🇪🇸',
    //   'locale': const Locale('es'),
    // },
    // {
    //   'code': 'pl',
    //   'name': 'Polski',
    //   'flag': '🇵🇱',
    //   'locale': const Locale('pl'),
    // },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  // Завантаження поточної мови
  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language') ?? 'en';
    currentLocale.value = Locale(savedLang);
  }

  // Збереження вибраної мови
  Future<void> _saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
  }

  void _showChangeLanguageDialog(Map<String, dynamic> language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            width: 2,
          ),
        ),
        title: Text(
          currentLocale.value.languageCode == 'en' 
            ? 'Change language?'
            : 'Змінити мову?',
          style: TextStyle(
            fontFamily: 'RubikMonoOne',
            fontSize: 25,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          currentLocale.value.languageCode == 'en'
            ? 'Switch language to "${language['name']}"?'
            : 'Перемкнути мову на "${language['name']}"?',
          style: TextStyle(
            fontFamily: 'RubikMonoOne',
            fontSize: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLocale.value.languageCode == 'en' ? 'Cancel' : 'Відмінити',
              style: TextStyle(
                fontFamily: 'RubikMonoOne',
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              await _saveLanguage(language['code']);
              currentLocale.value = language['locale'];
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(
              currentLocale.value.languageCode == 'en' ? 'Yes' : 'Так',
              style: TextStyle(
                fontFamily: 'RubikMonoOne',
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLocale.value.languageCode == 'en' ? ' Select language' : 'Оберіть мову',
          style: const TextStyle(
            fontFamily: 'RubikMonoOne',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = currentLocale.value.languageCode == language['code'];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Text(
                        language['flag'],
                        style: const TextStyle(fontSize: 30),
                      ),
                      title: Text(
                        language['name'],
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          )
                        : null,
                      tileColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                        : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: isSelected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : BorderSide.none,
                      ),
                      onTap: () {
                        if (!isSelected) {
                          _showChangeLanguageDialog(language);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}