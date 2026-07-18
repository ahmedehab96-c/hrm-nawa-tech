<?php

namespace App\Filament\Resources\AttendanceRecords;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Concerns\RequiresPermission;
use App\Filament\Resources\AttendanceRecords\Pages\CreateAttendanceRecord;
use App\Filament\Resources\AttendanceRecords\Pages\EditAttendanceRecord;
use App\Filament\Resources\AttendanceRecords\Pages\ListAttendanceRecords;
use App\Filament\Resources\AttendanceRecords\Schemas\AttendanceRecordForm;
use App\Filament\Resources\AttendanceRecords\Tables\AttendanceRecordsTable;
use App\Models\AttendanceRecord;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class AttendanceRecordResource extends Resource
{
    use RequiresPermission;
    use ScopesToCompany;

    protected static ?string $model = AttendanceRecord::class;

    protected static string $requiredPermission = 'attendance.manage';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClock;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?int $navigationSort = 3;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.attendance');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('attendance_record');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('attendance_records');
    }

    public static function form(Schema $schema): Schema
    {
        return AttendanceRecordForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return AttendanceRecordsTable::configure($table);
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
            'index' => ListAttendanceRecords::route('/'),
            'create' => CreateAttendanceRecord::route('/create'),
            'edit' => EditAttendanceRecord::route('/{record}/edit'),
        ];
    }
}
