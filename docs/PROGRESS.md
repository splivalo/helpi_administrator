# Helpi Admin – Progress

> Zadnja izmjena: 2026-04-18

## Ukupno stanje

| Modul                 | Status                                                                                                                                                                                  | Dovršenost |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Auth (Login)          | ✅ UI gotov, pravi backend auth, forgot/reset password flow, server reachability detection (3-way logic)                                                                                | 100%       |
| Analitika             | ✅ GA-style: line chart (fl_chart), date range picker (7d/mjesec/custom), 4 metrike (narudžbe/prihod/seniori/zarada), usporedba perioda, KPI kartice, Excel export, SignalR reaktivnost | 100%       |
| Postavke              | ✅ 6 sekcija: Cijena usluge, Studentska satnica, Pravila otkazivanja, Operativno, Zarada (marža+PDV), Jezik — API CRUD, SignalR reaktivnost                                             | 100%       |
| Studenti – Lista      | ✅ 6 tabova, pretraga, napredni filteri, sort, grid/list                                                                                                                                | 100%       |
| Studenti – Detalj     | ✅ Profil, ugovor, obračun, dostupnost, narudžbe, sesije, dodjela studenta                                                                                                              | 100%       |
| Seniori – Lista       | ✅ 5 tabova, pretraga, sort, grid/list, inline detalj                                                                                                                                   | 100%       |
| Seniori – Detalj      | ✅ Profil, narudžbe (sortirano najnovije), "Dodaj narudžbu", centralizirani status badge                                                                                                | 100%       |
| Seniori – Dodaj/Uredi | ✅ Forme kompletne, shared mixin                                                                                                                                                        | 100%       |
| Narudžbe – Lista      | ✅ 5 tabova, pretraga, sort, grid/list, FAB                                                                                                                                             | 100%       |
| Narudžbe – Detalj     | ✅ Sesije, dodjela/promjena studenta, reprogramiranje (3-branch), uređivanje, promo kod, udaljenost, planirani termini                                                                  | 100%       |
| Narudžbe – Kreiranje  | ✅ Kompletna forma, senior pre-assignment, session preview                                                                                                                              | 100%       |
| Chat (Moderacija)     | ✅ Real-time chat s backendom (API + SignalR), split-view moderacija, WhatsApp-style bubbles, unread badge na navigaciji (3 layouta), auto-create admin room, welcome message           | 100%       |
| Notifikacije          | ✅ NotificationBell + drawer + SignalR real-time + backend-only feed bez demo seedanja + reschedule/reassignment refresh hooks                                                          | 100%       |
| Responsive Shell      | ✅ Mobile/Tablet/Desktop layout, locale-aware rebuild, ConsumerStatefulWidget, chat badge                                                                                               | 100%       |
| i18n (HR/EN)          | ✅ AppStrings Gemini Hybrid, locale switching rebuilda sve ekrane                                                                                                                       | 100%       |
| Tema (HelpiTheme)     | ✅ Material 3, datePickerTheme, sve boje/dimenzije/radijusi                                                                                                                             | 100%       |
| Mock/Fallback Data    | ✅ Backend-first učitavanje za sve podatke; mock fallback ostaje samo za offline/dev scenarij                                                                                           | 100%       |
| State Management      | ✅ Riverpod (flutter_riverpod ^2.6.1) — svi ekrani, reaktivni UI bez manual refresha                                                                                                    | 100%       |
| SignalR Real-time     | ✅ signalr_netcore ^1.4.4, auto-reconnect, ReceiveNotification + ReceiveChatMessage + SettingsChanged handlers, Riverpod sync                                                           | 100%       |
| DRY / Shared Widgets  | ✅ Kompletno refaktorirano, session_preview_sheet, ActionChipButton size enum                                                                                                           | 100%       |
| SharedPreferences     | ✅ Grid/sort/tab persistencija po ekranu (web-safe fallback)                                                                                                                            | 100%       |
| UI Consistency        | ✅ AlertDialogs (SizedBox 400), modali, DatePicker, TextButton hover, badges                                                                                                            | 100%       |
| Web deploy            | ✅ Flutter Web build, deploy na kungfu.digital/helpi/                                                                                                                                   | 100%       |
| Backend integracija   | ✅ Kompletna admin backend integracija: auth, students, seniors, orders, reviews, notifications, sessions, settings, assign/reschedule, cities, dashboard API, chat (real-time + REST)  | 100%       |

