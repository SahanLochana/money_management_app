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
