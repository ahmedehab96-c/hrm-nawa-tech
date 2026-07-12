# SaaS Trial Launch | إطلاق التجربة

> **Nawa Tech HRM** — multi-tenant HR platform ready for free trial signup.

---

## Quick start (3 terminals)

```bash
# 1) Laravel API (:8000) — runs from ~/Developer/hrm-nawa-api
chmod +x scripts/*.sh
./scripts/start_api.sh

# 2) Web admin (:3000)
./scripts/start_web_admin.sh

# 3) Employee iOS simulator (from ~/Developer/hrm-nawa-tech)
./scripts/start_employee_ios.sh
```

| Surface | URL / Device | Login |
|---------|--------------|--------|
| Landing | http://localhost:3000/welcome | — |
| Register | http://localhost:3000/register | new company (14-day trial) |
| Admin | http://localhost:3000/login | `admin@demo.com` / `Admin12345!` |
| Platform | http://localhost:3000/platform | `platform@nawatech.com` / `Platform12345!` |
| Employee | iPhone Simulator | `emp01@demo.com` / `Employee12345!` |

API: `http://127.0.0.1:8000/api` (auto-wired in debug for web + iOS sim).

**Physical phone:** Profile → Server → `http://<YOUR-LAN-IP>:8000/api`

---

## What is ready

| Feature | Status |
|---------|--------|
| Company self-registration (`/register`) | ✅ + 14-day `trial_ends_at` |
| Email verification | ✅ signed link + `email_unverified` gate |
| Employee plan limits | ✅ trial=10, starter=25, growth=100, enterprise=unlimited |
| Demo employees on new signup | ✅ (`demo.emp1.{id}@trial.local`) |
| Multi-tenant API (Laravel) | ✅ |
| Admin web + employee mobile | ✅ same API |
| Trial expiry middleware | ✅ `403` + `code: trial_expired` |
| Suspended company gate | ✅ `403` + `code: company_suspended` |
| Super-admin platform console | ✅ `/platform` + `GET/PUT /api/platform/*` |
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

### Platform console (super_admin)

- Login as `platform@nawatech.com` / `Platform12345!` → redirected to `/platform`
- List / search companies, suspend / activate, extend trial, manually set Starter / Growth
- API: `GET /api/platform/overview`, `GET/PUT /api/platform/companies/{id}`, `POST .../checkout`

### Billing scaffold

- Company admin: Settings → request Starter / Growth (`POST /api/billing/checkout`)
- Without Stripe keys → `501` + `code: billing_not_configured`
- Platform admin can activate plans with `provider=manual`

### Docker + optional MySQL

```bash
# Default (SQLite)
docker compose up --build

# MySQL profile
DB_CONNECTION=mysql docker compose --profile mysql up --build
```

---

## Phase 2 remaining

- Stripe / Moyasar live checkout + webhooks  
- Custom domains  

See also: [README.md](./README.md) · [DEPLOY.md](./DEPLOY.md)
