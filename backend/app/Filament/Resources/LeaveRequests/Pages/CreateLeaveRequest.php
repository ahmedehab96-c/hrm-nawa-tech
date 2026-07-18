<?php

namespace App\Filament\Resources\LeaveRequests\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\LeaveRequests\LeaveRequestResource;
use Filament\Resources\Pages\CreateRecord;

class CreateLeaveRequest extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = LeaveRequestResource::class;
}
