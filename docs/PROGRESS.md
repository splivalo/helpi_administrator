# Helpi Admin – Progress

> Zadnja izmjena: 2026-03-23

## Ukupno stanje

| Modul                 | Status                                                                                                      | Dovršenost |
| --------------------- | ----------------------------------------------------------------------------------------------------------- | ---------- |
| Auth (Login)          | ✅ UI gotov, mock login                                                                                     | 90%        |
| Dashboard             | ✅ KPI, narudžbe u obradi, aktivni studenti, ugovori, grid/list                                             | 100%       |
| Studenti – Lista      | ✅ 6 tabova, pretraga, napredni filteri, sort, grid/list                                                    | 100%       |
| Studenti – Detalj     | ✅ Profil, ugovor, obračun, dostupnost, narudžbe, sesije, dodjela studenta                                  | 100%       |
| Seniori – Lista       | ✅ 5 tabova, pretraga, sort, grid/list, inline detalj                                                       | 100%       |
| Seniori – Detalj      | ✅ Profil, narudžbe, "Dodaj narudžbu", status logika                                                        | 100%       |
| Seniori – Dodaj/Uredi | ✅ Forme kompletne, shared mixin                                                                            | 100%       |
| Narudžbe – Lista      | ✅ 5 tabova, pretraga, sort, grid/list, FAB                                                                 | 100%       |
| Narudžbe – Detalj     | ✅ Sesije, dodjela/promjena studenta, reprogramiranje, uređivanje, promo kod, udaljenost, planirani termini | 100%       |
| Narudžbe – Kreiranje  | ✅ Kompletna forma, senior pre-assignment, session preview                                                  | 100%       |
| Chat (Moderacija)     | ✅ Lista razgovora + poruke                                                                                 | 90%        |
| Notifikacije          | ✅ NotificationBell + drawer + SignalR real-time + 30-type enum aligned with backend + 7 icon/color mappings | 95%        |
| Responsive Shell      | ✅ Mobile/Tablet/Desktop layout, locale-aware rebuild                                                       | 100%       |
| i18n (HR/EN)          | ✅ AppStrings Gemini Hybrid, locale switching rebuilda sve ekrane                                           | 100%       |
| Tema (HelpiTheme)     | ✅ Material 3, datePickerTheme, sve boje/dimenzije/radijusi                                                 | 100%       |
| Mock Data             | ✅ Kompletni mock podaci (6 seniora, studenti, narudžbe)                                                    | 100%       |
| State Management      | ✅ Riverpod (flutter_riverpod ^2.6.1) — svi ekrani, reaktivni UI bez manual refresha                        | 100%       |
| SignalR Real-time     | ✅ signalr_netcore ^1.4.4, auto-reconnect, ReceiveNotification handler, Riverpod sync                       | 100%       |
| DRY / Shared Widgets  | ✅ Kompletno refaktorirano, session_preview_sheet, ActionChipButton size enum                               | 100%       |
| SharedPreferences     | ✅ Grid/sort/tab persistencija po ekranu (web-safe fallback)                                                | 100%       |
| UI Consistency        | ✅ AlertDialogs (SizedBox 400), modali, DatePicker, TextButton hover, badges                                | 100%       |
| Web deploy            | ✅ Flutter Web build, deploy na kungfu.digital/helpi/                                                       | 100%       |
| Backend integracija   | ❌ Nije započeta                                                                                            | 0%         |

**Ukupna dovršenost frontenda: ~98%**
**28 Dart fajlova, ~18.400 linija koda**
**Deploy:** `https://kungfu.digital/helpi/index.html`

---

## Checklist završenih zadataka

### Scaffold & Infrastruktura

- [x] Projekt scaffold (Flutter 3.10.7+, Material 3)
- [x] HelpiTheme — boje, dimenzije, kompletna Material tema
- [x] ResponsiveShell — BottomNav (<600px), NavigationRail (600–900px), Sidebar (≥900px)
- [x] SVG logo u sidebaru
- [x] AppStrings (i18n) — HR + EN, parametrizirani stringovi, Gemini Hybrid pattern
- [x] AppData — studenti, seniori (uključujući Ankica Tomić s6 s 0 narudžbi), narudžbe, sesije, chat sobe, notifikacije
- [x] Dokumentacija (docs/ folder)
- [x] Flutter Web build i deploy (`--base-href /helpi/`)

### Auth

- [x] LoginScreen — email/password, jezični birač, mock login

### Dashboard

- [x] DashboardScreen — KPI kartice, narudžbe u obradi, aktivni studenti po mjesecu, ugovori koji istječu
- [x] Dashboard grid/list toggle sa SharedPreferences persistencijom
- [x] Mjesečni dropdown za filtriranje aktivnih studenata

