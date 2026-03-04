# Helpi Admin – Roadmap

> Zadnja izmjena: 2026-03-04

## TODO (čeka potvrdu)

- [ ] **Blagdani (javni praznici)** — Definirati listu hrvatskih blagdana i integrirati u obračun sati. Sati odrađeni na blagdan trebaju koristiti `sundayHourlyRate` (11.10 €) umjesto redovne satnice. Potrebno odlučiti: hardkodirana lista RH blagdana ili konfigurabilan popis iz backenda.
- [ ] **Backend integracija** — Zamjena MockData s REST API pozivima. Definiranje API endpointova, autentifikacija (JWT), error handling.
- [ ] **State management** — Uvesti Riverpod ili Bloc za state management umjesto lokalnog StatefulWidget stanja.
- [ ] **Notifikacije** — Push notifikacije za administratora (nova narudžba, istek ugovora, otkazana sesija).
- [ ] **Export podataka** — PDF/Excel export za obračune, liste studenata, izvještaje.
- [ ] **Filteri na narudžbama** — Napredni filteri za narudžbe (po seniorima, studentima, datumu, statusu).
- [ ] **Lokacija/mapa** — Prikaz lokacija seniora/studenata na mapi za optimizaciju dodjele.
- [ ] **Dark mode** — Podrška za tamnu temu.

## Dovršeno

- [x] **Projekt scaffold** — Flutter 3.10.7+, Material 3, responzivni shell (2026-02)
- [x] **Svih 5 ekrana** — Dashboard, Studenti, Seniori, Narudžbe, Chat (2026-02)
- [x] **i18n sustav** — AppStrings Gemini Hybrid pattern, HR + EN (2026-02)
- [x] **Mock podaci** — Kompletni mock podaci za sve entitete (2026-02)
- [x] **Responzivni gumbi** — 1/3 širine na ≥800px, full-width na mobilnom (2026-03-04)
- [x] **Date picker optimizacija** — Zamjena showDateRangePicker s dva showDatePicker (2026-03-04)
- [x] **UI polish** — Order kartice styling, italic fix, boja ikone (2026-03-04)
- [x] **Dead code cleanup** — Uklonjeno 10 nekorištenih konstanti/stringova, 0 errors (2026-03-04)
- [x] **Dokumentacija** — docs/ folder s PROGRESS, ROADMAP, ARCHITECTURE, PROJECT_HISTORY (2026-03-04)
- [x] **DRY refactor cijele aplikacije** — 7 ekrana refaktorirano, 6 shared fajlova kreirano, ~1000+ linija duplikata uklonjeno (2026-03-04)
- [x] **Contact actions fix** — PhoneCallButton/EmailCopyButton trailing uz tekst, GestureDetector fix (2026-03-04)

---

> ⚠️ **STROGO ZABRANJENO** samoinicijativno započeti bilo koji zadatak s ovog Roadmapa. Svaki novi korak zahtijeva izričitu potvrdu korisnika.
