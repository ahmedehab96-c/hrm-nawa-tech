# Deploy Guide | دليل النشر

> Host the **portfolio demo** live — Flutter Web admin + Laravel API in one stack.

---

## English — Quick start (Docker)

### Prerequisites
- Docker + Docker Compose
- Flutter SDK (to build web once)

### 1. Build Flutter Web

```bash
chmod +x scripts/build_web_portfolio.sh
./scripts/build_web_portfolio.sh
```

This builds with `--dart-define=API_BASE_URL=/api` so the web app talks to the API through nginx on the same host.

### 2. Start the stack

```bash
docker compose up --build
```

### 3. Open the demo

| URL | Purpose |
|-----|---------|
| http://localhost:8080/welcome | Landing page |
| http://localhost:8080/login | Admin login |

**Credentials:** `admin@demo.com` / `Admin12345!`

The API runs behind nginx at `/api` (auto-seeded on first start).

### Stop

```bash
docker compose down
```

To reset data:

```bash
docker compose down -v
docker compose up --build
```

---

## English — Production tips

| Topic | Recommendation |
|-------|----------------|
| **HTTPS** | Put Caddy/Traefik or cloud load balancer in front |
| **APP_KEY** | Set fixed `APP_KEY` in compose/env for stable sessions |
| **Database** | SQLite is fine for demo; use MySQL for multi-tenant SaaS later |
| **Flutter API URL** | Full URL: `--dart-define=API_BASE_URL=https://hrm.example.com/api` |
| **CORS** | Set `ALLOWED_ORIGINS` in backend `.env` when web/API are on different domains |

### Example: API only (Render / Railway)

1. Deploy `backend/Dockerfile` as a web service (port 8000)
2. Set env: `APP_KEY`, `APP_URL`, `DB_CONNECTION=sqlite`
3. Build Flutter web with full API URL pointing to your hosted API

### Example: Static web (Netlify / Vercel) + API elsewhere

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://your-api.onrender.com/api
```

Upload `build/web` to static hosting. Enable CORS on the API for your web domain.

---

## العربية — البدء السريع (Docker)

### المتطلبات
- Docker + Docker Compose
- Flutter SDK (لبناء الويب مرة واحدة)

### 1. بناء Flutter Web

```bash
chmod +x scripts/build_web_portfolio.sh
./scripts/build_web_portfolio.sh
```

### 2. تشغيل المنصة

```bash
docker compose up --build
```

### 3. افتح العرض

| الرابط | الغرض |
|--------|--------|
| http://localhost:8080/welcome | صفحة الترحيب |
| http://localhost:8080/login | دخول الأدمن |

**الدخول:** `admin@demo.com` / `Admin12345!`

الـ API يعمل خلف nginx على `/api` مع بيانات تجريبية تلقائية.

### إيقاف / إعادة ضبط

```bash
docker compose down          # إيقاف
docker compose down -v       # حذف البيانات
docker compose up --build    # إعادة التشغيل
```

---

## العربية — نصائح الإنتاج

| الموضوع | التوصية |
|---------|---------|
| **HTTPS** | ضع Caddy أو موازن تحميل أمام الخدمات |
| **APP_KEY** | ثبّت مفتاحاً ثابتاً في البيئة |
| **قاعدة البيانات** | SQLite للعرض؛ MySQL لاحقاً لـ SaaS |
| **عنوان API** | `--dart-define=API_BASE_URL=https://hrm.example.com/api` |
| **CORS** | عيّن `ALLOWED_ORIGINS` عند فصل الويب عن الـ API |

---

## Architecture

```
Browser → nginx:80 (web container)
            ├── /        → Flutter build/web (static)
            └── /api/*   → Laravel api:8000
```

Mobile employee app: point API URL to your hosted API (or LAN IP in dev).
