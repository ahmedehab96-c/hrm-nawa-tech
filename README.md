# HRM Platform — Portfolio Project
# منصة HRM — مشروع Portfolio

> **Full-Stack HR Management with AI** | **نظام إدارة موارد بشرية متكامل مع ذكاء اصطناعي**

A **portfolio demo project** by **Nawa Tech** — built with **Flutter + Laravel** to showcase full-stack, mobile, and AI skills.  
**Not a commercial SaaS product** — for employers and recruiters to explore the live demo.

مشروع **Portfolio** من **Nawa Tech** — مبني بـ **Flutter + Laravel** لعرض مهارات Full-Stack والموبايل والـ AI.  
**ليس منتج SaaS تجاري** — للعرض والتجربة عند البحث عن عمل.

---

## 🎮 Try the Demo | جرّب المشروع

### English — Quick start

1. **Clone & run backend**
   ```bash
   cd backend
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate:fresh --seed
   php artisan serve
   ```
   API runs at: `http://127.0.0.1:8000/api`

2. **Run Admin panel (Web)**
   ```bash
   flutter pub get
   flutter run -d chrome --web-port=3000
   ```
   Open: `http://localhost:3000/welcome` → click **Try Admin Dashboard**  
   Web debug mode auto-connects to `http://127.0.0.1:8000/api`.

3. **Run Employee app (Mobile)**
   ```bash
   flutter run -d ios    # or android
   ```
   In **Settings → Server**: enable API and set `http://127.0.0.1:8000/api`  
   (Use your machine IP instead of `127.0.0.1` on a physical device.)

4. **Login credentials**

   | Role | Email | Password |
   |------|-------|----------|
   | **Admin (Web)** | `admin@demo.com` | `Admin12345!` |
   | **Employee (Mobile)** | `emp01@demo.com` | `Employee12345!` |
   | Employee 2 | `emp02@demo.com` | `Employee12345!` |

5. **What to explore**
   - Admin: Dashboard, Employees, Attendance, Leave, Payroll, Recruitment, **AI Command Center**
   - Employee: Check-in/out, leave requests, payslip, notifications
   - Toggle **Arabic / English** and **Dark / Light** theme in Settings

---

### العربية — البدء السريع

1. **تشغيل الباكند**
   ```bash
   cd backend
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate:fresh --seed
   php artisan serve
   ```
   عنوان الـ API: `http://127.0.0.1:8000/api`

2. **تشغيل لوحة الإدارة (ويب)**
   ```bash
   flutter pub get
   flutter run -d chrome --web-port=3000
   ```
   افتح: `http://localhost:3000/welcome` → اضغط **جرّب لوحة الإدارة**  
   في وضع التطوير على الويب يتصل تلقائياً بـ `http://127.0.0.1:8000/api`.

3. **تشغيل تطبيق الموظف (موبايل)**
   ```bash
   flutter run -d ios    # أو android
   ```
   من **الإعدادات → Server**: فعّل API وضع العنوان `http://127.0.0.1:8000/api`  
   (على جهاز حقيقي استخدم IP الجهاز بدلاً من `127.0.0.1`.)

4. **بيانات الدخول**

   | الدور | البريد | كلمة المرور |
   |-------|--------|-------------|
   | **أدمن (ويب)** | `admin@demo.com` | `Admin12345!` |
   | **موظف (موبايل)** | `emp01@demo.com` | `Employee12345!` |
   | موظف 2 | `emp02@demo.com` | `Employee12345!` |

5. **ماذا تجرب؟**
   - الأدمن: لوحة التحكم، الموظفون، الحضور، الإجازات، الرواتب، التوظيف، **مركز AI**
   - الموظف: حضور/انصراف، طلب إجازة، قسيمة راتب، إشعارات
   - جرّب **العربية / English** و**الوضع الليلي / النهاري** من الإعدادات

---

## 🎯 Features | المميزات

### Admin Panel (Web) | لوحة الأدمن (ويب)

| Feature | Details |
|---------|---------|
| **Dashboard** | Stats, pending leaves, activity |
| **Employees** | CRUD, profiles, search & pagination |
| **Attendance** | Daily records, edit status, export |
| **Leave** | Approve/reject, balances |
| **Payroll** | Generate payslips, PDF |
| **Recruitment** | Jobs, candidates, AI matching |
| **AI Command Center** | Assistant, SLO, escalations, reports |
| **Performance & Reports** | AI-powered HR insights |
| **Settings** | Company info, WiFi attendance, RBAC, AI governance |

### Employee App (Mobile) | تطبيق الموظف

| Feature | Details |
|---------|---------|
| **Home** | Check-in/out, quick actions |
| **Attendance** | WiFi-gated check-in, history |
| **Leave** | Submit requests, view balance |
| **Payslip** | Monthly view, PDF |
| **Notifications** | In-app alerts |

---

## 🏗️ Architecture | المعمارية

```
hrm-nawa-tech/
├── lib/                 # Flutter — Web Admin + Mobile Employee
│   ├── core/            # API, auth, repositories, AI
│   └── features/        # admin/ + employee/ + welcome/
├── backend/             # Laravel 13 REST API + AI services
└── test/                # Flutter + PHPUnit tests
```

---

## 🛠️ Tech Stack | التقنيات

| Layer | Stack |
|-------|-------|
| **Frontend** | Flutter 3, GoRouter, ARB i18n (AR/EN) |
| **Backend** | Laravel 13, Sanctum, SQLite/MySQL |
| **AI** | OpenAI / Gemini gateway, prompt registry, governance |
| **Patterns** | Clean Architecture, Repository Pattern, Multi-tenant |

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

Portfolio demonstration project. Contact the author for reuse permissions.
