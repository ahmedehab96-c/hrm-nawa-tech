# Demo Guide | دليل التجربة

> Quick reference for recruiters and employers.  
> مرجع سريع لأصحاب العمل والمسؤولين عن التوظيف.

---

## English

### Purpose

This is a **portfolio project** demonstrating full-stack HR software (Flutter + Laravel + AI).  
**No registration required** — use the demo credentials below.

### Demo credentials

| Role | Platform | Email | Password |
|------|----------|-------|----------|
| **Admin** | Web (Chrome) | `admin@demo.com` | `Admin12345!` |
| **Employee** | Mobile (iOS/Android) | `emp01@demo.com` | `Employee12345!` |

Demo company: **HRM Portfolio Demo**

---

### Step 1 — Backend API

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

API: `http://127.0.0.1:8000/api`

---

### Step 2 — Admin Dashboard (Web)

```bash
flutter pub get
flutter run -d chrome --web-port=3000
```

1. Open `http://localhost:3000/welcome`
2. Click **Try Admin Dashboard**
3. Login with `admin@demo.com` / `Admin12345!`

**Explore:** Dashboard → Employees → Attendance → Leave → Payroll → Recruitment → **AI Command Center**

---

### Step 3 — Employee App (Mobile)

```bash
flutter run -d ios     # or: flutter run -d android
```

1. **Settings** → enable **Use server API**
2. Base URL: `http://127.0.0.1:8000/api`
3. Login with `emp01@demo.com` / `Employee12345!`

> **Physical phone:** use your PC's LAN IP, e.g. `http://192.168.1.10:8000/api`

**Explore:** Home → Check-in/out → Leave request → Payslip → Notifications

---

### Step 4 — Language & Theme

- Toggle **AR ↔ EN** from the top bar (admin) or settings
- Toggle **Dark / Light** mode from settings

---

### Troubleshooting

| Issue | Fix |
|-------|-----|
| Login fails | Ensure `php artisan serve` is running |
| Mobile can't connect | Use LAN IP, not `127.0.0.1` on real device |
| Old Flutter icon | Uninstall app, run `flutter run` again |
| Empty data | Run `php artisan migrate:fresh --seed` |

---

## العربية

### الغرض

هذا **مشروع Portfolio** يعرض بناء أنظمة HR (Flutter + Laravel + AI).  
**لا يلزم تسجيل** — استخدم بيانات الدخول التجريبية أدناه.

### بيانات الدخول

| الدور | المنصة | البريد | كلمة المرور |
|-------|--------|--------|-------------|
| **أدمن** | ويب (Chrome) | `admin@demo.com` | `Admin12345!` |
| **موظف** | موبايل (iOS/Android) | `emp01@demo.com` | `Employee12345!` |

شركة العرض: **HRM Portfolio Demo**

---

### الخطوة 1 — API الباكند

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

الـ API: `http://127.0.0.1:8000/api`

---

### الخطوة 2 — لوحة الإدارة (ويب)

```bash
flutter pub get
flutter run -d chrome --web-port=3000
```

1. افتح `http://localhost:3000/welcome`
2. اضغط **جرّب لوحة الإدارة**
3. سجّل دخول: `admin@demo.com` / `Admin12345!`

**جرّب:** لوحة التحكم → الموظفون → الحضور → الإجازات → الرواتب → التوظيف → **مركز AI**

---

### الخطوة 3 — تطبيق الموظف (موبايل)

```bash
flutter run -d ios     # أو: flutter run -d android
```

1. **الإعدادات** → فعّل **Use server API**
2. العنوان: `http://127.0.0.1:8000/api`
3. سجّل دخول: `emp01@demo.com` / `Employee12345!`

> **هاتف حقيقي:** استخدم IP جهازك على الشبكة، مثل `http://192.168.1.10:8000/api`

**جرّب:** الرئيسية → حضور/انصراف → طلب إجازة → قسيمة راتب → إشعارات

---

### الخطوة 4 — اللغة والثيم

- بدّل **عربي ↔ English** من الشريط العلوي (أدمن) أو الإعدادات
- بدّل **الوضع الليلي / النهاري** من الإعدادات

---

### حل المشاكل

| المشكلة | الحل |
|---------|------|
| فشل تسجيل الدخول | تأكد أن `php artisan serve` يعمل |
| الموبايل لا يتصل | استخدم IP الشبكة وليس `127.0.0.1` على جهاز حقيقي |
| أيقونة Flutter القديمة | احذف التطبيق وأعد `flutter run` |
| بيانات فارغة | شغّل `php artisan migrate:fresh --seed` |

---

## Future SaaS | التحويل لاحقاً إلى SaaS

This project can be extended to a **multi-company SaaS platform** with subscription billing.  
The backend already uses `company_id` tenant isolation — only billing and registration UI need to be added.

يمكن توسيع المشروع لاحقاً إلى **منصة SaaS متعددة الشركات** مع اشتراكات مدفوعة.  
الباكند يدعم عزل الشركات عبر `company_id` — يبقى إضافة الفوترة وواجهة التسجيل.

See [README.md — Future SaaS section](./README.md#-future-saas-multi-tenant-platform--المستقبل-منصة-saas-متعددة-الشركات)
