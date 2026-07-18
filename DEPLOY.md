# Deploy | النشر

> Host **Nawa Tech HRM** — Laravel (API + Filament admin) + Flutter employee mobile.
>
> Before a public launch, complete [`docs/PRODUCTION_CHECKLIST.md`](./docs/PRODUCTION_CHECKLIST.md).

## Local / VPS (Docker)

### Prerequisites
- Docker Compose
- PHP 8.3+ with `intl` (for non-Docker local runs)

### 1. Configure env

Copy backend `.env` and set `APP_KEY`, `APP_URL`, DB, mail, and AI keys as needed.

For production behind nginx or a load balancer, set:

```env
TRUSTED_PROXIES=*
APP_VERSION=1.0.0
```

### 2. Start stack

```bash
docker compose up -d --build
```

- App (nginx → Laravel): **http://localhost:8080**
- Admin: **http://localhost:8080/admin**
- API: **http://localhost:8080/api**
- Health: **http://localhost:8080/api/health**

Demo accounts:

| Role | Email | Password |
|------|-------|----------|
| Company admin | `admin@demo.com` | `Admin12345!` |
| Platform | `platform@nawatech.com` | `Platform12345!` |
| Employee (mobile) | `emp01@demo.com` | `Employee12345!` |
| HR manager | `hr@demo.com` | `HrManager12345!` |
| Recruiter | `recruiter@demo.com` | `Recruiter12345!` |

### Queue & scheduler (Docker)

The default stack runs a **queue worker** container (`queue`) for mail, leave notifications, and AI jobs.

For scheduled tasks (AI digests, monitors), enable the production profile:

```bash
docker compose --profile production up -d
```

This adds the `scheduler` service (`php artisan schedule:work`).

Set `QUEUE_CONNECTION=database` (default in Docker) so jobs persist between restarts.

### Optional MySQL

```bash
docker compose --profile mysql up -d --build
```

Set `DB_CONNECTION=mysql` and matching credentials in the `api` service env.

### CORS

Set `ALLOWED_ORIGINS` in backend `.env` when the employee app / other clients call the API from another origin.

## Local development (without Docker)

```bash
./scripts/start_api.sh          # API + Filament admin on :8000
./scripts/start_queue.sh        # queue worker (separate terminal)
./scripts/start_scheduler.sh    # scheduler (optional, separate terminal)
./scripts/smoke_test.sh         # verify /api/health and /admin
```

## Health & smoke checks

`GET /api/health` returns JSON with `status`, `version`, and checks for `app`, `database`, and `queue`.

`GET /up` is Laravel's built-in health route (used by uptime monitors).

```bash
SMOKE_BASE_URL=http://127.0.0.1:8000 ./scripts/smoke_test.sh
```

## CI

GitHub Actions workflows:

- `.github/workflows/backend_ci.yml` — PHP 8.3, migrate, `php artisan test`
- `.github/workflows/flutter_ci.yml` — `flutter analyze`, `flutter test`

Tests run without real OpenAI/Gemini keys (`OPENAI_API_KEY` and `GEMINI_API_KEY` are empty in `phpunit.xml`).

## Employee mobile builds

Point the Flutter app at your hosted API:

```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://your-domain.com/api

flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-domain.com/api
```

### Password reset deep links (employee app)

Reset emails include a mobile link using the custom scheme `nawatechhrm://reset-password?token=...&email=...`.

Email verification uses `nawatechhrm://verify-email?id=...&hash=...&expires=...&signature=...`.

Configure on the server:

```env
MOBILE_DEEP_LINK_SCHEME=nawatechhrm
FCM_SERVER_KEY=
```

The web reset page (`/reset-password`) also shows **Open in mobile app** when the scheme is set.

### Push notifications (FCM)

When `FCM_SERVER_KEY` is set, leave approvals/rejections also send push notifications to registered device tokens.

Employees register tokens via `POST /api/device-tokens` (the Flutter app supports `PUSH_TOKEN` dart-define until Firebase is wired).

## Architecture

```
Browser / Mobile
    │
    ├─ /admin/*     → Filament (session auth)
    └─ /api/*       → Laravel JSON API (Sanctum)
```

nginx proxies all traffic to the Laravel `api` container (see `deploy/nginx/default.conf`).

---

## العربية

### التشغيل بـ Docker

```bash
docker compose up -d --build
```

- اللوحة: **http://localhost:8080/admin**
- الـ API: **http://localhost:8080/api**
- الصحة: **http://localhost:8080/api/health**
- الدخول: `admin@demo.com` / `Admin12345!`

**Queue:** حاوية `queue` تعالج البريد ومهام AI تلقائياً.

**Scheduler:** `docker compose --profile production up -d` لتفعيل المهام المجدولة.

تطبيق الموظف (Flutter) يتصل بنفس الـ API عبر `API_BASE_URL`.

### التطوير المحلي

```bash
./scripts/start_api.sh
./scripts/start_queue.sh
./scripts/smoke_test.sh
```