**Ukupna dovršenost frontenda: ~100%**
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

- [x] LoginScreen — email/password, jezični birač, pravi backend auth

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

- [x] ChatScreen — real-time chat moderacija (API + SignalR), WhatsApp-style bubbles, senderName prikaz
- [x] Chat API service (chat_api_service.dart) — getRooms, getMessages, sendMessage, markAsRead, getUnreadCount
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

### Reschedule Notifikacije (2026-04-01)

- [x] `NotificationType.jobRescheduled` sada pokreće automatski `DataLoader.loadAll()` refresh u adminu

### Backend integracija (2026-04-04)

- [x] `LoginScreen` više nije mock-only — koristi pravi backend auth + forgot/reset password flow
- [x] `DataLoader.loadAll()` puni core admin podatke iz API-ja: students, seniors, orders, reviews, notifications, sessions
- [x] `SeniorsScreen` city dropdown više ne izvodi opcije iz trenutno učitanih seniora, nego prioritizira `GET /api/cities` kao backend source of truth uz lokalni fallback ako API nije dostupan
- [x] Live smoke test odrađen preko disposable admin korisnika: `register/admin` + `login` + `students/seniors/orders/reviews/sessions/PricingConfiguration` rute vraćaju očekivane rezultate na lokalnom backendu
- [x] `NotificationType.reassignmentStarted` dodan u SignalR refresh trigger set
- [x] Backend emitira `JobRescheduled` notifikacije za seniora i admine pri simple i full reschedule flowu
- [x] Backend emitira `ReassignmentStarted` / `ReassignmentCompleted` admin notifikacije kroz postojeći SignalR + storage pipeline
- [x] Dodani backend lokalizacijski ključevi `Notifications.JobRescheduled` (HR + EN)
- [x] Verifikacija: `flutter analyze` = 0 issues, `Helpi.Application.csproj` build prolazi

### Dashboard → Analitika transformacija (2026-04-02)

- [x] Prepisana `dashboard_screen.dart` iz redundantnog dashboarda u analytics ekran (1074→727 linija)
- [x] 4 KPI kartice (responsive: 2x2 na mobitelu, 4x1 na desktopu)
- [x] Tjedni bar chart (7 dana) s prev/next navigacijom + % usporedba s prethodnim tjednom
- [x] Mjesečni bar chart (tjedni u mjesecu) s prev/next + % usporedba s prethodnim mjesecom
- [x] Prosječna ocjena studenata sa zvjezdicama (za ukloniti u sljedećoj iteraciji)
- [x] 11 mrtvih `dashboardTile*` GPT artefakt ključeva uklonjeno iz AppStrings (HR, EN, getteri)
- [x] Navigacija: Analitika prebačena na zadnju poziciju (Seniori → Studenti → Chat → Analitika)
- [x] Ikona promjenjena: `Icons.dashboard` → `Icons.analytics`
- [x] Dodano 7 novih analytics i18n ključeva (HR + EN)
- [x] Verifikacija: `flutter analyze` = 0 issues
- [x] TODO: Preraditi u Google Analytics stil (date range picker, line/area chart, detaljnija usporedba perioda)

### GA-style Analitika redesign (2026-04-02)

