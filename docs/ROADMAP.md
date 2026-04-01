# Helpi Admin – Roadmap

> Zadnja izmjena: 2026-03-31 (Reschedule rewrite + server reachability + senior status centralization)

## 📖 Za Sidney-a — Što čitati

| GitHub repo (splivalo/) | Fajl                            | Sadržaj                                          |
| ----------------------- | ------------------------------- | ------------------------------------------------ |
| **helpi_administrator** | **docs/ROADMAP.md** (ovaj fajl) | **Svi preostali TODO-ovi (START HERE)**          |
| helpi_administrator     | docs/PROGRESS.md                | Admin app status (98% frontend done)             |
| helpi_administrator     | docs/ARCHITECTURE.md            | Admin tech stack, folder structure, UI standardi |
| helpi_administrator     | docs/PROJECT_HISTORY.md         | Kronologija odluka (Feb→Mart 2026)               |
| helpi_backend_v2        | docs/PROGRESS.md                | Backend task tracking (16 taskova ✅)            |
| helpi_backend_v2        | README.md                       | DB schema, use case flows, 19 LINQ queries       |
| helpi_backend_v2        | seeds/README.md                 | Test data, login credentials, promo codes        |
| helpi_apps              | README.md                       | App tech stack, Riverpod/SignalR info            |
| helpi_apps              | docs/ARCHITECTURE.md            | Folder structure, 64 fajlova, providers          |

---

## TODO (čeka potvrdu)

### Integracije (backend kod postoji, treba credentials + testiranje)

- [ ] **Stripe — produkcijski ključevi + e2e test** — Backend `StripePaymentService` potpuno implementiran (CreateCustomer, ChargePayment, SetupIntent, SavePaymentMethod). Credentials `credentials/stripe.json` imaju DUMMY test ključeve. Treba: (1) nabaviti prave Stripe test ključeve, (2) testirati payment flow end-to-end (setup intent → save card → charge), (3) konfigurirati webhook endpoint u Stripe Dashboard, (4) Flutter app već ima `StripePaymentController` integraciju.
- [ ] **Minimax — produkcijski credentials + e2e test** — Backend `MinimaxService` potpuno implementiran (OAuth2, CreateCustomer, CreateIssuedInvoice, ProcessIssuedInvoice). Credentials `credentials/minimax.json` imaju DUMMY podatke. Treba: (1) nabaviti prave Minimax HR portal credentials (clientId, clientSecret, username, password), (2) verificirati organizationId, (3) testirati invoice generation flow, (4) pregledati VAT rate (0%) i currency (EUR) postavke.
- [ ] **Mailgun — produkcijski credentials + verified domain** — Backend `MailgunService` potpuno implementiran (SendEmailAsync s HTML body + PDF attachments). Credentials `credentials/mailgun.json` imaju sandbox domain. Treba: (1) nabaviti pravi API key, (2) verificirati sending domain u Mailgun, (3) testirati slanje emaila s invoice PDF-om, (4) pregledati email template.
- [ ] **MailerLite — produkcijski API key + grupe** — Backend `MailerLiteService` potpuno implementiran (AddSubscriberAsync s group assignment). Credentials `credentials/mailerlite.json` imaju DUMMY key. Treba: (1) nabaviti pravi API key iz MailerLite dashboarda, (2) kreirati grupe u MailerLite (welcome, contractNotifications), (3) testirati subscriber flow pri registraciji.
- [ ] **Firebase — produkcijski service account + FCM test** — Backend `FirebaseService` potpuno implementiran (GenerateCustomToken, SendPushNotification, AnonymizeUser). Credentials `credentials/helpi-firebase-service-account.json` imaju DUMMY service account (init se preskače u Development modu). Treba: (1) kreirati Firebase projekt (ili koristiti postojeći), (2) download-ati pravi service account JSON, (3) testirati FCM push notifikacije na uređaju, (4) konfigurirati Firestore rules.
- [x] **Google Drive — student contract upload** — Backend `GoogleDriveService` implementiran. Pravi credentials kreirani, upload ugovora testiran i radi (naming: contractNumber-userId-year). ✅

### Suspenzija

- [x] **Suspenzija — auto-otkazivanje narudžbi (backend)** — Backend `SuspendUserAsync` VEĆ poziva `CancelAllOrdersForCustomerAsync(userId)` za seniore i `ReassignExpiredContractJobs` za studente. ✅
- [x] **Suspenzija — API middleware blokada (backend)** — `SuspensionCheckMiddleware.cs` vraća 403 za suspendirane korisnike. Preskače auth/suspensions endpointe i admine. ✅ (2026-03-22, commit `a652bff`)
- [ ] **Suspenzija — notifikacije (backend + app)** — Kad se korisnik suspendira: (1) push notifikacija korisniku, (2) notifikacija povezanim korisnicima (npr. senioru čiji je student suspendiran), (3) email obavijest. ⚠️ Push ovisi o Firebase credentials.
- [x] **Suspenzija — "suspendirani" ekran u helpi_app** — `suspended_screen.dart` prikazuje razlog suspenzije + kontakt info + delete account. `ApiClient` interceptor hvata 403 i trigera suspension state. ✅ (2026-03-22, commit `5ca6a13`)
- [x] **Suspenzija — provjera prije kreiranja narudžbe (backend)** — `OrdersService.CreateOrderAsync()` provjerava `Senior→Customer→User→IsSuspended` na vrhu. Throw-a `ForbiddenException` ako je suspendiran. ✅ (2026-03-22, commit `a652bff`)

### Admin app & infrastruktura

