@php
    use App\Support\AdminTrans;
    $company = $this->getCompany();
    $catalog = $this->getCatalog();
    $limit = $company?->employeeLimit();
    $count = $company?->employeeCount() ?? 0;
    $provider = $this->getPaymentProvider();
@endphp

<x-filament-panels::page>
    <div class="space-y-6">
        <x-filament::section>
            <x-slot name="heading">{{ AdminTrans::blade('current_plan') }}</x-slot>
            @if ($company)
                <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::field('plan') }}</dt>
                        <dd class="text-sm font-semibold capitalize">{{ $company->plan ?? 'trial' }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::blade('billing_status') }}</dt>
                        <dd class="text-sm font-semibold capitalize">{{ $company->status ?? 'active' }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::blade('billing_employees') }}</dt>
                        <dd class="text-sm font-semibold">
                            {{ $count }}
                            /
                            {{ $limit === null ? '∞' : $limit }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500 dark:text-gray-400">{{ AdminTrans::blade('billing_trial_ends') }}</dt>
                        <dd class="text-sm font-semibold">
                            {{ $company->trial_ends_at?->toFormattedDateString() ?? '—' }}
                        </dd>
                    </div>
                </dl>
            @endif
        </x-filament::section>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
            @foreach ($catalog as $plan => $meta)
                @php $isCurrent = ($company?->plan === $plan); @endphp
                <x-filament::section>
                    <x-slot name="heading">{{ $meta['label'] }}</x-slot>
                    <x-slot name="description">{{ $meta['price_hint'] }}</x-slot>
                    <p class="text-sm text-gray-600 dark:text-gray-300 mb-3">
                        @if ($meta['employee_limit'] === null)
                            {{ AdminTrans::blade('unlimited_seats') }}
                        @else
                            {{ AdminTrans::blade('includes_employees', ['count' => $meta['employee_limit']]) }}
                        @endif
                    </p>
                    @if ($isCurrent)
                        <span class="inline-flex items-center rounded-md bg-success-100 px-2 py-1 text-xs font-medium text-success-700 dark:bg-success-500/20 dark:text-success-400">
                            {{ AdminTrans::blade('current_plan') }}
                        </span>
                    @else
                        <p class="text-xs text-gray-500 dark:text-gray-400">
                            @if ($provider === 'stripe')
                                {{ AdminTrans::blade('billing_stripe_hint') }}
                            @elseif ($provider === 'moyasar')
                                {{ AdminTrans::blade('billing_moyasar_hint') }}
                            @else
                                {{ AdminTrans::blade('billing_manual_hint') }}
                            @endif
                        </p>
                    @endif
                </x-filament::section>
            @endforeach
        </div>
    </div>
</x-filament-panels::page>
