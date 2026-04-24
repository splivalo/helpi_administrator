# Helpi Admin - Project History

> Key implementation timeline and decision log.

## 2026-04-24 - Security Audit & Hardening

- IDOR protection added for schedule-assignment student endpoints.
- Exception middleware adjusted to avoid production info leakage.
- DomainException usage unified for business-level error handling.
- Hardcoded language strings replaced with localization keys.
- Raw exception rendering removed from coupon dialog UI.
- Sensitive debug logs removed from coupon payload path.
- Dead code and useless catch wrappers removed.

## 2026-04-24 - Sponsor System Closure

- Sponsor feature verified end-to-end and marked complete.
- Backend sponsor CRUD + logo upload endpoints confirmed.
- Admin settings sponsor management confirmed.
- App-side sponsor banner integration confirmed on required screens.
- Sponsor removed from TODO lists and moved to completed status.

## 2026-04-18 - Coupon Type Simplification

- Coupon types reduced to hour-based variants only.
- Related UI formatting and localization entries cleaned up.

## 2026-04-12 - Chat System Completion

- Backend chat entities/services/controllers/hub integrated.
- Admin chat UI migrated from mock to backend-driven flow.
- Real-time unread badge and message updates stabilized.

## 2026-04-04 - Settings + Dynamic Pricing

- Settings screen finalized with pricing and operational controls.
- Analytics formula aligned with v2 payout model.
- Travel buffer and student payout snapshots aligned with backend.

## 2026-03 to 2026-04

- Admin notifications upgraded to backend-driven SignalR flow.
- Reschedule/reassignment UX aligned with backend state machine.
- Responsive shell, i18n consistency, and shared widget cleanup completed.
