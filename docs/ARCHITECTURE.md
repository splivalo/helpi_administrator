# Helpi Admin – Architecture

> Tehnička istina o sustavu. Zadnja izmjena: 2026-03-30

---

## Tech Stack

| Komponenta      | Tehnologija                     | Verzija     |
| --------------- | ------------------------------- | ----------- |
| Framework       | Flutter                         | SDK ≥3.10.7 |
| Jezik           | Dart                            | ≥3.10.7     |
| Dizajn sustav   | Material 3                      | —           |
| SVG rendering   | flutter_svg                     | ^2.0.17     |
| File picker     | file_selector                   | ^1.1.0      |
| URL launcher    | url_launcher                    | ^6.3.1      |
| Lokalna pohrana | shared_preferences              | ^2.5.4      |
| Lokalizacija    | flutter_localizations           | SDK         |
| Ikone           | cupertino_icons                 | ^1.0.8      |
| State mgmt      | **Riverpod** (flutter_riverpod) | ^2.6.1      |
| Real-time       | **SignalR** (signalr_netcore)   | ^1.4.4      |
| Backend         | ❌ AppData (in-memory store)    | —           |
| Deploy          | Flutter Web                     | Chrome      |

**Deploy URL:** `https://kungfu.digital/helpi/index.html` (build: `flutter build web --base-href /helpi/`)

---

## Folder struktura

```
lib/
├── main.dart                          # Entry point (ProviderScope, async init) (10 linija)
├── app/
│   ├── app.dart                       # Root widget (HelpiAdminApp) — ConsumerStatefulWidget (59 linija)
│   ├── theme.dart                     # HelpiTheme – boje, dimenzije, ThemeData (212 linija)
│   └── responsive_shell.dart          # Responsive shell (sidebar/rail/bottomnav), ConsumerStatefulWidget, chat badge (~400 linija)
├── core/
│   ├── l10n/
│   │   ├── app_strings.dart           # i18n stringovi (HR + EN) (1417 linija)
│   │   └── locale_notifier.dart       # ValueNotifier<Locale> (11 linija)
│   ├── models/
│   │   └── admin_models.dart          # Svi modeli + AppData + enumi (1717 linija)
│   ├── providers/
│   │   └── data_providers.dart        # 7 StateNotifier Riverpod providera (students, seniors, orders, reviews, notifications, chatRooms, unreadMessages)
│   ├── services/
│   │   ├── data_loader.dart           # DataLoader — API load + AppData + provider sync (ref param)
│   │   ├── preferences_service.dart   # SharedPreferences wrapper (singleton, web-safe) (88 linija)
│   │   └── signalr_notification_service.dart # SignalR real-time notifications + chat messages (auto-reconnect, Riverpod sync) (~175 linija)
│   ├── utils/
│   │   ├── formatters.dart            # Formatiranje datuma/vremena + haversineKm (14 linija)
│   │   └── session_preview_helper.dart # Base class za session preview helpers (allStudents/allOrders params)
│   └── widgets/
│       ├── widgets.dart               # Barrel export (6 linija)
│       ├── status_badges.dart         # StatusBadge (size enum), ServiceChip (177 linija)
│       ├── shared_widgets.dart        # SectionCard, InfoRow, DragHandle, EmptyState, ResultCountRow, HelpiSearchBar, ActionChipButton (size enum), show15MinTimePicker (459 linija)
│       ├── session_preview_sheet.dart # SessionPreviewSheet — prikaz sesija, dodjela studenta (ConsumerStatefulWidget) (851 linija)
│       ├── contact_actions.dart       # PhoneCallButton, EmailCopyButton (45 linija)
│       └── notification_bell.dart     # NotificationBell (ConsumerWidget) + NotificationsDrawer (ConsumerStatefulWidget) (283 linija)
└── features/
    ├── auth/
    │   └── presentation/
    │       └── login_screen.dart       # Login ekran (160 linija)
    ├── dashboard/
    │   └── presentation/
    │       └── dashboard_screen.dart   # Dashboard s KPI karticama (888 linija)
    ├── students/
    │   └── presentation/
    │       ├── students_screen.dart    # Lista studenata (1571 linija)
    │       └── student_detail_screen.dart # Detalj studenta (2550 linija)
    ├── seniors/
    │   └── presentation/
    │       ├── seniors_screen.dart     # Lista + inline detalj seniora (1459 linija)
    │       ├── add_senior_screen.dart  # Dodaj seniora (295 linija)
    │       ├── edit_senior_screen.dart # Uredi seniora (268 linija)
    │       └── senior_form_helpers.dart # Shared form mixin (122 linija)
    ├── orders/
    │   └── presentation/
    │       ├── orders_screen.dart      # Lista narudžbi (462 linija)
    │       ├── order_detail_screen.dart # Detalj narudžbe (3152 linija)
    │       └── create_order_screen.dart # Kreiranje narudžbe (1223 linija)
    └── chat/
        └── presentation/
            └── chat_screen.dart        # Chat moderacija (461 linija)
```

