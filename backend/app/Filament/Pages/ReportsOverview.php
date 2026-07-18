<?php

namespace App\Filament\Pages;

use App\Filament\Resources\ReportSummaries\ReportSummaryResource;
use App\Models\Company;
use App\Services\HrMetricsService;
use App\Services\ReportGenerationService;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class ReportsOverview extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBar;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 9;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.reports');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('hr_reports');
    }

    protected string $view = 'filament.pages.reports-overview';

    public ?string $periodStart = null;

    public ?string $periodEnd = null;

    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null
            && $user->company_id !== null
            && $user->hasPermission('reports.ai.summarize');
    }

    public function mount(): void
    {
        $this->periodStart = now()->startOfMonth()->toDateString();
        $this->periodEnd = now()->endOfMonth()->toDateString();
    }

    /**
     * @return array<string, int>
     */
    public function getMetrics(): array
    {
        $company = $this->company();
        if ($company === null || ! $this->periodStart || ! $this->periodEnd) {
            return [];
        }

        return app(HrMetricsService::class)->aggregate(
            $company->id,
            $this->periodStart,
            $this->periodEnd,
        );
    }

    protected function company(): ?Company
    {
        $id = auth()->user()?->company_id;

        return $id ? Company::query()->find($id) : null;
    }

    /**
     * @return array<Action>
     */
    protected function getHeaderActions(): array
    {
        return [
            Action::make('generateReport')
                ->label(AdminTrans::action('generate_summary'))
                ->icon('heroicon-o-sparkles')
                ->form([
                    DatePicker::make('period_start')
                        ->label(AdminTrans::field('period_start'))
                        ->default($this->periodStart)
                        ->required(),
                    DatePicker::make('period_end')
                        ->label(AdminTrans::field('period_end'))
                        ->default($this->periodEnd)
                        ->required()
                        ->afterOrEqual('period_start'),
                    Select::make('report_type')
                        ->label(AdminTrans::field('report_type'))
                        ->options(AdminTrans::options('report_type'))
                        ->default('hr_overview')
                        ->required(),
                    Select::make('language_code')
                        ->options(AdminTrans::options('language'))
                        ->default('en'),
                    Toggle::make('with_ai')
                        ->label(AdminTrans::blade('include_ai_narrative'))
                        ->default(true),
                ])
                ->action(function (array $data): void {
                    $company = $this->company();
                    $user = auth()->user();
                    abort_unless($company !== null && $user !== null, 404);

                    $record = app(ReportGenerationService::class)->generate(
                        company: $company,
                        user: $user,
                        periodStart: $data['period_start'],
                        periodEnd: $data['period_end'],
                        reportType: $data['report_type'],
                        languageCode: $data['language_code'] ?? 'en',
                        withAiNarrative: (bool) ($data['with_ai'] ?? true),
                    );

                    Notification::make()
                        ->title(AdminTrans::notification('report_generated'))
                        ->success()
                        ->send();

                    $this->redirect(ReportSummaryResource::getUrl('view', ['record' => $record]));
                }),
        ];
    }
}
