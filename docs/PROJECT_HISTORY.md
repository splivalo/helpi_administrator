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
