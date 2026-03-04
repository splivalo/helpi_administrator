# Helpi Admin – Progress

> Zadnja izmjena: 2026-03-04

## Ukupno stanje

| Modul                 | Status                                                | Dovršenost |
| --------------------- | ----------------------------------------------------- | ---------- |
| Auth (Login)          | ✅ UI gotov, mock login                               | 90%        |
| Dashboard             | ✅ Kompletiran, DRY refaktorirano                     | 98%        |
| Studenti – Lista      | ✅ Tabovi, pretraga, filteri, sortiranje, DRY         | 98%        |
| Studenti – Detalj     | ✅ Profil, ugovor, obračun, dostupnost, narudžbe, DRY | 98%        |
| Seniori – Lista       | ✅ Pretraga, filteri, DRY                             | 98%        |
| Seniori – Detalj      | ✅ Profil, narudžbe, arhiviranje (inline u listi)     | 95%        |
| Seniori – Dodaj/Uredi | ✅ Forme kompletne, shared mixin                      | 98%        |
| Narudžbe – Lista      | ✅ Tabovi, pretraga, DRY                              | 98%        |
| Narudžbe – Detalj     | ✅ Sesije, dodjela studenta, reprogramiranje, DRY     | 98%        |
| Chat (Moderacija)     | ✅ Lista razgovora + poruke                           | 90%        |
| Responsive Shell      | ✅ Mobile/Tablet/Desktop layout                       | 100%       |
| i18n (HR/EN)          | ✅ AppStrings Gemini Hybrid                           | 95%        |
| Tema (HelpiTheme)     | ✅ Material 3, sve boje i dimenzije                   | 100%       |
| Mock Data             | ✅ Kompletni mock podaci                              | 100%       |
| DRY / Shared Widgets  | ✅ Kompletno refaktorirano (7 ekrana)                 | 100%       |
| Backend integracija   | ❌ Nije započeta                                      | 0%         |

**Ukupna dovršenost frontenda: ~90%**

---

## Checklist završenih zadataka

- [x] Projekt scaffold (Flutter 3.10.7+, Material 3)
- [x] HelpiTheme — boje, dimenzije, kompletna Material tema
- [x] ResponsiveShell — BottomNav (<600px), NavigationRail (600–900px), Sidebar (≥900px)
- [x] SVG logo u sidebaru
- [x] LoginScreen — email/password, jezični birač, mock login
- [x] DashboardScreen — KPI kartice, nedavne narudžbe, današnje sesije, ugovori koji istječu
- [x] StudentsScreen — tabovi (Svi/Aktivni/Neaktivni), pretraga, napredni filteri, sortiranje
- [x] StudentDetailScreen — osobni podaci, ugovor (upload PDF), obračun perioda, dostupnost, narudžbe, recenzije
- [x] SeniorsScreen — lista s pretragom + inline detalj
- [x] AddSeniorScreen — forma za dodavanje seniora
- [x] EditSeniorScreen — forma za uređivanje seniora
- [x] AdminOrdersScreen — tabovi (Svi/Aktivni/Završeni/Otkazani), pretraga
- [x] OrderDetailScreen — detalji narudžbe, sesije, dodjela/promjena studenta, reprogramiranje sesije
- [x] ChatScreen — moderacija razgovora
- [x] AppStrings (i18n) — HR + EN, parametrizirani stringovi, Gemini Hybrid pattern
- [x] MockData — studenti, seniori, narudžbe, sesije, chat sobe
- [x] Responsive gumbi — 1/3 širine na desktopu, full-width na mobilnom
- [x] Zamjena showDateRangePicker s dva showDatePicker (performanse)
- [x] Dead code cleanup — uklonjeno 10 nekorištenih konstanti i stringova
- [x] Dokumentacija (docs/ folder)
- [x] Copy/call buttons — PhoneCallButton i EmailCopyButton na svim ekranima (trailing uz tekst, ne na rubu)
- [x] Contact actions fix — GestureDetector umjesto IconButton (Material3 min-size bug)
- [x] InfoRow trailing pozicioniranje — Flexible umjesto Expanded kad ima trailing (ikona uz tekst)
- [x] DRY refactor — kompletno za cijelu aplikaciju (7 ekrana)
  - [x] `core/utils/formatters.dart` — formatDate, formatTime, formatTimeOfDay, formatDateDot
  - [x] `core/widgets/status_badges.dart` — StatusBadge, ServiceChip, orderStatusStyle, contractStatusStyle, serviceLabel
  - [x] `core/widgets/shared_widgets.dart` — SectionCard, InfoRow, DragHandle, EmptyState, ResultCountRow, HelpiSearchBar
  - [x] `core/widgets/contact_actions.dart` — PhoneCallButton, EmailCopyButton
  - [x] `core/widgets/widgets.dart` — barrel export
  - [x] `features/seniors/presentation/senior_form_helpers.dart` — SeniorFormHelpers mixin
  - [x] orders_screen.dart refaktorirano
  - [x] order_detail_screen.dart refaktorirano
  - [x] students_screen.dart refaktorirano
  - [x] student_detail_screen.dart refaktorirano
  - [x] seniors_screen.dart refaktorirano
  - [x] dashboard_screen.dart refaktorirano
  - [x] add_senior_screen.dart + edit_senior_screen.dart — shared mixin

---

## Sljedeći koraci (Next Steps)

Pogledaj [ROADMAP.md](ROADMAP.md) za prioritizirane buduće zadatke.
