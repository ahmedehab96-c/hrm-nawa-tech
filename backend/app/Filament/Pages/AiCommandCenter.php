<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\AiUsageStats;
use App\Models\AiUsageLog;
use App\Models\Company;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class AiCommandCenter extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSparkles;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 8;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.ai');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('ai_command_center');
    }

    protected string $view = 'filament.pages.ai-command-center';

    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null && (
            $user->hasRole('super_admin')
            || ($user->company_id !== null && $user->hasPermission('ai.usage.view'))
        );
    }

    /**
     * @return array<class-string>
     */
    protected function getHeaderWidgets(): array
    {
        return [
            AiUsageStats::class,
        ];
    }

    /**
     * @return array<int, array{endpoint: string, requests: int, tokens: int}>
     */
    public function getTopEndpoints(): array
    {
        $companyId = $this->companyId();
        if ($companyId === null) {
            return [];
        }

        return AiUsageLog::query()
            ->where('company_id', $companyId)
            ->whereBetween('created_at', [now()->startOfMonth(), now()->endOfMonth()])
            ->selectRaw('endpoint, COUNT(*) as requests, COALESCE(SUM(total_tokens),0) as tokens')
            ->groupBy('endpoint')
            ->orderByDesc('requests')
            ->limit(8)
            ->get()
            ->map(fn ($row) => [
                'endpoint' => (string) $row->endpoint,
                'requests' => (int) $row->requests,
                'tokens' => (int) $row->tokens,
            ])
            ->all();
    }

    public function getCompany(): ?Company
    {
        $id = $this->companyId();

        return $id ? Company::query()->find($id) : null;
    }

    protected function companyId(): ?int
    {
        $user = auth()->user();
        if ($user === null) {
            return null;
        }
        if ($user->hasRole('super_admin')) {
            return null;
        }

        return $user->company_id !== null ? (int) $user->company_id : null;
    }
}
