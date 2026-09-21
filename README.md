# Ruty 📅 — Routine & Organization

> A cross-platform Flutter app for time management, habits, and health.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)]()
[![Version](https://img.shields.io/badge/version-1.0.2-blue)]()
[![Status](https://img.shields.io/badge/status-beta-orange)]()

Ruty is a personal organization app that combines calendar, tasks, routines, health tracking, and habit-building in one place. It is built with Flutter and runs fully offline, with local persistence and native Android notifications.

---

## ✨ Features

### Free tier
- 📅 Event calendar (monthly, weekly, and yearly views)
- ✅ Tasks with priorities and reminders
- 🔁 Daily routines and habit tracking
- 🏥 Health modules (nutrition, exercise, medication)
- 🔔 Configurable local notifications
- ⏰ Real alarm with looping sound (level 3)
- 🎨 Theme and color customization
- 📝 Quick notes ("mental clarity")
- 🌎 Regional holidays (6 countries)
- 💾 Local backup / export / import
- 👥 Local community (offline, non-synced)

### Pro tier
- 📊 Full statistics with charts
- 🤖 Smart recommendations
- 🖼️ Event illustrations (60+ emojis)
- 📈 Weekly automated summary
- 🎯 Goals, XP, levels, and achievements
- 🛠️ Expert customization mode
- ☁️ *(planned)* Cloud sync
- 🌐 *(planned)* Real community backend

---

## 🛠️ Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter (Dart) |
| State management | Provider |
| Local storage | SharedPreferences |
| Notifications | flutter_local_notifications + timezone |
| Audio | just_audio |
| Calendar | table_calendar |
| Charts | fl_chart |
| Backup | share_plus + file_picker + path_provider |
| Licenses | crypto (SHA-256) |
| Auto-update | http + url_launcher + package_info_plus |

---

## 📁 Project Structure

```
lib/
├── main.dart
├── data/           # Seed data and static catalogs
├── models/         # Data models
├── providers/      # State management (Provider)
├── screens/        # App screens
├── services/       # Business logic and services
├── widgets/        # Reusable UI components
└── utils/          # Helpers and utilities
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- Android Studio (for Android builds)
- Java 8+ (bundled with Android Studio)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/DonMate-app/Ruty-App.git
   cd Ruty-App
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on a connected device or emulator:
   ```bash
   flutter run
   ```

4. Build a release APK (universal, works on all architectures):
   ```bash
   flutter build apk --release
   ```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Automated version bump

The project includes a `build.ps1` script for Windows that automatically increments the build number in `pubspec.yaml` before compiling:

```powershell
.\build.ps1
```

---

## 📸 Screenshots

> _[Pending: screenshots will be added soon]_

---

## 🎯 Roadmap

- [x] Calendar, tasks, routines
- [x] Health tracking (nutrition, exercise, medication)
- [x] Local notifications + real alarm
- [x] Backup / export / import
- [x] Goals, XP, levels, achievements
- [x] Global celebration system (confetti + sound)
- [ ] Lemon Squeezy integration (Pro licensing)
- [ ] Regional pricing
- [ ] Play Store release

---

## 👥 Team

Ruty is built by **DonMate**, a two-person independent studio:

- **Leonard Vera** — Lead Developer
- **Sebastián Marín** — Co-Developer & Legal Representative

---

## 📬 Contact

- **Email:** donmate.apps@gmail.com
- **Repository:** [github.com/DonMate-app/Ruty-App](https://github.com/DonMate-app/Ruty-App)

---

## 📄 License

This project is **not open source**. All rights reserved.

The source code is publicly visible for transparency and distribution purposes only. Redistribution, modification, or commercial use of this code without explicit written permission from DonMate is prohibited.

© 2026 DonMate. All rights reserved.