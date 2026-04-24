# Helpi Admin – Roadmap

> Last updated: 2026-04-24

## 📖 For Sidney — What to Read

### Step 1 — This file (ROADMAP.md) — that's all you need

This file contains all remaining TODOs for all 3 repositories. **Read only this** — the rest are details for when you need them.

### Step 2 — If you're working on a specific module, open the corresponding file

| What you're doing                              | Open                                            |
| ---------------------------------------------- | ----------------------------------------------- |
| Backend (C#) — don't know what's implemented   | `helpi_backend / docs/PROGRESS.md`              |
| Backend — don't know DB schema or use cases    | `helpi_backend / README.md`                     |
| Backend — need test data / login credentials   | `helpi_backend / seeds/README.md`               |
| Admin app (Flutter web) — don't know structure | `helpi_administrator / docs/ARCHITECTURE.md`    |
| Mobile app (Flutter) — don't know structure    | `helpi_apps / docs/ARCHITECTURE.md`             |
| Asking "why is this solved this way?"          | `helpi_administrator / docs/PROJECT_HISTORY.md` |

### Never need to read (unless interested in history)

- `helpi_administrator / docs/PROGRESS.md` — just tracking completed tasks
- `helpi_apps / docs/PROJECT_HISTORY.md` — chronology of mobile app decisions

---

## TODO (awaiting confirmation)

### Integrations (backend code exists, need credentials + testing)

- [ ] **Stripe — production keys + e2e test** — Backend `StripePaymentService` fully implemented (CreateCustomer, ChargePayment, SetupIntent, SavePaymentMethod). Credentials `credentials/stripe.json` have DUMMY test keys. Need: (1) obtain real Stripe test keys, (2) test payment flow end-to-end (setup intent → save card → charge), (3) configure webhook endpoint in Stripe Dashboard, (4) Flutter app already has `StripePaymentController` integration.

- [ ] **Minimax — production credentials + e2e test** — Backend `MinimaxService` fully implemented (OAuth2, CreateCustomer, CreateIssuedInvoice, ProcessIssuedInvoice). Credentials `credentials/minimax.json` have DUMMY data. Need: (1) obtain real Minimax HR portal credentials (clientId, clientSecret, username, password), (2) verify organizationId, (3) test invoice generation flow, (4) review VAT rate (0%) and currency (EUR) settings.

- [ ] **Mailgun — production credentials + verified domain** — Backend `MailgunService` fully implemented (SendEmailAsync with HTML body + PDF attachments). Credentials `credentials/mailgun.json` have sandbox domain. Need: (1) obtain real API key, (2) verify sending domain in Mailgun, (3) test sending emails with invoice PDF, (4) review email template.

- [ ] **MailerLite — production API key + groups** — Backend `MailerLiteService` fully implemented (AddSubscriberAsync with group assignment). Credentials `credentials/mailerlite.json` have DUMMY key. Need: (1) obtain real API key from MailerLite dashboard, (2) create groups in MailerLite (welcome, contractNotifications), (3) test subscriber flow on registration.

- [ ] **Firebase — production service account + FCM test** — Backend `FirebaseService` fully implemented (GenerateCustomToken, SendPushNotification, AnonymizeUser). Credentials `credentials/helpi-firebase-service-account.json` have DUMMY service account (init skipped in Development mode). Need: (1) create Firebase project (or use existing), (2) download real service account JSON, (3) test FCM push notifications on device, (4) configure Firestore rules.

- [x] **Google Drive — student contract upload** — Backend `GoogleDriveService` implemented. Real credentials created, contract upload tested and working (naming: contractNumber-userId-year). ✅

### Suspension

- [x] **Suspension — auto-cancel orders (backend)** — Backend `SuspendUserAsync` ALREADY calls `CancelAllOrdersForCustomerAsync(userId)` for seniors and `ReassignExpiredContractJobs` for students. ✅

- [x] **Suspension — API middleware block (backend)** — `SuspensionCheckMiddleware.cs` returns 403 for suspended users. Skips auth/suspensions endpoints and admins. ✅ (2026-03-22, commit `a652bff`)

- [ ] **Suspension — notifications (backend + app)** — When user suspended: (1) push notification to user, (2) notification to related users (e.g., senior whose student is suspended), (3) email notice. ⚠️ Push depends on Firebase credentials.

- [x] **Suspension — "suspended" screen in helpi_app** — `suspended_screen.dart` shows suspension reason + contact info + delete account. `ApiClient` interceptor catches 403 and triggers suspension state. ✅ (2026-03-22, commit `5ca6a13`)

- [x] **Suspension — check before creating order (backend)** — `OrdersService.CreateOrderAsync()` checks `Senior→Customer→User→IsSuspended` at top. Throws `ForbiddenException` if suspended. ✅ (2026-03-22, commit `a652bff`)

### Admin app & infrastructure

- [ ] **Stripe fee from webhook (backend + frontend)** — Currently admin analytics "Helpi net" uses formula `1.5% + €0.25` (EEA standard). For non-EEA cards (Revolut UK etc.) Stripe charges 3.25% + €0.25, so formula underestimates fee for those transactions. **Plan**:
  1. Backend: add `StripeFee` (decimal) column to `PaymentTransaction` entity + migration
  2. Backend: in `StripeWebhookController` add handler for `charge.succeeded` event — extract actual fee from `Charge.BalanceTransaction.Fee` and save it
  3. API: return `stripeFee` field in session/payment DTO
  4. Frontend: read actual fee from API instead of formula in `analytics_screen.dart` (see `TODO(neto-exact)` comment)
  - **Reference**: Order #30 (€42) and Order #24 (€56) in Stripe dashboard have higher fee → non-EEA cards
  - **Impact**: Difference is minimal (~€0.74 per non-EEA transaction), but for 100% accuracy need this

- [ ] **Per-user preferences** — When auth is added, extend SharedPreferences keys with userId (e.g., `gridView_orders_userId123`) so each admin has their own settings.

- [x] **Backend integration** — DataLoader fetches all data from REST API in parallel, populates Riverpod providers. AppData serves only as static cache/intermediary. UI layer reads exclusively from providers. ✅ (long complete)

- [x] **Holidays (public holidays)** — `CroatianHolidays.cs` (backend) + `croatian_holidays.dart` (admin) — 13 fixed holidays + Computus algorithm for Easter Monday and Corpus Christi. `HangfireRecurringJobService` uses `isOvertimeDay = Sunday || CroatianHolidays.IsPublicHoliday(date)`. Label: "Increased rate" (not "Sunday"). ✅ (2026-03-22, commit backend `a652bff`, admin `742ff07`)

- [x] **Admin notifications (SignalR)** — 7 backend notifications (newStudent, newSenior, orderCancel, jobCancel, contractExpired, paymentSuccess, paymentFailed) + SignalR real-time delivery in admin app + icon/color mapping for each type. Does NOT depend on Firebase — uses SignalR WebSocket. ✅ (2026-03-23, backend commit `69aec15`, admin commit `adcad0f`)

- [x] **Filter & Assignment safety** — Block assignment on cancelled/completed orders, suspended students excluded from substitutes, "Substitute" hidden when no subs, faculty dropdown always visible, 60-day filter removed, availability labels updated. ✅ (2026-03-30)

- [x] **Chat unread badge infrastructure** — `unreadMessagesProvider`, SignalR `ReceiveMessage` handler, `Badge.count` on all 3 nav layouts (desktop/tablet/mobile), reset on chat tap. ✅ (2026-03-30)

- [x] **Reschedule flow rewrite (backend + frontend)** — 3-branch ManageJobInstance routing (simple/student-change/reassign), backend available-students endpoint, frontend async fetch, lightweight `_refreshOrder` (2→6 calls), student sort by distance fix. ✅ (2026-03-31)

- [x] **Server reachability detection** — `DataLoader.isServerReachable()`, 3-way `_checkExistingSession` (server-down vs expired-token vs OK), `_handleLogin`/`_handleServerBack` always proceed. ✅ (2026-03-31)

- [x] **Senior status centralization** — `seniorStatusStyle()` + `StatusBadge.senior()` factory, fixed AppBar bug (checked all orders instead of live only), orders sorted newest first, "Planned" badge per card. ✅ (2026-03-31)

- [ ] **Push notifications (Firebase FCM)** — Push notifications for mobile users (student app, senior app). ⚠️ Depends on Firebase credentials.

### Chat / Messages system ✅ COMPLETE (2026-04-12)

- [x] **Backend: Chat entities + migration** — `ChatRoom` and `ChatMessage` entities, DB migration applied.

- [x] **Backend: ChatController + ChatService** — CRUD for chat rooms, send/receive messages, auto-create admin room, welcome message. Endpoint: `api/chat`.

- [x] **Backend: ChatHub (SignalR)** — Real-time messages. `ChatHub` created + broadcast via `NotificationHub` (both apps connect to NotificationHub).

- [x] **Admin app: wiring** — `ChatModScreen` completely rewritten. `chat_api_service.dart` created. Providers rewritten (`AdminChatRoomsNotifier`, `AdminChatMessagesNotifier`). Mock data removed.

- [x] **Admin app: chat unread badge** — `UnreadMessagesNotifier`, SignalR `ReceiveChatMessage` listener, `Badge.count` on all 3 nav layouts, reset on chat tap. ✅

- [x] **helpi_app: replace mock chat** — `DirectChatScreen` (auto-open admin room), `ChatApiService`, `chatRoomsProvider`/`chatMessagesProvider`/`chatUnreadCountProvider`. Unread badge on both shells. WhatsApp-style bubbles. Sender name ("Helpi") displayed.

## Complete ✅

- [x] **Project scaffold** — Flutter 3.10.7+, Material 3, responsive shell (2026-02)
- [x] **All 5 screens** — Dashboard, Students, Seniors, Orders, Chat (2026-02)
- [x] **i18n system** — AppStrings Gemini Hybrid pattern, HR + EN, locale switching rebuilds screens (2026-02 → 2026-03-05)
- [x] **Mock data** — Complete mock data for all entities incl. 6 seniors and notifications (2026-02 → 2026-03-04)
- [x] **Responsive buttons** — 1/3 width on ≥800px, full-width on mobile (2026-03-04)
- [x] **Date picker optimization** — Replace showDateRangePicker with two showDatePicker (2026-03-04)
- [x] **UI polish** — Order card styling, italic fix, icon color (2026-03-04)
- [x] **Dead code cleanup** — Removed 10 unused constants/strings, 0 errors (2026-03-04)
- [x] **Documentation** — docs/ folder with PROGRESS, ROADMAP, ARCHITECTURE, PROJECT_HISTORY (2026-03-04)
- [x] **DRY refactor entire app** — 7 screens refactored, 6 shared files created, ~1000+ duplicate lines removed (2026-03-04)
- [x] **Contact actions fix** — PhoneCallButton/EmailCopyButton trailing text, GestureDetector fix (2026-03-04)
- [x] **CreateOrderScreen** — Complete single-page form for creating orders (1223 lines), senior pre-assignment, auto-scroll, session preview (2026-03-04)
- [x] **FAB "Add Order"** — On orders list + "Add Order" button on senior detail screen (2026-03-04)
- [x] **Senior status business logic** — "Processing" until no student → "Active" when has (hasStudentAssigned) (2026-03-04)
- [x] **Students 7 tabs** — Expanded from 3 to 7 (All/Active/Expiring/Expired/No Contract/Deactivated/Archived) (2026-03-04)
- [x] **Seniors 5 tabs** — All/Processing/Active/Inactive/Archived (2026-03-04)
- [x] **Orders 5 tabs** — All/Processing/Active/Completed/Cancelled + sorting (2026-03-04)
- [x] **Filter panel redesign** — DropdownButtonFormField, day chips full-width, consistent borderRadius/padding (2026-03-04)
- [x] **bodyLarge font unification** — 18px → 16px for consistent TextField/Dropdown (2026-03-04)
- [x] **NotificationBell widget** — Bell icon with badge + drawer with mock notifications (2026-03-04)
- [x] **SharedPreferences persistence** — Grid/sort/tab per screen, web-safe fallback, wired in 4 screens (2026-03-04)
- [x] **SessionPreviewSheet** — Shared widget for displaying generated sessions and student assignment (851 lines) (2026-03-05)
- [x] **Edit Order modal** — Edit orders (service, frequency, date, hours) (2026-03-05)
- [x] **Assign flow** — 2-step student assignment with ClipRRect rounded corners (2026-03-05)
- [x] **AlertDialog consistency** — All 14 dialogs: dialogTheme, SizedBox(width:400), TextButton, AppStrings.ok (2026-03-05 → 2026-03-08)
- [x] **TextButton hover shape** — Global RoundedRectangleBorder(buttonRadius) instead of stadium (2026-03-05)
- [x] **Reorder sheet spacing** — Removed excess padding, header pattern unified (2026-03-05)
- [x] **StatusBadge size** — Consistent small badges in all AppBars (2026-03-05)
- [x] **ActionChipButton size enum** — small/medium for inline vs modal actions (2026-03-05)
- [x] **Locale switching fix** — ValueKey rebuild for IndexedStack screens (2026-03-05)
- [x] **DatePicker global theme** — datePickerTheme: teal colors, smaller header (20px), cardRadius, "OK" instead of "OK" (2026-03-05)
- [x] **Flutter Web deploy** — Build with `--base-href /helpi/`, deploy to kungfu.digital/helpi/ (2026-03-05)
- [x] **Promo code (Stripe prep)** — promoCode field in OrderModel, AppStrings, display in details, admin action with dialog (2026-03-08)
- [x] **Dialog unification** — dialogTheme in theme.dart, SizedBox(width:400) on all 14 AlertDialogs (2026-03-08)
- [x] **Review comment scroll** — ConstrainedBox + SingleChildScrollView instead of truncation (2026-03-15)
- [x] **Admin Notes (NotesSection)** — add/edit/delete notes in StudentDetail and SeniorDetail (2026-03-15)
- [x] **Suspension warning + auto-cancel** — Warning about active orders + automatic cancellation on suspension (2026-03-15)
- [x] **SuspensionStateManager listener fix** — addListener in initState() on list screens (2026-03-15)
- [x] **Tab hover color** — tabBarTheme with neutral grey overlayColor (2026-03-15)
- [x] **ContractStatus cleanup** — Removed deactivated + expiring tabs/enum/filters/badge (2026-03-15)
- [x] **Dashboard expiring → date-based** — active + expiryDate < 30 days instead of enum-based (2026-03-15)
- [x] **Haversine distance** — Calculate km distance student↔senior, display in assign modal and reschedule picker (2026-03-18→19)
- [x] **Sort students by distance** — 3-level sort: availability → distance → rating (2026-03-19)
- [x] **Rating decimal fix** — toStringAsFixed(1) on all 8 locations in 5 files (2026-03-19)
- [x] **Planned sessions (projected sessions)** — Display planned sessions for Pending orders from schedule before student assignment (2026-03-20)
- [x] **Order Details cleanup** — Removed redundant sections (time, duration, schedule, address) from order details (2026-03-21)
- [x] **Riverpod state management** — flutter_riverpod ^2.6.1, 6 StateNotifier providers, 17 widgets migrated, reactive UI without manual refresh, 0 AppData references in UI layer (2026-03-22)
- [x] **Admin notifications + SignalR real-time** — signalr_netcore ^1.4.4, NotificationType enum 30 types, SignalRNotificationService with auto-reconnect, 7 icon/color mappings, notification parser fix (2026-03-23)
- [x] **Notification overhaul** — Backend FormatSafe fix, TranslateNotifications refactor (specialized branches for each type), NewOrderAdded localization, NotificationsFactory OrderId fix, translation key fix in DB (2026-04-05)
- [x] **Notification archive to Google Drive** — Single master `notifications-archive.csv`, find/download/append/update flow, 3 new GoogleDriveService methods, DI binding fix, CSV format Date/Title/Message (2026-04-05)
- [x] **Notification pill bar redesign** — Unified pill (✓✓|☁ Archive), hover animation (AnimatedSlide+AnimatedOpacity), tile interaction split (tap=read, icon=navigate), ListView bottom padding (2026-04-05)
- [x] **Sponsor system** — Backend entity + SponsorsController CRUD + file upload, Admin settings UI with file picker, App SponsorBanner widget on 2 screens (order_detail + job_detail), dark mode support, SVG+PNG/JPG/WebP support, AppStrings localization (2026-04-24) ✅

---

> ⚠️ **STRICTLY FORBIDDEN** to independently start any task from this Roadmap. Each new step requires explicit user confirmation.
