Project Overview
A personal money management mobile application built with Flutter for Android that helps users track daily expenses, manage multiple wallets, receive meal-time reminders, and visualize spending patterns. The app runs completely locally with no cloud dependencies.

Tech Stack
Category	Technology
Framework	Flutter (Latest stable)
Platform	Android only (min SDK 21+)
State Management	BLoC (flutter_bloc)
Local Database	SQLite (sqflite)
Local Notifications	flutter_local_notifications
Charts	fl_chart
Date/Time	intl
Dependency Injection	Constructor injection + context.read()
Architecture	Simple 3-layer (Presentation → BLoC → Database)
Permissions	permission_handler
Core Features (User Stories)
1. Expense Management
As a user, I want to:

✅ Add expenses with category, amount, wallet, date, time, and optional note

✅ Edit any existing expense

✅ Delete expenses with confirmation (soft delete)

✅ View today's expenses on home screen

✅ View all expenses grouped by date in history

2. Categories
As a user, I want to:

✅ Use 5 system categories: Breakfast, Lunch, Dinner, Lending, Other

✅ Add custom categories with emoji and name

✅ Delete custom categories (system categories are protected)

✅ Set default amount for each category

3. Wallets
As a user, I want to:

✅ Use 2 default wallets: In Hand, In Bank

✅ Select wallet when adding expenses

✅ See wallet balance split in statistics

4. Daily Reminders
As a user, I want to:

✅ Get daily notifications at pre-defined times

✅ Have default slots: Breakfast (08:00), Lunch (13:00), Dinner (20:00)

✅ Toggle reminders ON/OFF individually

✅ Edit reminder time and default amount

✅ Add custom reminder slots

Notification Behavior:

Shows: Title = Category name, Body = "Add expense: ₹{amount}?"

Tap opens Add Expense page with pre-filled category, amount, and time

Time is auto-filled with tap time (user can override)

5. Statistics
As a user, I want to:

✅ View monthly spending breakdown

✅ See pie chart showing category distribution

✅ See bar chart showing wallet split

✅ Navigate between months

✅ View recent transactions

6. Settings Management
As a user, I want to:

✅ Manage reminder slots (add, edit, delete, toggle)

✅ Manage categories (add custom, delete custom)

✅ Export all data to CSV/JSON

✅ Clear all data with confirmation

##dont over engineering

----------------------------------------------------------
# app functionalities
1. Expense CRUD Operations
Add Expense
User fills: Category (required), Amount (required, >0), Wallet (required), Date (default today), Time (default now), Note (optional)

Validate: Category selected, Amount > 0, Wallet selected

Save to database → Show success toast → Navigate back to home

Amount stored in cents (multiply by 100 before saving)

Edit Expense
User taps existing expense → Opens same form with all fields pre-filled

Update database → Show success toast → Navigate back

All fields editable

Delete Expense
User taps delete icon on expense card → Show confirmation dialog

On confirm: Soft delete (set is_deleted = 1)

Refresh UI to hide deleted expense

2. Home Screen
On Screen Open
Load today's expenses (is_deleted = 0, expense_date = today)

Calculate today's total

Display expense list and summary card

If no expenses: Show empty state

Refresh
After add/edit/delete: Auto-refresh list

Pull-to-refresh: Reload today's expenses and totals

3. Statistics Page
Monthly View
Default: Current month

Navigation: Previous month (◀) and Next month (▶) arrows

Show: Month name + Year (e.g., "August 2026")

Data to Display
Total spent for selected month

Pie/Donut chart: Expenses grouped by category (amount in ₹, percentage)

Wallet split: Two horizontal bars (In Hand vs In Bank)

Recent transactions: Last 5 expenses for the month

4. Reminder Management
Load Reminders
On Settings screen open: Load all reminder slots from database

Show: Time, Category name, Default amount, Toggle switch state

Toggle Reminder ON
User flips switch to ON

Check Android 13+ notification permission → If denied → Show dialog → Open system settings

Check Android 12+ exact alarm permission → If denied → Show dialog → Open system settings

If both granted → Schedule daily notification

Set is_active = 1 in database

Toggle Reminder OFF
User flips switch to OFF

Cancel scheduled notification

Set is_active = 0 in database

Edit Reminder Time
User taps time field → Opens TimePicker

Update time in database

Reschedule notification (if active)

Edit Default Amount
User taps amount → Opens number input dialog

Update default_amount in database

Update notification payload

Add Custom Reminder
User taps "+ Add Custom Reminder"

Opens dialog: Category dropdown, Time picker, Amount input, Toggle (default ON)

Validate: Category selected, No duplicate time with same category

Insert into database → Schedule notification (if ON)

Delete Custom Reminder
User taps delete icon

Confirm → Cancel notification → Delete from database

