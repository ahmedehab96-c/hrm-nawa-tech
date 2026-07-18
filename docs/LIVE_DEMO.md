# Live Demo for Portfolio | ديمو لايف للبورتفوليو

**Goal | الهدف:** public HTTPS URL so anyone can try **web admin + API + mobile** without guessing links.

**الهدف:** رابط عام يجرب منه أي شخص لوحة الأدمن والـ API والموبايل بدون تخمين.

---

## Try now | جرّب الآن

| Part / الجزء | Link / الرابط | Login / الدخول |
|--------------|---------------|----------------|
| **Web / الويب** | https://hrm-nawa-api.onrender.com/admin | `admin@demo.com` / `Admin12345!` |
| **API / الباكند** | https://hrm-nawa-api.onrender.com/api/health | — (must show OK) |
| **Phone / الهاتف** | `./scripts/run_mobile_live.sh` after clone | `emp01@demo.com` / `Employee12345!` |

**Other accounts | حسابات أخرى**

| Role / الدور | Email | Password |
|--------------|-------|----------|
| Recruiter / توظيف | `recruiter@demo.com` | `Recruiter12345!` |
| HR manager / مدير HR | `hr@demo.com` | `HrManager12345!` |
| Platform / المنصة | `platform@nawatech.com` | `Platform12345!` |

Step-by-step walkthrough (EN + AR): **[DEMO.md](../DEMO.md)**

---

## What is hosted where | أين يستضاف ماذا؟

| Piece / الجزء | Hosted on Render? | Notes / ملاحظة |
|---------------|-------------------|----------------|
| Laravel API | Yes | `/api/*` |
| Filament admin (web) | Yes | same service `/admin` |
| Flutter phone app | No | runs on your device/simulator; talks to Render API |

الويب والباكند على Render. تطبيق الهاتف محلي ويتصل بنفس الـ API اللايف.

---

## Mobile | الموبايل

```bash
git clone https://github.com/ahmedehab96-c/hrm-nawa-tech.git
cd hrm-nawa-tech
./scripts/run_mobile_live.sh
# optional device:
./scripts/run_mobile_live.sh "iPhone 16 Pro"
```

Or manually | أو يدوياً:

```bash
flutter run \
  --dart-define=USE_LIVE_DEMO=true \
  --dart-define=API_BASE_URL=https://hrm-nawa-api.onrender.com/api
```

Release APK defaults to the live API.  
بناء APK للإصدار يستخدم الـ API اللايف تلقائياً.

On a physical phone: HTTPS live URL works (no LAN IP).  
أو داخل التطبيق: **Profile → Server** → `https://hrm-nawa-api.onrender.com/api`

---

## Keep-alive | إبقاء الخدمة يقظة

Free Render sleeps after ~15 minutes idle. This repo pings health every 10 minutes via
[`.github/workflows/keep_alive.yml`](../.github/workflows/keep_alive.yml).

Optional: [cron-job.org](https://cron-job.org) → same health URL every 10 minutes.

**Never sleep:** upgrade Render instance to **Starter** (~$7/mo).  
**حد الساعات:** ~750 ساعة مجانية/شهر؛ اليقظة 24/7 تستهلكها تقريباً كلها.

---

## Recreate hosting | إعادة إنشاء الاستضافة

1. https://dashboard.render.com → New → Blueprint  
2. Connect `ahmedehab96-c/hrm-nawa-tech`  
3. Confirm `render.yaml`

Dashboard for current service: https://dashboard.render.com/web/srv-d9djnb77f7vs738q6ug0

Railway remains an alternative if you prefer paid PaaS with Postgres.

---

## Portfolio copy | نص جاهز للبورتفوليو

```markdown
### Live demo
- Admin: https://hrm-nawa-api.onrender.com/admin
- API health: https://hrm-nawa-api.onrender.com/api/health
- Mobile: clone repo → ./scripts/run_mobile_live.sh
- Admin: admin@demo.com / Admin12345!
- Employee: emp01@demo.com / Employee12345!
```

## Honest notes | ملاحظات بصراحة

- Keep `APP_DEBUG=false` on the public URL.
- Demo passwords are intentional for portfolio.
- AI needs a paid provider key; otherwise safe fallbacks.
- Loom walkthrough is a good backup if the free host is cold.
