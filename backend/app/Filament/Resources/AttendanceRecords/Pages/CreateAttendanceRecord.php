<?php

namespace App\Filament\Resources\AttendanceRecords\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\AttendanceRecords\AttendanceRecordResource;
use Filament\Resources\Pages\CreateRecord;

class CreateAttendanceRecord extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = AttendanceRecordResource::class;
}
