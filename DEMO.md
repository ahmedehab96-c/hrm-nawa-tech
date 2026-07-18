# Portfolio Demo Guide | دليل عرض المشروع

**Recruiter one-pager:** [docs/PORTFOLIO.md](./docs/PORTFOLIO.md) · **Live hosting:** [docs/LIVE_DEMO.md](./docs/LIVE_DEMO.md) · **Screenshots:** [docs/screenshots/README.md](./docs/screenshots/README.md)

Use this guide for a focused **5–10 minute technical review**. It covers **web admin**, **backend API**, and **employee mobile** in English and Arabic.

استخدم هذا الدليل لعرض تقني **5–10 دقائق**: لوحة الويب، الـ API، وتطبيق الموظف — بالإنجليزية والعربية.

---

## Try in 3 steps (no deep setup) | جرّب بثلاث خطوات

### 1) Web | الويب (Filament)

Open → افتح: **https://hrm-nawa-api.onrender.com/admin**

| Role / الدور | Email | Password |
|--------------|-------|----------|
| Company admin / أدمن | `admin@demo.com` | `Admin12345!` |
| Recruiter / توظيف | `recruiter@demo.com` | `Recruiter12345!` |
| Platform / المنصة | `platform@nawatech.com` | `Platform12345!` |

### 2) Backend | الباكند (API)

Health → الصحة: **https://hrm-nawa-api.onrender.com/api/health**

Optional login check | فحص دخول اختياري:

```bash
curl -s -X POST https://hrm-nawa-api.onrender.com/api/login \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -d '{"email":"emp01@demo.com","password":"Employee12345!"}'
```

Web admin and the phone app use **the same** Laravel API.  
لوحة الأدمن وتطبيق الهاتف يستخدمان **نفس** الـ API.

### 3) Phone | الهاتف (Flutter)

```bash
git clone https://github.com/ahmedehab96-c/hrm-nawa-tech.git
cd hrm-nawa-tech
./scripts/run_mobile_live.sh
```

Login → دخول: `emp01@demo.com` / `Employee12345!`

> First visit after idle may take ~30–60s (Render free). Keep-alive reduces this.  
> أول فتح بعد خمول قد يأخذ 30–60 ثانية.

---

## English — reviewer walkthrough

### Credentials

| Role | Email | Password |
|------|-------|----------|
| **Company admin** | `admin@demo.com` | `Admin12345!` |
| **HR manager** | `hr@demo.com` | `HrManager12345!` |
| **Recruiter** | `recruiter@demo.com` | `Recruiter12345!` |
| **Employee** | `emp01@demo.com` | `Employee12345!` |
| **Platform admin** | `platform@nawatech.com` | `Platform12345!` |

### Recommended path (live preferred)

#### A. Company admin — product breadth (3 minutes)

1. Sign in at the live admin URL as `admin@demo.com` (or local: `./scripts/start_api.sh` → http://127.0.0.1:8000/admin).
2. Toggle **AR/EN** and dark mode to show localization and RTL/LTR.
3. Open **Dashboard** to show tenant-scoped HR metrics.
4. Open **Employees** and one employee record to show attendance, leave, and payroll relations.
5. Open **Leave** and approve/reject a pending request.
6. Open **Settings** to show company and AI configuration.

#### B. Recruiter — focused workflow (2 minutes)

1. Sign in as `recruiter@demo.com`.
2. Open **Recruitment** and view the seeded Flutter position.
3. Open candidates and move one through interview/hired/rejected stages.
4. Show the AI fit score and matching reason.

#### C. Platform admin — SaaS foundations (1 minute)

1. Sign in as `platform@nawatech.com`.
2. Open **Companies**.
3. Show tenant status, trial, plan controls, and aggregate platform metrics.

Billing is an integration scaffold — not live production payments.

#### D. Employee mobile — API integration (2 minutes)

```bash
./scripts/run_mobile_live.sh
# local API instead: flutter run -d ios
```

Sign in as `emp01@demo.com`, then show attendance, leave, payslips, notifications, and Profile → Server URL.

### Engineering discussion points

- Filament admin and Flutter mobile consume the same Laravel API.
- `company_id` scopes tenant data; RBAC separates roles.
- Service classes isolate leave, payroll, onboarding, billing, reports, and AI.
- AI providers are optional with safe fallbacks.
- Backend and Flutter have separate GitHub Actions workflows.
- Queue, scheduler, health endpoint, Docker, and smoke tests support deployment.

### Verification commands

```bash
cd backend && php artisan test
cd .. && flutter test
./scripts/smoke_test.sh
```

### Honest project boundaries

- Portfolio-ready demo with SaaS foundations.
- Stripe/Moyasar scaffolded; public production checkout is not claimed.
- Observability, backups, and final security review remain roadmap items.

---

## العربية — سيناريو العرض

### الحسابات

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| **أدمن الشركة** | `admin@demo.com` | `Admin12345!` |
| **مدير HR** | `hr@demo.com` | `HrManager12345!` |
| **توظيف** | `recruiter@demo.com` | `Recruiter12345!` |
| **موظف** | `emp01@demo.com` | `Employee12345!` |
| **المنصة** | `platform@nawatech.com` | `Platform12345!` |

### المسار المقترح (اللايف أولاً)

#### أدمن الشركة

1. ادخل عبر https://hrm-nawa-api.onrender.com/admin بحساب `admin@demo.com` (أو محلياً: `./scripts/start_api.sh`).
2. بدّل بين العربية والإنجليزية والوضع الداكن.
3. اعرض لوحة المؤشرات والموظفين وعلاقات الحضور والإجازات والرواتب.
4. وافق أو ارفض طلب إجازة.
5. اعرض إعدادات الشركة والذكاء الاصطناعي.

#### مسؤول التوظيف

1. ادخل بحساب `recruiter@demo.com`.
2. افتح التوظيف والوظيفة التجريبية.
3. اعرض المرشح ودرجة الملاءمة.
4. انقل المرشح بين مراحل المقابلة/التوظيف/الرفض.

#### أدمن المنصة

1. ادخل بحساب `platform@nawatech.com`.
2. اعرض الشركات والخطة والتجربة.
3. وضّح أن الفوترة هيكل تكامل وليست دفعاً إنتاجياً حياً.

#### تطبيق الموظف

```bash
./scripts/run_mobile_live.sh
```

ادخل `emp01@demo.com` ثم اعرض الحضور والإجازات وقسيمة الراتب والإشعارات.

### نقاط تقنية

- لوحة Filament وتطبيق Flutter على نفس Laravel API.
- عزل الشركات عبر `company_id` مع صلاحيات متعددة الأدوار.
- طبقة Services للرواتب والإجازات والتقارير والفوترة والـ AI.
- اختبارات وCI منفصلة للـ Backend وFlutter.
- Queue وScheduler وDocker وHealth Check لدعم النشر.

### حدود المشروع

- جاهز للـ Portfolio مع أساس SaaS.
- الدفع الحقيقي العام غير مكتمل.
- المراقبة والنسخ الاحتياطي والمراجعة الأمنية النهائية ضمن خارطة الطريق.
