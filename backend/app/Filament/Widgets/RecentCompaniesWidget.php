<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\Companies\CompanyResource;
use App\Models\Company;
use App\Support\AdminTrans;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class RecentCompaniesWidget extends TableWidget
{
    protected int|string|array $columnSpan = 'full';

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('super_admin') ?? false;
    }

    public function getTableHeading(): ?string
    {
        return AdminTrans::widget('recent_companies');
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Company::query()
                    ->withCount('employees')
                    ->latest()
                    ->limit(10),
            )
            ->columns([
                TextColumn::make('name')->searchable(),
                TextColumn::make('plan')->badge(),
                TextColumn::make('status')->badge(),
                TextColumn::make('employees_count')->label(AdminTrans::field('employees')),
                TextColumn::make('trial_ends_at')->dateTime()->placeholder('—'),
                TextColumn::make('created_at')->since(),
            ])
            ->recordUrl(fn (Company $record): string => CompanyResource::getUrl('edit', ['record' => $record]))
            ->paginated(false);
    }
}