**28 Dart fajlova, ~18.400 linija koda**

### Shared widgeti/utilitiji (core/)

| Fajl                                            | Sadržaj                                                                                                                                  |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `core/utils/formatters.dart`                    | formatDate, formatTime, formatTimeOfDay, formatDateDot                                                                                   |
| `core/services/preferences_service.dart`        | PreferencesService singleton — grid/sort/tab per screen, web-safe fallback                                                               |
| `core/widgets/status_badges.dart`               | StatusBadge (StatusBadgeSize enum: small/large), ServiceChip, orderStatusStyle, contractStatusStyle, serviceLabel                        |
| `core/widgets/shared_widgets.dart`              | SectionCard, InfoRow, DragHandle, EmptyState, ResultCountRow, HelpiSearchBar, ActionChipButton (ActionChipButtonSize enum: small/medium) |
| `core/widgets/session_preview_sheet.dart`       | SessionPreviewSheet — prikaz generiranih sesija, dodjela studenta (ConsumerStatefulWidget)                                               |
| `core/widgets/contact_actions.dart`             | PhoneCallButton, EmailCopyButton                                                                                                         |
| `core/widgets/notification_bell.dart`           | NotificationBell (ConsumerWidget) + NotificationsDrawer (ConsumerStatefulWidget, markRead via provider)                                  |
| `core/widgets/widgets.dart`                     | Barrel export svih widgeta                                                                                                               |
| `core/providers/data_providers.dart`            | 7 StateNotifier Riverpod providera (students, seniors, orders, reviews, notifications, chatRooms, unreadMessages)                        |
| `seniors/presentation/senior_form_helpers.dart` | SeniorFormHelpers mixin (forme za add/edit senior)                                                                                       |

---

## Responsive dizajn

Tri breakpointa definirana u `ResponsiveShell`:

| Breakpoint | Layout  | Navigacija                                                         |
| ---------- | ------- | ------------------------------------------------------------------ |
| < 600px    | Mobile  | BottomNavigationBar (5 tabova)                                     |
| 600–900px  | Tablet  | NavigationRail (collapsed, ikone)                                  |
| ≥ 900px    | Desktop | Extended Sidebar (260px, SVG logo, labele, jezični toggle, logout) |

Navigacija koristi `IndexedStack` s 5 ekrana: Dashboard, Narudžbe, Studenti, Seniori, Chat.

**Locale-aware rebuild:** `_screens` je getter (ne `late final`) koji koristi `ValueKey('screenName_$locale')`. Kad se promijeni jezik, `IndexedStack` tretira ekrane kao nove widgete i rebuilda ih sa svježim stringovima.

**Responsive gumbi:** Action gumbi koriste `LayoutBuilder` — full-width na <800px, 1/3 širine na ≥800px.

---

## State Management — Riverpod

