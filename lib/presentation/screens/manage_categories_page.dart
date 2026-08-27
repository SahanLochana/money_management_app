import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/presentation/blocs/category/category_bloc.dart';
import 'package:money_management_app/presentation/blocs/category/category_event.dart';
import 'package:money_management_app/presentation/blocs/category/category_state.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_event.dart';
import 'package:money_management_app/presentation/blocs/stats/stats_bloc.dart';
import 'package:money_management_app/presentation/blocs/stats/stats_event.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
  }

  Future<void> _addCategoryDialog() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedEmoji = '🏷️';
    final emojis = [
      '🍳',
      '🍔',
      '🌙',
      '☕',
      '🍕',
      '🚗',
      '🛍️',
      '💊',
      '🎮',
      '📚',
      '🏋️',
      '✈️',
      '🎬',
      '💡',
      '🏠',
      '🤝',
      '🍿',
      '🏷️',
    ];

    final created = await showDialog<Category>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Text(
            "Add New Category",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose Emoji",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((e) {
                    final isSelected = selectedEmoji == e;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedEmoji = e),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Category Name",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "e.g. Gym, Coffee, Groceries",
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Default Amount (Optional)",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "0.00",
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixText: "Rs ",
                    prefixStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty) {
                  Navigator.pop(
                    context,
                    Category(
                      name: name,
                      emoji: selectedEmoji,
                      defaultAmountCents: (amt * 100).toInt(),
                      isSystem: false,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F0F14),
              ),
              child: const Text(
                "Add",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );

    if (created != null && mounted) {
      context.read<CategoryBloc>().add(AddCategoryEvent(created));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Category '${created.name}' added"),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _deleteCategoryDialog(Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.expense,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Delete '${cat.name}'?",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${cat.emoji} ${cat.name}?",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.expense.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.expense,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Any existing transactions under this category will automatically be reassigned to 'Other'.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Delete Category",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && cat.id != null) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(cat.id!));
      // Refresh dependent blocs so UI updates seamlessly
      context.read<ExpenseBloc>().add(const LoadExpenses());
      context.read<ReminderBloc>().add(const LoadRemindersEvent());
      final now = DateTime.now();
      context.read<StatsBloc>().add(
            LoadMonthlyStatsEvent(year: now.year, month: now.month),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Deleted '${cat.name}' (expenses reassigned to 'Other')"),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Categories",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _addCategoryDialog,
              icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
              label: const Text(
                "Add",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.expense,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CategoryLoaded) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Info header card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.category_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${state.categories.length} Categories",
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "All categories can be removed or customized anytime.",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ...state.categories.map((cat) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cat.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (cat.defaultAmount > 0) ...[
                                const SizedBox(height: 2),
                                Text(
                                  "Default: Rs ${cat.defaultAmount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ] else if (cat.isSystem) ...[
                                const SizedBox(height: 2),
                                const Text(
                                  "System preset",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.expense,
                            size: 20,
                          ),
                          tooltip: "Delete Category",
                          onPressed: () => _deleteCategoryDialog(cat),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
