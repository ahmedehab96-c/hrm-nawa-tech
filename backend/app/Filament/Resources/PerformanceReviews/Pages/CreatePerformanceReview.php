<?php

namespace App\Filament\Resources\PerformanceReviews\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\PerformanceReviews\PerformanceReviewResource;
use Filament\Resources\Pages\CreateRecord;

class CreatePerformanceReview extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = PerformanceReviewResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $user = auth()->user();
        if ($user !== null && ! $user->hasRole('super_admin') && $user->company_id !== null) {
            $data['company_id'] = $user->company_id;
        }
        $data['reviewer_user_id'] = auth()->id();
        if (empty($data['reviewed_at'])) {
            $data['reviewed_at'] = now();
        }

        return $data;
    }
}
