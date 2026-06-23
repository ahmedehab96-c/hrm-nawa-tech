# Demo Guide | دليل التجربة

---

## English

### Purpose

This is a **portfolio project** to demonstrate full-stack HR software skills (Flutter + Laravel + AI).  
Use the credentials below — **no registration required**.

### Step 1 — Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

### Step 2 — Admin (Web)

```bash
flutter pub get
flutter run -d chrome --web-port=3000
```

- Open **http://localhost:3000/welcome**
- Click **Try Admin Dashboard** / **جرّب لوحة الإدارة**
- Or go directly to **http://localhost:3000/login**

| Field | Value |
|-------|-------|
| Email | `admin@demo.com` |
| Password | `Admin12345!` |

### Step 3 — Employee (Mobile)

```bash
flutter run -d ios   # or: flutter run -d android
```

1. Open **Settings**
2. Enable **Use server API**
3. Base URL: `http://127.0.0.1:8000/api`
4. Login:

| Field | Value |
|-------|-------|
| Email | `emp01@demo.com` |
| Password | `Employee12345!` |

> On a **physical phone**, replace `127.0.0.1` with your computer's LAN IP (e.g. `http://192.168.1.10:8000/api`).

### Recommended tour

1. **Dashboard** — overview stats  
2. **Employees** — list & profiles  
3. **Attendance** — daily records  
4. **AI Command Center** — assistant, reports, monitoring  
5. **Recruitment** — jobs & candidate matching  
6. Switch language **AR ↔ EN** in the top bar  

---

## العربية

### الغرض

هذا **مشروع Portfolio** لعرض مهارات بناء أنظمة HR (Flutter + Laravel + AI).  
استخدم بيانات الدخول أدناه — **لا يلزم تسجيل حساب جديد**.

### الخطوة 1 — الباكند

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```

### الخطوة 2 — لوحة الإدارة (ويب)

```bash
flutter pub get
flutter run -d chrome --web-port=3000
```

- افتح **http://localhost:3000/welcome**
- اضغط **جرّب لوحة الإدارة**
- أو مباشرة: **http://localhost:3000/login**

| الحقل | القيمة |
|-------|--------|
| البريد | `admin@demo.com` |
| كلمة المرور | `Admin12345!` |

### الخطوة 3 — تطبيق الموظف (موبايل)

```bash
flutter run -d ios   # أو: flutter run -d android
```

1. افتح **الإعدادات**
2. فعّل **Use server API**
3. العنوان: `http://127.0.0.1:8000/api`
4. سجّل الدخول:

| الحقل | القيمة |
|-------|--------|
| البريد | `emp01@demo.com` |
| كلمة المرور | `Employee12345!` |

> على **هاتف حقيقي**، استبدل `127.0.0.1` بـ IP جهازك على الشبكة (مثل `http://192.168.1.10:8000/api`).

### جولة مقترحة

1. **لوحة التحكم** — إحصائيات عامة  
2. **الموظفون** — القائمة والملفات  
3. **الحضور** — سجلات اليوم  
4. **مركز AI** — المساعد والتقارير والمراقبة  
5. **التوظيف** — الوظائف ومطابقة المرشحين  
6. بدّل اللغة **عربي ↔ English** من الشريط العلوي  

---

## Demo company | شركة العرض

- **Name:** HRM Portfolio Demo  
- **Admin:** `admin@demo.com`  
- **Employees:** `emp01@demo.com` … `emp10@demo.com` (password: `Employee12345!`)
