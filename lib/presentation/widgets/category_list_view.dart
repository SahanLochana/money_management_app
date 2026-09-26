import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/entity_list_tile.dart';

class CategoryListView<T> extends StatelessWidget {
  final List<T> categories;
  final String Function(T item) emoji;
  final String Function(T item) name;
  final void Function(T item) onDelete;
  final String deleteTooltip;
  final EdgeInsetsGeometry padding;

  const CategoryListView({
    super.key,
    required this.categories,
    required this.emoji,
    required this.name,
    required this.onDelete,
    this.deleteTooltip = "Delete Category",
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        return EntityListTile(
          emoji: emoji(item),
          name: name(item),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.expense,
              size: 20,
            ),
            tooltip: deleteTooltip,
            onPressed: () => onDelete(item),
          ),
        );
      },
    );
  }
}
