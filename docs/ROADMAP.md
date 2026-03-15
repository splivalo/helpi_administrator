# Helpi Admin – Roadmap

> Zadnja izmjena: 2026-03-15

## TODO (čeka potvrdu)

- [ ] **Suspenzija — auto-otkazivanje narudžbi (backend)** — Frontend admin app VEĆ otkazuje narudžbe lokalno (MockData) pri suspenziji. Backend `SuspendUserAsync` u `SuspensionService.cs` MORA napraviti isto: dohvatiti sve Order-e tog korisnika sa statusom Active/Processing, postaviti ih na Cancelled, otkazati sve scheduled sesije (JobInstance → Cancelled). Bez toga će pri backend integraciji narudžbe ostati aktivne unatoč suspenziji.
- [ ] **Suspenzija — API middleware blokada (backend)** — Suspendirani korisnici mogu i dalje koristiti API. Potreban middleware ili auth check koji blokira sve API pozive suspendiranog korisnika (osim GET suspension statusa).
- [ ] **Suspenzija — notifikacije (backend + app)** — Kad se korisnik suspendira: (1) push notifikacija korisniku, (2) notifikacija povezanim korisnicima (npr. senioru čiji je student suspendiran), (3) email obavijest.
- [ ] **Suspenzija — "suspendirani" ekran u helpi_app** — Kad suspendirani korisnik otvori aplikaciju, treba vidjeti dedicirani ekran s razlogom suspenzije i kontakt informacijama, umjesto normalnog UI-ja.
- [ ] **Suspenzija — provjera prije kreiranja narudžbe (backend)** — Backend ne provjerava je li korisnik suspendiran prilikom kreiranja nove narudžbe. Dodati provjeru u CreateOrder flow.
- [ ] **Suspenzija — aktivacija cleanup (backend)** — Kad se korisnik aktivira nakon suspenzije, razmotriti treba li automatski ponovo aktivirati prethodno otkazane narudžbe ili kreirati nove.
- [ ] **Backend integracija** — Zamjena MockData s REST API pozivima. Definiranje API endpointova, autentifikacija (JWT), error handling. Ovo je GLAVNI preostali zadatak.
- [ ] **State management** — Uvesti Riverpod ili Bloc za state management umjesto lokalnog StatefulWidget stanja. Potrebno za backend integraciju.
- [ ] **Per-user preferencije** — Kad se doda auth, SharedPreferences ključeve proširiti s userId (npr. `gridView_orders_userId123`) tako da svaki admin ima svoje postavke.
- [ ] **Blagdani (javni praznici)** — Definirati listu hrvatskih blagdana i integrirati u obračun sati. Sati odrađeni na blagdan trebaju koristiti `sundayHourlyRate` (11.10 €) umjesto redovne satnice. Potrebno odlučiti: hardkodirana lista RH blagdana ili konfigurabilan popis iz backenda.
- [ ] **Notifikacije (push)** — Push notifikacije za administratora (nova narudžba, istek ugovora, otkazana sesija). Trenutno su notifikacije samo lokalne mock.
- [ ] **Export podataka** — PDF/Excel export za obračune, liste studenata, izvještaje.
- [ ] **Filteri na narudžbama** — Napredni filteri za narudžbe (po seniorima, studentima, datumu, statusu) — slično studenti filter panelu.
- [ ] **Lokacija/mapa** — Prikaz lokacija seniora/studenata na mapi za optimizaciju dodjele.
- [ ] **Dark mode** — Podrška za tamnu temu.

## Dovršeno

