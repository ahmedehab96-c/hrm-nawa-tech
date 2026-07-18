<?php

namespace App\Services;

use App\Models\LeaveRecommendation;
use App\Models\LeaveRequest;

class LeaveRecommendationService
{
    public function __construct(
        private readonly HrInsightsService $hrInsightsService,
        private readonly LeaveBalanceService $leaveBalanceService,
    ) {}

    /**
     * @return array{record: LeaveRecommendation, remaining_balance: float, recommendation: array{action: string, confidence: float, reason: string}}
     */
    public function recommend(LeaveRequest $leave, int $generatedByUserId): array
    {
        $leave->loadMissing('employee:id,name');

        $remaining = $this->leaveBalanceService->remainingBalanceForType(
            (int) $leave->company_id,
            (int) $leave->employee_id,
            (string) $leave->type,
        );

        $recommendation = $this->hrInsightsService->buildLeaveRecommendation(
            leave: $leave,
            remainingBalanceForType: $remaining,
        );

        $record = LeaveRecommendation::query()->create([
            'company_id' => $leave->company_id,
            'leave_request_id' => $leave->id,
            'generated_by' => $generatedByUserId,
            'recommended_action' => $recommendation['action'],
            'confidence_score' => $recommendation['confidence'],
            'reason' => $recommendation['reason'],
            'engine' => 'rule-engine-v1',
        ]);

        return [
            'record' => $record,
            'remaining_balance' => $remaining,
            'recommendation' => $recommendation,
        ];
    }
}
