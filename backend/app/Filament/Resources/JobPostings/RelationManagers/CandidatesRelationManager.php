<?php

namespace App\Filament\Resources\JobPostings\RelationManagers;

use App\Models\Candidate;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CandidatesRelationManager extends RelationManager
{
    protected static string $relationship = 'candidates';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')->label(AdminTrans::field('name'))->required()->maxLength(255),
                TextInput::make('email')->label(AdminTrans::field('email'))->email()->maxLength(255),
                TextInput::make('phone')->label(AdminTrans::field('phone'))->tel()->maxLength(50),
                Select::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->options(AdminTrans::options('candidate_stage'))
                    ->default('new')
                    ->required(),
                TextInput::make('years_experience')
                    ->label(AdminTrans::field('experience_years'))
                    ->numeric()
                    ->minValue(0),
                TextInput::make('ai_fit_score')
                    ->label(AdminTrans::field('ai_fit_score'))
                    ->numeric()
                    ->minValue(0)
                    ->maxValue(100),
                Textarea::make('notes')->label(AdminTrans::field('notes'))->columnSpanFull(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')->label(AdminTrans::field('name'))->searchable(),
                TextColumn::make('email')->label(AdminTrans::field('email'))->toggleable(),
                TextColumn::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('candidate_stage', $state))
                    ->badge(),
                TextColumn::make('ai_fit_score')->label(AdminTrans::field('ai_fit'))->numeric(),
            ])
            ->filters([
                SelectFilter::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->options(AdminTrans::options('candidate_stage')),
            ])
            ->headerActions([
                CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $data['company_id'] = $this->getOwnerRecord()->company_id;

                        return $data;
                    }),
            ])
            ->recordActions([
                Action::make('hire')
                    ->label(AdminTrans::action('hire'))
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (Candidate $record): bool => $record->stage !== 'hired')
                    ->action(function (Candidate $record): void {
                        $record->update(['stage' => 'hired']);
                        Notification::make()->title(AdminTrans::notification('hired'))->success()->send();
                    }),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
