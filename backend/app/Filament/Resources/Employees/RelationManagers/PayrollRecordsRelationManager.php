<?php

namespace App\Filament\Resources\Employees\RelationManagers;

use App\Support\AdminTrans;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PayrollRecordsRelationManager extends RelationManager
{
    protected static string $relationship = 'payrollRecords';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('month')
                    ->label(AdminTrans::field('month'))
                    ->placeholder(AdminTrans::helpers('month_yyyy_mm'))
                    ->required(),
                TextInput::make('base_salary')->label(AdminTrans::field('base_salary'))->numeric()->default(0)->required(),
                TextInput::make('allowances')->label(AdminTrans::field('allowances'))->numeric()->default(0)->required(),
                TextInput::make('deductions')->label(AdminTrans::field('deductions'))->numeric()->default(0)->required(),
                TextInput::make('net_salary')->label(AdminTrans::field('net_salary'))->numeric()->default(0)->required(),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('payroll_status'))
                    ->default('pending')
                    ->required(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('month')
            ->defaultSort('month', 'desc')
            ->columns([
                TextColumn::make('month')->label(AdminTrans::field('month'))->searchable()->sortable(),
                TextColumn::make('base_salary')->label(AdminTrans::field('base_salary'))->money('USD'),
                TextColumn::make('allowances')->label(AdminTrans::field('allowances'))->money('USD')->toggleable(),
                TextColumn::make('deductions')->label(AdminTrans::field('deductions'))->money('USD')->toggleable(),
                TextColumn::make('net_salary')->label(AdminTrans::field('net_salary'))->money('USD'),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('payroll_status', $state))
                    ->badge(),
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
