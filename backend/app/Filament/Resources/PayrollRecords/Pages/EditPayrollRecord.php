<?php

namespace App\Filament\Resources\PayrollRecords\Pages;

use App\Filament\Resources\PayrollRecords\PayrollRecordResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditPayrollRecord extends EditRecord
{
    protected static string $resource = PayrollRecordResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
