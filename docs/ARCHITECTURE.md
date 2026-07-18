# Architecture — Nawa Tech HRM

Single canonical architecture document. See also [README](../README.md) and [DEMO](../DEMO.md).

## Overview

Three surfaces share one Laravel domain and database:

```text
┌─────────────────────┐     ┌──────────────────────┐
│ Filament Admin      │     │ Flutter Employee App │
│ web /admin          │     │ iOS / Android only   │
│ session + RBAC      │     │ Sanctum token        │
└──────────┬──────────┘     └──────────┬───────────┘
           │                           │
           ▼                           ▼
        ┌──────────────────────────────────┐
        │ Laravel (API /api + Services)    │
        │ Multi-tenant company_id · Queue  │
        └──────────────────┬───────────────┘
                           ▼
                     SQLite / MySQL
```

| Surface | Owns | Does not own |
|---------|------|--------------|
| Flutter | Employee login, attendance, leave, payslip, notifications, profile | Company admin CRUD, AI ops, billing |
| Filament `/admin` | Company/platform admin, HR workflows, settings, AI ops UI | Employee mobile UX |
| Laravel API + Services | Auth, tenancy, domain rules, webhooks, AI gateway | Client UI |

## Backend layering

- `backend/app/Http/Controllers/Api` — thin HTTP adapters
- `backend/app/Filament` — admin UI (Resources, Pages, Widgets)
- `backend/app/Services` — business actions (leave decide, payroll, onboarding, billing, AI)
- `backend/app/Models` — Eloquent + company scoping
- `backend/app/Jobs` — should call the same Services as sync endpoints

Golden rule: **one business action = one service method**; API, Filament, and Queue call it.

## Flutter layering

```text
lib/
  main.dart
  core/          # network, session, theme, router, shared widgets
  features/
    employee/    # auth, home, attendance, leave, payslip, notifications, profile
  l10n/
```

Employee repositories talk only to employee-scoped API routes. Demo mode (`ApiConfig.useApi = false`) returns offline sample data for local UI work.

## Multi-tenancy and RBAC

- Rows are scoped by `company_id`.
- Roles: `super_admin` (platform), `company_admin`, `hr_manager`, `hr`, `recruiter`, `employee`.
- Filament uses permission checks (`RequiresPermission`, `ScopesToCompany`).
- Employee API routes resolve the current employee via `users.id` ↔ `employees.user_id`.

## AI (activated)

- Gateway + middleware: `ai.enabled`, rollout, quota, plus per-permission gates (`ai.chat`, etc.).
- Admin AI ops live in Filament / split API controllers under `Http/Controllers/Api/Ai/`.
- Employee assistant lives in `lib/features/employee/assistant/` and is **on by default** (`ENABLE_EMPLOYEE_AI=true`); override with `--dart-define=ENABLE_EMPLOYEE_AI=false`.
- Cloud provider is selected per company (`ai_provider`) and calls the remote API when the server key is present (`OPENAI_API_KEY` / `GEMINI_API_KEY`); otherwise a deterministic bilingual fallback is returned, so the feature degrades gracefully without keys.
- Remote activation checklist: set the provider key in the server `.env`, keep the company on the enterprise plan with `ai_enabled=true`, and run the queue worker for async AI jobs.

## Testing and CI

- Backend: `.github/workflows/backend_ci.yml` → `php artisan test`
- Flutter: `.github/workflows/flutter_ci.yml` → `dart analyze` + `flutter test`
- Prefer approximate counts and CI badges over hard-coded numbers in docs.

## Honest scope

This is a portfolio HRM SaaS foundation: multi-tenant admin + employee mobile + AI scaffolding. Production payment, App Store push, and full AI ops still need environment-specific keys and product hardening before commercial launch.