### Studenti

- [x] StudentsScreen — 6 tabova (Svi/Aktivni/Istekao/Bez ugovora/Suspendirani/Arhivirani)
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
- [x] **Svih 14 AlertDialoga** — konzistentni shape (dialogTheme), SizedBox(width: 400), TextButton, AppStrings.ok
- [x] **DialogTheme** — globalni dialogTheme u theme.dart (shape, backgroundColor, actionsPadding)
- [x] **TextButton hover shape** — globalni textButtonTheme s RoundedRectangleBorder(buttonRadius) umjesto stadium
- [x] **Reorder sheet spacing** — uklonjen Padding(vertical:16) na Dialogu, header fromLTRB(20,12,8,8), čist spacing
- [x] **StatusBadge size konzistentnost** — svi AppBar-ovi koriste default small, large samo za posebne slučajeve
- [x] **ActionChipButton size enum** — small (inline) / medium (modal) varijante na svim gumbima
- [x] **Assign flow zaobljeni rubovi** — ClipRRect(cardRadius) na step 2 sadržaju (order + student)
- [x] **DatePicker globalna tema** — datePickerTheme u ThemeData: teal boje, manji header font (20px), cardRadius zaobljenje
- [x] **DatePicker gumbi** — confirmText/cancelText iz AppStrings ("U redu" umjesto "U REDU")
- [x] **Locale switching** — ValueKey rebuild svih ekrana u IndexedStack pri promjeni jezika

### Suspenzija, Admin Notes & Tab Cleanup (2026-03-15)

- [x] **Review comment scroll** — Zamjena truncation (maxLines:5) s ConstrainedBox(maxHeight:100) + SingleChildScrollView
- [x] **Admin Notes (NotesSection)** — Widget za admin bilješke (add/edit/delete) integriran u StudentDetail (9 sekcija) i SeniorDetail (8 sekcija)
- [x] **Suspension warning dialog** — Upozorenje s brojem aktivnih narudžbi prije suspenzije (student + senior detail)
- [x] **Auto-cancel orders on suspend** — Loop u \_confirmSuspend() otkazuje aktivne/processing narudžbe pri suspenziji
- [x] **SuspensionStateManager listener fix** — Dodano addListener u initState() na StudentsScreen i SeniorsScreen (lista) — badge "Suspendiran" se sad ažurira
- [x] **Tab hover boja fix** — tabBarTheme u theme.dart s neutralnim sivim overlayColor umjesto teal splasha
- [x] **Uklonjen ContractStatus.deactivated** — Enum, tab, filter, badge, AppStrings (4 ključa)
- [x] **Uklonjen ContractStatus.expiring** — Enum, tab, filter, badge, AppStrings; Dashboard "ističe" logika prebačena na date-based (active + expiryDate < 30 dana)
- [x] **Suspend button style** — TextButton.styleFrom(foregroundColor: error) za pravilan hover

### Udaljenost & Sortiranje (2026-03-18→19)

- [x] **Haversine formula** — `haversineKm()` u `formatters.dart` za izračun udaljenosti student↔senior
- [x] **Lat/Lng polja** — Dodani `latitude`/`longitude` na SeniorModel i StudentModel
- [x] **Prikaz udaljenosti u assign modalu** — Km udaljenost studenta od seniora na student assign kartici (zamjenjuje broj završenih narudžbi)
- [x] **Sortiranje studenata** — Dostupnost → Udaljenost → Ocjena (3-level sort)
- [x] **Udaljenost u reschedule pickeru** — Km prikaz i u modalnom izborniku za promjenu studenta
- [x] **Uklonjen `~` prefix** — Oznaka "~" ispred udaljenosti uklonjena (nepotrebna)
- [x] **Rating decimal fix** — `toStringAsFixed(1)` na svih 8 lokacija u 5 fajlova (dashboard, session_preview_content, session_preview_sheet, order_detail_screen)

### Planirani termini & UI Cleanup (2026-03-20→21)

- [x] **Projected sessions za Pending narudžbe** — Generiranje planiranih termina iz `dayEntries` rasporeda prije dodjele studenta
- [x] **`_generateProjectedSessions()`** — Algoritam: one-time → 1 sesija, recurring → weekly do endDate ili 3 mjeseca, poravnato s `RecurrenceDateGenerator`
- [x] **Muted session card dizajn** — Sivi `_buildProjectedSessionCard()` s Column layoutom (datum + vrijeme/trajanje), bez akcijskih gumba
- [x] **"Planirano" badge** — Narančasti badge i subtitle "Planirani termini — čeka se dodjela studenta."
- [x] **Vrijeme + trajanje na kartici** — Column layout: datum gore, HH:MM · Xh dolje s ikonom
- [x] **Detalji narudžbe cleanup** — Uklonjeni redundantni: Vrijeme, Trajanje, Raspored, Adresa (vidljivi u drugim sekcijama)
- [x] **AppStrings dodani** — `sessionsPlannedSubtitle`, `sessionStatusPlanned` (HR + EN)

