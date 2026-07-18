<?php

namespace App\Filament\Resources\ReportSummaries\Pages;

use App\Filament\Resources\ReportSummaries\ReportSummaryResource;
use Filament\Resources\Pages\ListRecords;

class ListReportSummaries extends ListRecords
{
    protected static string $resource = ReportSummaryResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
