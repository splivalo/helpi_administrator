# Helpi Admin - Architecture

> Last updated: 2026-04-24

## Stack

- Flutter Web (Material 3)
- Riverpod for app state
- Dio + backend REST APIs
- SignalR for real-time notifications and chat events
- SharedPreferences for local UI preferences

## High-Level Structure

```text
lib/
  app/
    app.dart
    responsive_shell.dart
    theme.dart
  core/
    l10n/
    models/
    network/
    providers/
    services/
    utils/
    widgets/
  features/
    analytics/
    auth/
    chat/
    coupons/
    orders/
    seniors/
    settings/
    students/
```

## Architectural Notes

- Data loading is backend-first; local/static data is only fallback compatibility.
- UI reads state through providers; direct mutable global state is avoided.
- SignalR listeners trigger targeted or full refreshes depending on event type.
- Order/session workflows are aligned with backend terminology (`sessions`).
- Notification feed is backend-driven (no demo seeded notifications).

## Persistence

- SharedPreferences stores screen-level UI preferences (grid/list, sort, active tab).
- Per-user preference namespacing is planned when multi-admin auth is expanded.

## Quality Rules

- `flutter analyze` must remain clean.
- Keep changes incremental and provider-safe.
- Preserve backend as source of truth for business rules.