### Promo kod (Stripe priprema)

- [x] `promoCode` (String?) polje dodano u OrderModel
- [x] AppStrings: `promoCode`, `promoCodeHint`, `promoCodeApply` (HR + EN)
- [x] Prikaz promo koda u detaljima narudžbe (zadnje polje, nakon usluga)
- [x] "Primijeni promo kod" gumb u Admin akcijama s dijalogom za unos
- [x] CreateOrderScreen čuva promoCode pri uređivanju

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

### State Management — Riverpod migracija (2026-03-22)

- [x] `flutter_riverpod: ^2.6.1` dodan u pubspec.yaml
- [x] `ProviderScope` wrapper u main.dart
- [x] `core/providers/data_providers.dart` — 6 StateNotifier providera (students, seniors, orders, reviews, notifications, chatRooms)
- [x] `DataLoader.loadAll(ref: ref)` — sinkronizira AppData → Riverpod providere nakon svakog učitavanja
- [x] `app.dart` → ConsumerStatefulWidget
- [x] `dashboard_screen.dart` → ConsumerStatefulWidget, ref.watch() za reaktivne podatke
- [x] `students_screen.dart` → ConsumerStatefulWidget, \_FilterPanel dobiva seniors parametar
- [x] `student_detail_screen.dart` → ConsumerStatefulWidget, svi AppData → ref.read()
- [x] `seniors_screen.dart` → ConsumerStatefulWidget, \_SeniorCard→ConsumerWidget, SeniorDetailScreen→ConsumerStatefulWidget
- [x] `edit_senior_screen.dart` → ConsumerStatefulWidget
- [x] `add_senior_screen.dart` → ConsumerStatefulWidget
- [x] `order_detail_screen.dart` → ConsumerStatefulWidget, provider.notifier.updateItem(), \_OrderAssignFlowSheet→ConsumerStatefulWidget
- [x] `create_order_screen.dart` → ConsumerStatefulWidget
- [x] `chat_screen.dart` → \_ChatRoomList претvorен у ConsumerWidget
- [x] `notification_bell.dart` → ConsumerWidget + ConsumerStatefulWidget, markRead/markAllRead через provajder
- [x] `session_preview_sheet.dart` → ConsumerStatefulWidget
- [x] `session_preview_helper.dart` → allStudents/allOrders parametri umjesto AppData
- [x] Nula AppData referenci u UI sloju (samo DataLoader koristi AppData kao intermediate store)
- [x] flutter analyze: 0 errors throughout

### Session Preview & Scheduling

- [x] 15-minutni travel buffer — findAltSlots dodaje 15 min nakon svake zauzete sesije tako da student ima vremena stići od jednog seniora do drugog
- [x] Shared `show15MinTimePicker` dialog — dropdown picker (Sat 0-23, Min 00/15/30/45) u shared_widgets.dart, koristi se u filterima studenata (Dostupan od/do)
- [x] `HelpiTheme.inputFieldHeight` (48px) — centralna konstanta za visinu input polja
- [x] Filter panel mobile background fix — HelpiTheme.surface umjesto scaffold
- [x] Availability filter overlap semantika — "pokriva" → "preklapa se"

---

## Sljedeći koraci (Next Steps)

Pogledaj [ROADMAP.md](ROADMAP.md) za prioritizirane buduće zadatke.

---

## Canonical Domain V1 usklađivanje (2026-03-06)

- [x] `SessionStatus.upcoming` → `SessionStatus.scheduled` (UI label ostaje "Nadolazeći" HR / "Scheduled" EN)
- [x] `JobStatus` enum: `assigned`/`upcoming` → `scheduled` (kanonski single pre-execution state)
- [x] `ServiceType.walk` → `ServiceType.walking` (kanonski code)
- [x] `ServiceType.fromCode()` alias mapper: `socializing` → `companionship`, `walk` → `walking`, `house_help` → `houseHelp`
- [x] `SessionModel.orderId` dodan (explicit foreign key)
- [x] `ReviewModel`: dodani `sessionId`, `studentId`, `seniorId` (explicit linkage IDs)
- [x] AppStrings: `sessionStatusUpcoming` → `sessionStatusScheduled`, `serviceWalk` → `serviceWalking`, `jobAssigned`/`jobUpcoming` → `jobScheduled`
- [x] Cancel order = status promjena (potvrđeno, nikad brisanje)
- [x] OrderStatus transition rules: već ispravni (processing→active→completed→cancelled→archived)
