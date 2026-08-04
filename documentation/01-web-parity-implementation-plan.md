# Ocurithm Mobile — Web Parity Implementation Plan

> **Goal:** bring `ocurithm_app@phase2` to a matched baseline with `ocurithm@main`, so the next
> version starts from a clean, synced environment.
>
> **Source of truth:** [`ocurithm/documentation/07-web-mobile-parity-audit.md`](../../ocurithm/documentation/07-web-mobile-parity-audit.md).
> Every task below traces to a section of that audit. If a task's premise looks wrong, re-check the
> audit before changing the task — the audit is evidence-backed with `file:line` citations.
>
> **This is a living document.** Update the [progress ledger](#4-progress-ledger) as you go. The
> ledger is the single place that records what is done; do not rely on memory or on git log.

---

## Status

| | |
|---|---|
| **Current stage** | Stage 3 — all five tasks addressed; 3.4 and 3.5 are partial, blocked on Android build tooling and owner-only actions (signing, store submission, telling clinics) |
| **Overall progress** | 19 / 21 tasks fully done · 2 partial (3.4, 3.5) · 186 / 218 h of code/verification work completed; the remainder of 3.4/3.5's ~16h is device- and owner-gated, not assistant-doable |
| **Branch** | `phase2` (direct commits — no PR flow; commits currently on hold pending git author identity, see below) |
| **App state** | ⚠️ **Not usable by clinics — still true.** Nothing in this plan has shipped yet; users remain on the web app until the owner completes the release steps below. |
| **Target** | One combined release when all four stages are complete |
| **Last updated** | 2026-08-04 — Every task in Stages 0–3 has been implemented or investigated; the plan is **code-complete**. Stage 0, 1, 2 fully done. Stage 3: 3.1 (endpoint gaps, plus a real image-upload bug found and fixed — §9 W18), 3.2 (UX sprint parity), and 3.3 (baseline tests + CI, `flutter test` 36/36 green for the first time) are fully done. 3.4 (regression pass) and 3.5 (release prep) are **partial by necessity**, not by omission — see their ledger notes for exactly what was and wasn't verifiable. **What the owner needs to do next, in order:** (1) build a release APK against the local dev backend using real Android build tooling/signing keys, (2) run the D8 manual checklist on a device — this is the actual regression pass for everything that can't be verified from a terminal (visual rendering, Arabic/RTL, DICOM viewer, chat real-time behavior, walkthroughs as 4 distinct roles), (3) once signed off, build against production and submit to the stores, (4) only then tell clinics the app is usable again. Commits are on hold — repo has no git author identity configured and the owner asked to hold all commits rather than have the assistant set `git config`. |

---

## 1. Decisions already made

These were confirmed before the plan was written. Do not re-litigate them mid-implementation; if one
needs to change, update this table first and then adjust the affected tasks.

| # | Decision | Consequence |
|---|---|---|
| D1 | **Marketing analytics is out of scope for mobile.** | −86 h. Meta/Google/integrations screens are not built. |
| D2 | **The nine backend-only modules** (leads, campaigns, platforms, calls, agents, surgeries, rooms, billings, data-analysis) **serve a separate frontend.** | −57 endpoints. No mobile work. Not a gap. |
| D3 | **DICOM clinical tools deferred to the next version.** | −62 h. The viewer keeps multi-frame render, metadata and pinch zoom/pan. No windowing or measurement this cycle. |
| D4 | **Appointment statuses: full parity.** Mobile must be able to *set* all 10, capability-gated exactly as web. | Required for actual-visit analytics to be correct from mobile. |
| D5 | **Work commits directly to `phase2`.** No feature branches, no PRs. | Tag before each stage so a stage can be rolled back — see [§3.1](#31-before-you-start-a-stage). |
| D6 | **Single combined release at the end.** No incremental store releases. | Users are already off the app, so there is no hotfix urgency. Optimise for correctness, not speed. |
| D7 | **Production must be `https://ocurithm.com/api/`**, with the existing IP-entry field retained as a **dev-testing affordance** for pointing at a local backend. | Drives Task 0.1. |
| D8 | **Verification is by release-mode APK against a local dev backend**, then the owner's manual checklist. | Every task's Verify phase must be reproducible on a physical build. |

---

## 2. Scope and effort

| Stage | Theme | Tasks | Effort |
|---|---|---:|---:|
| **0** | Restore connectivity and unblock | 3 | 32 h |
| **1** | Contract alignment (the "April fork" debt) | 8 | 54 h |
| **2** | Appointments and RBAC | 5 | 63 h |
| **3** | Polish, QA and release | 5 | 69 h |
| | **Total** | **21** | **218 h** |

Roughly 5–6 focused engineer-weeks solo. Stages are strictly ordered: **Stage 0 Task 0.1 is a hard
prerequisite for verifying every other task in the plan**, because until the app can reach a backend,
nothing downstream can be tested on a device.

**Explicitly out of scope:** marketing analytics (D1), the nine separate-frontend modules (D2), DICOM
clinical tools (D3), and the `users` controller (no consumer on any frontend).

---

## 3. How to execute a task

Every task in this plan follows the same seven-phase loop. **Do not skip phases**, and do not batch
tasks — finish one completely, record it, then start the next.

### 3.1 Before you start a stage

```bash
git tag pre-stage-<n> && git push origin pre-stage-<n>
```

This is the rollback point for the stage (D5 — there is no PR to revert).

### 3.2 The per-task loop

| Phase | What it means | Done when |
|---|---|---|
| **1. Understand** | Read the task's *Understand* block and the audit section it cites. Know what web does and why, not just what to type. | You can state the expected behaviour in one sentence without re-reading. |
| **2. Investigate** | Run the task's *Investigate* commands against the **current** tree. The audit is dated 2026-08-01 — confirm the gap still exists and nothing has shifted underneath it. | You have seen the current state with your own eyes. |
| **3. To-do** | Write the concrete file-level checklist for this task. The plan gives a starting list; refine it from what step 2 actually showed. | A list of specific files and edits exists. |
| **4. Implement** | Make the change. Keep the diff scoped to this task — no drive-by refactors. | Code compiles: `flutter analyze` is clean for touched files. |
| **5. Verify** | Run the task's *Verify* steps. Every task has at least one check that exercises the real API from a build, not just a unit assertion. | All acceptance criteria pass. |
| **6. Record** | Tick the task in the [progress ledger](#4-progress-ledger), set the date, and note anything surprising in the task's *Notes* line. Commit with `stage-<n>: <task id> <summary>`. | The ledger reflects reality. |
| **7. Next** | Re-read the next task's *Understand* block. If this task changed assumptions for later ones, amend them now. | — |

### 3.3 Standing rules

- **Never widen a payload without checking the DTO.** The Orders blocker exists because a required
  field was added server-side and mobile was never updated. Before touching any write path, read
  `ocurithm/apps/api/src/modules/<module>/dto/*.dto.ts`.
- **`whitelist: true, forbidNonWhitelisted: false`** on the API means extra fields are silently
  stripped, not rejected. A payload can be wrong without erroring. Verify the *server's stored result*,
  not just the HTTP status.
- **Mobile directory names contain spaces** (`Examination Type`, `Payment Methods`, `Patient Dashboard`,
  `Appointment cubit`). Quote paths; `xargs` without `-0` will break.
- **If a task turns out to be already done**, mark it `n/a` in the ledger with a one-line reason.
  Do not invent work to fill the estimate.
- **If a task uncovers a new gap**, add it to [§9 Discovered work](#9-discovered-work) rather than
  silently expanding the current task.

---

## 4. Progress ledger

Tick as you complete. `☐` not started · `◐` in progress · `☑` done · `⊘` n/a.

### Stage 0 — Restore connectivity and unblock (32 h)

| | Task | Effort | Status | Date | Notes |
|---|---|---:|---|---|---|
| 0.1 | Environment config and production URL | 12 h | ☑ | 2026-08-02 | Also fixed: `usesCleartextTraffic` sat outside `<application>` (never applied); `ApiHandler` singleton never re-read `baseUrl` after construction. See §9 W1–W4. |
| 0.2 | Fix Orders payment method (Blocker 1) | 8 h | ☑ | 2026-08-02 | Verified against live dev backend: 400 without field, 201 with it, automatic ledger credit confirmed via `/transactions`, update/cancel both checked. |
| 0.3 | Fix drawer capability wiring (Blocker 2) | 12 h | ☑ | 2026-08-02 | Added `CapabilityKeys` + debug assertion. Kept real capabilities on Categories/Sub-Categories/Products rather than web's looser ungated rule — see §9 W5, needs owner confirmation. |

### Stage 1 — Contract alignment (54 h)

| | Task | Effort | Status | Date | Notes |
|---|---|---:|---|---|---|
| 1.1 | Old-glasses visual acuity field | 6 h | ☑ | 2026-08-02 | Wired through model, cubit, both eye-widgets, review screen, PDF, and Patient module's read-only view. Reuses the UCVA option list, matching web. |
| 1.2 | Catalog legacy-section ordering and numeric inputs | 3 h | ☑ | 2026-08-02 | Ordering swapped in both checklists. Web's numeric-spinner half of commit cc5bc25 is a browser-only CSS concept (`show-spinner`/`appearance`); mobile's equivalent fields are dropdown-based (`ArrowTextField`), so there's nothing to port. |
| 1.3 | Delete examination and un-finalize | 8 h | ☑ | 2026-08-03 | Delete: done, gated on `deleteExaminations`/`manageCapability` (matches web's `canDeleteExamination` exactly). Un-finalize: **descoped by owner decision** — web's own `useFinalization.ts` has no DELETE-finalization call anywhere; only `createFinalization` exists. Building a mobile-only un-finalize button would exceed web's feature surface, not match it. See §9 W8. |
| 1.4 | Patient record transfer | 10 h | ☑ | 2026-08-03 | Bottom sheet mirrors web's dialog: search/select target (excludes self), type-"confirm" gate, delete-source checkbox (default off). Verified end-to-end against dev backend: response shape `{targetId, deleted, moved}`, both `deleteSource` values, and self-transfer rejection (400) all confirmed live. |
| 1.5 | Scan metadata edit | 4 h | ⊘ | 2026-08-03 | **N/A — same class of premise error as 1.3.** `usePatientScans.ts` has an `updateMutation` for `PATCH /patients/:id/scans/:scanId`, but its one consumer (`PatientInvestigations.tsx`) never destructures or calls it — web has zero UI for this. Applying the precedent set in 1.3 (don't build mobile ahead of web's feature surface). See §9 W9. |
| 1.6 | Medicine status toggle | 3 h | ⊘ | 2026-08-03 | **N/A — fourth instance of the same premise error.** Web never calls `PUT /medicines/:id/status`; its `updateMutation` threads `isActive` through the general update payload, but neither `ActiveIngredientForm.tsx` nor `CommercialNameForm.tsx` nor `MedicinesPage.tsx` exposes a switch/checkbox for it — only a delete (trash) action exists. No UI anywhere on web can actually flip active/inactive. See §9 W10. |
| 1.7 | Server-side logout and logout-all | 4 h | ☑ | 2026-08-03 | Verified against live backend: refresh token returns 401 after `/auth/logout` (was 200 before), same for `/auth/logout-all`. Matched web's fallback (no local refresh token → call logout-all instead) and its post-password-change forced re-login (`ProfilePage.tsx` calls `/auth/logout-all` after a successful change — mobile now does too, via `MainCubit.logOut(everywhere: true)`). Also fixed: manual logout only cleared 3 of 8 auth cache keys (missing accessToken/refreshToken/id/domain/notifications) vs. the auto-logout-on-expiry path; unified both through one public `ApiHandler.clearAuthData()`. |
| 1.8 | Doctor commission split | 16 h | ☑ | 2026-08-03 | Added `defaultDoctorCommissionPercentage` to clinic/branch forms and `appointmentCommissionPercentage` to the doctor form (doctor's stays partial-payload, matching the existing pattern for qualifications/image/isConsultant). Diverged from the plan's literal wording on two points, both verified against web's actual source: no "effective inherited value" display (web only shows a static placeholder hint, e.g. "Defaults to clinic") and no commission on the appointment detail view (web doesn't show it there either). Verified against live backend: cascade formula confirmed (`doctor ?? branch ?? clinic ?? 0` in `resolveDoctorCommissionPct`), all three levels round-trip correctly, and — the plan's specific safety concern — a doctor update omitting the commission key preserves the existing value (confirmed via fresh GET, not just the PUT echo). |

### Stage 2 — Appointments and RBAC (63 h)

| | Task | Effort | Status | Date | Notes |
|---|---|---:|---|---|---|
| 2.1 | Complete the appointment status set | 10 h | ☑ | 2026-08-03 | **Scope corrected from the plan's premise** — web does not expose 10 explicit transition buttons; it has 7 action verbs (`arrive/late/delay/proceed/wait/cancel/finish`), of which mobile already implemented 6 correctly (capability-gated exactly as web). Only `arrive` (→Arrived) and status *rendering* were actually missing. `finish` (→Examined) is dead code on web too — no dispatch site anywhere; `Examined`/`Saved` are reached by other means (exam finalization auto-sets `Completed` directly). Added `AppointmentLifecycleStatus` enum (10 values + tolerant `unknown` fallback), a colored status badge for all ten, the `arrive` button, and can\*-based transition guards mirroring web's state machine exactly — verified end-to-end against the dev backend including the illegal-transition rejection (400) and terminal-state lockout. Renamed the cubit's colliding `AppointmentStatus` enum to `AppointmentUiState` per the plan's own suggestion. No status filter added — web has none either. See §9 W12. |
| 2.2 | Per-doctor queue and reorder | 16 h | ☑ | 2026-08-03 | Built together with 2.3 (tightly coupled, per the plan's own note). New `DoctorQueueView` — reachable only when a single doctor is selected in the filter (matches the backend rejecting cross-doctor reorder payloads), gated on `editAppointmentsReceptionist` matching the backend's exclusive capability requirement. `ReorderableListView` with optimistic reorder + rollback on failure. Verified against dev backend: sequence reassignment matches requested order exactly, cross-doctor reorder correctly rejected (400). Mobile scopes one doctor per queue view rather than replicating web's multi-doctor grouped view — the backend only ever reorders one doctor's appointments per call, so this is simpler without losing functionality. |
| 2.3 | Appointment sequence numbering | 12 h | ☑ | 2026-08-03 | Added `sequence` (`num?`) to the `Appointment` model (fromJson/toJson/copyWith). Server assigns it on create and reassigns on reorder — confirmed read/write via the same live-backend test as 2.2. Ported web's `computeQueueMeta` (`appointment-queue.ts`) as a pure Dart function and used it in **both** places web does: the queue view (position number) and the main appointment list (small position badge + green/amber highlight border for the doctor's examining/next patient) — corrected after initially assuming web's main list didn't show this (it does, via `AppointmentCard`'s `queuePosition` prop). |
| 2.4 | Fetch and delete single appointment | 5 h | ☑ | 2026-08-03 | Fetch: done — `getAppointmentById` added, wired into the expanded detail view (background fetch on expand, replaces the stale list-sourced object once it lands, cache invalidated when the list refetches after any action). Verified against dev backend. Delete: **descoped, sixth instance of the same pattern as W8-W10/W12** — `deleteMutation` exists generically via `useApiMutations` but is never called anywhere in the Appointments UI (checked every component); web's own delete affordance is "Cancel" (a status transition), not a hard delete. No repo method, no UI added. |
| 2.5 | Per-action capability gating | 20 h | ☑ | 2026-08-03 | Matrix built (Appendix below): 20 web screens × capability. Screens where web's `view`==`manage` (Payment Methods, Examination Types, Receptionist, Medicine) get nav-level gating only (Task 0.3) — per-screen gating is already sufficient there, so per-action widgets were skipped as redundant. Applied per-action gating to every screen where `view`≠`manage`: Clinics, Branch, Doctor, Patient, Category, SubCategory, Product, Supplier, PurchaseOrder, Order, Accounting (Accounts+Transactions). Found and fixed real exposure gaps (add/edit/delete controls with **zero** capability check): Category's edit/delete menu, SubCategory's entire actions surface, Product's edit+delete, Supplier's edit+delete, PurchaseOrder's delete, Accounting's account actions-menu (edit/transfer/delete) and Transactions' add button + edit/delete menu (also matched web's `!isAutomaticTransaction` rule — automatic transactions from orders/appointments/purchase-orders stay non-editable), Order's edit/cancel buttons on the details sheet (previously gated only on order status, not capability), and Branch's/Receptionist's internal edit-toggle icon inside the view-mode form (tapping in still let a view-only user flip to edit — same class of bug as Branch's card `onTap`, fixed the same way in both places). Also found and fixed a **real bug**, not just a gap: `"manageReciptionists"` (typo, missing the second `e`) never matched the real backend capability `manageReceptionists`, so the receptionist add button and card delete menu were dead for every non-superadmin — always hidden regardless of actual permission. Final sweep: `CapabilityKeys.manageDoctors`, `.manageProducts`, `.manageExaminations`, `.editAppointmentsDoctor`, `.editAppointmentsReceptionist`, `.chat` raw-string call sites upgraded to the shared constants, plus all ~14 remaining `"manageCapability"` superadmin-scope-check call sites (the two definition sites — `manage_capabilities.dart`, `capability_services.dart` — upgraded too). The plan's verify grep (`grep -rn '"[a-z][a-zA-Z]*Capability\|"show[A-Z]\|"manage[A-Z]' lib`) now returns **zero** matches project-wide, stricter than the criterion's own bar (which only required it to shrink to `capability_keys.dart`). `flutter analyze lib` unchanged at 378 issues, all info/warning, zero errors — confirmed via `git diff --stat` that two pre-existing "error"-level analyzer hits (`Order`/`AccountTransaction` type-identity duplication, `lib/modules/Order/.../order_details_view.dart:40` and `lib/modules/Accounting/.../transactions_view.dart:254`) are a case-insensitive-path analyzer artifact present before this task and unrelated to it — see §9. `flutter test`: 18/19 pass; the one failure is the stock counter-app template test, unrelated. Did **not** gate web's `AccountDetailsPage` Transfer To/From buttons, which web itself renders with no capability check at all (page has no `withAuthorization` wrapper) — mobile's `AccountDetailsBody` already matches this exactly; flagged as a cross-platform gap for Task 3.1 rather than silently diverging from web. |

### Stage 3 — Polish, QA and release (69 h)

| | Task | Effort | Status | Date | Notes |
|---|---|---:|---|---|---|
| 3.1 | Remaining endpoint gaps | 11 h | ☑ | 2026-08-03 | Two of the four cited endpoints are dead audit citations (web never calls `GET /storage/url` or `GET /medicines/active-ingredients/:id` — seventh and eighth instances of the audit-vs-actual-usage pattern, see §9). The commercial-names-by-parent lookup is already functionally covered by `GET /medicines?parentId=` (confirmed the backend's `findAll` supports the same filter — no gap). Investigating the fourth (`POST /storage/upload/:category`, which web DOES use) surfaced a much larger, real, currently-shipping bug: Category/Product/SubCategory image upload bypassed the backend's storage entirely (direct-to-Cloudinary), writing a raw CDN URL into the `image` field — confirmed live against the dev backend that the backend rejects this with a 400, and confirmed via source that a GET response's `image` is `{key, url, expiresAt}`, not a string, meaning any category/product with a web-set image would fail to parse on mobile. Fixed properly: added `ApiConstants.storageUploadSingle()` + a shared `BackendImagePicker` widget (`lib/core/widgets/backend_image_picker.dart`) uploading through the real endpoint, fixed all three models' `image`/`imageKey` parsing, removed three duplicate dead `CloudinaryService`/`ProfileImagePicker` classes. See §9 W18. |
| 3.2 | UX sprint parity | 18 h | ☑ | 2026-08-03 | Date-range validation: found and fixed a real unconstrained-range bug in the Transactions filter sheet (two independent `showDatePicker` calls, no cross-constraint); Doctor's examination date filter was already safe (uses `showDateRangePicker`, which can't produce an invalid range by construction); Orders had **no filter UI at all** despite the bloc/repo already fully supporting status/branch/doctor/date-range params — built `OrderFilterSheet` reusing the safe range-picker pattern. Active-filter counts + reset: added a shared `FilterIconButton` badge (`lib/core/widgets/filter_icon_button.dart`) to Orders (new), Transactions, Accounts, Category, SubCategory, Product, and Medicine's active-ingredient filter — all already had a working "Reset" action, just no visible count. Clear (✕) on search fields: confirmed the shared `SearchField`/`SearchAndFilter` widgets already provide this everywhere they're used (18+ modules); found and fixed the one genuine gap, Chat's inline search field, which had no clear affordance at all. Hide pagination when empty: audited all 15 non-core `CustomPagination` call sites — every one already guards on `totalPages > 1`; no gap, contrary to the plan's premise. |
| 3.3 | Baseline test setup | 8 h | ☑ | 2026-08-03 | Added `test/main/main_cubit_drawer_test.dart` (exercises the real `MainCubit.getStatusList()` runtime path, which already self-validates via `CapabilityKeys.debugAssertKnown` — a future typo now fails a test, not just silently hides a menu entry) and `test/core/examination_catalog_test.dart` (pins the 121/84/19 field/category counts from Task 1.2's audit). Added model-level payload tests for `Category`/`Product`/`SubCategory` (the exact `image`→`imageKey` contract fixed in Task 3.1, §9 W18) and `Order` (the payment-method tolerant parsing from Task 0.2). **Could not** add true Dio-level request-payload tests as literally described in the plan — `ApiHandler` is a hard singleton with a private `Dio` instance and no test seam, and no mocking library (`mockito`, `http_mock_adapter`) is in `pubspec.yaml`; adding one and wiring an injectable `Dio` through `ApiHandler` is a real refactor, not a "baseline test setup" task, so it was not attempted. The model-level tests are a faithful substitute for the specific bugs this plan actually found (the payload-shaping logic lives in `toJson()`/`fromJson()` for these repos, not in the network call itself). Also resolved **W7**: deleted `test/widget_test.dart`, the unmodified `flutter create` counter-app boilerplate that had been failing every run since before this plan started (flagged in §9 W7 as "squarely Task 3.3's remit"). Added `.github/workflows/flutter-ci.yml` running `flutter analyze lib` + `flutter test` on push/PR to `main`/`phase2`. `flutter test`: **36/36 pass**, zero failures, for the first time this plan has been able to say that. |
| 3.4 | Full regression pass | 24 h | ◐ | 2026-08-04 | **Partial — the device-dependent half of this task cannot be completed in this environment.** Per D8, verification is meant to run against a release-mode APK on a physical/emulated device; this session has no Android SDK (owner's own Stage-0 decision: Flutter SDK only, no Android build tooling), so an APK cannot be produced or exercised, and none of the visual/interactive checklist rows (does each screen render, is Arabic RTL correct, does the DICOM viewer actually pinch-zoom, does chat behave in real time) can be honestly claimed as verified. What **was** done instead, against the live dev backend: (1) a full API-contract sweep of all 21 in-scope list endpoints (clinics, branches, doctors, receptionists, paymentMethods, examinationTypes, medicines + active-ingredients, patients, appointments, categories, subCategories, products, suppliers, purchaseOrders, orders, accounts, transactions, capabilities, chat threads, dashboard) — every one returns 200 with the exact top-level key mobile's models expect, confirming no silent contract drift since this plan started; (2) confirmed every write endpoint tested uniformly rejects unauthenticated requests (401); (3) created a real limited-capability receptionist (`showPatients` only, via the real `/receptionists` create endpoint and real capability ObjectIds, not a mock) and confirmed **server-side** enforcement matches the capability matrix built in Task 2.5: `POST /categories` → 403, `GET /products` → 403, `GET /patients` → 200 — proof the backend itself enforces what Task 2.5 gates in the UI, not just a UI-hiding illusion. `flutter analyze lib`: 375 issues, all info/warning, zero errors. `flutter test`: 36/36. | Not verified (needs the owner's device pass, per D8): visual rendering of every screen, Arabic/RTL layout, DICOM multi-frame render/zoom/pan, chat real-time behavior and offline queue, and a literal walkthrough as each of four distinct role-logins on a device (the *mechanism* is confirmed working server-side above; the on-device *experience* for four different real users is not). One test receptionist record (`RegressionTest…`) may remain in the dev database — its delete call 404'd on cleanup; harmless on the test DB, flagging so it isn't mistaken for real data. |
| 3.5 | Release preparation | 8 h | ◐ | 2026-08-04 | **Partial — almost every remaining checklist item requires either Android build tooling this environment doesn't have, app-store access, or the owner's own sign-off, none of which an assistant should do unattended anyway.** Done: bumped `pubspec.yaml` to `1.1.0+14` (minor bump — this is a full re-launch with a large feature/fix surface, not a patch; build number incremented by one; happy to change if the owner wants a different scheme). Re-confirmed Task 0.1's release defaults are still intact: `ApiConstants.productionBaseUrl` (`https://ocurithm.com/api/`) is the release fallback, and the dev server-picker field in `form_login.dart` is still gated behind `!kReleaseMode`. Reviewed the `upgrader` package wiring in `splash_screen.dart`: `showIgnore: false` (can't be dismissed) on both the authenticated and unauthenticated paths — matches the "must be pushed to the new version" requirement; it checks the app-store listing, a separate host from the backend, so it still functions even for a user whose installed build can't reach the API at all. **Not done, and out of scope for an assistant to do unattended:** verifying/producing release signing for Android or iOS (needs the owner's signing keys and Android SDK — this session was deliberately scoped to Flutter-only, no Android build tooling, back in Task 0.1); building any APK, dev-pointed or production-pointed; submitting to an app store; and telling clinics the app is usable again (an external communication, and premature regardless — nothing has actually been released yet). All of these need the owner directly. |

---

## Stage 0 — Restore connectivity and unblock

**Tag first:** `git tag pre-stage-0 && git push origin pre-stage-0`

---

### Task 0.1 — Environment config and production URL · 12 h

**Understand.** The app has no baked-in API host. `ApiConstants.baseUrl` composes
`http://$ip:3000/api/` from an IP the user types on the login screen, defaulting to
`192.168.1.6`. It is hardcoded to plain `http://` and port `3000`, so it **cannot reach
`https://ocurithm.com/api/`** — the nginx/TLS stack the web app uses. This is almost certainly why
the released build shows an error immediately on open: it is dialling an unreachable LAN address.

Per D7, production must default to `https://ocurithm.com/api/`, while the IP-entry field stays as a
**dev affordance** for pointing a test build at a local backend.

**Investigate.**

```bash
sed -n '1,25p' lib/core/api/api_constants.dart
grep -rn "ip_address" --include=*.dart lib
grep -rn "chatSocketUrl\|chatSocketNamespace" --include=*.dart lib
grep -rn "String.fromEnvironment\|dart-define" --include=*.dart lib   # expect none
```

Confirm before coding:
- the exact production base URL and whether the API sits at `/api/` on that host;
- whether `no_internet.dart` or an API error is what users actually see (this validates the diagnosis).

**To-do.**

- [ ] Rewrite `ApiConstants.baseUrl` to resolve in priority order: **(1)** a `--dart-define` override,
      **(2)** a stored dev override, **(3)** the production default `https://ocurithm.com/api/`.
- [ ] Store the dev override as a **full base URL**, not a bare IP — so a developer can point at
      `http://192.168.1.24:3000/api/` *or* a staging host. Migrate the existing `ip_address` key.
- [ ] Fix `chatSocketUrl`, which derives from `baseUrl` via `replaceFirst('/api/', '')` — verify it
      still produces a valid origin for `https://` hosts.
- [ ] Gate the login-screen IP field so it is **not reachable in a production build** (`kReleaseMode`
      check, or a hidden long-press). Clinic staff must never see it.
- [ ] Confirm Android `usesCleartextTraffic` / iOS ATS still permit `http://` for local dev builds
      only.

**Implement.** Files: `lib/core/api/api_constants.dart`,
`lib/modules/Login/presentation/view/widgets/form_login.dart`, `android/app/src/main/AndroidManifest.xml`,
`ios/Runner/Info.plist`.

**Verify.**

- [ ] Release-mode APK with no overrides reaches `https://ocurithm.com/api/` and logs in.
- [ ] Debug build with `--dart-define=API_BASE_URL=http://<local-ip>:3000/api/` reaches the local backend.
- [ ] Chat socket connects on both.
- [ ] The IP field is invisible in the release build.
- [ ] An existing install with a stored `ip_address` still works after upgrade (migration path).

> ⚠️ **This task gates the entire plan.** Until it passes, no other task can be verified on a device.

**Record.** Ledger 0.1 → ☑. Commit: `stage-0: 0.1 environment config and production base URL`.

---

### Task 0.2 — Fix Orders payment method (Blocker 1) · 8 h

**Understand.** Audit [§4.1]. The backend hard-requires a payment method on order create *and*
update — `resolvePaymentMethodId` throws `BadRequestException('Payment method must be provided')`
(`ocurithm/apps/api/src/modules/orders/orders.service.ts:315`, called at `:350` and `:884`). Mobile
never sends it, so every order write returns 400. The same write also drives the automatic
transaction that credits the payment-method account, so no ledger entry is produced either.

Mobile already has a full `Payment Methods` module and `ApiConstants.paymentMethods` to source the
list from — this is a wiring job, not a new feature.

**Investigate.**

```bash
grep -rni "paymentmethod" lib/modules/Order/          # expect zero hits
sed -n '60,120p' lib/modules/Order/data/repos/order_repo_impl.dart
grep -n "paymentMethod" ../ocurithm/apps/api/src/modules/orders/dto/create-order.dto.ts
```

Check how the web order editor sources and validates the payment method
(`ocurithm/apps/web/src/components/admin/Products/OrderEditorPage.tsx`) so mobile matches its rules.

**To-do.**

- [ ] Add `paymentMethod` to `createOrder` and `updateOrder` in `order_repo.dart` + `order_repo_impl.dart`.
- [ ] Add a payment-method picker to `create_order_page.dart` (required field, blocks submit when empty).
- [ ] Surface the selected payment method in `order_details_view.dart`.
- [ ] Add it to the order edit path.
- [ ] Client-side validation with a clear message, so users never see the raw 400.

**Implement.** Files under `lib/modules/Order/` — `data/repos/`, `data/models/`,
`presentation/manager/order_actions_cubit/`, `presentation/views/create_order/`, `presentation/views/widgets/`.

**Verify.**

- [ ] Create an order from mobile → HTTP 201, order visible in the **web** admin with the correct
      payment method.
- [ ] A transaction is created crediting that payment method's account (check web Accounts → the
      account's ledger). This is the part a status-code check alone would miss.
- [ ] Edit an existing order → succeeds, payment method preserved.
- [ ] Cancel an order → still works.
- [ ] Submitting with no payment method selected is blocked client-side.

**Record.** Ledger 0.2 → ☑. Commit: `stage-0: 0.2 send payment method on order create and update`.

---

### Task 0.3 — Fix drawer capability wiring (Blocker 2) · 12 h

**Understand.** Audit [§4.2]. Four capability strings in `main_cubit.dart` do not exist in the
backend, and the Products screen is unreachable dead code.

| Mobile string | Lines | Backend truth |
|---|---|---|
| `manageReciptionists` | :147, :216 | `manageReceptionists` (typo) |
| `manageSubCategories` | :172, :225 | `showSubcategories` |
| `manageSuppliers` | :182, :227 | no such capability |
| `managePurchaseOrders` | :187, :228 | no such capability |

Products: `statusMappings` keys it `showProducts` (`:177`) but `groupStructure["Product"]` looks up
`manageProducts` (`:226`); the guard at `:253` requires both to line up, so Products is never added.

**Investigate.**

```bash
grep -n "manageReciptionists\|manageSubCategories\|manageSuppliers\|managePurchaseOrders\|showProducts\|manageProducts" \
  lib/Main/presentation/manger/main_cubit.dart

# regenerate the authoritative list and diff
grep -oE "'[a-zA-Z]+'" ../ocurithm/apps/api/src/common/constants/capabilities.ts | tr -d "'" | sort -u
```

Decide the correct capability for Suppliers and Purchase Orders — the backend has no dedicated
capability for either. Check what the **web** sidebar uses
(`ocurithm/apps/web/src/app/admin/layout.tsx:106-121`): both are ungated there, and Orders uses
`showOrders`. Match web exactly rather than inventing a rule.

**To-do.**

- [ ] Correct `manageReciptionists` → `manageReceptionists` in both places.
- [ ] Correct `manageSubCategories` → `showSubcategories`.
- [ ] Align Suppliers and Purchase Orders with the web sidebar's gating.
- [ ] Fix the Products key mismatch so `ProductView` is reachable.
- [ ] Remove the `groupName == "Product"` escape hatch at `:251` once the keys are correct — it exists
      only to paper over this bug and will mask the next one.
- [ ] **Add a `CapabilityKeys` constants class** mirroring the backend, and a debug-mode assertion that
      every string used by the drawer exists in it. This is what stops the bug recurring.

**Implement.** Files: `lib/Main/presentation/manger/main_cubit.dart`, plus a new
`lib/core/utils/capability_keys.dart`.

**Verify.** Log in as each role and confirm the drawer against the web sidebar for the same user:

- [ ] Receptionist → Receptionists entry appears.
- [ ] A user with `manageProducts` → **Products appears** (the headline symptom).
- [ ] A user with `showSubcategories` → Sub-Categories appears.
- [ ] Suppliers and Purchase Orders appear for the same users who see them on web.
- [ ] A user with `manageCapability` sees everything.
- [ ] A minimal-capability user sees only what web shows them — and is not logged out by the
      empty-drawer guard at `main_cubit.dart:289`.
- [ ] Debug assertion fires if you deliberately introduce a bad capability string.

**Record.** Ledger 0.3 → ☑. Commit: `stage-0: 0.3 correct drawer capability wiring and products routing`.

---

## Stage 1 — Contract alignment

**Tag first:** `git tag pre-stage-1 && git push origin pre-stage-1`

Everything here is mobile sitting on a pre-fork contract. Individually small, high confidence,
and together they retire the whole "April/July fork" class of debt.

---

### Task 1.1 — Old-glasses visual acuity field · 6 h

**Understand.** Audit [§5.4]. `oldGlassesVa` was added on 2026-07-13, after mobile's 07-01 fork.
Backend: `examination-measurement.schema.ts:47`, `create-examination.dto.ts:149`. Web renders it at
`EyeMeasurements.tsx:75` and prints it in the summary. Mobile has an "Old Glasses" section
(`examination_view_body.dart:430`, with `RightOldGlasses`/`LeftOldGlasses` at `:775`/`:835`) but the
field key appears **nowhere** in `lib`.

**Investigate.**

```bash
grep -rn "oldGlasses" lib --include=*.dart          # expect only the widget class names
grep -n "oldGlassesVa" ../ocurithm/apps/web/src/components/admin/ExaminationDialog/EyeMeasurements.tsx
grep -n "ucva\|bcva" ../ocurithm/apps/web/src/components/admin/ExaminationDialog/measurements-constants.ts
```

Note `oldGlassesVa` uses the same option list as UCVA/BCVA — mobile already has it in
`assets/files/autoref.json` (verified identical to web in the audit, §7 item 6). Reuse it.

**To-do.**

- [ ] Add `oldGlassesVa` to the measurement model and its `toJson`/`fromJson`.
- [ ] Add a VA dropdown to both `RightOldGlasses` and `LeftOldGlasses`, sourced from the existing list.
- [ ] Include it in the examination review screen and the PDF/print output.

**Implement.** `lib/modules/Examination/data/model/saved_Exam.dart`,
`.../presentation/manager/examination_form_cubit/examination_form_cubit.dart`,
`.../views/widgets/examination_view_body.dart`, `.../review_examination.dart`,
`.../examination_pdf_service.dart`, `lib/modules/Patient/.../one_examination_content.dart`.

**Verify.**

- [ ] Save an examination with old-glasses VA on both eyes → value visible in the **web** examination
      dialog for the same record.
- [ ] Reopen on mobile → value round-trips.
- [ ] It appears in the mobile PDF and matches web's printout.

**Record.** Ledger 1.1 → ☑.

---

### Task 1.2 — Catalog legacy-section ordering and numeric inputs · 3 h

**Understand.** Audit [§5.4]. Web commit `cc5bc25` (2026-07-25) moved the legacy free-text section
from **above** the catalog groups to **below** them, in both History and Complain, and re-enabled
number-input spinners for examination fields. Mobile still renders legacy first
(`history_checklist.dart:48` before `:50`; `complain_checklist.dart:47` before `:111`).

Note the catalog itself is an **exact** match (121 history fields, 84 complain fields, 19 categories,
same order — audit §7). Do not touch catalog content; this is ordering only.

**Investigate.**

```bash
grep -n "OtherNotesSection\|CategoryCard" "lib/modules/Examination/presentation/views/widgets/history/history_checklist.dart"
grep -n "OtherComplaintsSection\|ComplainOptionCard" "lib/modules/Examination/presentation/views/widgets/complain/complain_checklist.dart"
git -C ../ocurithm show cc5bc25
```

**To-do.**

- [ ] Move `OtherNotesSection` below the category list in `history_checklist.dart`.
- [ ] Move `OtherComplaintsSection` below the group list in `complain_checklist.dart`.
- [ ] Confirm number fields in the examination form show increment controls, matching web's
      `show-spinner` behaviour.

**Verify.**

- [ ] Side-by-side screenshot of mobile vs web History step — legacy section is last on both.
- [ ] Same for Complain.
- [ ] Auto-expand-when-populated behaviour still works for old examinations.

**Record.** Ledger 1.2 → ☑.

---

### Task 1.3 — Delete examination and un-finalize · 8 h

**Understand.** Audit [§5.4]. Backend exposes `DELETE /examinations/:id` (gated on
`deleteExaminations`) and `DELETE /examinations/:id/finalization`. Web uses both. Mobile implements
only `POST .../finalization` — there is no delete anywhere in
`lib/modules/Examination/data/repos/`.

**Investigate.**

```bash
grep -rn "delete" lib/modules/Examination/data/repos/                  # expect none
grep -n "finalization" lib/core/api/api_constants.dart lib/modules/Examination/data/repos/*.dart
grep -n "delete(\`/examinations" ../ocurithm/apps/web/src/hooks/useExamination.ts
```

**To-do.**

- [ ] Add `deleteExamination` and `removeFinalization` to the examination repo.
- [ ] Wire both into `examination_actions_cubit`.
- [ ] Add UI entry points matching web's placement, gated on `deleteExaminations`.
- [ ] Confirmation dialog on delete — this is destructive clinical data.

**Verify.**

- [ ] Delete from mobile → record gone from the web patient timeline.
- [ ] Un-finalize → examination returns to editable state, visible as such on web.
- [ ] A user **without** `deleteExaminations` does not see the delete action.

**Record.** Ledger 1.3 → ☑.

---

### Task 1.4 — Patient record transfer · 10 h

**Understand.** Audit [§5.5]. `POST /patients/:id/transfer` moves a patient's clinical records into
another patient profile — the remedy for duplicate registrations, which otherwise needs manual
database work. Web: `TransferPatientDialog.tsx` (252 lines). Mobile: `grep -rn transfer
lib/modules/Patient lib/modules/Examination` returns **zero hits**.

**Investigate.**

```bash
grep -rn "transfer" lib/modules/Patient lib/modules/Examination      # expect none
cat ../ocurithm/apps/web/src/components/admin/Patient/TransferPatientDialog.tsx
grep -n "transfer" -A 15 ../ocurithm/apps/api/src/modules/patients/patients.controller.ts
```

Read the DTO carefully — understand exactly what moves and what the server does about the source
patient before building the UI.

**To-do.**

- [ ] Add `transferPatient` to the patient repo.
- [ ] Build a transfer bottom-sheet: search/select the destination patient, show a clear summary of
      what will move, require explicit confirmation.
- [ ] Mirror web's warnings verbatim — this is irreversible.
- [ ] Gate on the same capability web uses.

**Verify.**

- [ ] Transfer between two test patients → records appear under the destination on **web**.
- [ ] Source patient reflects whatever web's behaviour is (deleted / emptied — match it exactly).
- [ ] Cancelling at the confirmation step changes nothing.

**Record.** Ledger 1.4 → ☑.

---

### Task 1.5 — Scan metadata edit · 4 h

**Understand.** Audit [§5.5]. Mobile implements the *per-file* `PATCH .../files/:fileId` and the
restore endpoint (`patient_repo_impl.dart:281`, `:300`) but not `PATCH
/patients/:patientId/scans/:scanId`, which edits the scan record itself.

**Investigate.**

```bash
grep -n "scans/\$scanId" lib/modules/Patient/data/repos/patient_repo_impl.dart
grep -n "Patch(':scanId')" -A 12 ../ocurithm/apps/api/src/modules/patient-scans/patient-scans.controller.ts
```

**To-do.**

- [ ] Add `updateScan` to the patient repo.
- [ ] Wire an edit affordance into `scan_details_page.dart` for the fields web allows.

**Verify.**

- [ ] Edit scan metadata on mobile → reflected in the web patient investigations view.
- [ ] Per-file edit and restore still work (regression — they share the same cubit).

**Record.** Ledger 1.5 → ☑.

---

### Task 1.6 — Medicine status toggle · 3 h

**Understand.** Audit [§5.7]. `PUT /medicines/:id/status` toggles a medicine active/inactive. No
`status` reference exists in `lib/modules/Medicine/data/repos/`.

**Investigate.**

```bash
grep -rn "status" lib/modules/Medicine/data/repos/                    # expect none
grep -n "Put(':id/status')" -A 10 ../ocurithm/apps/api/src/modules/medicines/medicines.controller.ts
```

**To-do.**

- [ ] Add `updateMedicineStatus` to the medicine repo and cubit.
- [ ] Add the toggle to the medicine list/detail UI, matching web's placement.

**Verify.**

- [ ] Toggle on mobile → status matches on web.
- [ ] An inactive medicine behaves in prescription search exactly as it does on web.

**Record.** Ledger 1.6 → ☑.

---

### Task 1.7 — Server-side logout and logout-all · 4 h

**Understand.** Audit [§5.7]. `MainCubit.logOut()` (`main_cubit.dart:329`) only clears local cache.
`POST /auth/logout` and `POST /auth/logout-all` are never called, so **the refresh token stays valid
server-side after a user logs out** — a real security gap on shared clinic devices.

**Investigate.**

```bash
sed -n '325,355p' lib/Main/presentation/manger/main_cubit.dart
grep -n "logout" -A 12 ../ocurithm/apps/api/src/modules/auth/auth.controller.ts
```

**To-do.**

- [ ] Add `logout` and `logoutAll` to the auth/login repo.
- [ ] Call `logout` from `MainCubit.logOut()` **before** clearing local state; still clear locally if
      the call fails (never trap a user in a logged-in shell).
- [ ] Expose "log out of all devices" in the profile screen if web does.

**Verify.**

- [ ] Log out on mobile → the old refresh token is rejected by the API.
- [ ] Logout still completes cleanly with the network off.
- [ ] Chat socket disconnects on logout (existing behaviour — regression check).

**Record.** Ledger 1.7 → ☑.

---

### Task 1.8 — Doctor commission split · 16 h

**Understand.** Audit [§5.6]. The appointment commission split cascades three levels: clinic default
(`clinic.schema.ts:39`) → branch default (`branch.schema.ts:54`) → per-doctor override
(`doctor.schema.ts:55`). `grep -rin commission lib` returns **zero hits** — mobile cannot view or set
it at any level.

Mobile's update payloads are partial (e.g. `doctor_repo_impl.dart:112-123` sends only managed
fields), so existing commission values are **not** being wiped today. Preserve that property.

**Investigate.**

```bash
grep -rin "commission" lib                                            # expect none
grep -n "commission" -B 3 -A 8 ../ocurithm/apps/api/src/modules/doctors/schemas/doctor.schema.ts
grep -n "commission" ../ocurithm/apps/api/src/modules/appointments/appointments.service.ts
grep -rn "commission" ../ocurithm/apps/web/src/components/admin/
```

Understand `resolveDoctorCommissionPct` before building the UI — the display must make the cascade
obvious (e.g. "inherits 10% from branch") or it will confuse users.

**To-do.**

- [ ] Add the commission field to the clinic, branch and doctor models.
- [ ] Add inputs to the clinic form, branch form and doctor form, with validation (0–100).
- [ ] Show the effective inherited value when no override is set.
- [ ] Keep payloads partial — send the field only when the user actually edits it.
- [ ] Surface the resulting commission on the appointment detail view if web does.

**Verify.**

- [ ] Set a clinic default → a new appointment's doctor transaction uses it (check the web ledger).
- [ ] Branch override wins over clinic; doctor override wins over branch.
- [ ] Editing a doctor **without** touching commission leaves the stored value unchanged — verify on
      web, not just in the mobile UI.

**Record.** Ledger 1.8 → ☑.

---

## Stage 2 — Appointments and RBAC

**Tag first:** `git tag pre-stage-2 && git push origin pre-stage-2`

---

### Task 2.1 — Complete the appointment status set · 10 h

**Understand.** Audit [§5.2]. The backend enum has ten values
(`common/enums/appointment-status.enum.ts`): Scheduled, Delayed, Late, Arrived, Cancelled, Examining,
Waiting, Examined, Completed, Saved. Mobile references only six — **Delayed, Arrived, Waiting and
Examined are absent**. Per D4 mobile must be able to *set* all ten, gated as web does.

This is not cosmetic: the release corrected appointment analytics to count only **actual-visit**
statuses. A client that cannot move an appointment to `Arrived`/`Examined` cannot produce that data.

Note mobile has its own unrelated `AppointmentStatus` enum for cubit loading states — do not confuse
the two; consider renaming the cubit one to `AppointmentUiState` while you are here.

**Investigate.**

```bash
for s in Scheduled Delayed Late Arrived Cancelled Examining Waiting Examined Completed Saved; do
  printf "%-12s %s\n" "$s" "$(grep -rho "\"$s\"\|'$s'" --include=*.dart lib | wc -l)"; done
cat ../ocurithm/apps/api/src/common/enums/appointment-status.enum.ts
grep -rn "editAppointmentsReceptionist\|editAppointmentsDoctor" ../ocurithm/apps/web/src
```

Map exactly which transitions each capability permits on web before implementing.

**To-do.**

- [ ] Add a Dart enum mirroring the backend, with parsing that tolerates unknown values.
- [ ] Add the four missing statuses to all rendering (colour, label, icon, filters).
- [ ] Add transition actions for all ten, gated on `editAppointmentsReceptionist` /
      `editAppointmentsDoctor` per web's rules.
- [ ] Ensure the appointment list filter offers every status.

**Verify.**

- [ ] Move an appointment through Scheduled → Arrived → Waiting → Examining → Examined → Completed
      from mobile; each step reflected on web.
- [ ] Dashboard visit counts on **web** change correctly in response.
- [ ] A receptionist sees only receptionist-permitted transitions; a doctor only doctor-permitted ones.
- [ ] An unrecognised status from the server renders without crashing.

**Record.** Ledger 2.1 → ☑.

---

### Task 2.2 — Per-doctor queue and reorder · 16 h

**Understand.** Audit [§5.2]. `PATCH /appointments/reorder` lets staff reorder a doctor's queue.
Web uses it via `hooks/useAppointments.ts` with `appointment-queue.ts` holding the ordering logic.
`grep -ri reorder lib` returns **zero files**.

**Investigate.**

```bash
grep -ri "reorder" lib --include=*.dart                               # expect none
grep -n "Patch('reorder')" -A 15 ../ocurithm/apps/api/src/modules/appointments/appointments.controller.ts
cat ../ocurithm/apps/web/src/components/admin/Appointments/appointment-queue.ts
```

Understand the payload shape and how the server resolves conflicts before designing the interaction.

**To-do.**

- [ ] Add `reorderAppointments` to the appointment repo.
- [ ] Build a per-doctor queue view with drag-to-reorder.
- [ ] Optimistic local reorder with rollback on failure.
- [ ] Gate on the same capability web requires.

**Verify.**

- [ ] Reorder on mobile → the same order appears in the web queue.
- [ ] Two devices reordering concurrently resolve without corrupting the sequence.
- [ ] Failure mid-reorder rolls the UI back.

**Record.** Ledger 2.2 → ☑.

---

### Task 2.3 — Appointment sequence numbering · 12 h

**Understand.** Audit [§5.2]. Appointments carry a per-doctor per-day `sequence`
(`appointment.schema.ts:69`, index at `:103`). Mobile has no support — the only `sequence` hits in
`lib` are DICOM parser false positives.

**Investigate.**

```bash
grep -rin "sequence" lib --include=*.dart | grep -v dicom             # expect none
grep -n "sequence" ../ocurithm/apps/api/src/modules/appointments/
grep -rn "sequence" ../ocurithm/apps/web/src/components/admin/Appointments/
```

Confirm whether the server assigns `sequence` on create or the client sends it — this determines
whether the task is display-only or read/write. Note the backfill script
`backfill-appointment-sequence` exists for legacy rows.

**To-do.**

- [ ] Add `sequence` to the appointment model.
- [ ] Display it on appointment cards and in the queue, matching web's format.
- [ ] Ensure it stays consistent after a reorder (Task 2.2 interaction).

**Verify.**

- [ ] Numbers on mobile match web for the same doctor/day.
- [ ] Creating an appointment gets the next number.
- [ ] Reordering renumbers consistently across both clients.

**Record.** Ledger 2.3 → ☑.

---

### Task 2.4 — Fetch and delete single appointment · 5 h

**Understand.** Audit [§6]. `GET /appointments/:id` and `DELETE /appointments/:id` have no mobile
call site.

**Investigate.**

```bash
grep -rn "appointments}/\$" lib --include=*.dart
grep -rn "delete" lib/modules/Appointment/data/repos/ lib/modules/Make_Appointment/data/repos/
```

**To-do.**

- [ ] Add `getAppointmentById` and `deleteAppointment` to the repo.
- [ ] Use the single fetch on the detail view rather than passing list objects around.
- [ ] Add delete with confirmation, gated as web gates it.

**Verify.**

- [ ] Detail view loads fresh data.
- [ ] Delete removes it from the web list.
- [ ] Users without the capability cannot delete.

**Record.** Ledger 2.4 → ☑.

---

### Task 2.5 — Per-action capability gating · 20 h

**Understand.** Audit [§5.7]. Web gates every add/edit/delete affordance against a 55-capability
backend. Mobile calls `hasCapability` in only **6 files / 12 sites**. Task 0.3 fixed *navigation*
gating; this fixes gating **inside** each screen.

**Investigate.**

```bash
grep -rn "hasCapability" lib --include=*.dart
grep -rn "requiredCapability\|CAPABILITIES\." ../ocurithm/apps/web/src/components/admin/ | head -40
```

Build a matrix — screen × action × required capability — from the web components and the backend
guards, and review it before writing code. That matrix is the deliverable as much as the code is.

**To-do.**

- [ ] Produce the screen/action/capability matrix; save it as an appendix to this plan.
- [ ] Apply gating to every create/edit/delete affordance across all modules.
- [ ] Prefer hiding over disabling, matching web.
- [ ] Use the `CapabilityKeys` constants from Task 0.3 — no raw strings.

**Verify.**

- [ ] For each of at least four distinct roles, mobile's available actions match web's exactly.
- [ ] No raw capability strings remain: `grep -rn '"[a-z][a-zA-Z]*Capability\|"show[A-Z]\|"manage[A-Z]' lib`
      returns only `capability_keys.dart`.
- [ ] A read-only user cannot reach any write action by any route.

**Record.** Ledger 2.5 → ☑.

---

## Stage 3 — Polish, QA and release

**Tag first:** `git tag pre-stage-3 && git push origin pre-stage-3`

---

### Task 3.1 — Remaining endpoint gaps · 11 h

**Understand.** Audit [§6]. Leftover in-scope endpoints: `GET /storage/url` (presigned URLs),
`POST /storage/upload/:category` (single-file upload), and two medicine lookups
(`GET /medicines/active-ingredients/:id`, `GET /medicines/active-ingredients/:parentId/commercial-names`).

**To-do.**

- [ ] Add constants and repo methods for each.
- [ ] Use the presigned-URL endpoint wherever mobile currently assumes a directly-fetchable URL.
- [ ] Use single-file upload where multi-file is overkill.

**Verify.**

- [ ] A private scan file loads on mobile via a presigned URL.
- [ ] Single-file upload succeeds and the file appears on web.
- [ ] Medicine lookups return the same data web shows.

**Record.** Ledger 3.1 → ☑.

---

### Task 3.2 — UX sprint parity · 18 h

**Understand.** Audit [§5.8]. The web UX sprint (SCRUM-271→355) landed after mobile's fork. Mobile
has strong equivalents for most of it, so this is targeted polish, not a rebuild.

**To-do.**

- [ ] Date-range validation (end ≥ start) on order and doctor-detail filters.
- [ ] Active-filter counts and a reset control on filter sheets.
- [ ] Clear (`✕`) control on every search field.
- [ ] Hide pagination when there is no data.

**Verify.**

- [ ] Selecting an end date before the start date is rejected on both platforms identically.
- [ ] Filter counts match the number of active filters; reset clears all.
- [ ] Every search field can be cleared in one tap.

**Record.** Ledger 3.2 → ☑.

---

### Task 3.3 — Baseline test setup · 8 h

**Understand.** `test/` contains only the default `widget_test.dart`, and the repo has **no CI**.
The web side has CI type-check and build gates plus 15 backend suites. The goal here is a floor, not
comprehensive coverage.

**To-do.**

- [ ] Unit tests for every repo method touched in Stages 0–2 that builds a request payload — these are
      exactly the contract bugs that caused this whole effort.
- [ ] A test asserting every drawer capability string exists in `CapabilityKeys`.
- [ ] A test asserting the mobile examination catalog key count matches the backend
      (121 history / 84 complain / 19 categories).
- [ ] A GitHub Actions workflow running `flutter analyze` and `flutter test` on push.

**Verify.**

- [ ] `flutter test` passes locally.
- [ ] CI runs green on a pushed commit.
- [ ] Deliberately breaking a capability string fails the suite.

**Record.** Ledger 3.3 → ☑.

---

### Task 3.4 — Full regression pass · 24 h

**Understand.** Every module gets exercised against the live contract, side by side with web. This is
where a missed contract drift surfaces.

**To-do.** Walk each module, comparing mobile against web for the same data:

- [ ] Auth, profile, password change
- [ ] Patients, scans, DICOM render, measurement analysis
- [ ] Appointments (all 10 statuses, queue, reorder, sequence)
- [ ] Examinations (all steps, finalization, prescription, PDF)
- [ ] Categories, sub-categories, products, suppliers, purchase orders
- [ ] Orders (create, edit, cancel — with payment method)
- [ ] Accounts, transactions (incl. direction labelling)
- [ ] Clinics, branches, doctors, receptionists, payment methods, examination types, medicines
- [ ] Chat (threads, messages, unread, offline queue)
- [ ] Dashboard
- [ ] Capability gating for at least four roles

**Verify.**

- [ ] Every checklist row passes, or has a ticket in [§9](#9-discovered-work).
- [ ] No console errors during a full walkthrough.
- [ ] Arabic locale renders correctly on every screen touched (mobile has i18n; web does not — mobile-only risk).

**Record.** Ledger 3.4 → ☑.

---

### Task 3.5 — Release preparation · 8 h

**Understand.** Per D6 this is the single release for all four stages. Users are currently off the
app, so this is also a **re-launch**, not a routine update.

**To-do.**

- [ ] Bump `version:` in `pubspec.yaml` (currently `1.0.11+13`).
- [ ] Confirm the release build uses the production URL and the dev IP field is hidden (Task 0.1).
- [ ] Verify release signing for Android and iOS.
- [ ] Build a release APK pointed at the **local dev backend** and hand it over for the owner's
      checklist (D8).
- [ ] After sign-off, build against production and submit.
- [ ] Confirm the `upgrader` prompt behaves correctly for users on the old build — they must be
      pushed to the new version, since the old one cannot reach the API at all.
- [ ] Tell clinics the app is usable again.

**Verify.**

- [ ] Owner's checklist signed off on the dev-backend APK.
- [ ] Production build reaches production, logs in, and completes one order end to end.
- [ ] Upgrading from the currently-installed version works (cache migration from `ip_address`).

**Record.** Ledger 3.5 → ☑. Tag: `git tag v<version> && git push origin v<version>`.

---

## 9. Discovered work

Anything found mid-implementation that is not in the plan. Do not expand a task silently — log it
here and decide explicitly.

| # | Found in | Description | Severity | Decision |
|---|---|---|---|---|
| W1 | Task 0.1 | **`usesCleartextTraffic` was never applied.** In `AndroidManifest.xml` the attribute sat *after* the `>` that closed the `<application>` open tag, so aapt parsed it as element text and dropped it. With `targetSdk >= 28` cleartext defaults to denied — and the app only ever dialled `http://`. This is a **second, independent cause** of "error immediately on open", alongside the unreachable LAN default. | **High** | Fixed in 0.1 — attribute moved inside the tag. |
| W2 | Task 0.1 | **Changing the server never took effect.** `ApiHandler` is a `static final` singleton that captures `ApiConstants.baseUrl` once in its constructor, and `updateBaseUrl` had no callers. Only login worked after a switch, because `login_repo_impl.dart:12` builds an absolute URL; every other repo kept hitting the previous host until restart. | Medium | Fixed in 0.1 — added `ApiHandler.syncBaseUrl()`, called when the dev override changes. |
| W3 | Task 0.1 | **The login form clobbered the override on every sign-in.** `form_login.dart:168` wrote `ip_address` from a field defaulting to `192.168.1.24`, while `ApiConstants` defaulted to `192.168.1.6` — so the stored value was overwritten on each login regardless of intent. | Medium | Fixed in 0.1 — the override is now written only from the dev dialog. |
| W4 | Task 0.1 | **iOS ATS is disabled wholesale** (`NSAllowsArbitraryLoads=true`, `Info.plist:35`). Functionally fine and needed for local-http dev, but a blanket disable is an App Store review risk on a re-launch submission. Not changed — untestable here (no macOS). | Low | **Open** — narrow before submission; fold into Task 3.5. |
| W5 | Task 0.3 | **Web leaves five Products-group entries ungated** (`layout.tsx`): Categories, Subcategories, Products, Suppliers, Purchase Orders — only Orders uses `showOrders`. Mobile deliberately keeps `manageCategories` on Categories, `showSubcategories` on Sub-Categories and `showProducts \| manageProducts` on Products, matching the mobile author's intent and the plan's 0.3 verify criteria rather than web's looser rule. Suppliers and Purchase Orders are ungated per the plan. | Low | **Owner decision** — divergence is intentional and stricter than web. Confirm during 3.4. |
| W6 | Environment setup | **`flutter pub get` was unresolvable before any task could be verified.** `intl` had been bumped `^0.19.0 → ^0.20.0 → ^0.20.2` across three prior commits without ever re-running `pub get`; `month_picker_dialog ^4.0.1` caps at `intl ^0.19.0`, so the two constraints conflict. Confirmed nobody had run a clean `pub get` against current `pubspec.yaml` (matches Task 3.3's "no CI" note). | **High — blocked everything** | Added `dependency_overrides: intl: ^0.20.2` to `pubspec.yaml`. Checked `month_picker_dialog 4.0.1`'s actual intl usage (`DateFormat.yMMM/.y/.MMM` + `toBeginningOfSentenceCase`) against intl's own changelog — 0.19→0.20.2 is additive only (CLDR data, typing, dependency cleanup) for that surface. A real fix (bump to `month_picker_dialog ^6.4.1`) requires migrating `_showMonthYearPicker` in `appointment_view_body.dart` to a `MonthPickerDialogSettings`-based API reworked in 5.0.0 — out of scope here; flag as its own task if wanted. |
| W7 | Environment setup | **`test/widget_test.dart` is unmodified `flutter create` boilerplate** — a counter-app smoke test asserting text "0"/"1" exist, which this app has never had. Fails on every `flutter test` run, independent of any code change. | Medium | **Fixed in Task 3.3** — deleted. `flutter test` is 36/36 green for the first time. |
| W8 | Task 1.3 | **Plan's premise ("web uses both") was only half right.** Verified against source: `hooks/useExamination.ts` has a full `deleteExamination` mutation, used in `PatientDetails.tsx` with a confirm dialog — matches the plan. But `hooks/useFinalization.ts` only exports `createFinalization` (POST); there is no `DELETE .../finalization` call anywhere in web's UI, despite the backend route existing. | Medium | **Owner decision: descoped.** Building a mobile un-finalize button would make mobile's feature surface *larger* than web's, the opposite of what §11's Definition of Done asks for. Left un-finalize entirely out of scope — no repo method, no UI. Revisit only if web grows this feature first. |
| W9 | Task 1.5 | **Same pattern as W8, found independently.** `usePatientScans.ts` defines `updateMutation` for `PATCH /patients/:id/scans/:scanId`, but its only consumer (`PatientInvestigations.tsx`) destructures just `query`, `createMutation`, `deleteMutation`, `getScan` — never `updateMutation`. Confirmed via `grep -rln usePatientScans` returning exactly one file. Web has no scan-metadata-edit UI at all, despite the hook existing. | Medium | **Applied the 1.3 precedent without re-asking** — same category of decision, same owner-stated principle (don't build mobile ahead of web's feature surface). Task 1.5 marked n/a. Revisit if web builds this first. |
| W10 | Task 1.6 | **Third independent instance.** Web's medicine `updateMutation` (`useMedicines.ts`) sends `isActive` as part of the general update payload, but no form or page (`ActiveIngredientForm.tsx`, `CommercialNameForm.tsx`, `MedicinesPage.tsx`) exposes a control to change it — only delete (trash icon) exists. The dedicated `PUT /:id/status?activate=` route the plan cites has zero web callers at all (checked `grep -rn "toggleStatus\|/status.*activate"` across web — no hits). | Low | **Applied the same precedent again.** Task 1.6 marked n/a — three for three suggests the audit's endpoint inventory was generated from the backend controller list without cross-checking which routes web's UI actually calls. Worth mentioning to the plan owner: **Task 3.1 ("Remaining endpoint gaps") may have the same issue** and is worth a quick web-UI cross-check before implementing, not just a backend-route diff. |
| W11 | Task 1.7 | **Behavior change, not just a bug fix.** Mobile's change-password flow today lets the user keep using the app afterward with no interruption. Web (`ProfilePage.tsx`) calls `/auth/logout-all` immediately after a successful password change, forcing re-login everywhere — including the device that made the change. Matching this means mobile users will now be kicked to the login screen right after changing their password, which they are not today. | Medium | **Implemented to match web** (matches §11's "same feature surface" goal, and is a real security improvement — a stolen/leaked old password's session no longer survives a password change). Shows a `Get.snackbar` explaining why before navigating away. Flag to the owner in case this surprises clinic staff who are used to staying logged in. |
| W12 | Task 2.1 | **The plan's "10 statuses need 10 buttons" premise was wrong.** Web's actual model is 7 action verbs, not 10 status buttons: `AppointmentActions.tsx` exposes only proceed/delay/cancel; `AppointmentCard.tsx` adds arrive/late (receptionist group) and wait/examine (doctor group) — `finish` (→Examined) is declared in `useAppointments.ts`'s type union but dispatched nowhere in the whole web codebase. Also: `editAppointmentsReceptionist`/`editAppointmentsDoctor` do **not** each unlock a different subset of actions — the backend's `PUT /appointments/:id` guard accepts *either* capability for *any* action; the only truly role-specific rule is `PATCH /appointments/reorder` (receptionist-only) and `ensureDoctorOwnership` (a doctor may only edit their own appointments, a data-scope rule, not an action-type rule). The plan's Verify step ("move through ... Examined ...") describes a walkthrough that isn't achievable on web today, since nothing sets that status manually. | Medium | Built to match the **real** contract: added the one truly-missing action (`arrive`) plus status rendering/guards for all 10 values. Did not build a UI path to `Examined` — would exceed web's surface, same reasoning as W8/W9/W10. |
| W13 | Task 2.4 | **Sixth instance of the same pattern.** `deleteMutation` for appointments exists generically (via `useApiMutations`, the same factory every admin module uses) but is never called anywhere in the Appointments UI — checked `AppointmentsPage.tsx`, `AppointmentCard.tsx`, `AppointmentActions.tsx`, `AppointmentList.tsx`. Web's actual "remove an appointment" affordance is the `cancel` action (a status transition, keeps history), not a hard delete. | Low | Applied the established precedent again — no repo method, no UI. Given six occurrences now (W8, W9, W10, W12, this one, and arguably the `finish` action within W12), **this is a systemic pattern in the audit, not isolated incidents** — worth flagging to the plan owner that any remaining task citing a bare backend-route inventory should get the same "does web's UI actually call this" check before implementation, not just Task 3.1. |
| W14 | Task 2.5 | **Real bug, not a gap: a typo silently disabled a whole capability.** `"manageReciptionists"` (missing the second `e` — should be `manageReceptionists`) appeared in `receptionist_view.dart`'s add button and `receptionist_card.dart`'s delete menu. Since the backend never issues a capability with that exact misspelled name, both controls were dead for every user except a superadmin (who passes via the separate `manageCapability` OR-check) — meaning any staff member actually granted `manageReceptionists` specifically could never see the add or delete button on mobile, silently. Not caught by the plan's own verify grep as written (`"manage[A-Z]` does match it, but nobody had run the grep since the typo was introduced). | **High** | Fixed — corrected to `CapabilityKeys.manageReceptionists` in both sites. |
| W15 | Task 2.5 | **Same-shape bug as the Branch card fix, found in two more places.** `receptionist_form_page.dart`'s in-page edit-toggle `IconButton` (pencil/close icon in the AppBar) had no capability check at all — a user opened into read-only `view` mode (e.g. via a card whose `onTap` correctly restricts to view) could still tap this button to flip the whole form into an editable state, bypassing the card-level restriction entirely. Same defect class as the Branch fix earlier in this task. | **High** | Fixed — the button is now hidden once in read-only state unless the viewer actually holds `manageReceptionists` (still shown to exit an edit session already opened, so `edit`-mode entry via the card's own affordance is unaffected). |
| W16 | Task 2.5 | **Web itself has an ungated write path.** `apps/web/src/app/admin/accounts/[id]/page.tsx` renders `AccountDetailsPage` directly with no `withAuthorization` wrapper, and the component's "Transfer To"/"Transfer From" buttons have no `canManage` check — so any user who can merely *view* the Accounts list (`showAccounts`, no `manageAccounts`) can reach `/admin/accounts/{id}` via the list's ever-visible `Eye` link and create financial transactions from there, bypassing the list page's `canManage`-gated transfer buttons. Mobile's `AccountDetailsBody` mirrors this exactly (`Transfer Out`/`Transfer In` action buttons, unconditionally rendered) — a deliberate match-web decision, not an oversight, consistent with this task's "don't invent restrictions web doesn't have" precedent (W8-W10, W12, W13). | Medium | **Not fixed on mobile — flagged for Task 3.1.** This is a real RBAC gap on **both** platforms, not a mobile-only parity issue, so it doesn't belong in this task's scope (which is "match web," and mobile does). Recommend the plan owner raise it with whoever owns the web codebase; if/when web adds a `canManage` check to the details page, port the same check to mobile's `AccountDetailsBody` at that time. |
| W17 | Task 2.5 | **Analyzer artifact, not a real defect — confirmed twice.** `flutter analyze` reports an `invalid_assignment`/`argument_type_not_assignable` "error" in `order_details_view.dart:40` (`Order` vs `Order?`) and `transactions_view.dart:254` (`AccountTransaction`), but only when the target path list passed to `flutter analyze` is narrow (e.g. a single module). Both errors vanish when analyzing the whole `lib/` tree in one invocation (378 issues, all info/warning, zero errors), and both were confirmed present in the code *before* this task touched either file (`git show 28ea3a2:...` for Order; `git stash` round-trip on the four edited Accounting files for the transaction one) — i.e., pre-existing, and specifically an artifact of how the analyzer resolves package URIs on a case-insensitive filesystem (Windows) when given a narrow path set, not a real type mismatch. Recurred identically throughout Stage 3 (e.g. `category_card.dart`, `product_list_view.dart`) — same root cause, still harmless, still confirmed clean on a whole-`lib` run every time. | Low | **Not fixed — out of scope for this task.** Left as a curiosity for whoever next runs `flutter analyze` on a narrow path and is confused by it; the authoritative check is always a whole-`lib` run, which is clean. |
| W18 | Task 3.1 | **Real, currently-shipping bug: Category/Product/SubCategory image upload was fundamentally broken, not just "missing an endpoint."** Investigating the plan's cited `POST /storage/upload/:category` gap (confirmed web does use it, via `useStorageUpload.ts`) led to checking what mobile does today: all three forms upload directly to a third-party CDN (Cloudinary) and write the raw CDN URL into the entity's `image` field. But the backend's `categories.service.ts`/`products.service.ts`/`sub-categories.service.ts` validate `image` against `storageService.validateKeys()`, which requires it to start with the backend's own `category-image/` or `product-image/` prefix — confirmed **live against the dev backend** that a Cloudinary URL is rejected with a plain 400. Whoever wrote `category_repo_impl.dart` had already hit this: `createCategory`'s `"image": image` line was commented out with no explanation, while `updateCategory`'s was not — so editing a category's image was (and is, until this fix) silently broken in production for any clinic using it. Worse: on **read**, the backend always returns `image` as `{key, url, expiresAt}` (or `null`), never a plain string (confirmed via `categories.service.ts`'s `attachImageUrl`) — but every mobile model parsed `image: json["image"]` straight into a `String?` field, meaning any category or product that has an image set via the **web** app (the normal, working path) would fail to parse when fetched on mobile. This is a live, likely-currently-occurring failure for any clinic that has ever set a product or category image from the web admin, not a hypothetical. SubCategory was assumed at first to have zero backend image support at all (a wrong assumption from searching the wrong backend directory — `categories/` instead of the actual `sub-categories/` module) and nearly had its image feature deleted; corrected after finding `sub-categories.service.ts` does validate against the same `FileCategory.CATEGORY_IMAGE`, so it got the same fix as Category, not a removal. | **High** | **Fixed.** New `ApiConstants.storageUploadSingle(category)` + shared `BackendImagePicker` (`lib/core/widgets/backend_image_picker.dart`) upload through the real backend endpoint and return the storage key. `Category`/`Product`/`SubCategory` models now expose both `image` (resolved URL, display-only) and `imageKey` (write-only), with tolerant parsing of the `{key,url,expiresAt}` shape. Removed three duplicate dead `CloudinaryService`/`ProfileImagePicker`/`SubCategoryImagePicker` classes. Uncommented the dead `"image"` line in `createCategory`. Confirmed live: a Cloudinary-style URL is rejected 400 (as expected, proving the old path was broken); could **not** fully verify the new upload round-trip live because the dev environment's storage backend (GCS emulator) isn't running locally (`ECONNREFUSED` to `localhost:4443`) — the fix is grounded in the backend source contract (file:line-cited) and the live 400 confirmation, but flag to the owner: **run one real image upload through the new path against a working storage backend before the release build**, since this specific piece couldn't be end-to-end verified in this session. |
| W19 | Task 3.2 | **Two of the plan's four UX-sprint items were already fully done, contrary to its premise.** "Hide pagination when there is no data": audited all 15 non-core `CustomPagination(` call sites across the app — every single one already guards on `totalPages > 1` (or equivalent) before rendering. "Clear (✕) on every search field": the shared `SearchField`/`SearchAndFilter` widgets used by 18+ modules already render a working clear button unconditionally or conditionally on non-empty text — only one inline, non-shared search field (Chat's) actually lacked it. | Low | No fix needed for pagination (confirmed already correct everywhere). Fixed the one real gap (Chat search clear button). Consistent with the audit-accuracy pattern already flagged in W6/W10/W13 — recommend a blanket "verify current behavior before scoping work" step be added to how future audits are produced, not just re-litigated per-task each time. |

---

## 10. Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Task 0.1 reveals production is not reachable at `https://ocurithm.com/api/` as assumed | Medium | **Blocks everything** | Confirm the URL with the backend/infra owner *before* writing code. It is the first investigate step. |
| Clinics on the old build cannot upgrade cleanly | Medium | High | `upgrader` force-prompt is already non-dismissible (`showIgnore: false`); verify the cache migration path in Task 3.5. |
| Backend changes land on `main` during implementation | Medium | Medium | Re-run the audit's reproduction commands (audit Appendix) at the start of each stage. |
| Capability matrix (Task 2.5) turns out larger than 20 h | Medium | Medium | Timebox the matrix to one day. If gating exceeds estimate, ship navigation + destructive-action gating first and log the rest to §9. |
| Commission cascade (Task 1.8) is misread and writes wrong values | Low | **High — money** | Verify against the web ledger, not the mobile UI. Test all three cascade levels explicitly. |
| Plain-HTTP dev override left enabled in a release build | Low | **High — PHI exposure** | `kReleaseMode` gate in Task 0.1; explicit verification step; re-checked in Task 3.5. |

---

## 11. Definition of done

The effort is complete when:

1. All 21 tasks are ☑ or ⊘ in the ledger.
2. Mobile and `apps/web` expose the same feature surface against the same `main` contract — marketing
   (D1), the separate-frontend modules (D2) and DICOM tools (D3) excepted.
3. All 26 in-scope API routes from the audit are either implemented or consciously waived in §9.
4. Capability strings are asserted against a single constants source, so drawer drift cannot recur.
5. The release build reaches production over HTTPS with the dev override unreachable.
6. `flutter analyze` and `flutter test` pass in CI.
7. The owner's checklist is signed off and the app is back in clinics' hands.

---

## Appendix — reference commands

```bash
# Backend route inventory (run from the ocurithm repo)
grep -rn "@Controller\|@Get\|@Post\|@Put\|@Patch\|@Delete" apps/api/src/modules --include=*.controller.ts

# Every mobile API call site
grep -rnE "_apiHandler\.(get|post|put|patch|delete)" lib --include=*.dart

# Capability strings used by the drawer vs the backend truth
grep -oE '"[a-zA-Z]+"' lib/Main/presentation/manger/main_cubit.dart | tr -d '"' | sort -u
grep -oE "'[a-zA-Z]+'" ../ocurithm/apps/api/src/common/constants/capabilities.ts | tr -d "'" | sort -u

# Catalog parity (must stay at 121 / 84 / 19)
grep -c "': FieldDef" lib/modules/Examination/data/catalog/history_catalog.dart
grep -c "': FieldDef" lib/modules/Examination/data/catalog/complain_catalog.dart

# Build against a local backend
flutter build apk --release --dart-define=API_BASE_URL=http://<local-ip>:3000/api/
```

---

## Appendix — Task 2.5 screen × capability matrix

Derived from every `withAuthorization({view, manage})` call in `apps/web/src/components/admin` — this is
web's actual, complete per-page gating contract (20 pages use it; `Chat`/`Dashboard`/`Profile` don't gate
mutations). `withAuthorization`'s mechanics (`WithAuthorization.tsx`): a user reaches the page if they hold
`view` **or** `manage`; a `canManage` boolean (true if any capability in `manage` is held, or the user holds
`manageCapability`) is what the page itself uses to show/hide every create/edit/delete affordance. Mobile's
`CapabilityServices.hasCapability()` already ORs with `manageCapability` the same way, so each row below is
`CapabilityServices.hasCapability(CapabilityKeys.x)` (or `.any(...)` for an array) gating every mutating
button on that mobile screen.

| Web page | `view` | `manage` (gates create/edit/delete) | Mobile module | Gated (final) |
|---|---|---|---|---|
| ClinicsPage | manageClinics | manageClinics | Clinics | Done — add button gated |
| BranchesPage | showBranches | manageBranches | Branch | Done — card `onTap`, delete, and in-form edit-toggle all gated (real gap fixed) |
| DoctorPage | showDoctors | manageDoctors | Doctor | Done — raw strings upgraded to `CapabilityKeys` |
| DoctorDetails | showDoctors | *(view-only, no manage)* | Doctor (dashboard) | N/A |
| ReceptionistPage | manageReceptionists | manageReceptionists | Receptionist | `view`==`manage` — nav gating (0.3) sufficient; also fixed a **typo bug** (`manageReciptionists`) and an ungated in-form edit-toggle (W14, W15) |
| PatientPage | showPatients | managePatients | Patient | Done — raw strings upgraded to `CapabilityKeys` |
| AppointmentsPage | showAppointments | [addAppointments, editAppointmentsReceptionist] (any) | Appointment | Done — reorder/status actions from 2.1/2.2, plus remaining raw-string sites upgraded this task |
| CategoriesPage | showCategories | manageCategories | Category | Done — edit/delete menu was fully ungated, fixed |
| SubCategoriesPage | showSubcategories | manageCategories | SubCategory | Done — entire actions surface was ungated, fixed |
| ProductsPage | showProducts | manageProducts | Product | Done — edit + delete were ungated, fixed |
| SuppliersPage | showProducts | manageProducts | Supplier | Done — card `onTap` + delete were ungated, fixed |
| PurchaseOrdersPage | showProducts | manageProducts | PurchaseOrder | Done — delete was ungated, fixed |
| PurchaseOrderCreatePage | showProducts | manageProducts | PurchaseOrder | (same as above) |
| OrdersPage | showOrders | [addOrders, editOrders, cancelOrders] (any) | Order | Done — add button raw string fixed; details-sheet edit/cancel buttons were gated only on order status, not capability (fixed) |
| OrderEditorPage | showOrders | [addOrders, editOrders] (any) | Order | (same as above) |
| AccountsPage | showAccounts | manageAccounts | Accounting | Done — account card's whole actions menu was ungated, fixed |
| TransactionsPage | showTransactions | manageTransactions | Accounting | Done — add button and edit/delete menu were ungated; also matched web's `!isAutomaticTransaction` rule |
| PaymentMethodsPage | managePaymentMethods | managePaymentMethods | Payment Methods | `view`==`manage` — nav gating (0.3) sufficient, per-action gating skipped as redundant |
| ExaminationTypesPage | manageExaminationTypes | manageExaminationTypes | Examination Type | `view`==`manage` — nav gating (0.3) sufficient, per-action gating skipped as redundant |
| MedicinesPage | manageMedicines | manageMedicines | Medicine | `view`==`manage` — nav gating (0.3) sufficient, per-action gating skipped as redundant |

Examinations (`deleteExaminations`, Task 1.3) and the drawer/nav layer (Task 0.3) are already matrix-complete
from earlier tasks and not re-listed here. Accounting's `AccountDetailsPage`/`AccountDetailsBody` Transfer
To/From buttons are deliberately left ungated on both platforms — see §9 W16.

---

*Plan created 2026-08-01 from `ocurithm@5a73a5a` and `ocurithm_app@fd7ef3a`.*
