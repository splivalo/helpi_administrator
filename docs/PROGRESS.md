# Helpi Admin – Progress

> Zadnja izmjena: 2026-03-05

## Ukupno stanje

| Modul                 | Status                                                                        | Dovršenost |
| --------------------- | ----------------------------------------------------------------------------- | ---------- |
| Auth (Login)          | ✅ UI gotov, mock login                                                       | 90%        |
| Dashboard             | ✅ KPI, narudžbe u obradi, aktivni studenti, ugovori, grid/list               | 100%       |
| Studenti – Lista      | ✅ 7 tabova, pretraga, napredni filteri, sort, grid/list                      | 100%       |
| Studenti – Detalj     | ✅ Profil, ugovor, obračun, dostupnost, narudžbe, sesije, dodjela studenta    | 100%       |
| Seniori – Lista       | ✅ 5 tabova, pretraga, sort, grid/list, inline detalj                         | 100%       |
| Seniori – Detalj      | ✅ Profil, narudžbe, "Dodaj narudžbu", status logika                          | 100%       |
| Seniori – Dodaj/Uredi | ✅ Forme kompletne, shared mixin                                              | 100%       |
| Narudžbe – Lista      | ✅ 5 tabova, pretraga, sort, grid/list, FAB                                   | 100%       |
| Narudžbe – Detalj     | ✅ Sesije, dodjela/promjena studenta, reprogramiranje, uređivanje narudžbe    | 100%       |
| Narudžbe – Kreiranje  | ✅ Kompletna forma, senior pre-assignment, session preview                    | 100%       |
| Chat (Moderacija)     | ✅ Lista razgovora + poruke                                                   | 90%        |
| Notifikacije          | ✅ NotificationBell widget + drawer sa mock podacima                          | 90%        |
| Responsive Shell      | ✅ Mobile/Tablet/Desktop layout, locale-aware rebuild                         | 100%       |
| i18n (HR/EN)          | ✅ AppStrings Gemini Hybrid, locale switching rebuilda sve ekrane             | 100%       |
| Tema (HelpiTheme)     | ✅ Material 3, datePickerTheme, sve boje/dimenzije/radijusi                   | 100%       |
| Mock Data             | ✅ Kompletni mock podaci (6 seniora, studenti, narudžbe)                      | 100%       |
| DRY / Shared Widgets  | ✅ Kompletno refaktorirano, session_preview_sheet, ActionChipButton size enum | 100%       |
| SharedPreferences     | ✅ Grid/sort/tab persistencija po ekranu (web-safe fallback)                  | 100%       |
| UI Consistency        | ✅ AlertDialogs, modali, DatePicker, TextButton hover, StatusBadge sizes      | 100%       |
| Web deploy            | ✅ Flutter Web build, deploy na kungfu.digital/helpi/                         | 100%       |
| Backend integracija   | ❌ Nije započeta                                                              | 0%         |

**Ukupna dovršenost frontenda: ~98%**
**27 Dart fajlova, ~18.345 linija koda**
**Deploy:** `https://kungfu.digital/helpi/index.html`

---

## Checklist završenih zadataka

### Scaffold & Infrastruktura

- [x] Projekt scaffold (Flutter 3.10.7+, Material 3)
- [x] HelpiTheme — boje, dimenzije, kompletna Material tema
- [x] ResponsiveShell — BottomNav (<600px), NavigationRail (600–900px), Sidebar (≥900px)
- [x] SVG logo u sidebaru
- [x] AppStrings (i18n) — HR + EN, parametrizirani stringovi, Gemini Hybrid pattern
- [x] MockData — studenti, seniori (uključujući Ankica Tomić s6 s 0 narudžbi), narudžbe, sesije, chat sobe, notifikacije
- [x] Dokumentacija (docs/ folder)
- [x] Flutter Web build i deploy (`--base-href /helpi/`)

### Auth

- [x] LoginScreen — email/password, jezični birač, mock login

### Dashboard

- [x] DashboardScreen — KPI kartice, narudžbe u obradi, aktivni studenti po mjesecu, ugovori koji istječu
- [x] Dashboard grid/list toggle sa SharedPreferences persistencijom
- [x] Mjesečni dropdown za filtriranje aktivnih studenata

### Studenti

- [x] StudentsScreen — 7 tabova (Svi/Aktivni/Ističe/Istekao/Bez ugovora/Deaktivirani/Arhivirani)
- [x] Pretraga, sortiranje (A-Ž, Ž-A, ocjena, poslovi)
- [x] Napredni filter panel: senior dropdown (DropdownButtonFormField), dani u tjednu (full-width chips), min/max poslova, datumski raspon, vremenski raspon
- [x] Grid/list toggle
- [x] StudentDetailScreen — osobni podaci, ugovor (upload PDF), obračun perioda, dostupnost, narudžbe, recenzije
- [x] Student dodjela narudžbi (assign flow) — session preview sheet s pregledom sesija

### Seniori

- [x] SeniorsScreen — 5 tabova (Svi/U obradi/Aktivni/Neaktivni/Arhivirani) + inline detalj
- [x] Senior status business logika: "U obradi" dok nema dodijeljenog studenta → "Aktivan" kad ima
- [x] "Dodaj narudžbu" gumb na senior detail ekranu (otvara CreateOrderScreen s pre-assigned seniorom)
- [x] Broj narudžbi prikaz na kartici seniora (font size 14)
- [x] AddSeniorScreen — forma za dodavanje seniora
- [x] EditSeniorScreen — forma za uređivanje seniora
- [x] Reorder sekcija u modalu (drag & drop) s čistim spacingom