> Dodano 2026-03-22. Svi ekrani migrirani sa `StatefulWidget` + `AppData.*` na `ConsumerStatefulWidget` + Riverpod providere.

### Provideri (`core/providers/data_providers.dart`)

6 `StateNotifierProvider`-a + 1 unread messages counter:

| Provider                 | Tip podataka              | Metode                                               |
| ------------------------ | ------------------------- | ---------------------------------------------------- |
| `studentsProvider`       | `List<StudentModel>`      | `setAll`, `addItem`, `updateItem`, `removeItem`      |
| `seniorsProvider`        | `List<SeniorModel>`       | `setAll`, `addItem`, `updateItem`, `removeItem`      |
| `ordersProvider`         | `List<OrderModel>`        | `setAll`, `addItem`, `updateItem`, `removeItem`      |
| `reviewsProvider`        | `List<StudentReview>`     | `setAll`, `addItem`                                  |
| `notificationsProvider`  | `List<NotificationModel>` | `setAll`, `addItem`, `markRead(id)`, `markAllRead()` |
| `chatRoomsProvider`      | `List<ChatRoom>`          | `setAll`, `addItem`                                  |
| `unreadMessagesProvider` | `int`                     | `increment`, `reset`, `set(int)` — chat badge count  |

### Data Flow

```
DataLoader.loadAll(ref: ref)
  → API fetch → AppData.xxx = results    (intermediate store)
  → ref.read(xxxProvider.notifier).setAll(AppData.xxx)   (provider sync)
```

### Korištenje u UI-ju

- **`ref.watch()`** u `build()` — reaktivno, rebuild kad se podaci promijene
- **`ref.read()`** u metodama — jednokratno čitanje, bez subscribea
- **`ref.read(xxxProvider.notifier).updateItem()`** — mutacija podataka kroz provider

### Migrirana hijerarhija

| Widget                     | Tip                      | Koristi                                                 |
| -------------------------- | ------------------------ | ------------------------------------------------------- |
| `HelpiAdminApp`            | `ConsumerStatefulWidget` | DataLoader.loadAll(ref: ref)                            |
| `ResponsiveShell`          | `ConsumerStatefulWidget` | ref.watch(unreadMessages) for chat badge                |
| `DashboardScreen`          | `ConsumerStatefulWidget` | ref.watch(orders/students/seniors)                      |
| `StudentsScreen`           | `ConsumerStatefulWidget` | ref.watch/read(students/orders/seniors)                 |
| `StudentDetailScreen`      | `ConsumerStatefulWidget` | ref.watch/read(reviews/orders/students)                 |
| `SeniorsScreen`            | `ConsumerStatefulWidget` | ref.watch/read(seniors/orders)                          |
| `SeniorDetailScreen`       | `ConsumerStatefulWidget` | ref.watch/read(seniors/orders)                          |
| `EditSeniorScreen`         | `ConsumerStatefulWidget` | ref.read(seniors)                                       |
| `AddSeniorScreen`          | `ConsumerStatefulWidget` | DataLoader.loadAll(ref: ref)                            |
| `OrderDetailScreen`        | `ConsumerStatefulWidget` | ref.read/watch(orders), notifier.update                 |
| `CreateOrderScreen`        | `ConsumerStatefulWidget` | ref.read(seniors)                                       |
| `_ChatRoomList`            | `ConsumerWidget`         | ref.watch(chatRooms), ref.read(seniors/students/orders) |
| `NotificationBell`         | `ConsumerWidget`         | ref.watch(notifications)                                |
| `_NotificationsDrawer`     | `ConsumerStatefulWidget` | ref.watch(notifications), markRead/markAllRead          |
| `_SessionPreviewSheet`     | `ConsumerStatefulWidget` | ref.read(orders/students)                               |
| `SessionPreviewHelperBase` | Plain class (not widget) | `allStudents`/`allOrders` constructor params            |

---

## Persistencija (SharedPreferences)

`PreferencesService` singleton u `core/services/preferences_service.dart`:

