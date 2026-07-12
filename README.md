# Nawa Tech HRM — SaaS Platform
# منصة Nawa Tech HRM — SaaS

> **Full-Stack HR Management with AI** | **نظام إدارة موارد بشرية متكامل مع ذكاء اصطناعي**

**Status:** Actively developing this HR system into a **commercial multi-tenant SaaS product** (trials, plans, platform console, billing scaffold).  
**الوضع:** جارٍ تطوير نظام الـ HR ليصبح **منتج SaaS تجاري متعدد المستأجرين** (تجارب، خطط، لوحة منصة، هيكل فوترة).

**Nawa Tech HRM** is a multi-tenant SaaS platform built with **Flutter + Laravel** — admin web dashboard, employee mobile app, and AI assistant. Start a **14-day free trial** or use the demo account.

**Nawa Tech HRM** منصة SaaS متعددة المستأجرين — لوحة ويب، تطبيق موظفين، ومساعد AI. **تجربة مجانية 14 يوم** أو حساب تجريبي جاهز.

📖 **Demo guide:** [DEMO.md](./DEMO.md) · **SaaS launch:** [SAAS.md](./SAAS.md)  
🚀 **Deploy:** [DEPLOY.md](./DEPLOY.md)

---

## 🎮 Try the platform | جرّب المنصة

### English — Step by step

#### Option A — Free trial (SaaS)

1. Start API + Flutter (see below)
2. Open **`http://localhost:3000/register`**
3. Create your company — you land in the admin dashboard

#### Option B — Demo account (no signup)

#### Prerequisites
- Flutter 3.x
- PHP 8.3+ & Composer
- Chrome (for web admin) + iOS Simulator or Android emulator (for employee app)

#### 1. Start the API (Laravel)

```bash
git clone https://github.com/ahmedehab96-c/hrm-nawa-tech.git
cd hrm-nawa-tech/backend

composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

✅ API available at: **`http://127.0.0.1:8000/api`**

#### 2. Run Admin Dashboard (Web)

```bash
cd ..   # back to project root
flutter pub get
flutter run -d chrome --web-port=3000
```

- Open **`http://localhost:3000/welcome`**
- Click **Start free trial** or go to **`/register`**
- Or login with demo admin at **`/login`**
- Platform console: `platform@nawatech.com` → **`/platform`**

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@demo.com` | `Admin12345!` |
| **Platform** | `platform@nawatech.com` | `Platform12345!` |

> In web debug mode, the app auto-connects to `http://127.0.0.1:8000/api`.

#### 3. Run Employee App (Mobile)

```bash
flutter run -d ios        # iPhone Simulator
# or
flutter run -d android  # Android Emulator
```

In **debug mode**, simulators auto-connect to the local API (`127.0.0.1` on iOS, `10.0.2.2` on Android emulator).

Or open **Profile** → **Server (Laravel API)**:
1. Enable **Use server**
2. Set Base URL: `http://127.0.0.1:8000/api`
3. Save

| Role | Email | Password |
|------|-------|----------|
| **Employee** | `emp01@demo.com` | `Employee12345!` |
| Employee 2 | `emp02@demo.com` | `Employee12345!` |

> On a **physical device**, use your computer's LAN IP instead of `127.0.0.1`  
> Example: `http://192.168.1.10:8000/api`

#### 4. What to explore

| Area | Highlights |
|------|------------|
| **Dashboard** | Stats, pending leaves, activity |
| **Employees** | CRUD, profiles, search |
| **Attendance** | Daily records, export |
| **AI Command Center** | Assistant, SLO, escalations, reports |
| **Recruitment** | Jobs, candidates, AI matching |
| **Platform** | Super-admin tenants, plans, trials |
| **Settings** | AR/EN language, dark/light theme, plan upgrade CTAs |

#### 5. App icon

The mobile app uses the **HRM logo** (not the default Flutter icon).  
After icon changes, **uninstall and reinstall** the app on the simulator/device to see the new icon.

---

### العربية — خطوة بخطوة

