import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/income_category.dart';
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
import 'package:money_management_app/presentation/widgets/app_back_appbar.dart';
import 'package:money_management_app/presentation/widgets/app_dialog_shell.dart';
import 'package:money_management_app/presentation/widgets/app_loading_indicator.dart';
import 'package:money_management_app/presentation/widgets/app_snackbar.dart';
import 'package:money_management_app/presentation/widgets/app_text_field.dart';
import 'package:money_management_app/presentation/widgets/category_list_view.dart';
import 'package:money_management_app/presentation/widgets/confirm_action_dialog.dart';
import 'package:money_management_app/presentation/widgets/emoji_picker_grid.dart';
import 'package:money_management_app/presentation/widgets/labeled_field.dart';
import 'package:money_management_app/presentation/widgets/pill_action_button.dart';

enum CategoryTab { expense, income }

class ManageCategoriesPage extends StatefulWidget {
  final CategoryTab initialTab;

  const ManageCategoriesPage({
    super.key,
    this.initialTab = CategoryTab.expense,
  });

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  late CategoryTab _currentTab;
  List<IncomeCategory> _incomeCategories = [];
  bool _isLoadingIncome = true;

  Color get _tabAccent =>
      _currentTab == CategoryTab.expense ? AppColors.primary : AppColors.income;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
    _loadIncomeCategories();
  }

  Future<void> _loadIncomeCategories() async {
    final list = await IncomeCategory.loadAll();
    if (mounted) {
      setState(() {
        _incomeCategories = list;
        _isLoadingIncome = false;
      });
    }
  }

  Future<void> _addCategoryDialog() async {
    final nameCtrl = TextEditingController();
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
        builder: (context, setDialogState) => AppDialogShell(
          title: "Add Expense Category",
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledField(
                  label: "Choose Emoji",
                  child: EmojiPickerGrid(
                    emojis: emojis,
                    selectedEmoji: selectedEmoji,
                    onSelected: (e) => setDialogState(() => selectedEmoji = e),
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: "Category Name",
                  child: AppTextField(
                    controller: nameCtrl,
                    autofocus: true,
                    hintText: "e.g. Gym, Coffee, Groceries",
                    accentColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          onConfirm: () {
            final name = nameCtrl.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(
                context,
                Category(
                  name: name,
                  emoji: selectedEmoji,
                  defaultAmountCents: 0,
                  isSystem: false,
                ),
              );
            }
          },
        ),
      ),
    );

    if (created != null && mounted) {
      context.read<CategoryBloc>().add(AddCategoryEvent(created));
      AppSnackBar.show(
        context,
        message: "Expense Category '${created.name}' added",
      );
    }
  }

  Future<void> _addIncomeCategoryDialog() async {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '💰';
    final emojis = [
      '💰',
      '💵',
      '💳',
      '🏦',
      '💼',
      '📈',
      '🎯',
      '💹',
      '🏠',
      '🚀',
      '💎',
      '🎁',
      '⭐',
      '🌟',
      '💡',
      '🤝',
      '📊',
      '🏆',
    ];

    final created = await showDialog<IncomeCategory?>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AppDialogShell(
          title: "Add Income Category",
          confirmColor: AppColors.income,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledField(
                  label: "Choose Emoji",
                  child: EmojiPickerGrid(
                    emojis: emojis,
                    selectedEmoji: selectedEmoji,
                    onSelected: (e) => setDialogState(() => selectedEmoji = e),
                    accentColor: AppColors.income,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: "Category Name",
                  child: AppTextField(
                    controller: nameCtrl,
                    autofocus: true,
                    hintText: "e.g. Freelance, Part-time, Bonus",
                    accentColor: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          onConfirm: () {
            final name = nameCtrl.text.trim();
            if (name.isNotEmpty) {
              final newCat = IncomeCategory(
                id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                emoji: selectedEmoji,
              );
              Navigator.pop(dialogCtx, newCat);
            }
          },
        ),
      ),
    );

    if (created != null) {
      await IncomeCategory.saveCustom(created);
      await _loadIncomeCategories();
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "Added ${created.emoji} ${created.name} income category",
        );
      }
    }
  }

  Future<void> _deleteCategoryDialog(Category cat) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: "Delete '${cat.name}'?",
      titleIcon: Icons.warning_amber_rounded,
      titleIconColor: AppColors.expense,
      message: "Are you sure you want to delete ${cat.emoji} ${cat.name}?",
      confirmLabel: "Delete Category",
      confirmColor: AppColors.expense,
      infoBox: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.expense.withValues(alpha: 0.3)),
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
    );

    if (confirmed && mounted && cat.id != null) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(cat.id!));
      context.read<ExpenseBloc>().add(const LoadExpenses());
      context.read<ReminderBloc>().add(const LoadRemindersEvent());
      final now = DateTime.now();
      context.read<StatsBloc>().add(
        LoadMonthlyStatsEvent(year: now.year, month: now.month),
      );

      AppSnackBar.show(
        context,
        message: "Deleted '${cat.name}' (expenses reassigned to 'Other')",
      );
    }
  }

  Future<void> _deleteIncomeCategoryDialog(IncomeCategory cat) async {
    final confirmed = await ConfirmActionDialog.show(
      context,
      title: "Delete '${cat.name}'?",
      titleIcon: Icons.warning_amber_rounded,
      titleIconColor: AppColors.expense,
      message: "Are you sure you want to delete ${cat.emoji} ${cat.name}?",
      confirmLabel: "Delete Category",
      confirmColor: AppColors.expense,
    );

    if (confirmed == true && mounted) {
      await IncomeCategory.deleteCategory(cat.id);
      await _loadIncomeCategories();
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "Deleted '${cat.name}' income category",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBackAppBar(
        title: "Manage Categories",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PillActionButton(
              label: _currentTab == CategoryTab.expense
                  ? "Add Expense"
                  : "Add Income",
              icon: Icons.add_rounded,
              color: _tabAccent,
              onPressed: _currentTab == CategoryTab.expense
                  ? _addCategoryDialog
                  : _addIncomeCategoryDialog,
            ),
          ),
        ],
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            AppSnackBar.show(context, message: state.message, isError: true);
          }
        },
        builder: (context, state) {
          final expenseCategories = (state is CategoryLoaded)
              ? state.categories
              : <Category>[];

          return Column(
            children: [
              // Segmented Tab Selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        label: "Expense",
                        count: expenseCategories.length,
                        tab: CategoryTab.expense,
                        activeColor: AppColors.expense,
                      ),
                      _buildTabButton(
                        label: "Income",
                        count: _incomeCategories.length,
                        tab: CategoryTab.income,
                        activeColor: AppColors.income,
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Body
              Expanded(
                child: _currentTab == CategoryTab.expense
                    ? _buildExpenseCategoriesList(state, expenseCategories)
                    : _buildIncomeCategoriesList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required int count,
    required CategoryTab tab,
    required Color activeColor,
  }) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTab = tab;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.25)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    color: isSelected ? activeColor : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCategoriesList(
    CategoryState state,
    List<Category> categories,
  ) {
    if (state is CategoryLoading) {
      return const AppLoadingIndicator(color: AppColors.primary);
    }

    return CategoryListView<Category>(
      categories: categories,
      emoji: (cat) => cat.emoji,
      name: (cat) => cat.name,
      onDelete: _deleteCategoryDialog,
      deleteTooltip: "Delete Category",
    );
  }

  Widget _buildIncomeCategoriesList() {
    if (_isLoadingIncome) {
      return const AppLoadingIndicator(color: AppColors.income);
    }

    return CategoryListView<IncomeCategory>(
      categories: _incomeCategories,
      emoji: (cat) => cat.emoji,
      name: (cat) => cat.name,
      onDelete: _deleteIncomeCategoryDialog,
      deleteTooltip: "Delete Income Category",
    );
  }
}
