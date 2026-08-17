import 'package:money_management_app/data/database/tables.dart';

class Category {
  final int? id;
  final String name;
  final String emoji;
  final int defaultAmountCents;
  final bool isSystem;
  final bool isDeleted;

  const Category({
    this.id,
    required this.name,
    required this.emoji,
    this.defaultAmountCents = 0,
    this.isSystem = false,
    this.isDeleted = false,
  });

  double get defaultAmount => defaultAmountCents / 100.0;

  Category copyWith({
    int? id,
    String? name,
    String? emoji,
    int? defaultAmountCents,
    bool? isSystem,
    bool? isDeleted,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      defaultAmountCents: defaultAmountCents ?? this.defaultAmountCents,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppTables.colCatId: id,
      AppTables.colCatName: name,
      AppTables.colCatEmoji: emoji,
      AppTables.colCatDefaultAmountCents: defaultAmountCents,
      AppTables.colCatIsSystem: isSystem ? 1 : 0,
      AppTables.colCatIsDeleted: isDeleted ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map[AppTables.colCatId] as int?,
      name: map[AppTables.colCatName] as String,
      emoji: map[AppTables.colCatEmoji] as String,
      defaultAmountCents: (map[AppTables.colCatDefaultAmountCents] as int?) ?? 0,
      isSystem: (map[AppTables.colCatIsSystem] as int? ?? 0) == 1,
      isDeleted: (map[AppTables.colCatIsDeleted] as int? ?? 0) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
