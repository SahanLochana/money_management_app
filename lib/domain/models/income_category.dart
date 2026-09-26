import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeCategory {
  final String id;
  final String name;
  final String emoji;

  const IncomeCategory({
    required this.id,
    required this.name,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
    };
  }

  factory IncomeCategory.fromMap(Map<String, dynamic> map) {
    return IncomeCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
    );
  }

  static const List<IncomeCategory> defaultCategories = [
    IncomeCategory(id: 'from_home', name: 'From Home', emoji: '🏠'),
    IncomeCategory(id: 'mahapola', name: 'Mahapola', emoji: '🎓'),
    IncomeCategory(id: 'bursary', name: 'Bursary', emoji: '🏛️'),
    IncomeCategory(id: 'other', name: 'Other', emoji: '🍿'),
  ];

  static const String _prefKey = 'custom_income_categories';
  static const String _deletedPrefKey = 'deleted_income_categories';

  static Future<List<IncomeCategory>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey);
    final deleted = (prefs.getStringList(_deletedPrefKey) ?? []).toSet();
    final List<IncomeCategory> customs = [];
    if (raw != null) {
      for (final item in raw) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          customs.add(IncomeCategory.fromMap(map));
        } catch (_) {}
      }
    }
    final all = [...defaultCategories, ...customs];
    return all.where((c) => !deleted.contains(c.id)).toList();
  }

  static Future<void> saveCustom(IncomeCategory cat) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    raw.add(jsonEncode(cat.toMap()));
    await prefs.setStringList(_prefKey, raw);

    final deleted = (prefs.getStringList(_deletedPrefKey) ?? []).toSet();
    if (deleted.remove(cat.id)) {
      await prefs.setStringList(_deletedPrefKey, deleted.toList());
    }
  }

  static Future<void> deleteCategory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefKey) ?? [];
    raw.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_prefKey, raw);

    final deleted = (prefs.getStringList(_deletedPrefKey) ?? []).toSet();
    deleted.add(id);
    await prefs.setStringList(_deletedPrefKey, deleted.toList());
  }
}
