<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\LeaveRequests\LeaveRequestResource;
use App\Models\LeaveRequest;
use App\Services\LeaveDecisionService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class PendingLeaveWidget extends TableWidget
{
    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 2;

    public function getHeading(): ?string
    {
        return AdminTrans::widget('pending_leave_requests');
    }

    public static function canView(): bool
    {
        $user = auth()->user();

        return $user !== null
            && ! $user->hasRole('super_admin')
            && $user->company_id !== null;
    }

    public function table(Table $table): Table
    {
        $companyId = auth()->user()?->company_id;

        return $table
            ->query(
                LeaveRequest::query()
                    ->when($companyId, fn ($q) => $q->where('company_id', $companyId))
                    ->where('status', 'pending')
                    ->with('employee:id,name')
                    ->latest()
                    ->limit(8),
            )
            ->columns([
                TextColumn::make('employee.name')->label(AdminTrans::field('employee')),
                TextColumn::make('type')
                    ->label(AdminTrans::field('type'))
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('leave_type', $state)),
                TextColumn::make('from_date')->label(AdminTrans::field('from_date'))->date(),
                TextColumn::make('to_date')->label(AdminTrans::field('to_date'))->date(),
                TextColumn::make('days')->label(AdminTrans::field('days'))->numeric(),
            ])
            ->recordActions([
                Action::make('approve')
                    ->label(AdminTrans::action('approve'))
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->approve($record);
                        Notification::make()->title(AdminTrans::notification('leave_approved'))->success()->send();
                    }),
                Action::make('reject')
                    ->label(AdminTrans::action('reject'))
                    ->icon('heroicon-o-x-mark')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->reject($record);
                        Notification::make()->title(AdminTrans::notification('leave_rejected'))->danger()->send();
                    }),
            ])
            ->recordUrl(fn (LeaveRequest $record): string => LeaveRequestResource::getUrl('edit', ['record' => $record]))
            ->paginated(false)
            ->emptyStateHeading(AdminTrans::widget('no_pending_leave'));
    }
}
