<?php

namespace App\Filament\Resources\PayrollRecords\Pages;

use App\Filament\Resources\PayrollRecords\PayrollRecordResource;
use App\Services\PayrollGenerationService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\CreateAction;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ListRecords;

class ListPayrollRecords extends ListRecords
{
    protected static string $resource = PayrollRecordResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('generatePayroll')
                ->label(AdminTrans::action('generate_payroll'))
                ->icon('heroicon-o-calculator')
                ->form([
                    TextInput::make('month')
                        ->label(AdminTrans::field('month'))
                        ->helperText(AdminTrans::helpers('month_yyyy_mm'))
                        ->default(now()->format('Y-m'))
                        ->required()
                        ->regex('/^\d{4}-\d{2}$/'),
                ])
                ->requiresConfirmation()
                ->modalDescription(AdminTrans::helpers('generate_payroll_modal'))
                ->action(function (array $data): void {
                    $companyId = auth()->user()?->company_id;
                    abort_unless($companyId !== null, 403);

                    $count = app(PayrollGenerationService::class)->generate(
                        (int) $companyId,
                        $data['month'],
                    );

                    Notification::make()
                        ->title(AdminTrans::notification('payroll_generated', ['count' => (string) $count]))
                        ->success()
                        ->send();
                }),
            CreateAction::make(),
        ];
    }
}
