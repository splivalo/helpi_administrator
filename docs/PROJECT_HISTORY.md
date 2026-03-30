# Helpi Admin – Project History

> Kronologija ključnih odluka i promjena.

---

## 2026-02 — Inicijalni scaffold

- **Projekat kreiran** — Flutter 3.10.7+, Material 3
- **Arhitektura definirana** — Feature-based folder struktura: `app/`, `core/`, `features/`
- **HelpiTheme** — Centralizirana tema s coral (#EF5B5B) primary, teal (#009D9D) accent, warm off-white background
- **ResponsiveShell** — Tri layout breakpointa:
  - Mobile (<600px): BottomNavigationBar
  - Tablet (600–900px): NavigationRail (collapsed)
  - Desktop (≥900px): Extended sidebar s SVG logom
- **5 feature modula kreirano:**
  - Auth (LoginScreen)
  - Dashboard (KPI kartice, nedavne narudžbe, današnje sesije, ugovori koji istječu)
  - Studenti (lista + detalj + obračun)
  - Seniori (lista + detalj + dodaj/uredi forme)
  - Narudžbe (lista + detalj + dodjela studenta + sesije)
  - Chat (moderacija razgovora)
- **i18n sustav** — AppStrings klasa s Gemini Hybrid patternom (`_localizedValues` map + statički getteri), HR + EN jezik
- **AppData** — Kompletni mock podaci za sve entitete (studenti, seniori, narudžbe, sesije, chat)
- **Modeli** — SeniorModel, StudentModel, OrderModel, SessionModel, ChatRoom, ChatMessage, StudentReview + enumi

## 2026-03-04 — UI Polish & Cleanup

- **Date picker optimizacija** — `showDateRangePicker` bio izuzetno spor za otvaranje. Zamijenjen s dva zasebna `showDatePicker` poziva (`_pickStartDate` + `_pickEndDate`) koji su puno lakši widgeti.
- **Responsive gumbi** — Svi full-width action gumbi (upload ugovora, arhiviranje, dodjela studenta) prebačeni na 1/3 širine na ekranima ≥800px. Implementirano putem `LayoutBuilder` wrappera.
- **Order kartice styling** — Uklonjen italic sa "Nije dodijeljen student" teksta; zadržana crvena boja (`statusCancelledText`). Ikona škole obojana u crveno kad nema dodijeljenog studenta.
- **Dead code cleanup:**
  - Uklonjeno 8 nekorištenih color konstanti iz `theme.dart` (`cardMint`, `cardLavender`, `cardCream`, `cardBlue`, `statusAssignedText`, `statusAssignedBg`, `statusUpcomingText`, `statusUpcomingBg`)
  - Uklonjena nekorištena dimenzija `sidebarCollapsedWidth`
  - Uklonjeni dead i18n stringovi `studentDeactivate`/`studentActivate` iz `app_strings.dart`
  - Potvrđeno: 93 "nekorištena" AppStrings gettera su i18n infrastruktura za budući backend, nisu pravi dead code
- **Dokumentacija** — Kreirani `docs/` folder s PROGRESS.md, ROADMAP.md, PROJECT_HISTORY.md, ARCHITECTURE.md
- **SVG logo brzina** — Istraženo (precaching u `main()` i `initState()`), zaključeno da je debug mode artefakt. Odustano.

## 2026-03-04 — DRY Refactor & Contact Actions

- **Kompletni DRY refactor** — 22 duplicirana patterna identificirana kroz audit svih 18 Dart fajlova. Kreirano 6 shared fajlova:
  - `core/utils/formatters.dart` — formatDate, formatTime, formatTimeOfDay, formatDateDot
  - `core/widgets/status_badges.dart` — StatusBadge (.order/.contract factory), ServiceChip, orderStatusStyle, contractStatusStyle, serviceLabel
  - `core/widgets/shared_widgets.dart` — SectionCard, InfoRow (label+value+trailing), DragHandle, EmptyState, ResultCountRow, HelpiSearchBar
  - `core/widgets/contact_actions.dart` — PhoneCallButton, EmailCopyButton
  - `core/widgets/widgets.dart` — barrel export
  - `features/seniors/presentation/senior_form_helpers.dart` — SeniorFormHelpers mixin (buildSectionLabel, buildTextField, buildGenderSelector, buildDatePicker)
- **7 ekrana refaktorirano** — orders_screen, order_detail_screen, students_screen, student_detail_screen, seniors_screen, dashboard_screen, add/edit_senior_screen
- **~1000+ linija duplikata uklonjeno** — svaki ekran koristi shared widgete umjesto privatnih kopija
- **Contact actions fix** — IconButton u SizedBox(20x20) nije renderirao ikone zbog Material 3 min tap target (48x48). Zamijenjeno s GestureDetector + Icon + Padding.
- **InfoRow trailing pozicioniranje** — Flexible umjesto Expanded kad ima trailing widget, pa ikona stoji uz tekst a ne na desnom rubu.

## 2026-03-04 — CreateOrderScreen & Narudžbe proširenja

- **CreateOrderScreen kreiran** (1141 linija) — Kompletna single-page forma za kreiranje narudžbe:
  - Odabir seniora s pretragom ili pre-assignment (kad se otvara s senior detaila)
  - Service chips full-width (Expanded umjesto fiksne širine)
  - Hour chips full-width s nullable default trajanjem
  - Frekvencija, raspoloživi dani, vremenski slot
  - Auto-scroll na sljedeću sekciju nakon odabira
  - Validacija svih polja
- **FAB "Dodaj narudžbu"** dodan na AdminOrdersScreen
- **"Dodaj narudžbu" gumb** dodan na senior detail ekranu (otvara CreateOrderScreen s pre-assigned seniorom)
- **OrderSort dodano** — sortiranje narudžbi (najnovije/najstarije/po statusu)
- **Processing tab** — dodan tab "U obradi" na listu narudžbi (5 tabova ukupno)

## 2026-03-04 — Seniori & Studenti proširenja

- **Senior status business logika** — Ispravljeno: senior je "U obradi" dok nema dodijeljenog studenta na nijednoj narudžbi → postaje "Aktivan" kad ima barem jednog dodijeljenog studenta (`hasStudentAssigned` flag)
- **Mock senior Ankica Tomić (s6)** — Dodan senior s 0 narudžbi za testiranje edge caseova
- **Broj narudžbi na senior kartici** — font size povećan s 12 na 14
- **Button border width fix** — ispravljena debljina obruba na gumbima
- **`_filteredSeniors` tab logika ažurirana** — filtriranje po statusu u tabovima koristi novu business logiku
- **Studenti 7 tabova** — prošireno s 3 na 7: Svi / Aktivni / Ističe ugovor / Istekao ugovor / Bez ugovora / Deaktivirani / Arhivirani

## 2026-03-04 — Filter Panel Redesign & Font Unifikacija

- **Filter dropdown redesign** — Zamijenjen `InputDecorator + DropdownButton` s `DropdownButtonFormField` + themed `InputDecoration` (filled, white, cardRadius borders, accent focusedBorder)
- **"Poništi sve" coral hover** — Promijenjen `TextButton` hover s plave na coral (`TextButton.styleFrom(foregroundColor: HelpiTheme.primary)`)
- **Day chips full-width** — Zamijenjeni `Wrap` s fiksnom širinom 44px na `Row` s 7 `Expanded` djece, visina 42
- **Sve filter borderRadius ujedinjeni** — hardkodirani `10` → `HelpiTheme.cardRadius` (12) na: dropdown, min/max fields, date picker buttons, time picker buttons, day chips
- **Min/Max polja visina** — uklonjeno `isDense: true`, padding promijenjeno na 20/18, dodani filled white i border dekoracija da matchaju dropdown
- **bodyLarge 18→16** — Globalna promjena u `theme.dart` da TextField input text i Dropdown text budu iste veličine (16px)

## 2026-03-04 — SharedPreferences & Notifikacije

- **NotificationBell widget** kreiran (298 linija) — Bell ikona s badge brojem nepročitanih, otvara NotificationsDrawer s listom mock notifikacija
- **`shared_preferences` package dodan** (^2.5.4)
- **PreferencesService singleton** kreiran — centralizirani wrapper s:
  - `getGridView(screen)` / `setGridView(screen, isGrid)` — pamti grid/list view
  - `getSort(screen)` / `setSort(screen, sortName)` — pamti sort odabir
  - `getTab(screen)` / `setTab(screen, index)` — pamti aktivni tab
  - Web-safe init: try-catch s in-memory fallback kad plugin nije dostupan (web hot-restart)
- **Wired u 4 ekrana**: Dashboard, OrdersScreen, StudentsScreen, SeniorsScreen
- **main.dart ažuriran** — async main s `await PreferencesService.instance.init()`
- **Buduća napomena**: Preferencije su trenutno globalne; kad se doda autentifikacija, trebaju postati per-user

## 2026-03-05 — Session Preview Sheet & Edit Order

- **SessionPreviewSheet** kreiran (851 linija) — `core/widgets/session_preview_sheet.dart`:
  - Generira pregled sesija na temelju frekvencije, odabranih dana i trajanja
  - Koristi se u CreateOrderScreen i OrderDetailScreen (assign/change student flow)
  - Prikaz: lista sesija, ukupan broj, potvrda dodjele studenta
- **Edit Order modal** — uređivanje narudžbe: promjena usluge, frekvencije, datuma, sati
- **Assign flow (dodjela studenta)** — 2-step modalni flow:
  - Step 1: Odabir studenta iz liste (pretraga, filtriranje)
  - Step 2: Pregled sesija i potvrda dodjele
  - Fix: `ClipRRect(cardRadius)` za zaobljene rubove na step 2 sadržaju

## 2026-03-05 — UI Consistency Audit & Fixes

- **AlertDialog konzistentnost** — Svih 13 AlertDialoga u aplikaciji popravljeno:
  - Dodan `shape: RoundedRectangleBorder(borderRadius: cardRadius)` na svaki
  - `ElevatedButton` → `TextButton` za OK/Cancel akcije
  - Hardkodirani "OK" / "Da" / "U redu" → `AppStrings.ok`
  - Uklonjena custom crvena boja na cancel order buttonu
  - Fajlovi: order_detail_screen, student_detail_screen, seniors_screen
- **TextButton hover shape fix** — Globalno dodano `shape: RoundedRectangleBorder(borderRadius: buttonRadius)` u `textButtonTheme` (theme.dart). Prije toga TextButton-i su imali stadium (pill) hover efekt.
- **Reorder sheet spacing fix** — Na sva 3 reorder modala (order_detail, student_detail, seniors):
  - Uklonjen `Padding(vertical: 16)` na Dialog wrapperu koji je gurao sadržaj predaleko od vrha
  - Header padding: `fromLTRB(20, 12, 8, 8)` — matching "Novi senior" modal pattern
  - Hint text: horizontalni padding 20
  - Action buttons: padding `fromLTRB(16, 0, 16, 16)`
- **StatusBadge size konzistentnost** — Order detail AppBar koristio `StatusBadgeSize.large`, student i senior koristili default `small` → unificirano na `small` svugdje u AppBarima
- **ActionChipButton size varijante** — Dodan `ActionChipButtonSize` enum:
  - `small` (default): icon 14, font 12, padding 10×6, radius 8 — za inline card akcije
  - `medium`: icon 18, font 14, padding 14×8, radius 10 — za modal primary akcije
  - Primijenjeno `medium` na 7 fajlova: sve spremi/potvrdi/poništi/primijeni akcije u modalima
- **Assign flow zaobljeni rubovi** — `_OrderAssignFlowSheet` i student assign:
  - Dodan `ClipRRect(borderRadius: cardRadius)` na content area
  - Hardkodirani `Radius.circular(20)` → `Radius.circular(HelpiTheme.cardRadius)`

## 2026-03-05 — Locale Fix & Web Deploy

- **Locale switching bug fix** — Promjena jezika nije ažurirala sadržaj tabova:
  - Root cause: `_screens` u `ResponsiveShell` bio `late final List<Widget>` kreiran u `initState` → `IndexedStack` cachirao const instance
  - Fix: `_screens` pretvoren u getter s `ValueKey('screenName_$locale')` — kad se locale promijeni, `IndexedStack` tretira ekrane kao nove widgete
- **Flutter Web build & deploy** — `flutter build web --base-href /helpi/` za deploy na `https://kungfu.digital/helpi/index.html`

## 2026-03-05 — DatePicker Global Theme

- **DatePicker tema definirana globalno** u `datePickerTheme` unutar `ThemeData`:
  - Accent (teal) boja za odabrani dan, header pozadinu, godine — umjesto default coral
  - Header font smanjen na 20px (default Material 3 ~32px je prevelik, lomi datum u 2 reda)
  - Shape: `cardRadius` (12px) zaobljenje — konzistentno s ostalim dijalozima
  - Confirm/Cancel button stilovi: accent za potvrdu, textSecondary za odustani
- **"U REDU" → "U redu"** — Svi `showDatePicker` pozivi (6 lokacija) dodali `confirmText: AppStrings.ok, cancelText: AppStrings.cancel` umjesto Material default lokalizacije koja je koristila caps lock "U REDU"
- **Builder override uklonjeni** — `student_detail_screen.dart` `_pickStartDate`/`_pickEndDate` imali lokalne builder-e s `ColorScheme.light(primary: accent)` → uklonjeni jer globalna tema to sada rješava

---

## 2026-03-06 — Canonical Domain V1 usklađivanje

- **SessionStatus enum**: `upcoming` → `scheduled` — kanonski termin za pre-execution stanje
- **JobStatus enum**: `assigned`/`upcoming` uklonjen → jedini `scheduled` — ujednačeno s SessionStatus
- **ServiceType enum**: `walk` → `walking` — kanonski service code; dodan `ServiceType.fromCode()` za alias mapping (`socializing` → `companionship`, `walk` → `walking`, `house_help` → `houseHelp`)
- **SessionModel**: dodan `orderId` (explicit foreign key prema OrderModel)
- **ReviewModel**: dodani `sessionId`, `studentId`, `seniorId` (explicit linkage ID-ovi)
- **AppStrings**: ključevi preimenovani (`sessionStatusUpcoming` → `sessionStatusScheduled`, `serviceWalk` → `serviceWalking`, `jobAssigned`/`jobUpcoming` → `jobScheduled`); UI labeli ostaju lokalizirani ("Nadolazeći" HR, "Scheduled" EN)
- **Cancel semantika potvrđena**: cancel order = `OrderStatus.cancelled` status promjena, nikad brisanje
- **Rezultat**: 0 errors → 0 errors (dart analyze)

---

## 2026-03-08 — Promo kod & Dialog unifikacija

- **Promo kod polje** — `promoCode` (String?) dodano u `OrderModel` za Stripe promo kod integraciju:
  - Prikaz u detaljima narudžbe kao zadnje polje (nakon Usluga/Services)
  - "Primijeni promo kod" ActionChipButton u admin akcijama s dijalogom za unos
  - `_rebuildOrder` proširena s `promoCode` parametrom
  - Svi OrderModel konstruktori u order_detail_screen.dart prosljeđuju `promoCode`
  - CreateOrderScreen edit mode čuva `promoCode` iz postojeće narudžbe
- **AppStrings promo ključevi** — `promoCode` ("Promo kod"/"Promo code"), `promoCodeHint`, `promoCodeApply` (HR + EN + getteri)
- **DialogTheme** — Dodan `dialogTheme` u `theme.dart` (backgroundColor, surfaceTintColor, shape s cardRadius, actionsPadding)
- **Dialog unifikacija (SizedBox width: 400)** — Svih 14 AlertDialoga unificirano:
  - Uklonjeno redundantno `shape: RoundedRectangleBorder(...)` — koristi se globalni dialogTheme
  - Content wrappan u `SizedBox(width: 400)` za konzistentnu širinu svih dijaloga
  - Fajlovi: order_detail_screen (8), student_detail_screen (3), seniors_screen (3)
- **Rezultat**: 0 errors → 0 errors (dart analyze)

---

## 2026-03-12 — Session Preview: 15-min travel buffer & UI fixes

- **15-minutni travel buffer (kompletno)** — Buffer od 15 min primijenjen u SVE 3 scheduling funkcije u oba fajla (`session_preview_helper.dart` + `session_preview_sheet.dart`):
  - `findConflict` / `_findConflict` — detektira konflikt kad je gap < 15 min prije ILI poslije postojećeg ordera
  - `findSubstitutes` / `_findSubstitutes` — zamjenski student mora imati 15 min gap oko svojih postojećih ordera
  - `findAltSlots` / `_findAlternativeSlots` — alternativni slotovi poštuju 15 min buffer u OBA smjera (prije i poslije busy intervala)
  - Buffer se NE primjenjuje na availability (to je čisti prozor studenta), samo između dva Helpi ordera
  - Konstanta `_buffer = 15` centralizirana na razini klase
- **Shared `show15MinTimePicker`** — Ekstrahiran zajednički time picker dialog u `shared_widgets.dart` s dva dropdowna (sat 0-23, minute 00/15/30/45). Koristi se u filterima studenata (Dostupan od/do). Session preview ekrani zadržavaju svoje slot-based pickere (inline chipovi / bottom sheet s ListTile).
- **`HelpiTheme.inputFieldHeight`** — Dodana centralna konstanta (48px) za konzistentnu visinu svih input polja u filter panelu.
- **Filter panel fixes** — Mobile background `HelpiTheme.scaffold` → `HelpiTheme.surface` (bijela); OutlinedButton → GestureDetector+Container za time picker gumbe (uklonjen bold tekst); availability filter logika promijenjena iz "covers" u "overlaps" semantiku.
- **Mock data update** — Maja Knežević: dostupnost četvrtkom proširena na 7:00–19:00 za testiranje višestrukih alternativnih slotova.
- **Rezultat**: 0 errors → 0 errors (flutter analyze)

---

## 2026-03-15 — Suspenzija, Admin Notes & Tab Cleanup

- **Review comment scroll** — Zamjena truncation (maxLines:5) s ConstrainedBox(maxHeight:100) + SingleChildScrollView
- **Admin Notes (NotesSection)** — Widget za admin bilješke (add/edit/delete) integriran u StudentDetail (9 sekcija) i SeniorDetail (8 sekcija)
- **Suspension warning dialog** — Upozorenje s brojem aktivnih narudžbi prije suspenzije (student + senior detail)
- **Auto-cancel orders on suspend** — Loop u \_confirmSuspend() otkazuje aktivne/processing narudžbe pri suspenziji
- **SuspensionStateManager listener fix** — Dodano addListener u initState() na StudentsScreen i SeniorsScreen
- **Tab hover boja fix** — tabBarTheme u theme.dart s neutralnim sivim overlayColor umjesto teal splasha
- **Uklonjen ContractStatus.deactivated** — Enum, tab, filter, badge, AppStrings (4 ključa)
- **Uklonjen ContractStatus.expiring** — Prebačeno na date-based (active + expiryDate < 30 dana)
- **Suspend button style** — TextButton.styleFrom(foregroundColor: error) za pravilan hover
- **Rezultat**: 0 errors → 0 errors (dart analyze)

---

## 2026-03-18→19 — Udaljenost & Sortiranje studenata

- **Haversine formula** — `haversineKm()` dodan u `formatters.dart` za izračun udaljenosti između studenta i seniora
- **Lat/Lng polja na modelima** — `latitude`/`longitude` dodani na SeniorModel i StudentModel, parsirani iz backend API odgovora
- **Prikaz udaljenosti u assign modalu** — Km udaljenost studenta od seniora prikazana na student assign kartici (zamjenjuje broj završenih narudžbi)
- **Sortiranje studenata** — 3-level sort: dostupnost → udaljenost → ocjena (najdostupniji i najbliži student prvi)
- **Udaljenost u reschedule pickeru** — Km prikaz i u modalnom izborniku za promjenu studenta
- **Uklonjen `~` prefix** — Nekorišten prefix ispred udaljenosti uklonjen
- **Rating decimal fix** — `toStringAsFixed(1)` na svih 8 lokacija u 5 fajlova (dashboard_screen, session_preview_content, session_preview_sheet, order_detail_screen)
- **Backend fix: StudentQueryBuilder** — Dodani `Latitude`/`Longitude` u `ContactInfoDto` projekciju (riješen 5331 km bug)
- **Backend fix: OrderDto** — Dodani `SeniorLatitude`/`SeniorLongitude` u OrderDto + AutoMapper mapping
- **Rezultat**: 0 errors (dart analyze), backend build success

---

## 2026-03-20→21 — Planirani termini & Order Details Cleanup

- **AdminDirectAssign instant JobInstance generation** — Backend `AdminDirectAssignAsync()` sada odmah generira JobInstance zapise pri dodjeli studenta (ranije ovisilo o Hangfire periodic jobu). Dodane 3 nove ovisnosti + metoda `GenerateJobInstancesForAssignmentAsync()`.
- **OrderScheduleRepository enhancement** — `.ThenInclude(o => o.Senior)` dodan u `GetByIdAsync()` za pristup `order.Senior.CustomerId` pri generaciji instanci.
- **Projected sessions za Pending narudžbe** — Nova metoda `_generateProjectedSessions()` u order_detail_screen.dart generira planirane termine iz `dayEntries` rasporeda (one-time: 1 sesija, recurring: weekly do endDate/3mj horizonta)
- **Muted session card dizajn** — `_buildProjectedSessionCard()` s Column layoutom: datum gore, vrijeme + trajanje dolje, sivi tonovi, bez akcijskih gumba
- **"Planirano" badge** — Narančasti badge u sessions sekciji i subtitle "Planirani termini — čeka se dodjela studenta."
- **Detalji narudžbe cleanup** — Uklonjene 4 redundantne sekcije iz "Detalji narudžbe" kartice: Vrijeme (vidljivo u terminima), Trajanje (vidljivo u terminima), Raspored (vidljiv u terminima), Adresa (vidljiva u "Korisnik usluge" kartici)
- **AppStrings** — Dodani `sessionsPlannedSubtitle`, `sessionStatusPlanned` (HR + EN + getteri)
- **Rezultat**: 0 errors (dart analyze), backend build success, testiran Order 9 → 21 sesija odmah po dodjeli

---

## 2026-03-22 — Riverpod State Management migracija

- **flutter_riverpod ^2.6.1 dodan** u pubspec.yaml
- **ProviderScope** wrapper u main.dart
- **6 StateNotifier providera** kreirano u `core/providers/data_providers.dart`:
  - `studentsProvider`, `seniorsProvider`, `ordersProvider`, `reviewsProvider`, `notificationsProvider`, `chatRoomsProvider`
  - Svaki ima: `setAll()`, `addItem()`, `updateItem()`, `removeItem()` (gdje primjenjivo)
  - `notificationsProvider` ima dodatno: `markRead(id)`, `markAllRead()` (NotificationModel nema copyWith, mutira isRead direktno)
- **DataLoader.loadAll(ref: ref)** — WidgetRef? parametar dodan; nakon AppData populacije, sinkronizira sve 6 providera
- **17 widgeta migrirano** na ConsumerStatefulWidget / ConsumerWidget:
  - `app.dart`, `dashboard_screen.dart`, `students_screen.dart`, `student_detail_screen.dart`, `seniors_screen.dart` (3 klase), `edit_senior_screen.dart`, `add_senior_screen.dart`, `order_detail_screen.dart` (2 klase), `create_order_screen.dart`, `chat_screen.dart` (\_ChatRoomList), `notification_bell.dart` (2 klase), `session_preview_sheet.dart`
- **session_preview_helper.dart** — `allStudents`/`allOrders` parametri dodani u base class (ne-widget klasa, ne može koristiti ref)
- **Nula AppData referenci u UI sloju** — samo DataLoader koristi AppData kao intermediate store za API fetch → provider sync
- **Ključni patterni:**
  - `ref.watch()` u `build()` za reaktivne rebuilde
  - `ref.read()` u metodama za jednokratno čitanje
  - `ref.read(xxxProvider.notifier).updateItem()` za mutacije
  - Privatni child widgeti koji nemaju `ref`: konvertirani u ConsumerWidget ili primaju podatke kao parametar
- **Backward kompatibilno**: AppData i dalje postoji kao data source (API → AppData → Provider). Buduća integracija može zamijeniti AppData s direktnim provider populiranjem.
- **Rezultat**: 0 errors → 0 errors (flutter analyze) throughout all 17+ file changes

---

## 2026-03-23 — Admin Notifications + SignalR Real-time

- **NotificationType enum aligned** — Zamjena 4-value enuma (`newOrder, contractExpiring, sessionCancelled, info`) sa 30-value enumom koji točno odgovara backend `NotificationType` (0=General→29=AdminDeleted)
- **signalr_netcore ^1.4.4** — Dodan package za SignalR konekciju s backendom
- **SignalRNotificationService kreiran** (165 linija) — `lib/core/services/signalr_notification_service.dart`:
  - HubConnectionBuilder s WebSocket transport + bearer token auth
  - Auto-reconnect (5 pokušaja s eksponencijalnim backoffom)
  - `ReceiveNotification` handler — parsira JSON → NotificationModel, insertira u AppData + refresha Riverpod provider
  - `start(ref:)` / `stop()` lifecycle metode
- **App lifecycle wiring** — `app.dart`:
  - SignalR start nakon uspješnog logina i session restore
  - SignalR stop pri logout i dispose
- **Notification parser fix** — `admin_api_service.dart` `_mapNotification()` sada koristi `_mapNotificationType(json['type'])` umjesto hardkodiranog `NotificationType.info`
- **Icon/color/background mapping** — `notification_bell.dart` ažuriran za 7 specifičnih admin notifikacija:
  - `newStudentAdded` / `newSeniorAdded` → person_add / teal
  - `orderCancelled` / `jobCancelled` → shopping_bag / event_busy / crvena
  - `contractExpired` → warning / narančasta
  - `paymentSuccess` → payment / zelena
  - `paymentFailed` → money_off / crvena
  - Svi ostali tipovi → info*outline / sivi (wildcard `*` default)
- **data_loader.dart demo data fix** — Zamjena starih enum konstanti (`newOrder`, `info`, `contractExpiring`) s novim (`orderCancelled`, `general`, `paymentSuccess`, `contractExpired`, `newSeniorAdded`)
- **Rezultat**: 0 errors → 0 errors (flutter analyze)
- **Commit:** `adcad0f`

---

## 2026-03-23 — Error Handling, Senior Status Fix & Contract Logic

- **Login error distinction** — `AuthResult.isConnectionError` flag razlikuje server nedostupan (narančasta poruka) od krivih credentialsa (crvena poruka). DioException type checking: connectionTimeout, connectionError, receiveTimeout, null response.
- **ServerUnavailableScreen compact restyle** — maxWidth 420, icon 48px, titleLarge, full-width button, warm off-white background (#FAF6F1)
- **Senior section reorder overflow** — `SizedBox(height: _sectionCount * 56.0)` zamijenjen s `Flexible` — riješen 16px bottom overflow
- **Senior status logika popravljena** — Senior bez narudžbi sada prikazuje "Neaktivan" (ne "U obradi"). Nova logika:
  - Suspendiran → isSuspended
  - Arhiviran → isArchived
  - **Neaktivan** → !isActive ILI nema narudžbi
  - **Aktivan** → isActive + ima narudžbe + bar jedna dodijeljena
  - **U obradi** → isActive + ima narudžbe + nijedna dodijeljena
  - Fix na 3 mjesta: `_filteredSeniors()` filter, `_SeniorCard` badge, `SeniorDetailScreen` AppBar badge
- **Rezultat**: 0 errors → 0 errors (flutter analyze)

---

## 2026-03-30 — Filter/Assignment Safety & Chat Unread Badge

- **Block assignment on cancelled/completed orders** — "Dodijeli studenta" button hidden for cancelled/completed/archived orders. Guard checks in `_showAssignSheet()` and `_assignStudent()` in `order_detail_screen.dart`.
- **Suspended students excluded from substitutes** — `!s.isSuspended` check added in both `session_preview_helper.dart` (base class) and `order_detail_screen.dart` (override) `isSubstituteCandidate`.
- **"Zamjena" button hidden when no subs** — Consistent with "Pomakni": hidden when `findSubstitutes()` returns empty list in `session_preview_content.dart`.
- **Faculty dropdown always visible** — Changed `faculties.length > 1` to `faculties.isNotEmpty`, auto-selects single faculty. Spacer removed when no dropdown (chip aligns left).
- **Removed 60-day filter** — `ActivityPeriod.last60Days` removed from student page filter modal.
- **Neutral dropdown colors** — Faculty dropdown stays grey/neutral regardless of selection (no teal).
- **Availability labels** — Desktop: "Dostupan sve dane" / "Djelomično dostupan". Mobile: "Dostupan" / "Djelomično". Added `availableAllDaysShort` string.
- **UnreadMessagesNotifier provider** — `StateNotifier<int>` with `increment()`, `reset()`, `set(int)` in `data_providers.dart`.
- **SignalR ReceiveMessage listener** — `_onReceiveMessage` handler in `signalr_notification_service.dart` increments unread count.
- **ResponsiveShell → ConsumerStatefulWidget** — Converted from `StatefulWidget` to access Riverpod providers. Added `_badgedIcon()` helper and `badgeCount` parameter to `_sidebarItem()`.
- **Chat badge on all 3 nav layouts**:
  - Desktop sidebar: `_sidebarItem(3, ..., badgeCount: ref.watch(unreadMessagesProvider))`
  - Tablet NavigationRail: `_badgedIcon()` wrapper on chat destination icon
  - Mobile BottomNav: `_badgedIcon()` wrapper on chat item icon
- **Reset unread on chat tap** — `ref.read(unreadMessagesProvider.notifier).reset()` when index == 3.
- **⚠️ TODO**: Currently `super(3)` for testing. Revert to `super(0)` and connect to real backend ChatHub + Firebase events.
- **Rezultat**: 0 errors → 0 errors (flutter analyze)

---

## Arhitekturalne odluke

| Odluka                                         | Razlog                                                                   | Datum      |
| ---------------------------------------------- | ------------------------------------------------------------------------ | ---------- | --- | ---------------------------------------- | --------------------------------------------------------------------- | ---------- |
| Feature-based folder struktura                 | Skalabilnost, jasna separacija                                           | 2026-02    |
| AppStrings Gemini Hybrid pattern               | Backend šalje labelKey, Flutter mapira lokalno                           | 2026-02    |
| AppData umjesto API-ja                         | Brži frontend development bez backenda                                   | 2026-02    |
| Dva showDatePicker umjesto showDateRangePicker | Performanse — DateRangePicker preopterećen                               | 2026-03-04 |
| LayoutBuilder za responsive gumbe              | Inline responsive bez globalnog breakpointa                              | 2026-03-04 |
| ~~Nema state management libraryja~~            | ~~Mock faza, lokalni state dovoljan~~ → **Riverpod** (2026-03-22)        | 2026-02    |
| **Riverpod state management**                  | Reaktivni UI, konzistentnost s helpi_app, zero AppData u UI              | 2026-03-22 |
| DRY refactor — shared widgeti + mixin          | Eliminacija ~1000+ linija duplikata                                      | 2026-03-04 |
| GestureDetector umjesto IconButton za contact  | Material 3 min tap target 48px blokira 20px                              | 2026-03-04 |
| InfoRow Flexible trailing                      | Ikona uz tekst, ne na rubu                                               | 2026-03-04 |
| SharedPreferences za UI preferencije           | Pamti korisničke UI odabire između sesija                                | 2026-03-04 |
| Web-safe PreferencesService s fallback         | Sprječava crash na web hot-restart                                       | 2026-03-04 |
| bodyLarge 16px globalno                        | Konzistentna veličina teksta u svim inputima                             | 2026-03-04 |
| CreateOrderScreen single-page forma            | Sve na jednom ekranu, auto-scroll UX                                     | 2026-03-04 |
| Senior status → hasStudentAssigned logika      | Automatski "U obradi" / "Aktivan" po podacima                            | 2026-03-04 |
| SessionPreviewSheet kao shared widget          | Reusable između create i assign flowova                                  | 2026-03-05 |
| ActionChipButtonSize enum (small/medium)       | Konzistentni gumbi — mali za kartice, srednji za modale                  | 2026-03-05 |
| DatePicker theme globalno u ThemeData          | Jedan izvor istine za boje/font/shape svuda                              | 2026-03-05 |
| confirmText/cancelText na showDatePicker       | "U redu" umjesto "U REDU" caps lock                                      | 2026-03-05 |
| ValueKey locale rebuild u IndexedStack         | Force rebuild ekrana pri promjeni jezika                                 | 2026-03-05 |
| ClipRRect na assign flow step 2                | Content clipping za zaobljene rubove                                     | 2026-03-05 |
| Haversine za km udaljenost                     | Sortiranje i prikaz koliko je student daleko od seniora                  | 2026-03-18 |
| Projected sessions iz dayEntries               | Planirani termini vidljivi i prije dodjele studenta                      | 2026-03-20 |
| Instant JobInstance na admin assign            | Sesije odmah vidljive nakon dodjele, ne čeka Hangfire                    | 2026-03-20 |
| Senior status = Neaktivan bez narudžbi         | !isActive \|\| !hasOrders = Neaktivan; hasOrders && !assigned = U obradi | 2026-03-23 |     | Chat unread badge via Riverpod + SignalR | Real-time badge count, reset on tap, infrastructure for Firebase chat | 2026-03-30 |
| ResponsiveShell → ConsumerStatefulWidget       | Needed ref.watch for reactive badge state across 3 nav layouts           | 2026-03-30 |
| Block assignment on terminal order statuses    | Prevent accidental student assignment to cancelled/completed orders      | 2026-03-30 |
