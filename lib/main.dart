import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/data/database/app_database.dart';
import 'package:money_management_app/data/datasources/category_local_datasource.dart';
import 'package:money_management_app/data/datasources/expense_local_datasource.dart';
import 'package:money_management_app/data/datasources/reminder_local_datasource.dart';
import 'package:money_management_app/data/datasources/wallet_local_datasource.dart';
import 'package:money_management_app/data/repositories/category_repository_impl.dart';
import 'package:money_management_app/data/repositories/expense_repository_impl.dart';
import 'package:money_management_app/data/repositories/reminder_repository_impl.dart';
import 'package:money_management_app/data/repositories/wallet_repository_impl.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';
import 'package:money_management_app/domain/repositories/reminder_repository.dart';
import 'package:money_management_app/domain/repositories/wallet_repository.dart';
import 'package:money_management_app/presentation/blocs/category/category_bloc.dart';
import 'package:money_management_app/presentation/blocs/category/category_event.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_event.dart';
import 'package:money_management_app/presentation/blocs/stats/stats_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/screens/add_transaction_page.dart';
import 'package:money_management_app/presentation/screens/main_shell.dart';
import 'package:money_management_app/presentation/screens/wallet_setup_page.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _handleNotificationPayload(String? payload) {
  if (payload == null || payload.isEmpty) return;
  try {
    final parts = payload.split('|');
    if (parts.isNotEmpty) {
      final categoryId = int.tryParse(parts[0]);
      final amountCents = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final double amount = amountCents / 100.0;

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => AddTransactionPage(
            initialCategoryId: categoryId,
            initialAmount: amount > 0 ? amount : null,
          ),
        ),
      );
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SQLite Database instance
  final appDb = AppDatabase.instance;
  await appDb.database;

  // Initialize Notification Service
  await NotificationService.instance.initialize(
    onDidReceiveNotificationResponse: (response) {
      _handleNotificationPayload(response.payload);
    },
  );

  // Request Android Notification Permissions
  await NotificationService.instance.requestPermissions();

  // Datasources
  final expenseDatasource = ExpenseLocalDatasource(appDatabase: appDb);
  final categoryDatasource = CategoryLocalDatasource(appDatabase: appDb);
  final walletDatasource = WalletLocalDatasource(appDatabase: appDb);
  final reminderDatasource = ReminderLocalDatasource(appDatabase: appDb);

  // Repositories
  final expenseRepository = ExpenseRepositoryImpl(localDatasource: expenseDatasource);
  final categoryRepository = CategoryRepositoryImpl(localDatasource: categoryDatasource);
  final walletRepository = WalletRepositoryImpl(localDatasource: walletDatasource);
  final reminderRepository = ReminderRepositoryImpl(localDatasource: reminderDatasource);

  // Re-sync all active daily reminders with the system alarm manager
  try {
    final activeReminders = await reminderRepository.getAllReminders();
    for (final slot in activeReminders) {
      if (slot.isActive && slot.id != null) {
        final cat = await categoryRepository.getCategoryById(slot.categoryId);
        await NotificationService.instance.scheduleDailyReminder(
          slot,
          cat?.name ?? 'Expense Reminder',
        );
      }
    }
  } catch (_) {}

  final prefs = await SharedPreferences.getInstance();
  final isSetupDone = prefs.getBool('wallet_setup_done') ?? false;

  runApp(
    MyApp(
      expenseRepository: expenseRepository,
      categoryRepository: categoryRepository,
      walletRepository: walletRepository,
      reminderRepository: reminderRepository,
      isSetupDone: isSetupDone,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;
  final ReminderRepository reminderRepository;
  final bool isSetupDone;

  const MyApp({
    super.key,
    required this.expenseRepository,
    required this.categoryRepository,
    required this.walletRepository,
    required this.reminderRepository,
    required this.isSetupDone,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<CategoryRepository>.value(value: categoryRepository),
        RepositoryProvider<WalletRepository>.value(value: walletRepository),
        RepositoryProvider<ReminderRepository>.value(value: reminderRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(
              expenseRepository: expenseRepository,
              categoryRepository: categoryRepository,
              walletRepository: walletRepository,
            )..add(const LoadExpenses()),
          ),
          BlocProvider<WalletBloc>(
            create: (context) => WalletBloc(
              walletRepository: walletRepository,
              expenseRepository: expenseRepository,
            )..add(const LoadWalletsEvent()),
          ),
          BlocProvider<StatsBloc>(
            create: (context) => StatsBloc(
              expenseRepository: expenseRepository,
              categoryRepository: categoryRepository,
              walletRepository: walletRepository,
            ),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              categoryRepository: categoryRepository,
            )..add(const LoadCategoriesEvent()),
          ),
          BlocProvider<ReminderBloc>(
            create: (context) => ReminderBloc(
              reminderRepository: reminderRepository,
              categoryRepository: categoryRepository,
            )..add(const LoadRemindersEvent()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Vault',
          builder: (context, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final pending = NotificationService.instance.pendingPayload;
              if (pending != null) {
                NotificationService.instance.clearPendingPayload();
                _handleNotificationPayload(pending);
              }
            });
            return child ?? const SizedBox.shrink();
          },
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              surface: AppColors.surface,
              primary: AppColors.primary,
            ),
            useMaterial3: true,
          ),
          home: isSetupDone ? const MainShell() : const WalletSetupPage(),
        ),
      ),
    );
  }
}
