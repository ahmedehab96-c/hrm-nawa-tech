<?php

namespace App\Services;

use App\Models\AiAuditEvent;

class AiAuditService
{
    /**
     * @param  array<string,mixed>  $context
     */
    public function log(
        int $companyId,
        ?int $userId,
        string $eventType,
        string $severity = 'info',
        ?string $endpoint = null,
        array $context = [],
    ): void {
        AiAuditEvent::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'event_type' => $eventType,
            'severity' => $severity,
            'endpoint' => $endpoint,
            'context' => $context,
            'event_at' => now(),
        ]);
    }
}