- [x] **Projekt scaffold** — Flutter 3.10.7+, Material 3, responzivni shell (2026-02)
- [x] **Svih 5 ekrana** — Dashboard, Studenti, Seniori, Narudžbe, Chat (2026-02)
- [x] **i18n sustav** — AppStrings Gemini Hybrid pattern, HR + EN, locale switching rebuilda ekrane (2026-02 → 2026-03-05)
- [x] **Mock podaci** — Kompletni mock podaci za sve entitete uklj. 6 seniora i notifikacije (2026-02 → 2026-03-04)
- [x] **Responzivni gumbi** — 1/3 širine na ≥800px, full-width na mobilnom (2026-03-04)
- [x] **Date picker optimizacija** — Zamjena showDateRangePicker s dva showDatePicker (2026-03-04)
- [x] **UI polish** — Order kartice styling, italic fix, boja ikone (2026-03-04)
- [x] **Dead code cleanup** — Uklonjeno 10 nekorištenih konstanti/stringova, 0 errors (2026-03-04)
- [x] **Dokumentacija** — docs/ folder s PROGRESS, ROADMAP, ARCHITECTURE, PROJECT_HISTORY (2026-03-04)
- [x] **DRY refactor cijele aplikacije** — 7 ekrana refaktorirano, 6 shared fajlova kreirano, ~1000+ linija duplikata uklonjeno (2026-03-04)
- [x] **Contact actions fix** — PhoneCallButton/EmailCopyButton trailing uz tekst, GestureDetector fix (2026-03-04)
- [x] **CreateOrderScreen** — Kompletna single-page forma za kreiranje narudžbe (1223 linija), senior pre-assignment, auto-scroll, session preview (2026-03-04)
- [x] **FAB "Dodaj narudžbu"** — Na listi narudžbi + "Dodaj narudžbu" gumb na senior detail ekranu (2026-03-04)
- [x] **Senior status business logika** — "U obradi" dok nema studenta → "Aktivan" kad ima (hasStudentAssigned) (2026-03-04)
- [x] **Studenti 7 tabova** — Prošireno s 3 na 7 (Svi/Aktivni/Ističe/Istekao/Bez/Deaktivirani/Arhivirani) (2026-03-04)
- [x] **Seniori 5 tabova** — Svi/U obradi/Aktivni/Neaktivni/Arhivirani (2026-03-04)
- [x] **Narudžbe 5 tabova** — Svi/U obradi/Aktivne/Završene/Otkazane + sortiranje (2026-03-04)
- [x] **Filter panel redesign** — DropdownButtonFormField, day chips full-width, konzistentni borderRadius/padding (2026-03-04)
- [x] **bodyLarge font unifikacija** — 18px → 16px za konzistentne TextField/Dropdown (2026-03-04)
- [x] **NotificationBell widget** — Bell ikona s badge + drawer s mock notifikacijama (2026-03-04)
- [x] **SharedPreferences persistencija** — Grid/sort/tab per screen, web-safe fallback, wired u 4 ekrana (2026-03-04)
- [x] **SessionPreviewSheet** — Shared widget za prikaz generiranih sesija i dodjelu studenta (851 linija) (2026-03-05)
- [x] **Edit Order modal** — Uređivanje narudžbi (usluga, frekvencija, datum, sati) (2026-03-05)
- [x] **Assign flow** — 2-step dodjela studenta s ClipRRect zaobljenim rubovima (2026-03-05)
- [x] **AlertDialog konzistentnost** — Svih 14 dialoga: dialogTheme, SizedBox(width:400), TextButton, AppStrings.ok (2026-03-05 → 2026-03-08)
- [x] **TextButton hover shape** — Globalni RoundedRectangleBorder(buttonRadius) umjesto stadium (2026-03-05)
- [x] **Reorder sheet spacing** — Uklonjen suvišni padding, header pattern ujednačen (2026-03-05)
- [x] **StatusBadge size** — Konzistentni mali badgevi u svim AppBarima (2026-03-05)
- [x] **ActionChipButton size enum** — small/medium za inline vs modal akcije (2026-03-05)
- [x] **Locale switching fix** — ValueKey rebuild za IndexedStack ekrane (2026-03-05)
- [x] **DatePicker globalna tema** — datePickerTheme: teal boje, manji header (20px), cardRadius, "U redu" umjesto "U REDU" (2026-03-05)
- [x] **Flutter Web deploy** — Build s `--base-href /helpi/`, deploy na kungfu.digital/helpi/ (2026-03-05)
- [x] **Promo kod (Stripe priprema)** — promoCode polje u OrderModel, AppStrings, prikaz u detaljima, admin akcija s dijalogom (2026-03-08)
- [x] **Dialog unifikacija** — dialogTheme u theme.dart, SizedBox(width:400) na svih 14 AlertDialoga (2026-03-08)
- [x] **Review comment scroll** — ConstrainedBox + SingleChildScrollView umjesto truncation (2026-03-15)
- [x] **Admin Notes (NotesSection)** — add/edit/delete bilješke u StudentDetail i SeniorDetail (2026-03-15)
- [x] **Suspension warning + auto-cancel** — Upozorenje o aktivnim narudžbama + automatsko otkazivanje pri suspenziji (2026-03-15)
- [x] **SuspensionStateManager listener fix** — addListener u initState() na list ekranima (2026-03-15)
- [x] **Tab hover boja** — tabBarTheme s neutralnim sivim overlayColor (2026-03-15)
- [x] **ContractStatus cleanup** — Uklonjeni deactivated + expiring tabovi/enum/filteri/badge (2026-03-15)
- [x] **Dashboard expiring → date-based** — active + expiryDate < 30 dana umjesto enum-based (2026-03-15)

---

> ⚠️ **STROGO ZABRANJENO** samoinicijativno započeti bilo koji zadatak s ovog Roadmapa. Svaki novi korak zahtijeva izričitu potvrdu korisnika.
