@php
    use App\Support\AdminTrans;
    $progress = $this->getProgressPercent();
@endphp

<x-filament-widgets::widget>
    <x-filament::section
        icon="heroicon-o-rocket-launch"
        icon-color="primary"
    >
        <x-slot name="heading">{{ AdminTrans::widget('finish_setup') }}</x-slot>
        <x-slot name="description">
            {{ AdminTrans::widget('setup_progress_banner', ['progress' => $progress]) }}
        </x-slot>

        <x-filament::button
            tag="a"
            :href="$this->getGettingStartedUrl()"
            size="sm"
        >
            {{ AdminTrans::action('continue_setup') }}
        </x-filament::button>
    </x-filament::section>
</x-filament-widgets::widget>
