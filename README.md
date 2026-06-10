# HRM SaaS — نظام إدارة الموارد البشرية

> **راحة الإدارة تبدأ من هنا**

نظام SaaS متكامل لإدارة الموارد البشرية للشركات الصغيرة والمتوسطة (5–200 موظف) مبني بـ **Flutter + Laravel**، يدعم العربية والإنجليزية بشكل كامل، ويعمل على الويب والجوال في آنٍ واحد.

---

## 🎯 المميزات

### لوحة الأدمن (ويب)
| الميزة | التفاصيل |
|--------|---------|
| **المصادقة** | تسجيل الشركة، دخول الأدمن، نسيت كلمة المرور، إعادة التعيين عبر إيميل |
| **لوحة التحكم** | 4 بطاقات إحصاء، الإجازات المعلقة، النشاط الأخير |
| **الموظفون** | CRUD كامل، 5 تبويبات (شخصي، وظيفي، راتب، تأمين، دخول التطبيق)، بحث وفلترة server-side، pagination |
| **الحضور** | جدول يومي مع date picker، تعديل وقت الدخول/الخروج والحالة، إنشاء سجل للغائبين، إحصائيات فورية |
| **الإجازات** | عرض الطلبات مع فلترة الحالة، موافقة/رفض، أرصدة الإجازات per موظف |
| **الرواتب** | توليد كشوف الرواتب، تفاصيل القسيمة، تحميل PDF احترافي |
| **التوظيف** | إدارة الوظائف (CRUD)، pipeline مرشحين (Kanban)، تحديث المراحل، تحويل مرشح لموظف |
| **الإشعارات** | قائمة كاملة، تعليم مقروء/غير مقروء، "تعليم الكل"، حذف بالسحب |
| **الإعدادات** | معلومات الشركة (تحفظ للـ API)، WiFi للحضور، الأدوار والصلاحيات، الاشتراكات |

### تطبيق الموظف (موبايل)
| الميزة | التفاصيل |
|--------|---------|
| **الرئيسية** | حالة WiFi، أزرار تسجيل الدخول/الخروج، إجراءات سريعة |
| **الحضور** | تسجيل الدخول/الخروج (مقيّد بـ WiFi الشركة)، سجل 7 أيام |
| **الإجازات** | طلب إجازة، عرض الرصيد والتاريخ |
| **الراتب** | عرض قسيمة الراتب الشهرية، تحميل PDF |
| **الملف الشخصي** | بيانات الموظف، الوثائق |
| **الإشعارات** | عرض وقراءة وحذف الإشعارات |

---

## 🏗️ المعمارية

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
│   │   └── widgets/              # HrmLogo, StatCard, StatusBadge
│   ├── features/
│   │   ├── admin/                # لوحة الأدمن (ويب)
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
│   │   └── employee/             # تطبيق الموظف (موبايل)
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

## 🚀 تشغيل المشروع

### المتطلبات
- Flutter 3.x
- PHP 8.3+ & Composer
- SQLite (مدمج) أو MySQL

### 1 — الباكند

```bash
cd backend

# تثبيت الحزم
composer install

# إعداد البيئة
cp .env.example .env
php artisan key:generate

# قاعدة البيانات + بيانات تجريبية
php artisan migrate:fresh --seed

# تشغيل السيرفر
php artisan serve
# → http://127.0.0.1:8000
```

### 2 — Flutter

```bash
# تثبيت الحزم
flutter pub get

# لوحة الأدمن (ويب)
flutter run -d chrome

# تطبيق الموظف (موبايل)
flutter run -d android   # أو -d ios
```

### 3 — ربط الفرونتند بالباكند

في التطبيق: **Settings → Server** → أدخل `http://127.0.0.1:8000/api` → فعّل "Use server"

> ملاحظة: التطبيق يعمل بدون سيرفر (Demo Mode) بيانات تجريبية جاهزة.

---

## 🔑 بيانات الدخول التجريبية

| الدور | البريد | كلمة المرور |
|-------|--------|------------|
| **Admin** | `admin@demo.com` | `Admin12345!` |
| **Employee** | `emp01@demo.com` | `Employee12345!` |
| Employee 2 | `emp02@demo.com` | `Employee12345!` |

---

## 📡 API Endpoints