#### المتطلبات
- Flutter 3.x
- PHP 8.3+ و Composer
- Chrome (لوحة الويب) + محاكي iOS أو Android (تطبيق الموظف)

#### 1. تشغيل الـ API (Laravel)

```bash
git clone https://github.com/ahmedehab96-c/hrm-nawa-tech.git
cd hrm-nawa-tech/backend

composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

✅ الـ API يعمل على: **`http://127.0.0.1:8000/api`**

#### 2. تشغيل لوحة الإدارة (ويب)

```bash
cd ..   # العودة لجذر المشروع
flutter pub get
flutter run -d chrome --web-port=3000
```

- افتح **`http://localhost:3000/welcome`**
- اضغط **ابدأ التجربة المجانية** أو اذهب إلى **`/register`**
- أو سجّل دخول الأدمن: **`/login`**
- لوحة المنصة: `platform@nawatech.com` → **`/platform`**

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| **أدمن** | `admin@demo.com` | `Admin12345!` |
| **المنصة** | `platform@nawatech.com` | `Platform12345!` |

> في وضع التطوير على الويب، التطبيق يتصل تلقائياً بـ `http://127.0.0.1:8000/api`.

#### 3. تشغيل تطبيق الموظف (موبايل)

```bash
flutter run -d ios        # محاكي iPhone
# أو
flutter run -d android    # محاكي Android
```

في **وضع التطوير**، المحاكي يتصل تلقائياً بالـ API المحلي (`127.0.0.1` على iOS، `10.0.2.2` على Android).

أو افتح **الملف الشخصي** → **الخادم (Laravel API)**:
1. فعّل **استخدام الخادم**
2. ضع العنوان: `http://127.0.0.1:8000/api`
3. احفظ

| الدور | البريد | كلمة المرور |
|-------|--------|-------------|
| **موظف** | `emp01@demo.com` | `Employee12345!` |
| موظف 2 | `emp02@demo.com` | `Employee12345!` |

> على **هاتف حقيقي**، استخدم IP جهازك على الشبكة بدلاً من `127.0.0.1`  
> مثال: `http://192.168.1.10:8000/api`

#### 4. ماذا تجرب؟

| القسم | أبرز المميزات |
|-------|----------------|
| **لوحة التحكم** | إحصائيات، إجازات معلقة، نشاط |
| **الموظفون** | إضافة/تعديل، ملفات، بحث |
| **الحضور** | سجلات يومية، تصدير |
| **مركز AI** | مساعد، SLO، تصعيد، تقارير |
| **التوظيف** | وظائف، مرشحين، مطابقة AI |
| **المنصة** | مستأجرون، خطط، تجارب (super_admin) |
| **الإعدادات** | عربي/إنجليزي، وضع ليلي/نهاري، ترقية الخطة |

#### 5. أيقونة التطبيق

تطبيق الموبايل يستخدم **شعار HRM** (وليس أيقونة Flutter الافتراضية).  
بعد تغيير الأيقونة، **احذف التطبيق وأعد تثبيته** على المحاكي/الهاتف لرؤية الأيقونة الجديدة.

---

## 🚀 SaaS product roadmap | خارطة منتج SaaS

> **Current status:** Active SaaS development — multi-tenant trials, plan limits, platform console, and billing scaffold are live in this repo.  
> **الوضع الحالي:** تطوير SaaS جارٍ — التجارب متعددة المستأجرين، حدود الخطط، لوحة المنصة، وهيكل الفوترة موجودة في المستودع.

This project is **no longer “demo-only.”** It is being built as a commercial **SaaS HRM platform** where companies register, trial, and upgrade independently.

المشروع **لم يعد عرضاً تجريبياً فقط.** يتم بناؤه كـ **منصة HRM SaaS تجارية** تسجّل فيها الشركات وتجرّب وترقّي بشكل مستقل.

### Already shipping | ما يعمل الآن

