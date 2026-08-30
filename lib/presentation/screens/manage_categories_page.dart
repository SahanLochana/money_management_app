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
import 'package:money_management_app/presentation/widgets/app_dialog_shell.dart';
import 'package:money_management_app/presentation/widgets/app_snackbar.dart';
import 'package:money_management_app/presentation/widgets/confirm_action_dialog.dart';
import 'package:money_management_app/presentation/widgets/emoji_avatar.dart';
import 'package:money_management_app/presentation/widgets/emoji_picker_grid.dart';
import 'package:money_management_app/presentation/widgets/info_banner_card.dart';

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
                const Text(
                  "Choose Emoji",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                EmojiPickerGrid(
                  emojis: emojis,
                  selectedEmoji: selectedEmoji,
                  onSelected: (e) => setDialogState(() => selectedEmoji = e),
                  accentColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Category Name",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "e.g. Gym, Coffee, Groceries",
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
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
    final emojiCtrl = TextEditingController(text: '💰');

    final created = await showDialog<IncomeCategory?>(
      context: context,
      builder: (dialogCtx) => AppDialogShell(
        title: "Add Income Category",
        confirmColor: AppColors.income,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category Name",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: "e.g. Freelance, Part-time, Bonus",
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.income,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Emoji Icon",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emojiCtrl,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: "💰",
                filled: true,
                fillColor: AppColors.surfaceLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.income,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        onConfirm: () {
          final name = nameCtrl.text.trim();
          final emoji = emojiCtrl.text.trim().isNotEmpty
              ? emojiCtrl.text.trim()
              : '💰';
          if (name.isNotEmpty) {
            final newCat = IncomeCategory(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              emoji: emoji,
            );
            Navigator.pop(dialogCtx, newCat);
          }
        },
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
    final isCustom = !IncomeCategory.defaultCategories.any(
      (d) => d.id == cat.id,
    );
    if (!isCustom) {
      AppSnackBar.show(
        context,
        message: "Default income categories cannot be deleted",
        isError: true,
      );
      return;
    }

    final confirmed = await ConfirmActionDialog.show(
      context,
      title: "Delete '${cat.name}'?",
      titleIcon: Icons.warning_amber_rounded,
      titleIconColor: AppColors.expense,
      message:
          "Are you sure you want to remove ${cat.emoji} ${cat.name} from income categories?",
      confirmLabel: "Delete",
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
              onPressed: _currentTab == CategoryTab.expense
                  ? _addCategoryDialog
                  : _addIncomeCategoryDialog,
              icon: Icon(
                Icons.add_rounded,
                color: _tabAccent,
                size: 18,
              ),
              label: Text(
                _currentTab == CategoryTab.expense
                    ? "Add Expense"
                    : "Add Income",
                style: TextStyle(
                  color: _tabAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: _tabAccent.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Info Banner
        InfoBannerCard(
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.expense,
          title: "${categories.length} Expense Categories",
          subtitle:
              "Used to track daily meals, shopping, transport & other expenses.",
        ),

        ...categories.map((cat) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                EmojiAvatar(emoji: cat.emoji),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIncomeCategoriesList() {
    if (_isLoadingIncome) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.income),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Info Banner
        InfoBannerCard(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.income,
          title: "${_incomeCategories.length} Income Categories",
          subtitle: "Used to tag your earnings when adding transactions",
          gradient: LinearGradient(
            colors: [
              AppColors.income.withValues(alpha: 0.15),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        ..._incomeCategories.map((cat) {
          final isDefault = IncomeCategory.defaultCategories.any(
            (d) => d.id == cat.id,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                EmojiAvatar(emoji: cat.emoji),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isDefault)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.expense,
                      size: 20,
                    ),
                    tooltip: "Delete Income Category",
                    onPressed: () => _deleteIncomeCategoryDialog(cat),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Preset",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