- [x] Kompletni rewrite `dashboard_screen.dart` — Google Analytics stil
- [x] `fl_chart: ^1.2.0` dodan za LineChart renderiranje
- [x] 4 date range preseta: Zadnjih 7 dana, Ovaj mjesec, Prošli mjesec, Prilagođeno (DateRangePicker)
- [x] 3 metrike: Narudžbe (count), Prihod (€ iz session×hourlyRate), Aktivni seniori (unique po danu)
- [x] Line chart s comparison overlay (solid teal vs dashed siva) za usporedbu s prethodnim periodom
- [x] Comparison toggle (Switch) — uključi/isključi usporedbu
- [x] Tooltip na dotik (datum + vrijednost)
- [x] 3 KPI kartice (responsive: column na mobitelu, row na desktopu) s % promjenom
- [x] Zamijenjeno 14 starih analytics i18n ključeva s novim GA-style ključevima (HR + EN)
- [x] Uklonjen bar chart, tjedna/mjesečna navigacija, prosječna ocjena studenata
- [x] Verifikacija: `flutter analyze` = 0 issues

### Notification Evidence Cleanup (2026-04-01)

- [x] Demo notifikacije uklonjene iz admin `DataLoader` fallbacka; notification drawer sada prikazuje samo stvarne backend događaje
- [x] Uklonjen lažni demo scenarij "Student dodijeljen" koji je izgledao kao automatska v1 dodjela
- [x] Chat mock preview ostavljen namjerno kako bi se UI mogao pregledavati i prije pravog chat backenda
- [x] Zapisano što je lokalno dokazano: učitavanje postojećih `HNotifications`, `mark-read`, `mark-all-read`, SignalR primitak i refresh za `jobRescheduled`, `reassignmentStarted`, `reassignmentCompleted`
- [x] Zapisano što nije end-to-end potvrđeno bez live integracija: Stripe payment notifovi (`paymentSuccess`, `paymentFailed`, `paymentRefunded`) i bilo koji tok koji ovisi o vanjskim servisima ili schedulerima koje trenutno ne palimo
- [x] Admin UI feed dodatno filtriran na v2-smislene tipove; participant-only ili v1-style noise (`jobRequest`, payment notifovi, review request, matching noise) više se ne prikazuje adminu

### Error Handling & UX (2026-03-23)

