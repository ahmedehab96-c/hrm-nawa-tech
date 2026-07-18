@php
    use App\Support\AdminTrans;
@endphp

<x-filament-panels::page>
    <x-filament::section>
        <x-slot name="heading">{{ AdminTrans::blade('platform_operations') }}</x-slot>
        <p class="text-sm text-gray-600 dark:text-gray-300">
            {{ AdminTrans::blade('platform_intro') }}
        </p>
    </x-filament::section>
</x-filament-panels::page>