```dart
// Inicijalizacija u main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.instance.init();
  runApp(const HelpiAdminApp());
}
```

**Što se pamti po ekranu:**

| Ključ pattern       | Tip    | Default | Opis                      |
| ------------------- | ------ | ------- | ------------------------- |
| `gridView_{screen}` | bool   | false   | Grid ili List prikaz      |
| `sort_{screen}`     | String | null    | Ime enum sort vrijednosti |
| `tab_{screen}`      | int    | 0       | Indeks aktivnog taba      |

**Screen identifikatori:** `dashboard`, `orders`, `students`, `seniors`

**Web safety:** Init ima try-catch; ako SharedPreferences plugin nije dostupan (web hot-restart), servis radi u in-memory fallback modu bez crasha.

> ⚠️ Trenutno globalne preferencije. Kad se doda auth, trebaju postati **per-user** (npr. `gridView_orders_userId123`).

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

| Element             | Vrijednost                 |
| ------------------- | -------------------------- |
| Primary (coral)     | `#EF5B5B`                  |
| Accent (teal)       | `#009D9D`                  |
| Background          | `#F9F7F4` (warm off-white) |
| Surface             | `#FFFFFF`                  |
| Text Primary        | `#2D2D2D`                  |
| Text Secondary      | `#757575`                  |
| Border              | `#E0E0E0`                  |
| Star yellow         | `#FFC107`                  |
| Button height       | 56px                       |
| Card/Button radius  | 12px                       |
| Chip radius         | 100px (pill)               |
| StatusBadge radius  | 100px (pill)               |
| BottomSheet radius  | 12px                       |
| Sidebar width       | 260px                      |
| bodyLarge fontSize  | 16px                       |
| bodyMedium fontSize | 16px                       |

Status boje: Processing (plava), Active/Completed (zelena), Cancelled (coral/crvena).

### DatePicker tema

Globalno definirana u `datePickerTheme` unutar `ThemeData`:

- **Boje:** accent (teal) za odabrani dan, header pozadina, godine
- **Header:** manji font (20px umjesto Material 3 default ~32px) da se datum ne lomi u 2 reda
- **Shape:** `cardRadius` (12px) zaobljenje — konzistentno s ostatkom UI-ja
- **Gumbi:** "U redu" / "Odustani" (iz AppStrings) umjesto Material default "U REDU" (caps lock)
- Svi `showDatePicker` pozivi koriste `confirmText: AppStrings.ok, cancelText: AppStrings.cancel`

### Widget Size Enumi

**StatusBadgeSize** (u `status_badges.dart`):

- `small` (default) — padding 10×3, fontSize 11, `statusBadgeRadius` (100)
- `large` — padding 14×6, fontSize 13, `chipRadius` (100)

**ActionChipButtonSize** (u `shared_widgets.dart`):

- `small` (default) — icon 14, font 12, padding 10×6, radius 8 — za inline card akcije
- `medium` — icon 18, font 14, padding 14×8, radius 10 — za modal primary akcije (spremi, potvrdi, poništi)

---

## Modeli podataka

Definirani u `lib/core/models/admin_models.dart` (1717 linija):

| Model               | Opis                                                                              |
| ------------------- | --------------------------------------------------------------------------------- |
| `SeniorModel`       | Senior (korisnik usluge) — ime, adresa, kontakt, potrebe, status                  |
| `StudentModel`      | Student (pružatelj usluge) — profil, ugovor, satnica, dostupnost, bankovni podaci |
| `OrderModel`        | Narudžba — senior ↔ student, usluga, frekvencija, lokacija, status, promoCode     |
| `SessionModel`      | Pojedinačna sesija unutar narudžbe — datum, trajanje, status                      |
| `ChatRoom`          | Chat soba za moderaciju                                                           |
| `ChatMessage`       | Pojedinačna poruka u chatu                                                        |
| `StudentReview`     | Recenzija studenta od seniora                                                     |
| `NotificationModel` | Notifikacija za admina (tip, poruka, timestamp, isRead)                           |

