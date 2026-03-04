# Helpi Admin – Architecture

> Tehnička istina o sustavu. Zadnja izmjena: 2026-03-04

---

## Tech Stack

| Komponenta    | Tehnologija              | Verzija     |
| ------------- | ------------------------ | ----------- |
| Framework     | Flutter                  | SDK ≥3.10.7 |
| Jezik         | Dart                     | ≥3.10.7     |
| Dizajn sustav | Material 3               | —           |
| SVG rendering | flutter_svg              | ^2.0.17     |
| File picker   | file_selector            | ^1.1.0      |
| Lokalizacija  | flutter_localizations    | SDK         |
| Ikone         | cupertino_icons          | ^1.0.8      |
| State mgmt    | StatefulWidget (lokalni) | —           |
| Backend       | ❌ Mock (MockData klasa) | —           |

---

## Folder struktura

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                       # Root widget (HelpiAdminApp)
│   ├── theme.dart                     # HelpiTheme – boje, dimenzije, ThemeData
│   └── responsive_shell.dart          # Responsive shell (sidebar/rail/bottomnav)
├── core/
│   ├── l10n/
│   │   ├── app_strings.dart           # i18n stringovi (HR + EN)
│   │   └── locale_notifier.dart       # ValueNotifier<Locale>
│   └── models/
│       └── admin_models.dart          # Svi modeli + MockData + enumi
└── features/
    ├── auth/
    │   └── presentation/
    │       └── login_screen.dart       # Login ekran
    ├── dashboard/
    │   └── presentation/
    │       └── dashboard_screen.dart   # Dashboard s KPI karticama
    ├── students/
    │   └── presentation/
    │       ├── students_screen.dart    # Lista studenata
    │       └── student_detail_screen.dart # Detalj studenta
    ├── seniors/
    │   └── presentation/
    │       ├── seniors_screen.dart     # Lista + detalj seniora
    │       ├── add_senior_screen.dart  # Dodaj seniora
    │       └── edit_senior_screen.dart # Uredi seniora
    ├── orders/
    │   └── presentation/
    │       ├── orders_screen.dart      # Lista narudžbi
    │       └── order_detail_screen.dart # Detalj narudžbe
    └── chat/
        └── presentation/
            └── chat_screen.dart        # Chat moderacija
```

**23 Dart fajlova, ~9.500 linija koda** (nakon DRY refaktora)

### Shared widgeti/utilitiji (core/)

| Fajl                                            | Sadržaj                                                                       |
| ----------------------------------------------- | ----------------------------------------------------------------------------- |
| `core/utils/formatters.dart`                    | formatDate, formatTime, formatTimeOfDay, formatDateDot                        |
| `core/widgets/status_badges.dart`               | StatusBadge, ServiceChip, orderStatusStyle, contractStatusStyle, serviceLabel |
| `core/widgets/shared_widgets.dart`              | SectionCard, InfoRow, DragHandle, EmptyState, ResultCountRow, HelpiSearchBar  |
| `core/widgets/contact_actions.dart`             | PhoneCallButton, EmailCopyButton                                              |
| `core/widgets/widgets.dart`                     | Barrel export svih widgeta                                                    |
| `seniors/presentation/senior_form_helpers.dart` | SeniorFormHelpers mixin (forme za add/edit senior)                            |

---

## Responsive dizajn

Tri breakpointa definirana u `ResponsiveShell`:

| Breakpoint | Layout  | Navigacija                                                         |
| ---------- | ------- | ------------------------------------------------------------------ |
| < 600px    | Mobile  | BottomNavigationBar (5 tabova)                                     |
| 600–900px  | Tablet  | NavigationRail (collapsed, ikone)                                  |
| ≥ 900px    | Desktop | Extended Sidebar (260px, SVG logo, labele, jezični toggle, logout) |

Navigacija koristi `IndexedStack` s 5 ekrana: Dashboard, Studenti, Seniori, Narudžbe, Chat.

**Responsive gumbi:** Action gumbi koriste `LayoutBuilder` — full-width na <800px, 1/3 širine na ≥800px.

---

## i18n sustav (AppStrings)

**Pattern:** Gemini Hybrid

```dart
// 1. Definicija u _localizedValues
static final Map<String, Map<String, String>> _localizedValues = {
  'hr': { 'save': 'Spremi', 'deleteConfirm': 'Obriši {item}?' },
  'en': { 'save': 'Save',   'deleteConfirm': 'Delete {item}?' },
};