### Narudžbe

- [x] AdminOrdersScreen — 5 tabova (Svi/U obradi/Aktivne/Završene/Otkazane), pretraga, sortiranje
- [x] OrderDetailScreen — detalji narudžbe, sesije, dodjela/promjena studenta, reprogramiranje sesije
- [x] Uređivanje narudžbe (edit order modal) — promjena usluge, frekvencije, datuma, sati
- [x] CreateOrderScreen — kompletna forma za kreiranje narudžbe (1223 linija)
  - [x] Senior odabir s pretragom ili pre-assignment
  - [x] Odabir usluga (service chips full-width)
  - [x] Trajanje (hour chips full-width, nullable default)
  - [x] Frekvencija, raspoloživi dani, vremenski slot
  - [x] Auto-scroll na sljedeću sekciju
  - [x] Session preview sheet s generiranim sesijama
- [x] FAB "Dodaj narudžbu" na listi narudžbi
- [x] Assign flow (dodjela studenta) — 2-step modal s ClipRRect zaobljenim rubovima

### Chat & Notifikacije

- [x] ChatScreen — moderacija razgovora
- [x] NotificationBell — ikona sa badge brojem nepročitanih + notifications drawer

### UI Polish & Consistency

- [x] Responsive gumbi — 1/3 širine na desktopu, full-width na mobilnom
- [x] Zamjena showDateRangePicker s dva showDatePicker (performanse)
- [x] Dead code cleanup — uklonjeno 10 nekorištenih konstanti i stringova
- [x] Copy/call buttons — PhoneCallButton i EmailCopyButton na svim ekranima
- [x] Contact actions fix — GestureDetector umjesto IconButton (Material3 min-size bug)
- [x] InfoRow trailing pozicioniranje — Flexible umjesto Expanded kad ima trailing
- [x] Filter panel redesign — DropdownButtonFormField, consistent borderRadius (cardRadius=12), padding (20/18)
- [x] Day chips full-width (Row + Expanded umjesto Wrap s fiksnom širinom)
- [x] Service chips full-width, hour chips full-width
- [x] Unified bodyLarge font size: 18px → 16px (TextField i Dropdown konzistentni)
- [x] "Poništi sve" button coral hover (foregroundColor: HelpiTheme.primary)
- [x] Order count font size 12 → 14 na senior kartici
- [x] Button border width fix
- [x] **Svih 13 AlertDialoga** — konzistentni shape (cardRadius), TextButton umjesto ElevatedButton, AppStrings.ok
- [x] **TextButton hover shape** — globalni textButtonTheme s RoundedRectangleBorder(buttonRadius) umjesto stadium
- [x] **Reorder sheet spacing** — uklonjen Padding(vertical:16) na Dialogu, header fromLTRB(20,12,8,8), čist spacing
- [x] **StatusBadge size konzistentnost** — svi AppBar-ovi koriste default small, large samo za posebne slučajeve
- [x] **ActionChipButton size enum** — small (inline) / medium (modal) varijante na svim gumbima
- [x] **Assign flow zaobljeni rubovi** — ClipRRect(cardRadius) na step 2 sadržaju (order + student)
- [x] **DatePicker globalna tema** — datePickerTheme u ThemeData: teal boje, manji header font (20px), cardRadius zaobljenje
- [x] **DatePicker gumbi** — confirmText/cancelText iz AppStrings ("U redu" umjesto "U REDU")
- [x] **Locale switching** — ValueKey rebuild svih ekrana u IndexedStack pri promjeni jezika

### Persistencija (SharedPreferences)

- [x] `shared_preferences` package dodan
- [x] `PreferencesService` singleton — grid/sort/tab per screen
- [x] Web-safe init s try-catch fallback (in-memory kad plugin nije dostupan)
- [x] Wired: Dashboard, OrdersScreen, StudentsScreen, SeniorsScreen
- [x] Sve 4 ekrana pamte: grid/list view, sort odabir, aktivni tab

### DRY Refactor

- [x] `core/utils/formatters.dart` — formatDate, formatTime, formatTimeOfDay, formatDateDot
- [x] `core/widgets/status_badges.dart` — StatusBadge (StatusBadgeSize enum), ServiceChip
- [x] `core/widgets/shared_widgets.dart` — SectionCard, InfoRow, DragHandle, EmptyState, ResultCountRow, HelpiSearchBar, ActionChipButton (ActionChipButtonSize enum)
- [x] `core/widgets/session_preview_sheet.dart` — SessionPreviewSheet (prikaz sesija, dodjela studenta)
- [x] `core/widgets/contact_actions.dart` — PhoneCallButton, EmailCopyButton
- [x] `core/widgets/notification_bell.dart` — NotificationBell + NotificationsDrawer
- [x] `core/widgets/widgets.dart` — barrel export
- [x] `core/services/preferences_service.dart` — SharedPreferences wrapper
- [x] `features/seniors/presentation/senior_form_helpers.dart` — SeniorFormHelpers mixin

---

## Sljedeći koraci (Next Steps)

Pogledaj [ROADMAP.md](ROADMAP.md) za prioritizirane buduće zadatke.
