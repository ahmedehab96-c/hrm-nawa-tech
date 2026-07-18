@php
    use App\Support\AdminTrans;
    $company = $this->getCompany();
    $endpoints = $this->getTopEndpoints();
@endphp

<x-filament-panels::page>
    <div class="space-y-6">
        <x-filament::section>
            <x-slot name="heading">{{ AdminTrans::blade('company_ai_status') }}</x-slot>
            <x-slot name="description">
                {{ AdminTrans::blade('ai_status_intro') }}
            </x-slot>

            @if ($company)
                <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::field('provider') }}</dt>
                        <dd class="text-sm font-medium">{{ $company->ai_provider ?? 'openai' }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::field('ai_model') }}</dt>
                        <dd class="text-sm font-medium">{{ $company->ai_model ?: 'default' }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::field('ai_plan') }}</dt>
                        <dd class="text-sm font-medium">{{ $company->ai_plan ?? 'starter' }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::field('enabled') }}</dt>
                        <dd class="text-sm font-medium">{{ $company->ai_enabled ? AdminTrans::field('yes') : AdminTrans::field('no') }}</dd>
                    </div>
                </dl>
            @else
                <p class="text-sm text-gray-500 dark:text-gray-400">
                    {{ AdminTrans::blade('platform_ai_view') }}
                </p>
            @endif
        </x-filament::section>

        <x-filament::section>
            <x-slot name="heading">{{ AdminTrans::blade('top_endpoints_month') }}</x-slot>
            @if (count($endpoints) === 0)
                <p class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::blade('no_ai_usage') }}</p>
            @else
                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b border-gray-200 dark:border-gray-700 text-left">
                                <th class="py-2 pr-4 font-medium">{{ AdminTrans::field('endpoint') }}</th>
                                <th class="py-2 pr-4 font-medium">{{ AdminTrans::field('requests') }}</th>
                                <th class="py-2 font-medium">{{ AdminTrans::field('tokens') }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($endpoints as $row)
                                <tr class="border-b border-gray-100 dark:border-gray-800">
                                    <td class="py-2 pr-4 font-mono text-xs">{{ $row['endpoint'] }}</td>
                                    <td class="py-2 pr-4">{{ number_format($row['requests']) }}</td>
                                    <td class="py-2">{{ number_format($row['tokens']) }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endif
        </x-filament::section>

        <p class="text-sm text-gray-500 dark:text-gray-400">
            <a href="{{ \App\Filament\Resources\AiUsageLogs\AiUsageLogResource::getUrl() }}" class="text-primary-600 underline">
                {{ AdminTrans::blade('link_usage_logs') }}
            </a>.
            @if (\App\Filament\Pages\CompanySettings::canAccess())
                <a href="{{ \App\Filament\Pages\CompanySettings::getUrl() }}" class="text-primary-600 underline">
                    {{ AdminTrans::blade('link_company_settings') }}
                </a>.
            @endif
        </p>
    </div>
</x-filament-panels::page>
