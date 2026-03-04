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

---

## Arhitekturalne odluke

| Odluka                                         | Razlog                                         | Datum      |
| ---------------------------------------------- | ---------------------------------------------- | ---------- |
| Feature-based folder struktura                 | Skalabilnost, jasna separacija                 | 2026-02    |
| AppStrings Gemini Hybrid pattern               | Backend šalje labelKey, Flutter mapira lokalno | 2026-02    |
| MockData umjesto API-ja                        | Brži frontend development bez backenda         | 2026-02    |
| Dva showDatePicker umjesto showDateRangePicker | Performanse — DateRangePicker preopterećen     | 2026-03-04 |
| LayoutBuilder za responsive gumbe              | Inline responsive bez globalnog breakpointa    | 2026-03-04 |
| Nema state management libraryja (zasad)        | Mock faza, lokalni state dovoljan              | 2026-02    |
| DRY refactor — shared widgeti + mixin          | Eliminacija ~1000+ linija duplikata            | 2026-03-04 |
| GestureDetector umjesto IconButton za contact  | Material 3 min tap target 48px blokira 20px    | 2026-03-04 |
| InfoRow Flexible trailing                      | Ikona uz tekst, ne na rubu                     | 2026-03-04 |
| SharedPreferences za UI preferencije           | Pamti korisničke UI odabire između sesija      | 2026-03-04 |
| Web-safe PreferencesService s fallback         | Sprječava crash na web hot-restart             | 2026-03-04 |
| bodyLarge 16px globalno                        | Konzistentna veličina teksta u svim inputima   | 2026-03-04 |
| CreateOrderScreen single-page forma            | Sve na jednom ekranu, auto-scroll UX           | 2026-03-04 |
| Senior status → hasStudentAssigned logika      | Automatski "U obradi" / "Aktivan" po podacima  | 2026-03-04 |
