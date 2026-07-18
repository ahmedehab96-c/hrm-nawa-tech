@php
    use App\Support\AdminTrans;
    $steps = $this->getOnboardingSteps();
    $progress = $this->getProgressPercent();
@endphp

<x-filament-panels::page>
    <div class="space-y-6">
        <x-filament::section>
            <x-slot name="heading">{{ __('admin.onboarding.setup_progress') }}</x-slot>
            <div class="space-y-3">
                <div class="flex items-center justify-between text-sm">
                    <span class="text-gray-600 dark:text-gray-300">{{ __('admin.onboarding.percent_complete', ['progress' => $progress]) }}</span>
                    <span class="text-gray-500">{{ __('admin.onboarding.steps_count', ['done' => collect($steps)->where('completed', true)->count(), 'total' => count($steps)]) }}</span>
                </div>
                <div class="h-2 w-full overflow-hidden rounded-full bg-gray-200 dark:bg-gray-700">
                    <div
                        class="h-full rounded-full bg-primary-500 transition-all"
                        style="width: {{ $progress }}%"
                    ></div>
                </div>
            </div>
        </x-filament::section>

        <div class="grid grid-cols-1 gap-4">
            @foreach ($steps as $step)
                <x-filament::section>
                    <div class="flex items-start justify-between gap-4">
                        <div class="flex items-start gap-3">
                            @if ($step['completed'])
                                <x-filament::icon
                                    icon="heroicon-o-check-circle"
                                    class="h-6 w-6 text-success-600 dark:text-success-400"
                                />
                            @else
                                <x-filament::icon
                                    icon="heroicon-o-ellipsis-horizontal-circle"
                                    class="h-6 w-6 text-gray-400"
                                />
                            @endif
                            <div>
                                <h3 class="text-sm font-semibold text-gray-900 dark:text-white">
                                    {{ $step['title'] }}
                                </h3>
                                <p class="mt-1 text-sm text-gray-600 dark:text-gray-300">
                                    {{ $step['description'] }}
                                </p>
                            </div>
                        </div>
                        @if (! $step['completed'] && filled($step['href'] ?? null))
                            <x-filament::button
                                tag="a"
                                :href="$step['href']"
                                size="sm"
                                color="gray"
                            >
                                {{ AdminTrans::action('open') }}
                            </x-filament::button>
                        @endif
                    </div>
                </x-filament::section>
            @endforeach
        </div>
    </div>
</x-filament-panels::page>