```
POST   /api/register                          تسجيل شركة جديدة
POST   /api/login                             تسجيل الدخول
POST   /api/logout                            تسجيل الخروج (إبطال التوكن)
POST   /api/forgot-password                   إرسال رابط استعادة كلمة المرور
POST   /api/reset-password                    إعادة تعيين كلمة المرور

GET    /api/employees?page=&search=&dept=     قائمة الموظفين (paginated)
POST   /api/employees                         إضافة موظف
GET    /api/employees/{id}                    تفاصيل موظف
PUT    /api/employees/{id}                    تعديل موظف
DELETE /api/employees/{id}                    حذف موظف
POST   /api/employees/{id}/app-access         تفعيل/إيقاف دخول التطبيق

GET    /api/attendance?date=YYYY-MM-DD        سجلات الحضور اليومي
POST   /api/attendance                        إنشاء/تحديث سجل حضور (admin)
PUT    /api/attendance/{id}                   تعديل سجل حضور
POST   /api/attendance/check-in               تسجيل حضور (موظف)
POST   /api/attendance/check-out              تسجيل انصراف (موظف)

GET    /api/leave-requests?page=&status=      طلبات الإجازات (paginated + filter)
POST   /api/leave-requests                    تقديم طلب إجازة
POST   /api/leave-requests/{id}/approve       موافقة على إجازة
POST   /api/leave-requests/{id}/reject        رفض إجازة
GET    /api/leave-balances                    أرصدة الإجازات

GET    /api/payroll?month=YYYY-MM&page=       كشوف الرواتب (paginated)
POST   /api/payroll/generate                  توليد رواتب الشهر

GET    /api/jobs                              قائمة الوظائف
POST   /api/jobs                              إضافة وظيفة
GET    /api/jobs/{id}                         تفاصيل وظيفة + المرشحين
PUT    /api/jobs/{id}                         تعديل وظيفة
DELETE /api/jobs/{id}                         حذف وظيفة
POST   /api/jobs/{id}/candidates              إضافة مرشح
PUT    /api/jobs/{id}/candidates/{cid}        تحديث مرحلة المرشح
DELETE /api/jobs/{id}/candidates/{cid}        حذف مرشح

GET    /api/notifications                     قائمة الإشعارات
PATCH  /api/notifications/{id}/read           تعليم مقروء
POST   /api/notifications/read-all            تعليم الكل مقروء
DELETE /api/notifications/{id}                حذف إشعار

GET    /api/company                           إعدادات الشركة
PUT    /api/company                           تحديث إعدادات الشركة
```

---

## 🔒 الأمان

- **Sanctum** — Token-based authentication
- **Role Middleware** — `company_admin` / `employee`
- **Rate Limiting** — Login: 10/دقيقة · Register/Forgot: 5/دقيقة
- **Security Headers** — `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`, `HSTS`
- **CORS** — قابل للتخصيص عبر `.env` (`ALLOWED_ORIGINS`)
- **LIKE Injection Prevention** — تنظيف مدخلات البحث
- **HTTPS Validation** — التطبيق يرفض روابط API غير آمنة في الإنتاج

---

## 🌍 الدعم اللغوي

- **العربية** — RTL كامل، خط Cairo
- **الإنجليزية** — LTR

التبديل من **Settings → Language**.

---

## 💳 خطط الاشتراك

| الخطة | الموظفون | التوظيف |
|-------|---------|---------|
| **Starter** | حتى 25 | ❌ |
| **Growth** | حتى 50 | ✅ |
| **Enterprise** | حتى 200 | ✅ + AI |

---

## 🧪 الاختبارات

```bash
# Laravel (56 test)
cd backend && php artisan test

# Flutter (38 test)
flutter test
```

**التغطية:**
- Auth (register, login, logout, forgot/reset password)
- Employees (CRUD, search, company isolation, role protection)
- Attendance (check-in/out, admin edit, company isolation)
- Leave (pagination, status filter, approve/reject)
- Notifications (CRUD, read, company isolation)
- Recruitment (jobs + candidates CRUD, stage updates)
- Payroll (generate, idempotency, pagination)
- Company settings (get/update, validation)
- Flutter: model parsing, repositories, utilities

---

## 🛠️ التقنيات المستخدمة

### Frontend
| التقنية | الاستخدام |
|--------|---------|
| **Flutter 3.x** | Web Admin + Mobile App |
| **GoRouter** | Client-side navigation |
| **pdf + printing** | PDF payslip generation |
| **network_info_plus** | WiFi-based attendance |
| **shared_preferences** | Local storage |
| **flutter_localizations** | Arabic/English i18n |

### Backend
| التقنية | الاستخدام |
|--------|---------|
| **Laravel 13** | REST API |
| **Sanctum** | Token authentication |
| **SQLite** | Development database |
| **MySQL** | Production database |
| **PHPUnit** | Feature testing |

---

## 📁 هيكل الـ SaaS

المشروع مبني على نموذج **Multi-tenant** — كل شركة مستقلة تمامًا عن الأخرى:
- `company_id` موجود على كل الجداول
- كل API تُفلتر تلقائياً بـ `$user->company_id`
- لا يمكن لأدمن شركة الوصول لبيانات شركة أخرى

---

## 📝 ملاحظة حول الميزات المستقبلية

- **Stripe Billing** — الدفع الحقيقي للاشتراكات
- **Super Admin** — لوحة لإدارة كل الشركات
- **Push Notifications** — Firebase Cloud Messaging
- **AI Assistant** — تكامل مع Claude أو GPT

---

## 👨‍💻 المطوّر

**Ahmed Ehab Mohammed**
- Email: ahmed96it96@gmail.com
- Built with Flutter + Laravel
