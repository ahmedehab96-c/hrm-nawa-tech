# Live Demo for Portfolio | ديمو لايف للبورتفوليو

Goal: a public HTTPS URL so recruiters can try Filament admin + Laravel API without cloning the repo.

## Recommended host options

### A) Railway (paid after trial)
If your Railway trial expired, pick a Hobby plan at https://railway.app/account/billing then run:

```bash
railway login
railway init --name hrm-nawa-tech
railway add   # PostgreSQL
railway up
railway domain
```

### B) Render free (live now)

**Public URL:** https://hrm-nawa-api.onrender.com  
**Admin:** https://hrm-nawa-api.onrender.com/admin  
**API health:** https://hrm-nawa-api.onrender.com/api/health  
**Dashboard:** https://dashboard.render.com/web/srv-d9djnb77f7vs738q6ug0

Service: `hrm-nawa-api` · Blueprint from `render.yaml` (SQLite + `SEED_ON_START` for free tier).

Free web services on Render may sleep after inactivity; the first request can take ~30–60s. That is acceptable for portfolio demos.

To recreate elsewhere: New → Blueprint → connect `ahmedehab96-c/hrm-nawa-tech` → confirm `render.yaml`.

## Demo accounts (seeded)

| Role | Email | Password |
|------|-------|----------|
| Company admin | `admin@demo.com` | `Admin12345!` |
| Recruiter | `recruiter@demo.com` | `Recruiter12345!` |
| HR manager | `hr@demo.com` | `HrManager12345!` |
| Employee (mobile) | `emp01@demo.com` | `Employee12345!` |
| Platform | `platform@nawatech.com` | `Platform12345!` |

After the first successful seed, set `SEED_ON_START=false` so redeploys do not wipe data unexpectedly. Re-seed manually when you want a clean demo.

## Mobile against the live API

```bash
flutter run -d ios \
  --dart-define=API_BASE_URL=https://hrm-nawa-api.onrender.com/api

# or release APK for reviewers:
flutter build apk --release \
  --dart-define=API_BASE_URL=https://hrm-nawa-api.onrender.com/api
```

## Portfolio copy (paste into README / site)

```markdown
### Live demo
- Admin: https://hrm-nawa-api.onrender.com/admin
- API health: https://hrm-nawa-api.onrender.com/api/health
- Recruiter: recruiter@demo.com / Recruiter12345!
- Company admin: admin@demo.com / Admin12345!
```

## Honest notes

- Keep `APP_DEBUG=false` on the public URL.
- Demo passwords are intentional for portfolio; do not reuse them for real customers.
- AI replies need a paid provider key; without it the gateway falls back safely.
- A short Loom walkthrough is a good backup if the free host sleeps.