// 2. Getter za jednostavne stringove
static String get save => _t('save');

// 3. Parametrizirani stringovi
static String deleteConfirm(String item) => _t('deleteConfirm', params: {'item': item});
```

- **Jezici:** Hrvatski (hr) — primarni, Engleski (en)
- **Locale switching:** `LocaleNotifier` (ValueNotifier) → `ValueListenableBuilder` u `app.dart`
- **Backend sync:** Backend šalje `labelKey`/`placeholderKey`, Flutter mapira na `AppStrings` gettere

---

## Tema (HelpiTheme)

Centralizirana u `lib/app/theme.dart`:

| Element            | Vrijednost                 |
| ------------------ | -------------------------- |
| Primary (coral)    | `#EF5B5B`                  |
| Accent (teal)      | `#009D9D`                  |
| Background         | `#F9F7F4` (warm off-white) |
| Surface            | `#FFFFFF`                  |
| Text Primary       | `#2D2D2D`                  |
| Text Secondary     | `#757575`                  |
| Border             | `#E0E0E0`                  |
| Star yellow        | `#FFC107`                  |
| Button height      | 56px                       |
| Card/Button radius | 12px                       |
| Sidebar width      | 260px                      |

Status boje: Processing (plava), Active/Completed (zelena), Cancelled (coral/crvena).

---

## Modeli podataka

Definirani u `lib/core/models/admin_models.dart`:

| Model           | Opis                                                                              |
| --------------- | --------------------------------------------------------------------------------- |
| `SeniorModel`   | Senior (korisnik usluge) — ime, adresa, kontakt, potrebe, status                  |
| `StudentModel`  | Student (pružatelj usluge) — profil, ugovor, satnica, dostupnost, bankovni podaci |
| `OrderModel`    | Narudžba — senior ↔ student, usluga, frekvencija, lokacija, status                |
| `SessionModel`  | Pojedinačna sesija unutar narudžbe — datum, trajanje, status                      |
| `ChatRoom`      | Chat soba za moderaciju                                                           |
| `ChatMessage`   | Pojedinačna poruka u chatu                                                        |
| `StudentReview` | Recenzija studenta od seniora                                                     |

**Enumi:** `OrderStatus`, `JobStatus`, `ServiceType`, `FrequencyType`, `ContractStatus`, `SessionStatus`, `Gender`

---

## Auth flow

1. `HelpiAdminApp` drži `_isLoggedIn` bool
2. `LoginScreen` — email/password forma, mock validacija → `onLogin()` callback
3. Login success → `setState(() => _isLoggedIn = true)` → prikazuje `ResponsiveShell`
4. Logout → sidebar/drawer logout gumb → `setState(() => _isLoggedIn = false)` → natrag na `LoginScreen`

> ⚠️ Nema pravog auth sustava — sve je mock. Backend integracija (JWT) planirana za budućnost.

---

## Konvencije

- **Nema hardkodiranja teksta** — svi stringovi kroz `AppStrings`
- **Async safety** — `if (!context.mounted) return;` nakon svakog `await`
- **Nema `// ignore` direktiva** — popravlja se kôd, ne utišava linter
- **Nema `dynamic` bez casta** — uvijek `as Map<String, dynamic>`
- **0 linter issues** — `flutter analyze` mora uvijek proći čisto
