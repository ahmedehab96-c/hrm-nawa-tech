# HRM SaaS — Human Resource Management System
# نظام إدارة الموارد البشرية

> **Where management meets simplicity** | **راحة الإدارة تبدأ من هنا**

A full-featured SaaS HRM platform for small and medium businesses (5–200 employees), built with **Flutter + Laravel**. Supports Arabic & English, runs on both **Web** (Admin panel) and **Mobile** (Employee app) from a single codebase.

نظام SaaS متكامل لإدارة الموارد البشرية للشركات الصغيرة والمتوسطة (5–200 موظف) مبني بـ **Flutter + Laravel**، يدعم العربية والإنجليزية بشكل كامل، ويعمل على الويب والجوال في آنٍ واحد.

---

## 🎯 Features | المميزات

### Admin Panel (Web) | لوحة الأدمن (ويب)

| Feature / الميزة | Details / التفاصيل |
|-----------------|-------------------|
| **Authentication / المصادقة** | Company registration, admin login, forgot password, email reset / تسجيل الشركة، دخول الأدمن، نسيت كلمة المرور، إعادة التعيين عبر إيميل |
| **Dashboard / لوحة التحكم** | 4 stat cards, pending leaves, recent activity / 4 بطاقات إحصاء، الإجازات المعلقة، النشاط الأخير |
| **Employees / الموظفون** | Full CRUD, 5 tabs (personal, job, salary, insurance, app access), server-side search & filter, pagination / CRUD كامل، 5 تبويبات، بحث وفلترة server-side، pagination |
| **Attendance / الحضور** | Daily table with date picker, edit check-in/out & status, mark absences, live stats / جدول يومي مع date picker، تعديل الحالة، إحصائيات فورية |
| **Leave / الإجازات** | Request list with status filter, approve/reject, per-employee balances / عرض الطلبات مع فلترة الحالة، موافقة/رفض، أرصدة per موظف |
| **Payroll / الرواتب** | Generate payslips, payslip detail view, professional PDF download / توليد كشوف الرواتب، تفاصيل القسيمة، تحميل PDF |
| **Recruitment / التوظيف** | Job CRUD, candidate Kanban pipeline, stage updates, convert to employee / إدارة الوظائف، pipeline مرشحين Kanban، تحويل مرشح لموظف |
| **Notifications / الإشعارات** | Full list, mark read/unread, mark all, swipe-to-delete / قائمة كاملة، تعليم مقروء، "تعليم الكل"، حذف بالسحب |
| **Settings / الإعدادات** | Company info, WiFi attendance config, roles & permissions, subscription plan / معلومات الشركة، WiFi، الأدوار والصلاحيات، الاشتراكات |

### Employee App (Mobile) | تطبيق الموظف (موبايل)

| Feature / الميزة | Details / التفاصيل |
|-----------------|-------------------|
| **Home / الرئيسية** | WiFi status, check-in/out buttons, quick actions / حالة WiFi، أزرار تسجيل الدخول/الخروج، إجراءات سريعة |
| **Attendance / الحضور** | Check-in/out (WiFi-gated), 7-day history / تسجيل الدخول/الخروج (مقيّد بـ WiFi الشركة)، سجل 7 أيام |
| **Leave / الإجازات** | Submit leave request, view balance and history / طلب إجازة، عرض الرصيد والتاريخ |
| **Payroll / الراتب** | Monthly payslip view, PDF download / عرض قسيمة الراتب الشهرية، تحميل PDF |
| **Profile / الملف الشخصي** | Employee info, documents / بيانات الموظف، الوثائق |
| **Notifications / الإشعارات** | View, read, delete notifications / عرض وقراءة وحذف الإشعارات |

---

## 🏗️ Architecture | المعمارية

```
hrm_saas/
├── lib/                          # Flutter Frontend
│   ├── core/
│   │   ├── api/                  # ApiClient, ApiConfig, ApiResult
│   │   ├── auth/                 # AuthSession, UserRole
│   │   ├── repositories/         # Employees, Attendance, Leave, Payroll,
│   │   │                         # Recruitment, Notifications, Settings
│   │   ├── services/             # PayslipPdfService, WifiAttendanceService
│   │   ├── theme/                # AppTheme, AppColors, AppTypography
│   │   ├── utils/                # JWT, PlatformHelper, LeaveStatusUtil
│   │   └── widgets/              # HrmLogo, StatCard, StatusBadge, Animations
│   ├── features/
│   │   ├── admin/                # Admin Panel (Web) | لوحة الأدمن (ويب)
│   │   │   ├── auth/
│   │   │   ├── attendance/
│   │   │   ├── companies/
│   │   │   ├── dashboard/
│   │   │   ├── employees/
│   │   │   ├── leave/
│   │   │   ├── notifications/
│   │   │   ├── payroll/
│   │   │   ├── recruitment/
│   │   │   └── settings/
│   │   └── employee/             # Employee App (Mobile) | تطبيق الموظف (موبايل)
│   │       ├── attendance/
│   │       ├── home/
│   │       ├── leave/
│   │       ├── notifications/
│   │       ├── payslip/
│   │       └── profile/
│   └── l10n/                     # Arabic + English (ARB files)
│
├── backend/                      # Laravel 13 API
│   ├── app/
│   │   ├── Http/Controllers/Api/ # Auth, Employee, Attendance, Leave,
│   │   │                         # Payroll, Recruitment, Notification, Company
│   │   └── Models/               # User, Company, Employee, AttendanceRecord,
│   │                             # LeaveRequest, PayrollRecord, AppNotification,
│   │                             # JobPosting, Candidate
│   ├── database/
│   │   ├── migrations/           # 11 migrations
│   │   └── seeders/              # Demo data: 10 employees + full data
│   └── tests/Feature/            # 56 feature tests
│
└── test/                         # Flutter unit tests (38 tests)
```

