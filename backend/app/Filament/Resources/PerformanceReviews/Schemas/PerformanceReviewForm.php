<?php

namespace App\Filament\Resources\PerformanceReviews\Schemas;

use App\Models\Employee;
use App\Support\AdminTrans;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class PerformanceReviewForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('employee_id')
                    ->label(AdminTrans::field('employee'))
                    ->options(function (): array {
                        $companyId = auth()->user()?->company_id;
                        $query = Employee::query()->orderBy('name');
                        if ($companyId && ! auth()->user()?->hasRole('super_admin')) {
                            $query->where('company_id', $companyId);
                        }

                        return $query->pluck('name', 'id')->all();
                    })
                    ->searchable()
                    ->required(),
                TextInput::make('period_label')
                    ->label(AdminTrans::field('period'))
                    ->placeholder(AdminTrans::helpers('period_example'))
                    ->required()
                    ->maxLength(32),
                Select::make('rating')
                    ->label(AdminTrans::field('rating'))
                    ->options(AdminTrans::options('performance_rating')),
                Textarea::make('goals_summary')->label(AdminTrans::field('goals'))->columnSpanFull(),
                Textarea::make('strengths')->label(AdminTrans::field('strengths'))->columnSpanFull(),
                Textarea::make('improvement_areas')->label(AdminTrans::field('improvement_areas'))->columnSpanFull(),
                Textarea::make('manager_comment')->label(AdminTrans::field('manager_comment'))->columnSpanFull(),
                Textarea::make('ai_summary')
                    ->label(AdminTrans::field('ai_summary'))
                    ->disabled()
                    ->dehydrated(false)
                    ->columnSpanFull(),
                DateTimePicker::make('reviewed_at')
                    ->label(AdminTrans::field('reviewed_at'))
                    ->default(now()),
            ]);
    }
}
