<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    public function show(Request $request)
    {
        $user    = $request->user();
        $company = Company::find($user->company_id);

        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        return response()->json($this->format($company));
    }

    public function update(Request $request)
    {
        $user    = $request->user();
        $company = Company::find($user->company_id);

        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $request->validate([
            'name'      => 'sometimes|string|max:255',
            'email'     => 'nullable|email|max:255',
            'phone'     => 'nullable|string|max:64',
            'address'   => 'nullable|string|max:500',
            'wifi_ssid' => 'nullable|string|max:128',
            'ai_plan'   => 'sometimes|in:starter,growth,enterprise',
            'ai_enabled'=> 'sometimes|boolean',
            'ai_provider' => 'sometimes|in:openai,gemini',
            'ai_model'  => 'nullable|string|max:64',
            'ai_requests_per_minute' => 'sometimes|integer|min:1|max:600',
            'ai_monthly_token_limit' => 'sometimes|integer|min:1000|max:50000000',
            'ai_feature_flags' => 'sometimes|array',
            'ai_rollout_percentage' => 'sometimes|integer|min:0|max:100',
            'ai_safety_level' => 'sometimes|in:standard,strict',
            'ai_alert_error_rate_threshold' => 'sometimes|numeric|min:0|max:100',
            'ai_alert_p95_latency_ms_threshold' => 'sometimes|integer|min:100|max:60000',
            'ai_alert_queue_failure_threshold' => 'sometimes|integer|min:1|max:1000',
            'ai_slo_target_success_rate' => 'sometimes|numeric|min:90|max:100',
            'ai_burn_rate_alert_threshold' => 'sometimes|numeric|min:0.1|max:100',
            'ai_cost_anomaly_multiplier' => 'sometimes|numeric|min:1|max:20',
            'ai_alert_channels' => 'sometimes|array',
            'ai_alert_channels.*' => 'string|in:email,slack,in_app',
            'ai_escalation_matrix' => 'sometimes|array',
            'ai_alert_email_from' => 'sometimes|nullable|email|max:255',
            'ai_slack_webhook_url' => 'sometimes|nullable|url|max:2000',
            'ai_silence_windows' => 'sometimes|array',
            'ai_runbook_links' => 'sometimes|array',
            'ai_digest_enabled' => 'sometimes|boolean',
            'ai_digest_window_minutes' => 'sometimes|integer|min:5|max:1440',
        ]);

        $company->fill($request->only([
            'name',
            'email',
            'phone',
            'address',
            'wifi_ssid',
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
        ]));
        $company->save();

        return response()->json(['message' => 'Settings saved', 'data' => $this->format($company)]);
    }

    private function format(Company $company): array
    {
        return [
            'id'        => $company->id,
            'name'      => $company->name,
            'email'     => $company->email,
            'phone'     => $company->phone,
            'address'   => $company->address,
            'wifi_ssid' => $company->wifi_ssid,
            'status'    => $company->status,
            'plan'      => $company->plan ?? 'trial',
            'trial_ends_at' => $company->trial_ends_at?->toIso8601String(),
            'employee_limit' => $company->employeeLimit(),
            'employee_count' => $company->employeeCount(),
            'ai_plan'   => $company->ai_plan,
            'ai_enabled'=> (bool) $company->ai_enabled,
            'ai_provider' => $company->ai_provider,
            'ai_model'  => $company->ai_model,
            'ai_requests_per_minute' => $company->ai_requests_per_minute,
            'ai_monthly_token_limit' => $company->ai_monthly_token_limit,
            'ai_feature_flags' => is_array($company->ai_feature_flags) ? $company->ai_feature_flags : [],
            'ai_rollout_percentage' => (int) ($company->ai_rollout_percentage ?? 100),
            'ai_safety_level' => (string) ($company->ai_safety_level ?? 'standard'),
            'ai_alert_error_rate_threshold' => (float) ($company->ai_alert_error_rate_threshold ?? 5.0),
            'ai_alert_p95_latency_ms_threshold' => (int) ($company->ai_alert_p95_latency_ms_threshold ?? 2500),
            'ai_alert_queue_failure_threshold' => (int) ($company->ai_alert_queue_failure_threshold ?? 3),
            'ai_slo_target_success_rate' => (float) ($company->ai_slo_target_success_rate ?? 99.5),
            'ai_burn_rate_alert_threshold' => (float) ($company->ai_burn_rate_alert_threshold ?? 2.0),
            'ai_cost_anomaly_multiplier' => (float) ($company->ai_cost_anomaly_multiplier ?? 2.0),
            'ai_alert_channels' => is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'],
            'ai_escalation_matrix' => is_array($company->ai_escalation_matrix) ? $company->ai_escalation_matrix : [],
            'ai_alert_email_from' => $company->ai_alert_email_from,
            'ai_slack_webhook_url' => $company->ai_slack_webhook_url,
            'ai_silence_windows' => is_array($company->ai_silence_windows) ? $company->ai_silence_windows : [],
            'ai_runbook_links' => is_array($company->ai_runbook_links) ? $company->ai_runbook_links : [],
            'ai_digest_enabled' => (bool) ($company->ai_digest_enabled ?? true),
            'ai_digest_window_minutes' => (int) ($company->ai_digest_window_minutes ?? 60),
        ];
    }
}
