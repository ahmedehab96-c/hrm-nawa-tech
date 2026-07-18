# Portfolio Demo Guide | دليل عرض المشروع

**Recruiter one-pager:** [docs/PORTFOLIO.md](./docs/PORTFOLIO.md) · **Screenshots checklist:** [docs/screenshots/README.md](./docs/screenshots/README.md)

Use this guide for a focused **5–10 minute technical review**. It highlights product thinking, full-stack architecture, permissions, mobile/API integration, and engineering quality without requiring every screen to be opened.

استخدم هذا الدليل لعرض تقني مدته **5–10 دقائق** يوضح المعمارية والصلاحيات وتكامل الموبايل والـAPI وجودة التنفيذ، دون الحاجة لفتح كل شاشة.

## English

### 1. Start the demo

```bash
./scripts/start_api.sh
```

Open **http://127.0.0.1:8000/admin**.

### Credentials

| Role | Email | Password |
|------|-------|----------|
| **Company admin** | `admin@demo.com` | `Admin12345!` |
| **HR manager** | `hr@demo.com` | `HrManager12345!` |
| **Recruiter** | `recruiter@demo.com` | `Recruiter12345!` |
| **Employee** | `emp01@demo.com` | `Employee12345!` |
| **Platform admin** | `platform@nawatech.com` | `Platform12345!` |

### 2. Recommended reviewer walkthrough

#### A. Company admin — product breadth (3 minutes)

1. Sign in as `admin@demo.com`.
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

This demonstrates role-aware navigation and a real workflow rather than isolated CRUD screens.

#### C. Platform admin — SaaS foundations (1 minute)

1. Sign in as `platform@nawatech.com`.
2. Open **Companies**.
3. Show tenant status, trial, plan controls, and aggregate platform metrics.

The billing area is an integration scaffold; it is intentionally not described as live production payments.

#### D. Employee mobile — API integration (2 minutes)

```bash
flutter pub get
flutter run -d ios   # or android
```

Sign in as `emp01@demo.com`, then show attendance, leave requests, payslips, notifications, deep links, and the configurable API server.

### 3. Engineering discussion points

- Filament admin and Flutter mobile consume the same Laravel domain/API.
- `company_id` scopes tenant data; RBAC separates platform, company, HR, recruiter, and employee access.
- Service classes isolate leave decisions, payroll generation, onboarding, billing, reports, and AI integrations.
- AI providers are optional and failures have controlled fallbacks.
- Backend and Flutter have separate GitHub Actions workflows.
- Queue, scheduler, health endpoint, Docker, and smoke-test scripts support deployment.

### 4. Verification commands

```bash
cd backend && php artisan test
cd .. && flutter test
./scripts/smoke_test.sh
```

### 5. Honest project boundaries

- The repository is a portfolio-ready demo with SaaS foundations.
- Stripe/Moyasar integration is scaffolded; public production checkout is not claimed.
- Production observability, backups, final security review, and a public resettable demo remain roadmap work.

---

## العربية

### 1. تشغيل العرض

```bash
./scripts/start_api.sh
```

افتح **http://127.0.0.1:8000/admin**.

### 2. سيناريو العرض المقترح

#### أدمن الشركة

1. ادخل بحساب `admin@demo.com`.
2. بدّل بين العربية والإنجليزية والوضع الداكن.
3. اعرض لوحة المؤشرات والموظفين وعلاقات الحضور والإجازات والرواتب.
4. وافق أو ارفض طلب إجازة.
5. اعرض إعدادات الشركة والذكاء الاصطناعي.

#### مسؤول التوظيف

1. ادخل بحساب `recruiter@demo.com`.
2. افتح قسم التوظيف والوظيفة التجريبية.
3. اعرض المرشح ودرجة ملاءمته وسبب المطابقة.
4. انقل المرشح بين مراحل المقابلة والتوظيف والرفض.

#### أدمن المنصة

1. ادخل بحساب `platform@nawatech.com`.
2. اعرض الشركات وحالة كل مستأجر والخطة والتجربة.
3. وضّح أن الفوترة الحالية هي هيكل تكامل وليست دفعاً إنتاجياً حياً.

#### تطبيق الموظف

```bash
flutter pub get
flutter run -d ios   # أو android
```

ادخل بحساب `emp01@demo.com` ثم اعرض الحضور والإجازات وقسيمة الراتب والإشعارات.

### 3. نقاط تقنية مهمة

- لوحة Filament وتطبيق Flutter يعملان على نفس Laravel API ونفس منطق الأعمال.
- عزل بيانات الشركات عبر `company_id` مع صلاحيات متعددة الأدوار.
- طبقة Services للرواتب والإجازات والتقارير والفوترة والذكاء الاصطناعي.
- اختبارات منفصلة للـBackend وFlutter وCI عبر GitHub Actions.
- Queue وScheduler وDocker وHealth Check وSmoke Test لدعم النشر.

### 4. حدود المشروع بوضوح

- المشروع جاهز للعرض في الـPortfolio مع أساس قابل للتحول إلى SaaS.
- الدفع الحقيقي العام غير مكتمل ولا يتم الادعاء بأنه جاهز للإنتاج.
- المراقبة والنسخ الاحتياطي والمراجعة الأمنية النهائية والنشر العام ما زالت ضمن خارطة الطريق.