| Capability | Status |
|------------|--------|
| Multi-tenant (`company_id` isolation) | ✅ |
| Company self-registration + 14-day trial | ✅ |
| Email verification gate | ✅ |
| Plan employee caps (trial / starter / growth / enterprise) | ✅ |
| Super-admin platform console (`/platform`) | ✅ |
| Billing checkout scaffold (Stripe/Moyasar → next) | ✅ scaffold |
| Admin Web + Employee Mobile | ✅ |
| RBAC (roles & permissions) + `super_admin` | ✅ |
| AI features + governance | ✅ |
| Optional MySQL Docker profile | ✅ |
| Flutter MVVM (platform + login) | ✅ |
| Arabic + English (RTL/LTR) | ✅ |

### Still planned | المتبقي

| Phase | Feature |
|-------|---------|
| **Next** | Live Stripe / Moyasar checkout + webhooks |
| **Next** | Custom domains |
| **Later** | Production deploy (`hrm.nawatech.com`) |

```
Earlier portfolio demo          SaaS product (now → launch)
─────────────────────           ──────────────────────────
1 showcase tenant      →        Many companies + trials
Login showcase         →        Register + plan upgrades
nawatech.com/portfolio →        hrm.nawatech.com (planned)
```

### Changelog — July 2026 | سجل التغييرات — يوليو 2026

**English**
- SaaS trial onboarding (register → 14-day trial + demo employees)
- Email verification + plan employee limits
- Platform console for super-admin (overview, suspend/activate, extend trial, manual plans)
- Billing scaffold (`POST /billing/checkout`) + Settings upgrade CTAs
- Suspended-company API gate (`company_suspended`)
- Optional MySQL via `docker compose --profile mysql`
- AppStrings localization (replaced flutter gen-l10n)
- MVVM foundation for Platform console and Login

**العربية**
- تسجيل شركة مع تجربة 14 يوماً + موظفين تجريبيين
- التحقق من البريد + حدود عدد الموظفين حسب الخطة
- لوحة المنصة لـ super_admin (نظرة عامة، تعليق/تفعيل، تمديد تجربة، تفعيل خطط يدوياً)
- هيكل الفوترة + أزرار الترقية في الإعدادات
- منع الشركات المعلّقة عبر الـ API
- MySQL اختياري عبر Docker profile
- ترجمة عبر `AppStrings` بدل gen-l10n
- أساس MVVM للوحة المنصة وتسجيل الدخول

---

## 🎯 Features | المميزات

### Admin Panel (Web) | لوحة الأدمن

Dashboard · Employees · Attendance · Leave · Payroll · Recruitment · AI Command Center · Performance · Reports · Settings · Platform (super_admin)

### Employee App (Mobile) | تطبيق الموظف

Home · Attendance · Leave · Payslip · Profile · Notifications

---

## 🏗️ Architecture | المعمارية

```
hrm-nawa-tech/
├── lib/
│   ├── core/            # API, auth, mvvm/, repositories
│   └── features/        # admin/ + employee/ + platform/ + welcome/
│       └── platform/    # models · data · viewmodels · views (MVVM)
├── backend/             # Laravel REST API + AI services
├── assets/images/       # HRM logo + app icon source
└── test/                # Flutter + PHPUnit tests
```

---

## 🛠️ Tech Stack | التقنيات

| Layer | Stack |
|-------|-------|
| **Frontend** | Flutter 3, GoRouter, AppStrings i18n (AR/EN), MVVM |
| **Backend** | Laravel, Sanctum, SQLite/MySQL |
| **AI** | OpenAI / Gemini gateway, prompt registry |
| **Patterns** | Multi-tenant, Repository, MVVM (feature folders) |

---

## 🧪 Tests | الاختبارات

```bash
cd backend && php artisan test
flutter test
```

---

## 👨‍💻 Developer | المطوّر

**Ahmed Ehab Mohammed — Nawa Tech**  
📧 ahmed96it96@gmail.com  
🌐 [nawatech.com](https://nawatech.com)  
💻 [GitHub — hrm-nawa-tech](https://github.com/ahmedehab96-c/hrm-nawa-tech)

---

## 📄 License

Portfolio + active SaaS product development. Contact the author for commercial use or SaaS licensing.
