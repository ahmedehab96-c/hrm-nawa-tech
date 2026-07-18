# SaaS Trial Launch | إطلاق التجربة

> **Nawa Tech HRM** — multi-tenant HR platform ready for free trial signup.

---

## Quick start (2 terminals)

```bash
# 1) Laravel API + Filament admin (:8000)
chmod +x scripts/*.sh
./scripts/start_api.sh

# 2) Employee iOS simulator
./scripts/start_employee_ios.sh
```

| Surface | URL / Device | Login |
|---------|--------------|--------|
| Admin (Filament) | http://127.0.0.1:8000/admin | `admin@demo.com` / `Admin12345!` |
| Register (trial) | http://127.0.0.1:8000/admin/register | new company (14-day trial) |
| Platform companies | http://127.0.0.1:8000/admin/companies | `platform@nawatech.com` / `Platform12345!` |
| Employee | iPhone Simulator / Android | `emp01@demo.com` / `Employee12345!` |
| Register (API) | `POST /api/register` | same trial flow for mobile/API clients |

API: `http://127.0.0.1:8000/api` (auto-wired in debug for mobile).

**Physical phone:** Profile → Server → `http://<YOUR-LAN-IP>:8000/api`

---

## What is ready

| Feature | Status |
|---------|--------|
| Company self-registration (`/admin/register` + `POST /api/register`) | ✅ + 14-day `trial_ends_at` |
| Filament company settings + AI command center | ✅ |
| Dashboard HR/AI stats widgets | ✅ |
| Leave approve/reject (row + bulk) | ✅ |
| Billing / plan upgrade (manual demo) | ✅ |
| Candidates pipeline actions | ✅ |
| Performance reviews + AI analyze | ✅ |
| HR reports overview + saved summaries | ✅ |
| Job candidates relation manager | ✅ |
| Email verification | ✅ signed link + `email_unverified` gate |
| Employee plan limits | ✅ trial=10, starter=25, growth=100, enterprise=unlimited |
| Demo employees on new signup | ✅ (`demo.emp1.{id}@trial.local`) |
| Multi-tenant API (Laravel) | ✅ |
| Filament admin web + Flutter employee mobile | ✅ same API / DB |
| Trial expiry middleware | ✅ `403` + `code: trial_expired` |
| Suspended company gate | ✅ `403` + `code: company_suspended` |
| Super-admin companies in Filament | ✅ `/admin/companies` |
| Billing scaffold | ✅ `POST /api/billing/checkout` (Stripe/Moyasar → 501) |
| Docker seed-on-empty only | ✅ `SEED_ON_START` flag |
| Optional MySQL | ✅ `docker compose --profile mysql` |
| Stripe / Moyasar live checkout | 🔜 next |

### Email verification

- Register sends a verification email (`MAIL_MAILER=log` locally → `storage/logs/laravel.log`).
- Link: `GET /api/email/verify/{id}/{hash}?signature=...`
- Resend: `POST /api/email/verification-notification` (auth)
- Demo accounts are pre-verified.

### Plan employee caps

| Plan | Max employees |
|------|----------------|
| trial | 10 |
| starter | 25 |
| growth | 100 |
| active / pro / enterprise | unlimited |

### Platform (super_admin)

- Login as `platform@nawatech.com` / `Platform12345!` → Filament `/admin`
- Companies resource: list / edit tenants, plans, trials
- API still available: `GET/PUT /api/platform/*`

### Billing scaffold

- Company admin: Settings via API → `POST /api/billing/checkout`
- Without Stripe keys → `501` + `code: billing_not_configured`
- Platform admin can activate plans with `provider=manual`

### Stack

| Layer | Tech |
|-------|------|
| Admin web | Laravel Filament (`/admin`) |
| Employee app | Flutter (iOS / Android) |
| Backend | Laravel API (`/api`) |
