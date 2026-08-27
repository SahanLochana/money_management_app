import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_fund.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_state.dart';
import 'package:money_management_app/presentation/screens/main_shell.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletSetupPage extends StatefulWidget {
  const WalletSetupPage({super.key});

  @override
  State<WalletSetupPage> createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  final Map<int, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWalletsEvent());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int walletId) {
    if (!_controllers.containsKey(walletId)) {
      _controllers[walletId] = TextEditingController();
    }
    return _controllers[walletId]!;
  }

  Future<void> _saveAndProceed(List<Wallet> wallets) async {
    setState(() => _isLoading = true);

    final now = DateTime.now().toIso8601String();
    final walletBloc = context.read<WalletBloc>();

    for (final wallet in wallets) {
      final text = _controllers[wallet.id]?.text.trim() ?? '';
      final amt = double.tryParse(text) ?? 0.0;
      if (amt > 0) {
        walletBloc.add(
          AddWalletFundsEvent(
            WalletFund(
              walletId: wallet.id,
              amountCents: (amt * 100).toInt(),
              note: "Initial setup balance",
              createdAt: now,
            ),
          ),
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallet_setup_done', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    }
  }

  Future<void> _skipSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallet_setup_done', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final List<Wallet> wallets = (state is WalletLoaded)
                ? state.wallets
                : [
                    const Wallet(id: 1, name: 'In Hand', emoji: '👛'),
                    const Wallet(id: 2, name: 'In Bank', emoji: '🏦'),
                  ];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Brand Badge
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primary,
                                size: 32,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              "Welcome to Vault",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Center(
                            child: Text(
                              "Set your current balances to keep your net worth and spending accurately tracked.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          ...wallets.map((wallet) {
                            final controller = _getController(wallet.id);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.surfaceBorder.withValues(alpha: 0.8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          wallet.emoji,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        wallet.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "0.00",
                                      hintStyle: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      prefixText: "Rs  ",
                                      prefixStyle: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.surfaceLight,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _saveAndProceed(wallets),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: const Color(0xFF0F0F14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0F0F14),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Get Started  →",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _isLoading ? null : _skipSetup,
                          child: const Text(
                            "Skip for now",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
