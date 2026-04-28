# ஆயிரம் துதிகள் — Thousand Praises

A Tamil Christian praise & hymn reader built with Flutter.  
Browse, read, and personalise 1 000+ Tamil praises on Android, iOS, and the web.

---

## Features

| Feature | Description |
|---|---|
| 📖 **Read from the beginning** | Open the full list of praises and scroll through them sequentially |
| 🗂️ **Browse by group** | Navigate praises in batches of 100 (1–100, 101–200, …) |
| 🔢 **Jump to a praise** | Enter any praise number to navigate directly to it |
| 🔖 **Continue reading** | Automatically resumes from the last praise you read |
| ➕ **Add custom praises** | Save your own praises that are merged with the built-in list |
| 📤 **Export user praises** | Share your custom praises as a JSON file |
| 🌗 **Dark / Light mode** | Switch themes; preference is remembered across sessions |
| 🔤 **Font size & line spacing** | Adjust reading comfort in the reader screen |
| 🖋️ **Tamil font** | Ships with *Noto Serif Tamil* for clear, consistent text |

---

## Screenshots

> *(Add screenshots here)*

---

## Tech Stack

- **Flutter** 3.x / Dart ≥ 3.3
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) — persist settings and last-read position
- [`scrollable_positioned_list`](https://pub.dev/packages/scrollable_positioned_list) — smooth scroll-to-index in the reader
- [`path_provider`](https://pub.dev/packages/path_provider) — local storage for user-added praises
- [`share_plus`](https://pub.dev/packages/share_plus) — share / export user praise data
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) — generate platform app icons

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, theme bootstrap
├── core/
│   ├── services/
│   │   ├── praise_storage.dart      # Load, save, and export user praises
│   │   └── settings_service.dart   # Persist dark-mode, font & spacing prefs
│   ├── theme/
│   │   ├── app_colors.dart          # Colour palette for light and dark modes
│   │   └── app_theme.dart           # ThemeData definitions
│   └── ui/
│       └── settings_bottom_sheet.dart  # Reusable settings bottom-sheet widget
└── features/
    ├── home/
    │   └── home_screen.dart         # Main menu screen
    ├── reader/
    │   └── scroll_reading_screen.dart  # Full-screen praise reader
    └── settings/
        └── settings_panel.dart      # Settings drawer/panel widget

assets/
├── praises.json                     # Built-in praise data
├── fonts/
│   └── NotoSerifTamil.ttf
└── icon/
    └── app_icon.png
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3
- Dart ≥ 3.3 (bundled with Flutter)
- Android Studio / Xcode for device-specific builds

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/johnwesly08/thousand_praises.git
cd thousand_praises

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release
```

### Generate App Icons

```bash
flutter pub run flutter_launcher_icons
```

---

## Data Format

Built-in praises live in `assets/praises.json` as a JSON array:

```json
[
  {
    "reference": "துதி 1",
    "praise": "..."
  }
]
```

User-added praises follow the same structure and are stored in the app's documents directory as `praises_user.json`.

---

## License

This project is licensed under the terms found in the [LICENSE](LICENSE) file.
