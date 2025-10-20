import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris/pages/buttons.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:tetris/pages/language.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> defaultButtons = [
    'none1',
    'none2',
    'Pause',
    'Down',
    'Left',
    'Right',
    'Rotate',
    'HardDrop',
  ];

  List<String> buttons = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadButtonOrder();
  }

  Future<void> _loadButtonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('buttonOrder');
    List<String> updatedOrder;
    if (savedOrder == null) {
      updatedOrder = List<String>.from(defaultButtons);
    } else {
      updatedOrder = List<String>.from(savedOrder);
      for (final btn in defaultButtons) {
        if (!updatedOrder.contains(btn)) {
          updatedOrder.add(btn);
        }
      }
      updatedOrder.removeWhere((btn) => !defaultButtons.contains(btn));
      if (updatedOrder.length != savedOrder.length || !updatedOrder.every((e) => savedOrder.contains(e))) {
        await prefs.setStringList('buttonOrder', updatedOrder);
      }
    }
    setState(() {
      buttons = updatedOrder;
      loading = false;
    });
  }

  Future<void> _saveButtonOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('buttonOrder', order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentLocale.value.languageCode == 'en' ? 'Settings' : 'Налаштування', style: TextStyle(
          fontFamily: 'RubikMonoOne',
          fontSize: 25,
        ),),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(currentLocale.value.languageCode == 'en' ? 'Drag buttons to change order' : 'Перетягніть кнопки для зміни порядку', style: TextStyle(
                      fontFamily: 'RubikMonoOne',
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),),
                  ),
                  Expanded(
                    child: ReorderableGridView.count(
                      crossAxisCount: 4,
                      // mainAxisSpacing: 10,
                      // crossAxisSpacing: 10,
                      childAspectRatio: 1, // Ширше для кращого вигляду
                      onReorder: (oldIndex, newIndex) async {
                        setState(() {
                          final item = buttons.removeAt(oldIndex);
                          buttons.insert(newIndex, item);
                        });
                        // Поки що не зберігаємо автоматично
                      },
                      children: [
                        for (final btn in buttons)
                          Container(
                            key: ValueKey(btn),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MoveButtonWidget(
                                  icon: getButtonIcon(btn),
                                  onPressed: () {},
                                  holdable: isHoldable(btn),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Кнопка "Зберегти"
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Зберігаємо новий порядок кнопок
                        await _saveButtonOrder(buttons);
                        
                        // Показуємо повідомлення про збереження
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              currentLocale.value.languageCode == 'en' 
                                ? 'Buttons saved successfully!' 
                                : 'Кнопки успішно збережено!',
                              style: TextStyle(
                                fontFamily: 'RubikMonoOne',
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onPrimary,
                                ),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        );
                        
                        // Через невелику затримку повертаємося на головну сторінку
                        await Future.delayed(Duration(milliseconds: 500));
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        currentLocale.value.languageCode == 'en' ? 'Save' : 'Зберегти',
                        style: TextStyle(
                          fontFamily: 'RubikMonoOne',
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// --- Глобальні функції для кнопок ---
IconData getButtonIcon(String btn) {
  switch (btn) {
    case 'none1':
      return Icons.circle_outlined;
    case 'none2':
      return Icons.circle_outlined;
    case 'Pause':
      return Icons.pause_circle_outline_outlined;
    case 'Down':
      return Icons.arrow_circle_down_outlined;
    case 'Left':
      return Icons.arrow_circle_left_outlined;
    case 'Right':
      return Icons.arrow_circle_right_outlined;
    case 'Rotate':
      return Icons.refresh_outlined;
    case 'HardDrop':
      return Icons.keyboard_double_arrow_down_outlined;
    default:
      return Icons.help_outline;
  }
}

bool isHoldable(String btn) {
  return btn == 'Left' || btn == 'Right' || btn == 'Down';
}