- [ ] **Backend integracija** — Zamjena AppData s REST API pozivima. Definiranje API endpointova, autentifikacija (JWT), error handling. Ovo je GLAVNI preostali zadatak.
- [ ] **Per-user preferencije** — Kad se doda auth, SharedPreferences ključeve proširiti s userId (npr. `gridView_orders_userId123`) tako da svaki admin ima svoje postavke.
- [x] **Blagdani (javni praznici)** — `CroatianHolidays.cs` (backend) + `croatian_holidays.dart` (admin) — 13 fiksnih praznika + Computus algoritam za Uskrsni ponedjeljak i Tijelovo. `HangfireRecurringJobService` koristi `isOvertimeDay = Sunday || CroatianHolidays.IsPublicHoliday(date)`. Label: "Povećana satnica" (ne "Nedjeljna"). ✅ (2026-03-22, commit backend `a652bff`, admin `742ff07`)
- [x] **Admin notifikacije (SignalR)** — 7 backend notifikacija (newStudent, newSenior, orderCancel, jobCancel, contractExpired, paymentSuccess, paymentFailed) + SignalR real-time delivery u admin app + icon/color mapping za svaki tip. NE ovisi o Firebase — koristi SignalR WebSocket. ✅ (2026-03-23, backend commit `69aec15`, admin commit `adcad0f`)
- [x] **Filter & Assignment safety** — Block assignment on cancelled/completed orders, suspended students excluded from substitutes, "Zamjena" hidden when no subs, faculty dropdown always visible, 60-day filter removed, availability labels updated. ✅ (2026-03-30)
- [x] **Chat unread badge infrastructure** — `unreadMessagesProvider`, SignalR `ReceiveMessage` handler, `Badge.count` on all 3 nav layouts (desktop/tablet/mobile), reset on chat tap. ✅ (2026-03-30)
- [x] **Reschedule flow rewrite (backend + frontend)** — 3-branch ManageJobInstance routing (simple/student-change/reassign), backend available-students endpoint, frontend async fetch, lightweight \_refreshOrder (2→6 calls), student sort by distance fix. ✅ (2026-03-31)
- [x] **Server reachability detection** — `DataLoader.isServerReachable()`, 3-way `_checkExistingSession` (server-down vs expired-token vs OK), `_handleLogin`/`_handleServerBack` always proceed. ✅ (2026-03-31)
- [x] **Senior status centralization** — `seniorStatusStyle()` + `StatusBadge.senior()` factory, fixed AppBar bug (checked all orders instead of live only), orders sorted newest first, "Planirano" badge per card. ✅ (2026-03-31)
- [ ] **Push notifikacije (Firebase FCM)** — Push notifikacije za mobilne korisnike (student app, senior app). ⚠️ Ovisi o Firebase credentials.

### Chat / Poruke sustav (NIŠTA ne postoji u backendu!)

- [ ] **Backend: Chat entiteti + migracija** — Kreirati `ChatRoom` i `ChatMessage` entitete u `Helpi.Domain`, DB migracija. Nema NI JEDNOG chat entityja u backendu trenutno.
- [ ] **Backend: ChatController + ChatService** — CRUD za chat rooms, send/receive poruke, lista razgovora. Endpoint: `api/chat`.
- [ ] **Backend: ChatHub (SignalR)** — Real-time poruke. Trenutno postoji samo `NotificationHub` (za push). Treba ili proširiti ili napraviti zasebni `ChatHub`.
- [ ] **Admin app: wiring** — `ChatModScreen` je UI-gotov (split-view, moderacija), ali čita iz `AppData.chatRooms` (prazan `[]`). `DataLoader` ima TODO comment. Treba: zamjena AppData → API pozivi.
- [x] **Admin app: chat unread badge** — `UnreadMessagesNotifier` provider, SignalR `ReceiveMessage` listener, red `Badge.count` on all 3 nav layouts (sidebar/rail/bottomnav), reset on chat tap. ✅ Infrastructure ready — needs backend ChatHub + Firebase to deliver real message events. (2026-03-30)
- [ ] **helpi_app: zamjena mock chata** — `senior_chat_list_screen.dart` i `student_chat_screen.dart` su identične kopije s hardkodiranim `_ChatMessage` listom (lokalni state, ne šalje ništa). Treba: pravi model, ChatService, SignalR konekcija.

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
- [x] **Haversine udaljenost** — Izračun km udaljenosti student↔senior, prikaz u assign modalu i reschedule pickeru (2026-03-18→19)
- [x] **Sortiranje studenata po udaljenosti** — 3-level sort: dostupnost → udaljenost → ocjena (2026-03-19)
- [x] **Rating decimal fix** — toStringAsFixed(1) na svih 8 lokacija u 5 fajlova (2026-03-19)
- [x] **Planirani termini (projected sessions)** — Prikaz planiranih sesija za Pending narudžbe iz rasporeda prije dodjele studenta (2026-03-20)
- [x] **Order Details cleanup** — Uklonjene redundantne sekcije (vrijeme, trajanje, raspored, adresa) iz detalja narudžbe (2026-03-21)
- [x] **Riverpod state management** — flutter_riverpod ^2.6.1, 6 StateNotifier providera, 17 widgeta migrirano, reaktivni UI bez manual refresha, 0 AppData referenci u UI sloju (2026-03-22)
- [x] **Admin notifikacije + SignalR real-time** — signalr_netcore ^1.4.4, NotificationType enum 30 tipova, SignalRNotificationService s auto-reconnect, 7 icon/color mappinga, notification parser fix (2026-03-23)

---

> ⚠️ **STROGO ZABRANJENO** samoinicijativno započeti bilo koji zadatak s ovog Roadmapa. Svaki novi korak zahtijeva izričitu potvrdu korisnika.
