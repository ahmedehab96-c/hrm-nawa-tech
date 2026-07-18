# Portfolio summary — Nawa Tech HRM

One-page overview for recruiters and hiring managers.

## Elevator pitch

Full-stack HR platform: **Laravel Filament admin** + **Flutter employee app** + **REST API**, with multi-tenant SaaS foundations, RBAC, bilingual UI (AR/EN), automated tests, and AI-assisted HR workflows.

## My role

Solo full-stack implementation: architecture, backend API, Filament admin, mobile app, seed data, CI, Docker scripts, localization, and test coverage.

## What to look at first (5 minutes)

1. **README.md** — stack overview + links
2. **docs/ARCHITECTURE.md** — canonical system boundaries
3. **DEMO.md** — guided walkthrough + credentials
4. **Filament admin** — http://127.0.0.1:8000/admin (`admin@demo.com` / `Admin12345!`)
5. **Recruiter role** — `recruiter@demo.com` / `Recruiter12345!` (recruitment-only access)
6. **Flutter app** — `emp01@demo.com` / `Employee12345!`

## Technical highlights

| Area | Evidence |
|------|----------|
| Multi-tenancy | `company_id` scoping, platform console, trial/plan limits |
| RBAC | Roles, permissions, Filament `canAccess` by permission |
| HR domain | Attendance, leave decisions, payroll generation, performance, recruitment |
| i18n | Admin AR/EN + RTL; mobile AppStrings |
| Quality | 120+ backend + 80+ Flutter tests; GitHub Actions CI |
| DevOps | Docker, queue/scheduler scripts, `/api/health`, smoke test |
| AI | Optional OpenAI/Gemini with quotas, fallbacks, usage logs |

## Honest scope

- Portfolio demo with **SaaS foundations**, not a live commercial product
- Billing is **integration scaffold** (Stripe/Moyasar webhooks tested; live checkout not claimed)
- Public hosted demo and screenshot gallery are planned next steps

## Contact

**Ahmed Ehab Mohammed** — ahmed96it96@gmail.com · [GitHub](https://github.com/ahmedehab96-c/hrm-nawa-tech)
