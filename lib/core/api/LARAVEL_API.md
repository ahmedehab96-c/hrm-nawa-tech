# ربط التطبيق مع Laravel API

## التشغيل السريع (مشروع Laravel داخل `backend/`)

```bash
cd backend
cp .env.example .env   # إن لزم — المفتاح وقاعدة SQLite جاهزة غالباً
php artisan serve --host=0.0.0.0 --port=8000
```

في تطبيق Flutter: **الإعدادات** → عنوان **Base URL** = `http://127.0.0.1:8000/api/` (أو جهازك على الشبكة) → فعّل **استخدام الخادم**.

> الويب (Chrome): إن واجهت CORS، استخدم نفس الجهاز وعنوان `127.0.0.1` أو أضف نطاقك في `backend/config/cors.php`.

## المصادقة (Sanctum)

- `POST /api/register` — الجسم: `name`, `email`, `password`, `password_confirmation` (اختياري: `company_name` يستبدل الاسم المعروض). يُنشئ مستخدمًا بدور **`company_admin`** (لوحة الويب).
- `POST /api/login` — الجسم: `email`, `password`.
- الاستجابة: `{ "token": "...", "user": { "id", "name", "email", "role" } }`.
  - **`role`**: `company_admin` | `employee` | … — تطبيق Flutter يفرض: **الويب للإدارة فقط**، **تطبيق الجوال لحسابات `employee` فقط** (انظر منطق العميل).

باقي الطلبات تتطلب الرأس: `Authorization: Bearer {token}` و`Accept: application/json`.

### صلاحية دخول تطبيق الموظف (من الأدمن)

- عند **إضافة موظف** يمكن إرسال: `enable_app_login: true` مع `password` و`password_confirmation` (نفس بريد الموظف `email` يُستخدم كاسم مستخدم في التطبيق). يُنشئ سجل `users` بدور **`employee`**.
- **بعد الإنشاء / للموظفين الحاليين**: `POST /api/employees/{id}/app-access` — الجسم:
  - `{ "enabled": false }` — إلغاء دخول التطبيق (حذف مستخدم الموظف المرتبط بالبريد).
  - `{ "enabled": true, "password": "...", "password_confirmation": "..." }` — تفعيل أو **تغيير كلمة مرور** التطبيق.

قائمة الموظفين والتفاصيل تتضمن **`app_login_enabled`** (هل يوجد حساب تطبيق نشط لهذا البريد).

## نقاط النهاية (REST)

- **الموظفون**: `GET/POST /api/employees`، `GET/PUT /api/employees/{id}`، `POST /api/employees/{id}/app-access`
- **الحضور**: `GET /api/attendance`، `POST /api/attendance/check-in`، `POST /api/attendance/check-out`
- **الإجازات**: `GET /api/leave-requests`، `POST /api/leave-requests` (طلب جديد)، `GET /api/leave-balances`، `POST /api/leave-requests/{id}/approve|reject`
- **الرواتب**: `GET /api/payroll?month=YYYY-MM`
- **الإشعارات**: `GET /api/notifications`

التطبيق يقبل JSON كقائمة مباشرة أو `{ "data": [ ... ] }` حيث ينطبق ذلك.

بدون تفعيل «استخدام الخادم» يعمل Flutter ببيانات تجريبية محلية.
