<?php

namespace App\Filament\Resources\Employees\RelationManagers;

use App\Models\LeaveRequest;
use App\Services\LeaveDecisionService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class LeaveRequestsRelationManager extends RelationManager
{
    protected static string $relationship = 'leaveRequests';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('type')
                    ->label(AdminTrans::field('type'))
                    ->options(AdminTrans::options('leave_type'))
                    ->required(),
                DatePicker::make('from_date')->label(AdminTrans::field('from_date'))->required(),
                DatePicker::make('to_date')->label(AdminTrans::field('to_date'))->required()->afterOrEqual('from_date'),
                TextInput::make('days')->label(AdminTrans::field('days'))->numeric()->default(1)->required(),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('leave_status'))
                    ->default('pending')
                    ->required(),
                Textarea::make('notes')->label(AdminTrans::field('notes'))->columnSpanFull(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('type')
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('type')
                    ->label(AdminTrans::field('type'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('leave_type', $state))
                    ->badge(),
                TextColumn::make('from_date')->label(AdminTrans::field('from_date'))->date(),
                TextColumn::make('to_date')->label(AdminTrans::field('to_date'))->date(),
                TextColumn::make('days')->label(AdminTrans::field('days'))->numeric(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('leave_status', $state))
                    ->badge(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('leave_status')),
            ])
            ->headerActions([
                CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $owner = $this->getOwnerRecord();
                        $data['company_id'] = $owner->company_id;
                        $data['employee_id'] = $owner->id;

                        return $data;
                    }),
            ])
            ->recordActions([
                Action::make('approve')
                    ->label(AdminTrans::action('approve'))
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->visible(fn (LeaveRequest $record): bool => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->approve($record);
                        Notification::make()->title(AdminTrans::notification('leave_approved'))->success()->send();
                    }),
                Action::make('reject')
                    ->label(AdminTrans::action('reject'))
                    ->icon('heroicon-o-x-mark')
                    ->color('danger')
                    ->visible(fn (LeaveRequest $record): bool => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->reject($record);
                        Notification::make()->title(AdminTrans::notification('leave_rejected'))->success()->send();
                    }),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
