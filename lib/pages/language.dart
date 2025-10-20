import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentLocale = ValueNotifier<Locale>(const Locale('en'));

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? selectedLanguageCode; // Тимчасово обрана мова
  
  // Переклади назв мов
  final Map<String, Map<String, String>> languageTranslations = {
    'en': {
      'en': 'English',
      'uk': 'Ukrainian', 
      // 'de': 'German',
      // 'fr': 'French',
      // 'es': 'Spanish',
      // 'pl': 'Polish',
    },
    'uk': {
      'en': 'Англійська',
      'uk': 'Українська',
      // 'de': 'Німецька', 
      // 'fr': 'Французька',
      // 'es': 'Іспанська',
      // 'pl': 'Польська',
    },
  //   'de': {
  //     'en': 'Englisch',
  //     'uk': 'Ukrainisch',
  //     'de': 'Deutsch',
  //     'fr': 'Französisch', 
  //     'es': 'Spanisch',
  //     'pl': 'Polnisch',
  //   },
  //   'fr': {
  //     'en': 'Anglais',
  //     'uk': 'Ukrainien',
  //     'de': 'Allemand',
  //     'fr': 'Français',
  //     'es': 'Espagnol', 
  //     'pl': 'Polonais',
  //   },
  //   'es': {
  //     'en': 'Inglés',
  //     'uk': 'Ucraniano',
  //     'de': 'Alemán',
  //     'fr': 'Francés',
  //     'es': 'Español',
  //     'pl': 'Polaco',
  //   },
  //   'pl': {
  //     'en': 'Angielski',
  //     'uk': 'Ukraiński', 
  //     'de': 'Niemiecki',
  //     'fr': 'Francuski',
  //     'es': 'Hiszpański',
  //     'pl': 'Polski',
  //   },
   };

  final List<Map<String, dynamic>> languages = [
    {
      'code': 'en',
      'name': 'English',
      'flag': '🇺🇸',
      'locale': const Locale('en'),
    },
    {
      'code': 'uk',
      'name': 'Ukrainian',
      'flag': '🇺🇦',
      'locale': const Locale('uk'),
    },
    // {
    //   'code': 'de',
    //   'name': 'German',
    //   'flag': '🇩🇪',
    //   'locale': const Locale('de'),
    // },
    // {
    //   'code': 'fr',
    //   'name': 'French',
    //   'flag': '🇫🇷',
    //   'locale': const Locale('fr'),
    // },
    // {
    //   'code': 'es',
    //   'name': 'Spanish',
    //   'flag': '🇪🇸',
    //   'locale': const Locale('es'),
    // },
    // {
    //   'code': 'pl',
    //   'name': 'Polish',
    //   'flag': '🇵🇱',
    //   'locale': const Locale('pl'),
    // },
  ];

  // Отримання перекладеної назви мови
  String getTranslatedLanguageName(String languageCode) {
    final currentLang = currentLocale.value.languageCode;
    return languageTranslations[currentLang]?[languageCode] ?? 
           languageTranslations['en']![languageCode]!;
  }

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
    selectedLanguageCode = savedLang; // Встановлюємо поточну мову як обрану
    setState(() {});
  }

  // Збереження вибраної мови
  Future<void> _saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
  }

  // Застосувати обрану мову
  Future<void> _applyLanguageChange() async {
    if (selectedLanguageCode != null && selectedLanguageCode != currentLocale.value.languageCode) {
      await _saveLanguage(selectedLanguageCode!);
      final selectedLanguage = languages.firstWhere((lang) => lang['code'] == selectedLanguageCode);
      currentLocale.value = selectedLanguage['locale'];
      setState(() {});
      
      // Показуємо повідомлення про успішну зміну
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentLocale.value.languageCode == 'en' 
              ? 'Language changed successfully!' 
              : 'Мову успішно змінено!',
            style: TextStyle(fontFamily: 'RubikMonoOne'),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLocale.value.languageCode == 'en' ? 'Language' : 'Мова',
          style: const TextStyle(
            fontFamily: 'RubikMonoOne',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isCurrentLanguage = currentLocale.value.languageCode == language['code'];
                    final isSelectedForChange = selectedLanguageCode == language['code'];
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Text(
                          language['flag'],
                          style: const TextStyle(fontSize: 30),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    getTranslatedLanguageName(language['code']),
                                    style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 15,
                                      fontWeight: isSelectedForChange ? FontWeight.bold : FontWeight.normal,
                                      color: isSelectedForChange
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isCurrentLanguage) ...[
                                  Text(
                                    currentLocale.value.languageCode == 'en' ? '(current)' : '(поточна)',
                                    style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 8,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (!isSelectedForChange) ...[
                              const SizedBox(height: 4),
                              Text(
                                '(${language['name']})',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        tileColor: isSelectedForChange
                          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                          : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isSelectedForChange
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                        ),
                        onTap: () {
                          setState(() {
                            selectedLanguageCode = language['code'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Кнопка збереження
                SizedBox(
                  child: ElevatedButton(
                    onPressed: selectedLanguageCode != null && selectedLanguageCode != currentLocale.value.languageCode
                      ? _applyLanguageChange
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      currentLocale.value.languageCode == 'en' ? 'Save' : 'Зберегти',
                      style: TextStyle(
                        fontFamily: 'RubikMonoOne',
                        fontSize: 20,
                        color: selectedLanguageCode != null && selectedLanguageCode != currentLocale.value.languageCode
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}