import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_state.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/theme/category_ui_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TransactionMode { expense, income, transfer }

class AddTransactionPage extends StatefulWidget {
  final Expense? expenseToEdit;
  final TransactionMode initialMode;
  final int? initialCategoryId;
  final double? initialAmount;

  const AddTransactionPage({
    super.key,
    this.expenseToEdit,
    this.initialMode = TransactionMode.expense,
    this.initialCategoryId,
    this.initialAmount,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late TransactionMode _mode;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  Category? _selectedCategory;
  Wallet? _selectedWallet;

  // For Transfer Mode
  Wallet? _fromWallet;
  Wallet? _toWallet;

  bool get isEditMode => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    final exp = widget.expenseToEdit;

    if (exp != null) {
      _amountController.text = exp.amount.toStringAsFixed(0);
      if (exp.note != null) _noteController.text = exp.note!;
      try {
        _selectedDate = DateTime.parse(exp.expenseDate);
      } catch (_) {
        _selectedDate = DateTime.now();
      }
      try {
        final parts = exp.expenseTime.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (_) {
        _selectedTime = TimeOfDay.now();
      }
    } else {
      if (widget.initialAmount != null && widget.initialAmount! > 0) {
        _amountController.text = widget.initialAmount!.toStringAsFixed(0);
      }
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _loadLastUsedWallet();
    }
  }

  Future<void> _loadLastUsedWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWalletId = prefs.getInt('last_used_wallet_id');
    if (lastWalletId != null && mounted) {
      final state = context.read<ExpenseBloc>().state;
      if (state is ExpenseLoaded) {
        final w = state.getWallet(lastWalletId);
        if (w != null) {
          setState(() => _selectedWallet = w);
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (_mode) {
      case TransactionMode.expense:
        return AppColors.expense;
      case TransactionMode.income:
        return AppColors.income;
      case TransactionMode.transfer:
        return AppColors.secondary;
    }
  }

  String get _pageTitle {
    if (isEditMode) return 'Edit Expense';
    switch (_mode) {
      case TransactionMode.expense:
        return 'Add Expense';
      case TransactionMode.income:
        return 'Add Income';
      case TransactionMode.transfer:
        return 'Transfer Funds';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentColor,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _accentColor,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _onSave(List<Category> categories, List<Wallet> wallets) async {
    final amountText = _amountController.text.trim();
    final parsedAmount = double.tryParse(amountText);

    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Amount must be greater than 0"),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final category = _selectedCategory ?? categories.firstOrNull;
    if (category == null && _mode != TransactionMode.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a category"),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final wallet = _selectedWallet ?? wallets.firstOrNull;
    if (wallet == null && _mode != TransactionMode.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a wallet"),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Save last used wallet to preferences
    if (wallet?.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_used_wallet_id', wallet!.id);
    }

    if (!mounted) return;

    final amountCents = (parsedAmount * 100).toInt();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final note = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null;

    if (_mode == TransactionMode.transfer) {
      final from = _fromWallet ?? wallets.firstOrNull;
      final to = _toWallet ?? (wallets.length > 1 ? wallets[1] : wallets.firstOrNull);

      if (from == null || to == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please select source and destination wallets"),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      if (from.id == to.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Cannot transfer to the same wallet"),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      final transfer = WalletTransfer(
        fromWalletId: from.id,
        toWalletId: to.id,
        amountCents: amountCents,
        transferDate: dateStr,
        transferTime: timeStr,
        note: note,
        createdAt: DateTime.now().toIso8601String(),
      );

      context.read<WalletBloc>().add(AddWalletTransferEvent(transfer));
      context.read<ExpenseBloc>().add(const LoadExpenses());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Transferred Rs ${parsedAmount.toStringAsFixed(0)} from ${from.name} to ${to.name}"),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (isEditMode) {
      final updated = widget.expenseToEdit!.copyWith(
        categoryId: category!.id ?? 1,
        amountCents: amountCents,
        walletId: wallet!.id,
        expenseDate: dateStr,
        expenseTime: timeStr,
        note: note,
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(updated));
    } else {
      final newExpense = Expense(
        categoryId: category?.id ?? 1,
        amountCents: amountCents,
        walletId: wallet?.id ?? 1,
        expenseDate: dateStr,
        expenseTime: timeStr,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<ExpenseBloc>().add(AddExpenseEvent(newExpense));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? "Expense updated successfully" : "Expense added successfully",
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        List<Category> categories = [];
        List<Wallet> wallets = [];

        if (state is ExpenseLoaded) {
          categories = state.categories;
          wallets = state.wallets;

          if (isEditMode && _selectedCategory == null) {
            _selectedCategory = state.getCategory(widget.expenseToEdit!.categoryId);
          } else if (_selectedCategory == null && widget.initialCategoryId != null) {
            _selectedCategory = state.getCategory(widget.initialCategoryId!);
          }
          if (isEditMode && _selectedWallet == null) {
            _selectedWallet = state.getWallet(widget.expenseToEdit!.walletId);
          }
          _selectedCategory ??= categories.firstOrNull;
          _selectedWallet ??= wallets.firstOrNull;
          _fromWallet ??= wallets.firstOrNull;
          _toWallet ??= wallets.length > 1 ? wallets[1] : wallets.firstOrNull;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _pageTitle,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segmented Mode Selector (hide during Edit)
                  if (!isEditMode) ...[
                    _buildModeSelector(),
                    const SizedBox(height: 24),
                  ],

                  // Large Amount Input
                  _buildAmountInput(),
                  const SizedBox(height: 24),

                  // Mode Specific Content
                  if (_mode == TransactionMode.transfer) ...[
                    _buildTransferWalletsSection(wallets),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Categories
                    _buildCategorySection(categories),
                    const SizedBox(height: 20),

                    // Wallet Selection
                    _buildWalletSection(wallets),
                    const SizedBox(height: 20),
                  ],

                  // Date & Time Row
                  _buildDateTimeSection(),
                  const SizedBox(height: 20),

                  // Optional Note Input
                  _buildNoteInput(),
                  const SizedBox(height: 32),

                  // Save Button
                  _buildSaveButton(categories, wallets),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _buildModeTab("Expense", TransactionMode.expense, AppColors.expense),
          _buildModeTab("Income", TransactionMode.income, AppColors.income),
          _buildModeTab("Transfer", TransactionMode.transfer, AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, TransactionMode mode, Color color) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color.withValues(alpha: 0.4), width: 1.2)
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          const Text(
            "Enter Amount",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Rs ",
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((cat) {
            final isSelected = _selectedCategory?.id == cat.id;
            final catColor = CategoryUIHelper.getColor(cat);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                  if (!isEditMode &&
                      cat.defaultAmountCents > 0 &&
                      _amountController.text.isEmpty) {
                    _amountController.text = cat.defaultAmount.toStringAsFixed(0);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? catColor.withValues(alpha: 0.18)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? catColor.withValues(alpha: 0.6)
                        : AppColors.surfaceBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: isSelected ? catColor : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWalletSection(List<Wallet> wallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Wallet",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: wallets.map((wallet) {
            final isSelected = _selectedWallet?.id == wallet.id;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedWallet = wallet);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: wallet == wallets.first ? 8 : 0,
                    left: wallet == wallets.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.surfaceBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wallet.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        wallet.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransferWalletsSection(List<Wallet> wallets) {
    final fromName = _fromWallet?.name ?? 'In Hand';
    final toName = _toWallet?.name ?? 'In Bank';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Transfer Between Wallets",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "From",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fromName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    final temp = _fromWallet;
                    _fromWallet = _toWallet;
                    _toWallet = temp;
                  });
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "To",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      toName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Date",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Time",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Note (Optional)",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Add any extra context or note...",
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(List<Category> categories, List<Wallet> wallets) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onSave(categories, wallets),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: const Color(0xFF0F0F14),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: Text(
          isEditMode
              ? "Update Expense"
              : _mode == TransactionMode.transfer
                  ? "Complete Transfer"
                  : "Save Expense",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
