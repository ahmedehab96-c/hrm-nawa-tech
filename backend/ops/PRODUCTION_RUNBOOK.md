# HRM Nawa Backend Production Operations

This runbook keeps AI escalation delivery and digest scheduling healthy in production.

## 1) Required Processes

- Queue workers must be running (for notifications and digest jobs).
- Laravel scheduler must run every minute.

## 2) Cron (recommended for scheduler)

Add this cron entry for the `deploy` user (`crontab -e`):

```cron
* * * * * cd /var/www/hrm-nawa/backend && php artisan schedule:run >> /dev/null 2>&1
```

Configured path for your environment: `/var/www/hrm-nawa/backend`.

## 3) Supervisor for Queue Workers

Use the included config (already set for user `deploy` and path `/var/www/hrm-nawa/backend`):

- `ops/supervisor/hrm-nawa-workers.conf`

Install/link it on the server, then run:

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status
```

## 4) Post-Deploy Commands

Run after each deploy:

```bash
php artisan config:cache
php artisan route:cache
php artisan migrate --force
php artisan queue:restart
```

## 5) Operational Verification

Quick checks:

```bash
php artisan schedule:list
php artisan ai:escalation-health
php artisan ai:queue-health-monitor --dry-run
php artisan ai:escalation-digest --dry-run --sync
php artisan queue:failed
```

API checks (authenticated):

- `GET /api/ai/escalation/notifications`
- `GET /api/ai/escalation/runbooks`

## 6) Incident Notes

- If queue workers are down, escalation notifications stay in `queued`.
- If a silence window is active, notifications are recorded as `suppressed`.
- Digest dispatch depends on `ai_digest_enabled` and `ai_digest_window_minutes` company settings.
- Automated queue-failure self-monitor runs every 5 minutes via `ai:queue-health-monitor`.
