# Production checklist

Use this before exposing Nawa Tech HRM on a public domain.

## Required configuration

- `APP_ENV=production`, `APP_DEBUG=false`, and a unique `APP_KEY`
- `APP_URL=https://your-domain.example`
- `SESSION_SECURE_COOKIE=true`
- Restrict `ALLOWED_ORIGINS` to trusted HTTPS origins
- Use production database credentials; never keep demo passwords
- Configure mail, queue, scheduler, and persistent storage
- Store OpenAI/Gemini, billing, mail, and FCM keys in the hosting provider's secret manager
- Run `php artisan config:cache`, `route:cache`, and `view:cache` after deployment

## AI

- Select the provider in Company Settings and set only its server-side key
- Keep rollout, monthly token quota, request-per-minute quota, and feature flags enabled
- Verify `/api/ai/chat` returns `status=success`; fallback responses are not proof of a live provider
- Current local OpenAI key reaches the provider but is blocked by `insufficient_quota`

## Operations

- Run one web/API process, one persistent `queue:work` process, and the scheduler
- Monitor `/api/health` and `/up`
- Back up the database and uploaded files on a tested schedule
- Test restoring a backup before launch
- Send application logs to retained, access-controlled storage

## Release verification

```bash
cd backend
php artisan migrate --force
php artisan test
cd ..
flutter analyze
flutter test
SMOKE_BASE_URL=https://your-domain.example ./scripts/smoke_test.sh
```

Build mobile clients with the public HTTPS API:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-domain.example/api

flutter build ios --release \
  --dart-define=API_BASE_URL=https://your-domain.example/api
```

Do not publish the seeded demo credentials on a permanent production database.
