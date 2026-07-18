<?php

namespace App\Filament\Resources\PayrollRecords;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Concerns\RequiresPermission;
use App\Filament\Resources\PayrollRecords\Pages\CreatePayrollRecord;
use App\Filament\Resources\PayrollRecords\Pages\EditPayrollRecord;
use App\Filament\Resources\PayrollRecords\Pages\ListPayrollRecords;
use App\Filament\Resources\PayrollRecords\Schemas\PayrollRecordForm;
use App\Filament\Resources\PayrollRecords\Tables\PayrollRecordsTable;
use App\Models\PayrollRecord;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class PayrollRecordResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = PayrollRecord::class;

    protected static string $requiredPermission = 'payroll.manage';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBanknotes;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?int $navigationSort = 6;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.payroll');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('payroll_record');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('payroll_records');
    }

    public static function form(Schema $schema): Schema
    {
        return PayrollRecordForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return PayrollRecordsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPayrollRecords::route('/'),
            'create' => CreatePayrollRecord::route('/create'),
            'edit' => EditPayrollRecord::route('/{record}/edit'),
        ];
    }
}
