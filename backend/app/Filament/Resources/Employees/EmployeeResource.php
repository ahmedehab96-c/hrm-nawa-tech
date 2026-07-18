<?php

namespace App\Filament\Resources\Employees;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Concerns\RequiresPermission;
use App\Filament\Resources\Employees\Pages\CreateEmployee;
use App\Filament\Resources\Employees\Pages\EditEmployee;
use App\Filament\Resources\Employees\Pages\ListEmployees;
use App\Filament\Resources\Employees\RelationManagers\AttendanceRecordsRelationManager;
use App\Filament\Resources\Employees\RelationManagers\LeaveRequestsRelationManager;
use App\Filament\Resources\Employees\RelationManagers\PayrollRecordsRelationManager;
use App\Filament\Resources\Employees\Schemas\EmployeeForm;
use App\Filament\Resources\Employees\Tables\EmployeesTable;
use App\Models\Employee;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class EmployeeResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = Employee::class;

    protected static string $requiredPermission = 'employees.manage';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?string $navigationLabel = null;

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?int $navigationSort = 2;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.employees');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('employee');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('employees');
    }

    public static function form(Schema $schema): Schema
    {
        return EmployeeForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return EmployeesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            AttendanceRecordsRelationManager::class,
            LeaveRequestsRelationManager::class,
            PayrollRecordsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListEmployees::route('/'),
            'create' => CreateEmployee::route('/create'),
            'edit' => EditEmployee::route('/{record}/edit'),
        ];
    }
}