---

## 🚀 Getting Started | تشغيل المشروع

### Prerequisites | المتطلبات
- Flutter 3.x
- PHP 8.3+ & Composer
- SQLite (built-in) or MySQL / SQLite (مدمج) أو MySQL

### 1 — Backend | الباكند

```bash
cd backend

# Install dependencies | تثبيت الحزم
composer install

# Configure environment | إعداد البيئة
cp .env.example .env
php artisan key:generate

# Database + demo data | قاعدة البيانات + بيانات تجريبية
php artisan migrate:fresh --seed

# Start server | تشغيل السيرفر
php artisan serve
# → http://127.0.0.1:8000
```

### 2 — Flutter Frontend | الفرونتند

```bash
# Install dependencies | تثبيت الحزم
flutter pub get

# Admin Panel (Web) | لوحة الأدمن (ويب)
flutter run -d chrome

# Employee App (Mobile) | تطبيق الموظف (موبايل)
flutter run -d android   # or | أو -d ios
```

### 3 — Connect Frontend to Backend | ربط الفرونتند بالباكند

In the app: **Settings → Server** → enter `http://127.0.0.1:8000/api` → enable "Use server"

في التطبيق: **Settings → Server** → أدخل `http://127.0.0.1:8000/api` → فعّل "Use server"

> **Demo Mode**: The app works without a server — demo data is built in.
> **وضع التجريب**: يعمل التطبيق بدون سيرفر — بيانات تجريبية جاهزة مدمجة.

---

## 🔑 Demo Credentials | بيانات الدخول التجريبية

| Role / الدور | Email / البريد | Password / كلمة المرور |
|-------------|--------------|----------------------|
| **Admin** | `admin@demo.com` | `Admin12345!` |
| **Employee** | `emp01@demo.com` | `Employee12345!` |
| Employee 2 | `emp02@demo.com` | `Employee12345!` |

---

## 📡 API Endpoints

```
POST   /api/register                          Register new company | تسجيل شركة جديدة
POST   /api/login                             Login | تسجيل الدخول
POST   /api/logout                            Logout (revoke token) | تسجيل الخروج (إبطال التوكن)
POST   /api/forgot-password                   Send password reset link | إرسال رابط الاستعادة
POST   /api/reset-password                    Reset password | إعادة تعيين كلمة المرور

GET    /api/employees?page=&search=&dept=     List employees (paginated) | قائمة الموظفين
POST   /api/employees                         Create employee | إضافة موظف
GET    /api/employees/{id}                    Employee details | تفاصيل موظف
PUT    /api/employees/{id}                    Update employee | تعديل موظف
DELETE /api/employees/{id}                    Delete employee | حذف موظف
POST   /api/employees/{id}/app-access         Toggle app access | تفعيل/إيقاف دخول التطبيق

GET    /api/attendance?date=YYYY-MM-DD        Daily attendance records | سجلات الحضور اليومي
POST   /api/attendance                        Create/update record (admin) | إنشاء/تحديث سجل (أدمن)
PUT    /api/attendance/{id}                   Edit record | تعديل سجل حضور
POST   /api/attendance/check-in               Employee check-in | تسجيل حضور (موظف)
POST   /api/attendance/check-out              Employee check-out | تسجيل انصراف (موظف)

GET    /api/leave-requests?page=&status=      Leave requests (paginated+filter) | طلبات الإجازات
POST   /api/leave-requests                    Submit leave request | تقديم طلب إجازة
POST   /api/leave-requests/{id}/approve       Approve leave | موافقة على إجازة
POST   /api/leave-requests/{id}/reject        Reject leave | رفض إجازة
GET    /api/leave-balances                    Leave balances | أرصدة الإجازات

GET    /api/payroll?month=YYYY-MM&page=       Payroll list (paginated) | كشوف الرواتب
POST   /api/payroll/generate                  Generate monthly payroll | توليد رواتب الشهر

GET    /api/jobs                              Job listings | قائمة الوظائف
POST   /api/jobs                              Create job | إضافة وظيفة
GET    /api/jobs/{id}                         Job details + candidates | تفاصيل وظيفة + المرشحين
PUT    /api/jobs/{id}                         Update job | تعديل وظيفة
DELETE /api/jobs/{id}                         Delete job | حذف وظيفة
POST   /api/jobs/{id}/candidates              Add candidate | إضافة مرشح
PUT    /api/jobs/{id}/candidates/{cid}        Update candidate stage | تحديث مرحلة المرشح
DELETE /api/jobs/{id}/candidates/{cid}        Remove candidate | حذف مرشح

GET    /api/notifications                     Notification list | قائمة الإشعارات
PATCH  /api/notifications/{id}/read           Mark as read | تعليم مقروء
POST   /api/notifications/read-all            Mark all read | تعليم الكل مقروء
DELETE /api/notifications/{id}                Delete notification | حذف إشعار

GET    /api/company                           Company settings | إعدادات الشركة
PUT    /api/company                           Update company settings | تحديث إعدادات الشركة
```

