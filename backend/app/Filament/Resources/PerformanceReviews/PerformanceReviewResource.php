<?php

namespace App\Filament\Resources\PerformanceReviews;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Concerns\RequiresPermission;
use App\Filament\Resources\PerformanceReviews\Pages\CreatePerformanceReview;
use App\Filament\Resources\PerformanceReviews\Pages\EditPerformanceReview;
use App\Filament\Resources\PerformanceReviews\Pages\ListPerformanceReviews;
use App\Filament\Resources\PerformanceReviews\Schemas\PerformanceReviewForm;
use App\Filament\Resources\PerformanceReviews\Tables\PerformanceReviewsTable;
use App\Models\PerformanceReview;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class PerformanceReviewResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = PerformanceReview::class;

    protected static string $requiredPermission = 'performance.manage';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedStar;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?int $navigationSort = 5;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.performance');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('performance_review');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('performance_reviews');
    }

    public static function form(Schema $schema): Schema
    {
        return PerformanceReviewForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return PerformanceReviewsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPerformanceReviews::route('/'),
            'create' => CreatePerformanceReview::route('/create'),
            'edit' => EditPerformanceReview::route('/{record}/edit'),
        ];
    }
}
