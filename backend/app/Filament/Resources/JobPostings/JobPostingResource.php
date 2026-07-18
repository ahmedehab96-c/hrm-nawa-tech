<?php

namespace App\Filament\Resources\JobPostings;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Concerns\RequiresPermission;
use App\Filament\Resources\JobPostings\Pages\CreateJobPosting;
use App\Filament\Resources\JobPostings\Pages\EditJobPosting;
use App\Filament\Resources\JobPostings\Pages\ListJobPostings;
use App\Filament\Resources\JobPostings\Schemas\JobPostingForm;
use App\Filament\Resources\JobPostings\Tables\JobPostingsTable;
use App\Models\JobPosting;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class JobPostingResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = JobPosting::class;

    protected static string $requiredPermission = 'recruitment.manage';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBriefcase;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?string $navigationLabel = null;

    protected static ?string $recordTitleAttribute = 'title';

    protected static ?int $navigationSort = 7;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.recruitment');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('job_posting');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('job_postings');
    }

    public static function form(Schema $schema): Schema
    {
        return JobPostingForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return JobPostingsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\CandidatesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListJobPostings::route('/'),
            'create' => CreateJobPosting::route('/create'),
            'edit' => EditJobPosting::route('/{record}/edit'),
        ];
    }
}
