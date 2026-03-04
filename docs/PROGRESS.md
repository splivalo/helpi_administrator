# Helpi Admin – Progress

> Zadnja izmjena: 2026-03-04

## Ukupno stanje

| Modul                 | Status                                                      | Dovršenost |
| --------------------- | ----------------------------------------------------------- | ---------- |
| Auth (Login)          | ✅ UI gotov, mock login                                     | 90%        |
| Dashboard             | ✅ Kompletiran                                              | 95%        |
| Studenti – Lista      | ✅ Tabovi, pretraga, filteri, sortiranje                    | 95%        |
| Studenti – Detalj     | ✅ Profil, ugovor, obračun, dostupnost, narudžbe, recenzije | 95%        |
| Seniori – Lista       | ✅ Pretraga, filteri                                        | 95%        |
| Seniori – Detalj      | ✅ Profil, narudžbe, arhiviranje                            | 95%        |
| Seniori – Dodaj/Uredi | ✅ Forme kompletne                                          | 95%        |
| Narudžbe – Lista      | ✅ Tabovi, pretraga                                         | 95%        |
| Narudžbe – Detalj     | ✅ Sesije, dodjela studenta, reprogramiranje                | 95%        |
| Chat (Moderacija)     | ✅ Lista razgovora + poruke                                 | 90%        |
| Responsive Shell      | ✅ Mobile/Tablet/Desktop layout                             | 100%       |
| i18n (HR/EN)          | ✅ AppStrings Gemini Hybrid                                 | 95%        |
| Tema (HelpiTheme)     | ✅ Material 3, sve boje i dimenzije                         | 100%       |
| Mock Data             | ✅ Kompletni mock podaci                                    | 100%       |
| Backend integracija   | ❌ Nije započeta                                            | 0%         |

**Ukupna dovršenost frontenda: ~85%**

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

---

## Sljedeći koraci (Next Steps)

Pogledaj [ROADMAP.md](ROADMAP.md) za prioritizirane buduće zadatke.