**Enumi:** `OrderStatus`, `OrderSort`, `StudentSort`, `SeniorSort`, `JobStatus`, `ServiceType`, `FrequencyType`, `ContractStatus`, `SessionStatus`, `Gender`

**AppData:** 6 seniora (uključujući Ankica Tomić s6 s 0 narudžbi), studenti, narudžbe, sesije, chat sobe, notifikacije

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
- **Incremental changes** — jedan fajl po promjeni, potvrda testa prije sljedećeg

---

## UI Consistency Standards

### AlertDialog

- Uvijek `shape: RoundedRectangleBorder(borderRadius: cardRadius)` — zaobljeni rubovi
- Gumbi: `TextButton` (ne `ElevatedButton`) s `AppStrings.ok` / `AppStrings.cancel`
- Nema hardkodiranog teksta ("OK", "Da", "Ne")

### Modal / Bottom Sheet

- Desktop (≥600px): `showDialog` s `maxWidth: 620, maxHeight: 750`
- Mobile: `showModalBottomSheet` s `heightFactor: 0.92`
- Standard header: `Padding(fromLTRB(20, 12, 8, 8))` → `Row(Icon(accent) + Text(18/w700) + IconButton(close))` → `Divider(height:1)`
- Content clipping: `ClipRRect(cardRadius)` na sadržaju koji može prelaziti granice

### TextButton

- Globalni `textButtonTheme` definira `shape: RoundedRectangleBorder(borderRadius: buttonRadius)` — nema stadium hover efekta

### DatePicker

- Globalni `datePickerTheme` — teal boje, manji header font, zaobljeni rubovi
- `confirmText: AppStrings.ok, cancelText: AppStrings.cancel` na svim pozivima
- Nema per-call `builder` overridea — sve iz teme

### Session Scheduling — 15-min Travel Buffer

**Pravilo:** Između dva Helpi ordera istog studenta mora biti **minimalno 15 minuta** razmaka (putovanje između lokacija).

**Gdje se primjenjuje (frontend mock faza):**

| Funkcija                | Fajl                          | Što radi                                                   |
| ----------------------- | ----------------------------- | ---------------------------------------------------------- |
| `findConflict`          | `session_preview_helper.dart` | Detektira konflikt — proširuje postojeći order za ±15 min  |
| `findSubstitutes`       | `session_preview_helper.dart` | Isključuje zamjenu ako joj je order unutar ±15 min         |
| `findAltSlots`          | `session_preview_helper.dart` | Predlaže slobodne slotove — busy zone proširene za ±15 min |
| `_findConflict`         | `session_preview_sheet.dart`  | Isto kao gore (duplicirana logika za mobile sheet)         |
| `_findSubstitutes`      | `session_preview_sheet.dart`  | Isto kao gore                                              |
| `_findAlternativeSlots` | `session_preview_sheet.dart`  | Isto kao gore                                              |

**Ključna pravila:**

- Buffer = `_buffer = 15` (konstanta na razini klase)
- Primjenjuje se u **oba smjera** — 15 min PRIJE i 15 min NAKON postojećeg ordera
- **NE primjenjuje se** na studentovu availability (to je čisti prozor, student je odgovoran doći na vrijeme)
- Ako je order prvi tog dana — nema buffera prije njega
- Ako je order zadnji tog dana — nema buffera poslije njega

**Backend requirement (za buduću integraciju):**

- Backend MORA implementirati istu 15-min buffer logiku u svim scheduling endpointima:
  - Dodjela studenta narudžbi
  - Kreiranje narudžbe s dodijeljenim studentom
  - Promjena termina (reschedule)
  - API za slobodne termine studenta
  - API za zamjenske studente
- Buffer vrijednost treba biti **konfigurabilan** (env/DB settings), ne hardkodiran
- Frontend zadržava svoju provjeru za brzi UX feedback, ali **backend je izvor istine** i mora odbiti nevažeći zahtjev
