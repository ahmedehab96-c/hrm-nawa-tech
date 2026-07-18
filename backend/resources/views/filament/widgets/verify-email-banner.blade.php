@php
    use App\Support\AdminTrans;
@endphp

<x-filament-widgets::widget>
    <x-filament::section
        icon="heroicon-o-envelope"
        icon-color="warning"
    >
        <x-slot name="heading">{{ AdminTrans::widget('verify_email') }}</x-slot>
        <x-slot name="description">
            {{ AdminTrans::widget('verify_email_body') }}
        </x-slot>

        <x-filament::button
            wire:click="resend"
            size="sm"
            color="gray"
        >
            {{ AdminTrans::action('resend_verification') }}
        </x-filament::button>
    </x-filament::section>
</x-filament-widgets::widget>
