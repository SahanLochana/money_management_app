import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';
import 'package:money_management_app/presentation/blocs/category/category_bloc.dart';
import 'package:money_management_app/presentation/blocs/category/category_event.dart';
import 'package:money_management_app/presentation/blocs/category/category_state.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_state.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/section_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _dailyBudget = 500.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    context.read<ReminderBloc>().add(const LoadRemindersEvent());
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyBudget = prefs.getDouble('daily_budget') ?? 500.0;
    });
  }

  Future<void> _editDailyBudgetDialog() async {
    final controller = TextEditingController(text: _dailyBudget.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          "Edit Daily Budget",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixText: "Rs ",
            prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              Navigator.pop(context, val);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0F0F14),
            ),
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('daily_budget', result);
      setState(() => _dailyBudget = result);
    }
  }

  Future<void> _addCategoryDialog() async {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '🏷️';
    final emojis = ['☕', '🍕', '🚗', '🛍️', '💊', '🎮', '📚', '🏋️', '✈️', '🏷️'];

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
            "Add Custom Category",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Choose Emoji", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: emojis.map((e) {
                  final isSelected = selectedEmoji == e;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: AppColors.primary) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 18)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text("Category Name", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "e.g. Gym, Coffee, Travel",
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(
                    context,
                    Category(
                      name: name,
                      emoji: selectedEmoji,
                      isSystem: false,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F0F14),
              ),
              child: const Text("Add", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    if (created != null && mounted) {
      context.read<CategoryBloc>().add(AddCategoryEvent(created));
    }
  }

  Future<void> _editReminderTime(ReminderSlot slot) async {
    final parts = slot.time.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final updated = slot.copyWith(time: timeStr);
      context.read<ReminderBloc>().add(UpdateReminderEvent(updated));
    }
  }

  Future<void> _clearAllDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          "Clear All Data?",
          style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          "This will delete all your local expense records. This action cannot be undone.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear All", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ExpenseBloc>().add(const ClearAllExpensesEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("All expense data cleared"),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    final repo = context.read<ExpenseRepository>();
    final data = await repo.exportAllData();
    final jsonString = jsonEncode(data);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Text(
            "Exported JSON Data",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              jsonString,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F0F14),
              ),
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Daily Reminders Section
          const SectionHeader(title: "Daily Reminders"),
          const SizedBox(height: 8),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state is ReminderLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state is ReminderLoaded) {
                return Column(
                  children: state.reminders.map((slot) {
                    final cat = state.getCategory(slot.categoryId);
                    final title = '${cat?.name ?? "Meal"} Reminder';

                    return _buildReminderCard(
                      title: title,
                      time: slot.time,
                      value: slot.isActive,
                      onChanged: (val) {
                        if (slot.id != null) {
                          context.read<ReminderBloc>().add(
                                ToggleReminderEvent(id: slot.id!, isActive: val),
                              );
                        }
                      },
                      onTimeTap: () => _editReminderTime(slot),
                    );
                  }).toList(),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 20),

          // Categories Section
          SectionHeader(
            title: "Manage Categories",
            actionLabel: "+ Add Category",
            onActionTap: _addCategoryDialog,
          ),
          const SizedBox(height: 8),
          BlocConsumer<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state is CategoryError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.expense,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CategoryLoaded) {
                return Column(
                  children: state.categories.map((cat) {
                    return _buildCategoryItemTile(cat);
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 20),

          // Preferences
          const SectionHeader(title: "Preferences"),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.warning,
            title: "Daily Budget Target",
            subtitle: "Rs ${_dailyBudget.toStringAsFixed(0)} / day",
            onTap: _editDailyBudgetDialog,
          ),

          const SizedBox(height: 20),

          // Data & Storage
          const SectionHeader(title: "Data Management"),
          const SizedBox(height: 8),
          _buildSettingTile(
            icon: Icons.file_download_outlined,
            iconColor: AppColors.primary,
            title: "Export Data",
            subtitle: "Export records to JSON format",
            onTap: _exportData,
          ),
          _buildSettingTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.expense,
            title: "Clear All Data",
            subtitle: "Reset all local expenses",
            onTap: _clearAllDataDialog,
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String time,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTimeTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 12, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItemTile(Category cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Text(cat.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            cat.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (cat.isSystem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textMuted),
                  SizedBox(width: 4),
                  Text("System", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 18),
              onPressed: () {
                if (cat.id != null) {
                  context.read<CategoryBloc>().add(DeleteCategoryEvent(cat.id!));
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
