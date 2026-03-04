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
