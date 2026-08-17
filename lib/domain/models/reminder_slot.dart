import 'package:money_management_app/data/database/tables.dart';

class ReminderSlot {
  final int? id;
  final int categoryId;
  final String time; // HH:mm
  final int defaultAmountCents;
  final bool isActive;
  final bool isSystem;

  const ReminderSlot({
    this.id,
    required this.categoryId,
    required this.time,
    this.defaultAmountCents = 0,
    this.isActive = true,
    this.isSystem = false,
  });

  double get defaultAmount => defaultAmountCents / 100.0;

  ReminderSlot copyWith({
    int? id,
    int? categoryId,
    String? time,
    int? defaultAmountCents,
    bool? isActive,
    bool? isSystem,
  }) {
    return ReminderSlot(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      time: time ?? this.time,
      defaultAmountCents: defaultAmountCents ?? this.defaultAmountCents,
      isActive: isActive ?? this.isActive,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppTables.colReminderId: id,
      AppTables.colReminderCategoryId: categoryId,
      AppTables.colReminderTime: time,
      AppTables.colReminderDefaultAmountCents: defaultAmountCents,
      AppTables.colReminderIsActive: isActive ? 1 : 0,
      AppTables.colReminderIsSystem: isSystem ? 1 : 0,
    };
  }

  factory ReminderSlot.fromMap(Map<String, dynamic> map) {
    return ReminderSlot(
      id: map[AppTables.colReminderId] as int?,
      categoryId: map[AppTables.colReminderCategoryId] as int,
      time: map[AppTables.colReminderTime] as String,
      defaultAmountCents: (map[AppTables.colReminderDefaultAmountCents] as int?) ?? 0,
      isActive: (map[AppTables.colReminderIsActive] as int? ?? 1) == 1,
      isSystem: (map[AppTables.colReminderIsSystem] as int? ?? 0) == 1,
    );
  }
}
