# Helpi Admin

Admin web panel for Helpi platform operations.

## Tech Stack

- Flutter (SDK >= 3.10.7), Material 3
- Dart
- State management: Riverpod (`flutter_riverpod ^2.6.1`)
- Real-time: SignalR (`signalr_netcore ^1.4.4`)
- Localization: HR + EN via `AppStrings` (Gemini Hybrid pattern)

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Documentation

- [PROGRESS.md](docs/PROGRESS.md) - implementation status and completion checklist
- [ROADMAP.md](docs/ROADMAP.md) - remaining tasks and external dependencies
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - architecture and folder structure
- [PROJECT_HISTORY.md](docs/PROJECT_HISTORY.md) - decision log and major changes
