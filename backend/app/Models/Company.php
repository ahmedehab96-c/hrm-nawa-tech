<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    protected $fillable = [
        'name',
        'email',
        'phone',
        'address',
        'wifi_ssid',
        'status',
        'ai_plan',
        'ai_enabled',
        'ai_provider',
        'ai_model',
        'ai_requests_per_minute',
        'ai_monthly_token_limit',
        'ai_feature_flags',
        'ai_rollout_percentage',
        'ai_safety_level',
        'ai_alert_error_rate_threshold',
        'ai_alert_p95_latency_ms_threshold',
        'ai_alert_queue_failure_threshold',
        'ai_slo_target_success_rate',
        'ai_burn_rate_alert_threshold',
        'ai_cost_anomaly_multiplier',
        'ai_alert_channels',
        'ai_escalation_matrix',
        'ai_alert_email_from',
        'ai_slack_webhook_url',
        'ai_silence_windows',
        'ai_runbook_links',
        'ai_digest_enabled',
        'ai_digest_window_minutes',
    ];

    protected function casts(): array
    {
        return [
            'ai_enabled' => 'boolean',
            'ai_requests_per_minute' => 'integer',
            'ai_monthly_token_limit' => 'integer',
            'ai_feature_flags' => 'array',
            'ai_rollout_percentage' => 'integer',
            'ai_alert_error_rate_threshold' => 'float',
            'ai_alert_p95_latency_ms_threshold' => 'integer',
            'ai_alert_queue_failure_threshold' => 'integer',
            'ai_slo_target_success_rate' => 'float',
            'ai_burn_rate_alert_threshold' => 'float',
            'ai_cost_anomaly_multiplier' => 'float',
            'ai_alert_channels' => 'array',
            'ai_escalation_matrix' => 'array',
            'ai_silence_windows' => 'array',
            'ai_runbook_links' => 'array',
            'ai_digest_enabled' => 'boolean',
            'ai_digest_window_minutes' => 'integer',
        ];
    }
}