---

## 🔒 Security | الأمان

| Measure / الإجراء | Details / التفاصيل |
|------------------|-------------------|
| **Sanctum** | Token-based authentication for every request |
| **Role Middleware** | `company_admin` / `employee` — enforced on all routes |
| **Rate Limiting** | Login: 10/min · Register/Forgot: 5/min |
| **Security Headers** | `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`, `HSTS` |
| **CORS** | Configurable via `.env` (`ALLOWED_ORIGINS`) |
| **LIKE Injection** | Search inputs sanitized before DB queries |
| **HTTPS Validation** | App rejects non-HTTPS API URLs in production |

---

## 🌍 Language Support | الدعم اللغوي

| Language / اللغة | Direction / الاتجاه | Font / الخط |
|-----------------|--------------------|-----------:|
| **Arabic / العربية** | RTL | Cairo |
| **English / الإنجليزية** | LTR | Default |

Switch from **Settings → Language** | التبديل من **Settings → Language**

---

## 💳 Subscription Plans | خطط الاشتراك

| Plan / الخطة | Employees / الموظفون | Recruitment / التوظيف |
|-------------|--------------------|--------------------|
| **Starter** | Up to 25 / حتى 25 | ❌ |
| **Growth** | Up to 50 / حتى 50 | ✅ |
| **Enterprise** | Up to 200 / حتى 200 | ✅ + AI |

---

## 🧪 Tests | الاختبارات

```bash
# Laravel (56 tests)
cd backend && php artisan test

# Flutter (38 tests)
flutter test
```

**Coverage / التغطية:**
- Auth: register, login, logout, forgot/reset password
- Employees: CRUD, search, company isolation, role protection
- Attendance: check-in/out, admin edit, company isolation
- Leave: pagination, status filter, approve/reject
- Notifications: CRUD, read, company isolation
- Recruitment: jobs + candidates CRUD, stage updates
- Payroll: generate, idempotency, pagination
- Company settings: get/update, validation
- Flutter: model parsing, repositories, utilities

---

## 🛠️ Tech Stack | التقنيات المستخدمة

### Frontend
| Tech | Usage |
|------|-------|
| **Flutter 3.x** | Web Admin + Mobile Employee App |
| **GoRouter 17** | Client-side navigation with fade transitions |
| **pdf + printing** | PDF payslip generation |
| **network_info_plus** | WiFi-based attendance gating |
| **shared_preferences** | Local session storage |
| **flutter_localizations** | Arabic/English i18n (ARB) |

### Backend
| Tech | Usage |
|------|-------|
| **Laravel 13** | REST API |
| **Sanctum** | Token authentication |
| **SQLite** | Development database |
| **MySQL** | Production database |
| **PHPUnit** | Feature testing (56 tests) |

---

## 🏢 Multi-Tenant Architecture | هيكل الـ SaaS

The project uses a **shared-database multi-tenant** model — every company is fully isolated:

يعتمد المشروع نموذج **Multi-tenant** بقاعدة بيانات مشتركة — كل شركة مستقلة تمامًا:

- `company_id` on every table / موجود على كل الجداول
- Every API query automatically filtered by `$user->company_id` / كل API تُفلتر تلقائياً
- Admin of Company A cannot access Company B's data / لا يمكن لأدمن شركة الوصول لبيانات شركة أخرى

---

## 🔮 Roadmap | الميزات المستقبلية

- **Stripe Billing** — Real subscription payments / الدفع الحقيقي للاشتراكات
- **Super Admin** — Dashboard to manage all companies / لوحة لإدارة كل الشركات
- **Push Notifications** — Firebase Cloud Messaging
- **AI Assistant** — Claude / GPT integration / تكامل مع Claude أو GPT

---

## 👨‍💻 Developer | المطوّر

**Ahmed Ehab Mohammed**  
Email: ahmed96it96@gmail.com  
Built with Flutter + Laravel
