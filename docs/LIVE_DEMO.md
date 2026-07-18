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

### B) Render free Blueprint (good portfolio alternative)
1. Open https://dashboard.render.com
2. **New → Blueprint**
3. Connect the GitHub repo `ahmedehab96-c/hrm-nawa-tech`
4. Confirm `render.yaml` (SQLite + auto-seed for free tier)
5. After deploy, set `APP_URL=https://YOUR-SERVICE.onrender.com` in Render → Environment
6. Redeploy once

You get a public admin at `https://YOUR-SERVICE.onrender.com/admin`.

Free web services on Render may sleep after inactivity; the first request can take ~30–60s. That is acceptable for portfolio demos.

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
  --dart-define=API_BASE_URL=https://YOUR-DOMAIN/api

# or release APK for reviewers:
flutter build apk --release \
  --dart-define=API_BASE_URL=https://YOUR-DOMAIN/api
```

## Portfolio copy (paste into README / site)

```markdown
### Live demo
- Admin: https://YOUR-DOMAIN/admin
- API health: https://YOUR-DOMAIN/api/health
- Recruiter: recruiter@demo.com / Recruiter12345!
- Company admin: admin@demo.com / Admin12345!
```

## Honest notes

- Keep `APP_DEBUG=false` on the public URL.
- Demo passwords are intentional for portfolio; do not reuse them for real customers.
- AI replies need a paid provider key; without it the gateway falls back safely.
- A short Loom walkthrough is a good backup if the free host sleeps.
