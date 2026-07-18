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

#### Keep-alive (so it does not sleep before demos)

Free Render spins down after **~15 minutes** without traffic. This repo runs
[`.github/workflows/keep_alive.yml`](../.github/workflows/keep_alive.yml): GitHub Actions
pings `/api/health` every **10 minutes** so cold starts are rare when you open the link.

Optional stronger ping (more reliable than Actions cron): create a free job at
[cron-job.org](https://cron-job.org) → URL `https://hrm-nawa-api.onrender.com/api/health` → every **10 minutes**.

**Hours limit:** Free workspaces get **~750 instance hours/month**. Keeping one service awake
24/7 uses almost all of that. If Render suspends free services near month-end, wait for the
next month or upgrade (below).

#### Never-sleep option (recommended for interviews)

Upgrade the service to **Starter** (~$7/mo) in the Render dashboard → **hrm-nawa-api** →
**Settings → Instance Type**. Paid instances do **not** spin down. Then you can disable
`keep_alive.yml` if you want.

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
# One command (simulator, device, or chrome):
./scripts/run_mobile_live.sh
./scripts/run_mobile_live.sh "iPhone 16 Pro"

# Or manually:
flutter run -d ios \
  --dart-define=USE_LIVE_DEMO=true \
  --dart-define=API_BASE_URL=https://hrm-nawa-api.onrender.com/api

# Release APK for reviewers (defaults to live API even without dart-define):
flutter build apk --release
```

**Employee login:** `emp01@demo.com` / `Employee12345!`

On a physical phone: same live URL works over HTTPS (no LAN IP needed).  
Or in the app: **Profile → Server** → enable Use server → Base URL
`https://hrm-nawa-api.onrender.com/api` → Save.
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
