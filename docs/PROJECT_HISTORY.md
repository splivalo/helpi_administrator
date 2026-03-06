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
- **MockData** — Kompletni mock podaci za sve entitete (studenti, seniori, narudžbe, sesije, chat)
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

## Arhitekturalne odluke

| Odluka                                         | Razlog                                                  | Datum      |
| ---------------------------------------------- | ------------------------------------------------------- | ---------- |
| Feature-based folder struktura                 | Skalabilnost, jasna separacija                          | 2026-02    |
| AppStrings Gemini Hybrid pattern               | Backend šalje labelKey, Flutter mapira lokalno          | 2026-02    |
| MockData umjesto API-ja                        | Brži frontend development bez backenda                  | 2026-02    |
| Dva showDatePicker umjesto showDateRangePicker | Performanse — DateRangePicker preopterećen              | 2026-03-04 |
| LayoutBuilder za responsive gumbe              | Inline responsive bez globalnog breakpointa             | 2026-03-04 |
| Nema state management libraryja (zasad)        | Mock faza, lokalni state dovoljan                       | 2026-02    |
| DRY refactor — shared widgeti + mixin          | Eliminacija ~1000+ linija duplikata                     | 2026-03-04 |
| GestureDetector umjesto IconButton za contact  | Material 3 min tap target 48px blokira 20px             | 2026-03-04 |
| InfoRow Flexible trailing                      | Ikona uz tekst, ne na rubu                              | 2026-03-04 |
| SharedPreferences za UI preferencije           | Pamti korisničke UI odabire između sesija               | 2026-03-04 |
| Web-safe PreferencesService s fallback         | Sprječava crash na web hot-restart                      | 2026-03-04 |
| bodyLarge 16px globalno                        | Konzistentna veličina teksta u svim inputima            | 2026-03-04 |
| CreateOrderScreen single-page forma            | Sve na jednom ekranu, auto-scroll UX                    | 2026-03-04 |
| Senior status → hasStudentAssigned logika      | Automatski "U obradi" / "Aktivan" po podacima           | 2026-03-04 |
| SessionPreviewSheet kao shared widget          | Reusable između create i assign flowova                 | 2026-03-05 |
| ActionChipButtonSize enum (small/medium)       | Konzistentni gumbi — mali za kartice, srednji za modale | 2026-03-05 |
| DatePicker theme globalno u ThemeData          | Jedan izvor istine za boje/font/shape svuda             | 2026-03-05 |
| confirmText/cancelText na showDatePicker       | "U redu" umjesto "U REDU" caps lock                     | 2026-03-05 |
| ValueKey locale rebuild u IndexedStack         | Force rebuild ekrana pri promjeni jezika                | 2026-03-05 |
| ClipRRect na assign flow step 2                | Content clipping za zaobljene rubove                    | 2026-03-05 |