5. Category Management
Load Categories
Show system categories (is_system = 1) with lock icon (delete disabled)

Show custom categories (is_system = 0) with delete icon

Add Custom Category
User taps "+ Add New Category"

Opens dialog: Emoji picker, Name input

Validate: Name not empty (3-30 chars), Emoji selected

Insert into database (is_system = 0)

Delete Custom Category
Check: If category has expenses → Show warning → Block deletion

If no expenses → Confirm → Delete from database

System Categories (Read-only)
Breakfast: 🍳, default_amount = 8000 (₹80)

Lunch: 🍔, default_amount = 15000 (₹150)

Dinner: 🌙, default_amount = 18000 (₹180)

Lending: 🤝, default_amount = 0

Other: 🍿, default_amount = 0

Cannot delete, cannot rename, cannot change emoji

6. Notification Handling
Schedule Notification
Use flutter_local_notifications

ID = reminder_slot.id

Title = Category name

Body = "Add expense: ₹{default_amount}?"

Time = reminder_slot.time

Payload = {category_id, category_name, default_amount, slot_id}

ScheduleMode = AndroidScheduleMode.exactAllowWhileIdle

MatchDateTimeComponents = DateTimeComponents.time (daily repeat)

Handle Notification Tap
Case 1: App is terminated

getInitialMessage() fires → Extract payload

Store in global variable (pendingNotificationPayload)

In main.dart, check pendingNotificationPayload before building

If exists → Navigate directly to Add Expense page with payload

Clear pendingNotificationPayload after navigation

Case 2: App is in background

onDidReceiveNotificationResponse() fires → Extract payload

Use GlobalKey<NavigatorState> to push Add Expense page with payload

Case 3: App is in foreground

Show in-app notification banner (Overlay or Snackbar)

User taps banner → Navigate to Add Expense page with payload

Auto-fill Add Expense from Notification
Category: Pre-select from payload

Amount: Pre-fill with default_amount (user can edit)

Time: Auto-fill with current time (user can edit)

Date: Auto-fill with current date

Wallet: Pre-select last used wallet

7. Wallet Management
Default Wallets (Read-only)
In Hand (👛) - ID: 1

In Bank (🏦) - ID: 2

Wallet Selection in Add Expense
Segmented control showing both wallets

Default: Last used wallet (store in shared_preferences)

On save: Store expense with selected wallet_id

Update last used wallet in shared_preferences

Wallet Stats
On Statistics page: Calculate total spent from each wallet for selected month

Show as horizontal progress bars with percentages

8. Daily Budget
Default Budget
Hardcode: ₹500 per day

Display
On Home screen summary card: Show "Today: ₹450 / ₹500"

Progress bar: Visual indicator

Color: Green if <80%, Yellow if 80-100%, Red if >100%

Edit Budget (Optional)
In Settings: Add "Daily Budget" input

Store in shared_preferences

9. Error Handling
Database Errors
Catch all database exceptions

Show user-friendly message: "Something went wrong. Please try again."

Log error to console

Permission Errors
Notification permission denied → Show explanation, open settings

Exact alarm permission denied → Show explanation, open settings

If both denied → Toggle reminder OFF automatically

Validation Errors
Amount = 0 → "Amount must be greater than 0"

No category selected → "Please select a category"

No wallet selected → "Please select a wallet"

Category name empty → "Please enter a category name"

Duplicate reminder time → "A reminder at this time already exists"

Empty States
No expenses today → "No expenses today"

No expenses in month → "No expenses for this month"

No custom categories → "No custom categories yet"

10. Navigation
Bottom Navigation (3 Tabs)
Index	Tab	Screen
0	Home	HomeScreen
1	Stats	StatisticsScreen
2	History	HistoryScreen
Routes
Route	Screen	Arguments
/	HomeScreen	None
/add-expense	AddEditExpenseScreen	ExpenseArguments (optional)
/edit-expense	AddEditExpenseScreen	Expense (to edit)
/settings	SettingsScreen	None
FAB
Only on Home tab

icon → Navigates to Add Expense (empty form)

Settings Access
Gear icon on Home app bar → Navigates to SettingsScreen

History Screen
All expenses grouped by date (Today, Yesterday, 15 Aug, etc.)

Swipe to delete → Show confirmation

Tap to edit → Navigate to Add Expense with pre-filled data

11. Implementation Order
Database Setup → Tables, default data, CRUD methods

Models → Expense, Category, Wallet, ReminderSlot

Expense CRUD → Add, Edit, Delete, Load

Home Screen → Display today's expenses + summary

Add Expense Screen → Form with validation

Statistics Screen → Charts + monthly data

Settings Screen → Reminders + Categories

Notification Service → Schedule, tap handling, permissions

History Screen → All expenses grouped by date

Polish → Empty states, error handling, edge cases