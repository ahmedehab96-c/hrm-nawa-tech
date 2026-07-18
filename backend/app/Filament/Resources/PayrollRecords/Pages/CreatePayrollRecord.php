<?php

namespace App\Filament\Resources\PayrollRecords\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\PayrollRecords\PayrollRecordResource;
use Filament\Resources\Pages\CreateRecord;

class CreatePayrollRecord extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = PayrollRecordResource::class;
}
