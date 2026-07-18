<?php

namespace App\Filament\Resources\ReportSummaries;

use App\Filament\Concerns\RequiresPermission;
use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Resources\ReportSummaries\Pages\ListReportSummaries;
use App\Filament\Resources\ReportSummaries\Pages\ViewReportSummary;
use App\Filament\Resources\ReportSummaries\Tables\ReportSummariesTable;
use App\Models\ReportSummary;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class ReportSummaryResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = ReportSummary::class;

    protected static string $requiredPermission = 'reports.ai.summarize';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedDocumentText;

    protected static string|UnitEnum|null $navigationGroup = 'Reports';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 2;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.summaries');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('report_summary');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('report_summaries');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make(AdminTrans::section('report'))
                    ->schema([
                        TextEntry::make('report_type')
                            ->label(AdminTrans::field('report_type'))
                            ->badge()
                            ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('report_type', $state)),
                        TextEntry::make('period_start')->label(AdminTrans::field('period_start'))->date(),
                        TextEntry::make('period_end')->label(AdminTrans::field('period_end'))->date(),
                        TextEntry::make('provider')->label(AdminTrans::field('provider')),
                        TextEntry::make('model')->label(AdminTrans::field('ai_model')),
                        TextEntry::make('created_at')->label(AdminTrans::field('created_at'))->dateTime(),
                    ])
                    ->columns(3),
                Section::make(AdminTrans::section('metrics'))
                    ->schema([
                        TextEntry::make('metrics_json')
                            ->label(AdminTrans::field('metrics'))
                            ->formatStateUsing(fn ($state) => is_array($state)
                                ? collect($state)->map(fn ($v, $k) => "{$k}: {$v}")->implode("\n")
                                : (string) $state)
                            ->columnSpanFull(),
                    ]),
                Section::make(AdminTrans::section('narrative'))
                    ->schema([
                        TextEntry::make('narrative')
                            ->label(AdminTrans::field('narrative'))
                            ->markdown()
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return ReportSummariesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListReportSummaries::route('/'),
            'view' => ViewReportSummary::route('/{record}'),
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
}
