# Helpi Admin

Admin panel za Helpi platformu — povezivanje studenata i seniora za usluge pomoći u kući.

## Tech Stack

- **Flutter** SDK ≥3.10.7, Material 3
- **Dart** ≥3.10.7
- **State management:** Riverpod (flutter_riverpod ^2.6.1)
- **Lokalizacija:** HR + EN (AppStrings Gemini Hybrid pattern)
- **Data:** AppData (in-memory store, backend integracija planirana)

## Pokretanje

```bash
flutter pub get
flutter run -d chrome   # web
flutter run -d windows  # desktop
flutter run              # connected device
```

## Dokumentacija

Sva dokumentacija nalazi se u [`docs/`](docs/) folderu:

- [PROGRESS.md](docs/PROGRESS.md) — Status i checklist završenih zadataka
- [ROADMAP.md](docs/ROADMAP.md) — Budući prioriteti i TODO
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Tehnička arhitektura sustava
- [PROJECT_HISTORY.md](docs/PROJECT_HISTORY.md) — Kronologija ključnih odluka
