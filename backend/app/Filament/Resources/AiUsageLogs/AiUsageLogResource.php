<?php

namespace App\Filament\Resources\AiUsageLogs;

use App\Filament\Concerns\RequiresPermission;
use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Resources\AiUsageLogs\Pages\ListAiUsageLogs;
use App\Filament\Resources\AiUsageLogs\Tables\AiUsageLogsTable;
use App\Models\AiUsageLog;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class AiUsageLogResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = AiUsageLog::class;

    protected static string $requiredPermission = 'ai.usage.view';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBar;

    protected static string|UnitEnum|null $navigationGroup = 'AI';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 2;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.usage_logs');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('ai_usage_log');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('ai_usage_logs');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema;
    }

    public static function table(Table $table): Table
    {
        return AiUsageLogsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAiUsageLogs::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function canDelete($record): bool
    {
        return false;
    }
}
