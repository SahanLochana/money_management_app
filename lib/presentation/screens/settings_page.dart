import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/section_header.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _breakfastReminder = true;
  bool _lunchReminder = true;
  bool _dinnerReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
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
            _buildReminderCard(
              title: "Breakfast Reminder",
              time: "08:00 AM",
              value: _breakfastReminder,
              onChanged: (val) => setState(() => _breakfastReminder = val),
            ),
            _buildReminderCard(
              title: "Lunch Reminder",
              time: "01:00 PM",
              value: _lunchReminder,
              onChanged: (val) => setState(() => _lunchReminder = val),
            ),
            _buildReminderCard(
              title: "Dinner Reminder",
              time: "08:00 PM",
              value: _dinnerReminder,
              onChanged: (val) => setState(() => _dinnerReminder = val),
            ),

            const SizedBox(height: 20),

            // Categories & Wallets Section
            const SectionHeader(title: "Preferences"),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.category_rounded,
              iconColor: AppColors.primary,
              title: "Manage Categories",
              subtitle: "5 System, 0 Custom categories",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.secondary,
              title: "Manage Wallets",
              subtitle: "In Hand, In Bank",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.track_changes_rounded,
              iconColor: AppColors.warning,
              title: "Daily Budget Target",
              subtitle: "₹2,000 / day",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Data & Storage
            const SectionHeader(title: "Data Management"),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: Icons.file_download_outlined,
              iconColor: AppColors.primary,
              title: "Export Data",
              subtitle: "Export records to CSV / JSON",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.expense,
              title: "Clear All Data",
              subtitle: "Reset all local expenses and settings",
              onTap: () {},
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
          Column(
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
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