- [x] **Login server vs auth error distinction** — `AuthResult.isConnectionError` flag, DioException type checking (connectionTimeout, connectionError, receiveTimeout, null response). Orange "Server nedostupan" vs red auth error.
- [x] **ServerUnavailableScreen compact restyle** — maxWidth 420, icon 48px, titleLarge, warm off-white bg (#FAF6F1)
- [x] **Senior section reorder overflow fix** — SizedBox(height: \_sectionCount \* 56.0) → Flexible (fixes 16px bottom overflow)
- [x] **Senior status logic fix** — Senior bez narudžbi sada prikazuje "Neaktivan" (ne "U obradi"). U obradi = ima narudžbe bez dodijeljenog studenta. Fix primijenjen na 3 mjesta: filter logika, \_SeniorCard badge, SeniorDetailScreen badge.

### Filter & Assignment Safety (2026-03-30)

- [x] **Block assignment on cancelled/completed orders** — "Dodijeli studenta" button hidden for cancelled/completed/archived orders. Guard checks in `_showAssignSheet()` and `_assignStudent()`.
- [x] **Faculty dropdown always visible** — Changed `faculties.length > 1` to `faculties.isNotEmpty`, auto-select when only 1 faculty exists.
- [x] **Removed 60-day filter** — `ActivityPeriod.last60Days` removed from student filter modal.
- [x] **Neutral dropdown colors** — Faculty dropdown stays grey/neutral (no teal on selection).
- [x] **Suspended students excluded from substitutes** — `!s.isSuspended` check added to both base and order-detail `isSubstituteCandidate`.
- [x] **"Zamjena" button hidden when empty** — Consistent with "Pomakni": hidden when `findSubstitutes()` returns empty list.
- [x] **Availability labels updated** — Desktop: "Dostupan sve dane" / "Djelomično dostupan". Mobile: "Dostupan" / "Djelomično".

### Reschedule Flow Rewrite & Session Fixes (2026-03-31)

- [x] **Reschedule 3-branch routing (backend)** — ManageJobInstance: simple reschedule (in-place), reschedule+student change (new session), reassignment only (no reschedule). HandleSimpleReschedule trusts admin's choice, no availability re-check.
- [x] **GET /api/students/available-students (backend)** — New endpoint checks: student active + availability slots + 15-min travel buffer + no conflicting sessions. Supports `excludeJobInstanceIds` param.
- [x] **Reschedule UI rewrite** — Uses backend available-students endpoint (async), loading spinner, selection by `studentId` (not name), sends `newEndTime` = newStart + originalDuration, only sends `preferredStudentId` when student actually changed.
- [x] **`endTime` + `studentId` on SessionModel** — Parsed from backend response in `_mapSession`. Used for duration calculation in reschedule.
- [x] **Lightweight \_refreshOrder** — Reduced from 6 parallel API calls (DataLoader.loadAll) to 2 targeted calls (getOrder + getSessionsByOrder). Falls back to full reload on failure.
- [x] **Student sort by distance (backend)** — Fixed `StudentRepository.FindEligibleStudentsCore`: two `OrderBy` calls (second overrode first) → `OrderByDescending(preferred) → ThenBy(distance) → ThenByDescending(rating)`.
- [x] **Senior status centralization** — `seniorStatusStyle()` function + `StatusBadge.senior()` factory in status_badges.dart. Used by both SeniorCard and SeniorDetailScreen AppBar. Fixed bug: detail AppBar checked `o.student != null` on ALL orders instead of filtering live orders only.
- [x] **Senior orders sorted newest first** — Descending sort by orderNumber in SeniorDetailScreen initState + both refresh methods.
- [x] **"Planirano" badge on individual cards** — Moved from "Termini" section header to each `_buildProjectedSessionCard` (right side, like active sessions).

### Server Reachability & Auth Robustness (2026-03-31)

- [x] **ServerUnavailableScreen health check fix** — Changed from `/health` (doesn't exist) to `/api/students`, accepts any HTTP response (even 401/404) as proof server is up.
- [x] **DataLoader.isServerReachable()** — Standalone Dio GET with 3s timeout. Returns true if any HTTP response, false only on connection error.
- [x] **3-way \_checkExistingSession** — Distinguishes: (1) server unreachable → ServerUnavailableScreen, (2) server reachable but data failed → force re-login (expired token), (3) data OK → proceed.
- [x] **\_handleLogin always proceeds** — Login proves server is up, so `_serverUnavailable = false` always. Partial data failure doesn't block UI.
- [x] **\_handleServerBack always recovers** — After retry, `_serverUnavailable = false` always. Prevents loop back to unavailable screen.

### Chat Unread Badge Infrastructure (2026-03-30)

- [x] **UnreadMessagesNotifier provider** — `StateNotifier<int>` with `increment()`, `reset()`, `set(int)` methods in `data_providers.dart`.
- [x] **SignalR ReceiveMessage listener** — `_onReceiveMessage` handler in `signalr_notification_service.dart` increments unread count on new messages.
- [x] **ResponsiveShell → ConsumerStatefulWidget** — Converted to access Riverpod providers for badge state.
- [x] **Badge on all 3 layouts** — Red `Badge.count` circle on chat icon: desktop sidebar (`_sidebarItem` badgeCount param), tablet NavigationRail (`_badgedIcon` wrapper), mobile BottomNav (`_badgedIcon` wrapper).
- [x] **Reset on chat tap** — `ref.read(unreadMessagesProvider.notifier).reset()` when user taps Chat (index 3).
- [ ] **Connect to Firebase Chat** — Currently uses test value `super(3)`. When backend ChatHub + Firebase are ready, remove test value and wire real message events.

---

### Analitika UX & Earnings toggle (2026-04-02)

- [x] **Earnings toggle redesign** — "Prihod [toggle] Zarada" klackalica dizajn, AnimatedOpacity (active=1.0, inactive=0.35), teal capsule + white knob
- [x] **hideTitle param** — `_buildMetricChartCard()` podržava `hideTitle: true` za revenue karticu (toggle služi kao naslov)
- [x] **Mobile responsive header** — Desktop: inline total+badge, Mobile: badge ispod totala desno poravnato
- [x] **Shorter mobile labels** — "Usporedi prethodno"/"Zarada" na mobilnom umjesto dugačkih naziva
- [x] **MouseRegion click cursor** — Oba togglea (comparison + earnings) imaju pointer kursor
- [x] **i18n rename** — `analyticsHelpiNeto` → `analyticsEarnings`, `analyticsNetoShort` → `analyticsEarningsShort`

### Session Preview & Order Detail fixes (2026-04-02)

- [x] **Session preview gray borders** — Sve session kartice koriste `HelpiTheme.border` umjesto obojenih (crveno/zeleno)
- [x] **Day chip colors match status badges** — Conflict dani koriste `statusCancelledBg/Text`, free dani koriste `statusActiveBg/Text`
- [x] **Senior detail state refresh** — `await Navigator.push` + re-read orders from provider na povratku iz OrderDetail
- [x] **Active order projected sessions** — Aktivne narudžbe sa studentom prikazuju projicirane termine kao normalne (ne muted), subtitle "Čeka se dodjela" samo kad nema studenta
- [x] **`sessionsProjectedSubtitle`** — Novi i18n string (HR + EN)

### Backend Seed realism (2026-04-02)

- [x] **Admin user u seedu** — `info@helpi.social` / `H3lp!5y5t3m5` automatski seedan
- [x] **Orders 1,3,4 → Completed** — Jednokratne narudžbe s prošlim datumima → realnije završene
- [x] **ScheduleAssignments + JobInstances za sve FullAssigned narudžbe** — 13 dodjela, 47 sesija
- [x] **Realne napomene** — Uklonjeno "Test differentTimes", "- zavrseno", "- otkazano"; sve napomene opisuju stvarnu uslugu
- [x] **Cities ON CONFLICT** — `ON CONFLICT DO NOTHING` za Cities insert (ne pada ako backend već seedao)
- [x] **Realna distribucija** — Max 1-2 aktivne usluge po senioru, više završenih nego aktivnih

### Settings Screen & Dynamic Pricing (2026-04-04)

- [x] **Settings screen created** — 6 sekcija: Cijena usluge, Studentska satnica, Pravila otkazivanja, Operativno, Zarada (marža+PDV), Jezik
- [x] **API CRUD** — GET/PUT `PricingConfiguration` endpoint, učitava sve parametre iz baze, sprema promjene
- [x] **Edit/Save flow** — Olovka ikona → edit mode → Save/Cancel. Snapshot+restore za revert.
- [x] **StudentHourlyRate + StudentSundayHourlyRate** — Nova polja u backendu (entity, DTO, validation, service, seeder, migracija). Default 7.40€/11.10€.
- [x] **IntermediaryPercentage** — Marža posrednika (studentservis %) dodana u backend + settings + analytics. Default 18%.
- [x] **SignalR reactive** — `BroadcastSettingsChangedAsync()` na PUT → `pricingVersionProvider` → analytics + settings auto-reload
- [x] **Analytics formula fix** — neto = gross - PDV - Stripe(1.5%+€0.25) - studentPay - intermediaryFee. Student rates fixed (from API), not computed.
- [x] **Excel export VAT fix** — Export neto uključuje PDV odbitak (prije bio izostavljen)
- [x] **Dashboard → AnalyticsScreen rename** — Klasa preimenovana, dead `features/dashboard/` folder obrisan
- [x] **pricingVersionProvider** — `StateProvider<int>` u data_providers.dart, inkrementira se na SignalR SettingsChanged + Settings save
- [x] **Responsive layout** — Wide: marža + PDV switch + PDV% u jednom redu. Narrow: vertikalno.
- [x] **Stepper arrows** — ↑/↓ gumbi na numeric fieldovima, step=1 ili 0.5 za decimalna polja

### Backend: StudentHourlyRate + StudentSundayHourlyRate (2026-04-04)

- [x] **PricingConfiguration entity** — Dodani `StudentHourlyRate` (default 7.40m), `StudentSundayHourlyRate` (default 11.10m)
- [x] **PricingConfigurationDtos** — Dodana oba polja
- [x] **Validator** — `GreaterThan(0)` za oba polja
- [x] **Service mapping** — Sva 4 metoda (GetAll, GetById, Add, Update)
- [x] **AppDbContext** — `decimal(18,2)` column types
- [x] **Seeder** — Default vrijednosti 7.40/11.10
- [x] **3 migracije** — AddIntermediaryPercentage, AddStudentRatesToPricingConfig, AddStudentRatesToPricingConfiguration
- [x] **DB verified** — psql potvrda: StudentHourlyRate=7.40, StudentSundayHourlyRate=11.10

### Travel Buffer + Historical Student Payout Snapshot (2026-04-04)

- [x] **Admin assign koristi dinamički buffer** — Direct assign više ne koristi hardkodiranih 15 minuta nego čita `TravelBufferMinutes` iz `PricingConfiguration`
- [x] **Live DB verification** — potvrđen realan scenarij za Luka Perić / 2026-04-10: buffer 15 => student je dostupan, buffer 20 => student više nije dostupan za slot 11:15-12:15
- [x] **Buffer reconciliation** — povećanje buffera automatski pokreće backend provjeru budućih accepted dodjela i otvara reassignment za kasniju konfliktu sesiju
- [x] **Session payout snapshot** — backend `JobInstance` sada sprema `StudentHourlyRate` po sesiji, pa promjena studentske satnice više ne prepisuje povijesne isplate
- [x] **Admin analytics formula aligned with v2 business rule** — prihod se računa iz `session.hourlyRate`, a zarada iz formule `gross - PDV - Stripe - studentPay - (studentPay * studentservis%)`; v1 `40/60` split i `companyPercentage` fallback više se ne koriste
- [x] **Legacy pricing fallback fix** — stare seed sesije bez kompletnog `hourlyRate + studentHourlyRate` snapshota više ne miješaju stari senior price s novim student pricingom; analytics za njih koristi current `PricingConfiguration` za oba ratea
- [x] **Student detail uses real sessions** — obračun sati i isplate više se ne procjenjuje iz recurring rasporeda i current price configa, nego iz stvarnih sesija u odabranom periodu
- [x] **Student card rate mapping fix** — admin više ne prikazuje studentima senior satnice; `StudentModel.hourlyRate` i `sundayHourlyRate` mapiraju se iz student pricing polja
- [x] **Migration generated** — dodana EF migracija `AddStudentHourlyRateSnapshotToJobInstances`
- [x] **Validation** — `flutter analyze` ostao 0 issues, backend full solution build prošao bez novih errora (80 postojećih warninga)

### Notification Overhaul — Content, Archive & UI (2026-04-05)

- [x] **FormatSafe fix** — `JsonLocalizationService.GetString` crashao jer `String.Format` dobivao `{0}` placeholder bez argumenata → dodan `FormatSafe` helper (try/catch, vraća template kad args prazni). Riješen 500 error na notification endpointu.
- [x] **Notification body improvements** — `TranslateNotifications` u `HNotificationService` refaktoriran sa specijaliziranim granama:
  - `seniorAndOrderList`: JobCancelled, OrderCancelled, OrderScheduleCancelled, NewOrderAdded → body format `"{seniorName}, Narudžba #{orderId}"`
  - `reassignmentList`: ReassignmentStarted, ReassignmentCompleted → isti format
  - `descList`: NoEligibleStudents, AllEligibleStudentNotified → GetEntityDescription
  - `userDeletedList`: parse Payload JSON za deletedUserName/deletedUserId
  - `NewStudentAdded` / `NewSeniorAdded`: pravo ime iz dto kontakta
- [x] **NewOrderAdded lokalizacija** — Dodano u hr.json/en.json: Title "Nova narudžba"/"New Order", Body "{0}, Narudžba #{1}"/"{0}, Order #{1}"
- [x] **NotificationsFactory fix** — `JobCancelledNotification` sada uključuje `OrderId` za body format
- [x] **Translation key fix u bazi** — Seeded notifikacije imale `TranslationKey = 'NewStudent'` umjesto `Notifications.NewStudent.Title` → ispravljeno u DB-u
- [x] **Single master CSV archive** — Archive endpoint refaktoriran za jednu `notifications-archive.csv` datoteku na Google Drive:
  - `FindFileInFolderAsync(folderId, fileName)` → traži postojeći fajl
  - `DownloadFileAsync(fileId)` → skida sadržaj
  - `UpdateFileAsync(fileId, data, mimeType)` → uploadira novu verziju
  - Ako fajl postoji: download → strip BOM → append novi redovi → update. Ako ne: create s headerom.
  - CSV format: `Datum,Naslov,Poruka` (bez Type stupca)
  - Testirano: prvi poziv kreira, drugi poziv appendira na isti file ID
- [x] **DependencyInjection.cs fix** — `NotificationsArchiveFolderId` nije bio bindiran iz konfiguracije → dodano mapiranje
- [x] **Pill bar redesign** — Unified pill: `_PillIconButton` (✓✓ done_all) | 1px grey divider | `_PillTextButton` (☁ cloud_upload + "Arhiviraj")
- [x] **Pill hover animation** — Layout promijenjen iz Column u Stack. Pill je `Positioned` overlay s `AnimatedSlide(offset: visible ? Offset.zero : Offset(0, 2))` + `AnimatedOpacity` (200-250ms, Curves.easeOut). Prikazuje se na `MouseRegion` hover ili tijekom archiving procesa.
- [x] **Tile interaction split** — Klik na tekst = označi pročitano (onTap). Klik na ikonu = navigacija (onNavigate). Ikona wrappana u `GestureDetector` s `MouseRegion(cursor: SystemMouseCursors.click)`.
- [x] **ListView bottom padding** — Dodan `EdgeInsets.only(bottom: 64)` da pill ne prekriva zadnju notifikaciju
- [x] **AppStrings archive ključevi** — notifArchiveSuccess, notifArchiveFailed, notifArchiveEmpty, notifArchiving, archiveNotifications (HR + EN)
- [x] **data_providers.dart** — `removeRead()` na `NotificationsNotifier` za lokalno uklanjanje pročitanih nakon archive-a
- [x] **admin_api_service.dart** — `archiveReadNotifications(userId)` + `languageCode` param na `getNotifications()`
- [x] **api_endpoints.dart** — `notificationArchive(userId)` endpoint
- [x] Verifikacija: `flutter analyze` = 0 issues, backend build = 0 errors

### Kupon sustav — UI Polish & Backend integracija (2026-04-14)

- [x] **Coupon card 3-row redesign** — `_CouponCard` potpuni redizajn:
  - Row 1: Kod u teal 16px bold monospace + copy ikona (dark tooltip) + Spacer + StatusBadge + delete ikona (dark tooltip)
  - Row 2: Naziv 13px normal (lijevo) + `_formatTypeValue()` 16px bold white (desno)
  - Row 3: Datumi 12px secondary (lijevo) + combinable ikona + grad + broj seniora (desno)
- [x] **Univerzalni value format** — `X sati / mj.`, `X sati / tj.`, `X sati / ukupno`, `X% / termin`, `€X / termin`
- [x] **Hrvatska gramatika sati** — `_hoursLabel()`: 1 sat, 2-4 sata, 5+ sati (handles 11-19 special case)
- [x] **Copy icon na coupon code** — Teal `Icons.copy` s custom dark tooltipom ("Kopiraj kod"), Clipboard copy + SnackBar potvrda
- [x] **City dropdown crash fix** — `_selectedCityId` više se ne postavlja u `initState` (gradovi još nisu učitani) → deferred u `_loadCities()` callback
- [x] **Order detail coupon chip cleanup** — Label sadrži samo `code` (uklonjeni type/value). Chip border 0.5px. `deleteButtonTooltipMessage: ''` (uklonjen default "Brisanje" tooltip)
- [x] **Coupon chip tooltip** — Custom dark tooltip na hover: naziv kupona + preostali sati ili tip/vrijednost
- [x] **Tooltip konzistentnost** — Svi tooltipovi u admin appu koriste custom dark stil: `Color(0xE6616161)`, borderRadius 6, fontSize 13, white text
- [x] **Button label promjene** — "Dodijeli senioru" → "Dodijeli kupon", "Otkaži" → "Otkaži narudžbu"
- [x] **AppStrings** — Dodani: `couponCodeCopied`, `couponCopyCode`. Izmijenjeni: `couponAssignSenior`, `cancelOrderBtn`
- [x] Verifikacija: `flutter analyze` = 0 issues

## Sljedeći koraci (Next Steps)

1. Zadržati vanjske providere (`Stripe`, `Minimax`, `Mailgun`, `MailerLite`, `Firebase`) izvan scopea dok ih developer ne spoji na live credentials.
2. Nakon potvrde nastaviti sa sljedećim prioritetom iz [ROADMAP.md](ROADMAP.md).

---

### Live Session Status Chips + Disabled Buttons (2026-04-14)

- [x] **LiveSessionBadge** — `StatefulWidget` s `Timer` u `core/widgets/status_badges.dart`, auto-transition Predstojeći→Aktivan→Završen po vremenu
- [x] **`_SessionPhase` enum** — `upcoming`, `active`, `completed`, `cancelled` s odgovarajućim bojama
- [x] **order_detail_screen.dart** — Koristi `LiveSessionBadge` umjesto statičkog badgea na sesijama
- [x] **Disabled buttons** — "Promijeni" i "Otkaži" gumbi disabled kad je sesija aktivna ili završena (`isActiveOrDone = now.isAfter(start)`)
- [x] **`_SessionActionButton.onTap` nullable** — Kad je `null`, gumb prikazuje sivu boju (`Colors.grey`) umjesto teal/coral
- [x] **"Obavljen" → "Završen"** — `sessionStatusCompleted` promijenjen u admin AppStrings za konzistentnost s mobilnom aplikacijom
- [x] **`sessionStatusActive`** — Novi i18n ključ (HR: "Aktivan")
- [x] Verifikacija: `flutter analyze` = 0 issues

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

---

## PromoCode→Coupon ujedinjenje (2026-04-18)

- [x] API endpointi: `promo-codes/*` uklonjeni, sada samo `coupons/*`
- [x] `OrderModel.promoCode` → `couponCode`
- [x] `admin_api_service.dart`: `updateOrderPromoCode` → `updateOrderCoupon`, `validatePromoCode` → `validateCoupon`
- [x] AppStrings: uklonjeni dupli `couponCode` ključevi (promo sekcija) — existing coupon CRUD ključevi dovoljni
- [x] Verifikacija: `flutter analyze` = 0 issues
