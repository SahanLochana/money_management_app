<h1 align="center">
  <br>
  🔐 Vault – Personal Money Manager
  <br>
</h1>

<p align="center">
  A beautifully simple, fully offline money management app for Android built with Flutter.
  <br>Track expenses, manage wallets, and never miss a meal-time log with smart daily reminders.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android" alt="Platform: Android">
  <img src="https://img.shields.io/badge/Framework-Flutter-blue?style=flat-square&logo=flutter" alt="Framework: Flutter">
  <img src="https://img.shields.io/badge/Version-1.2.0-purple?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Offline-100%25-brightgreen?style=flat-square" alt="Offline">
</p>

---

## 📖 About

**Vault** is a personal finance tracker designed to be fast, private, and friction-free. There's no account creation, no cloud sync, and no tracking — everything lives on your device. It's built for users who want a dead-simple way to log daily spending and stay within a budget.

> All data is stored locally using SQLite. Nothing ever leaves your phone.

---

## ✨ Features

### 💸 Expense Tracking
- Log expenses with **category, amount, wallet, date, time, and notes**
- Edit or delete any expense at any time
- Soft-delete keeps data integrity intact
- View today's spending at a glance on the Home screen
- Browse full history grouped by date (Today, Yesterday, specific dates)

### 📂 Smart Categories
- **5 built-in system categories**: Breakfast 🍳, Lunch 🍔, Dinner 🌙, Lending 🤝, Other 🍿
- Add unlimited **custom categories** with any emoji and name
- System categories are protected — they can't be renamed or deleted

### 👛 Dual Wallet Support
- Two default wallets: **In Hand** 👛 and **In Bank** 🏦
- Select the wallet per expense

### 📊 Monthly Statistics
- Monthly spending summary with month-to-month navigation
- **Pie / donut chart** breaking down expenses by category
- **Wallet split bars** showing In Hand vs In Bank proportions
- Recent transactions list for quick reference

### 🔔 Smart Daily Reminders *(Key Feature)*
Vault's reminder system is designed to nudge you into logging expenses at the right moment — without being intrusive.

**How it works:**
- Three default reminder slots: **Breakfast (08:00)**, **Lunch (13:00)**, **Dinner (20:00)**
- Each reminder fires a native Android notification:
  - **Title**: Category name (e.g., "Lunch")
  - **Body**: `"Add expense: Rs.150?"` (uses the remainder's default amount)
- **Tapping the notification** opens the Add Expense form with the category and amount pre-filled — you just confirm and save
- The **time field is auto-filled** with the moment you tap the notification, not the scheduled time
- Reminders are **individually togglable** — turn any slot ON or OFF with a single switch

**Full control over reminders:**
- Edit the time for any reminder slot
- Change the default amount per slot
- Add your own **custom reminder slots** (any category + any time)
- Delete custom slots when no longer needed
- Works correctly across all three app states: **terminated**, **background**, and **foreground**

**Permissions handled gracefully:**
- Android 13+: Notification permission requested at runtime
- Android 12+: Exact alarm permission handled with a user-friendly dialog that links to system settings if denied

### 💰 Daily Budget Tracker
- Default daily budget: **₹500**
- Progress bar on Home screen showing how close you are to the limit
- Color-coded: 🟢 under 80%, 🟡 80–100%, 🔴 over budget
- Configurable via Settings (stored in local preferences)

### ⚙️ Settings & Data Management
- Manage all reminder slots in one place
- Manage custom categories
- **Clear all data** with a confirmation dialog (irreversible, by design)

---

## 🛠️ Tech Stack

| Category              | Technology                          |
|-----------------------|-------------------------------------|
| Framework             | Flutter (latest stable)             |
| Platform              | Android (min SDK 21+)               |
| State Management      | BLoC (`flutter_bloc`)               |
| Local Database        | SQLite (`sqflite`)                  |
| Notifications         | `flutter_local_notifications`       |
| Charts                | `fl_chart`                          |
| Preferences           | `shared_preferences`                |
| Permissions           | `permission_handler`                |
| Date / Time           | `intl`, `timezone`, `flutter_timezone` |
| Architecture          | 3-layer: Presentation → BLoC → Database |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator (API 21+)

### Run Locally

```bash
git clone https://github.com/SahanLochana/vault-money-manager-app.git
cd vault-money-manager-app
flutter pub get
flutter run
```

### Build a Release APK

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📦 Download

Pre-built APKs are available on the [**Releases**](../../releases) page.
Each release is named `Vault {version}.apk` for easy identification.

---

## 🗂️ Project Structure

```
lib/
├── main.dart                  # App entry point, notification init
├── models/                    # Expense, Category, Wallet, ReminderSlot
├── database/                  # SQLite setup, CRUD operations
├── blocs/                     # BLoC state management per feature
├── screens/                   # UI screens (Home, Stats, History, Settings, AddExpense)
├── services/                  # Notification scheduling & handling
└── assets/                    # App icon and images
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">Made with ❤️ using Flutter</p>
