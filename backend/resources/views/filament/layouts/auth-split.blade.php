<x-filament-panels::layout.base :livewire="$livewire">
    @include('filament.partials.locale-toggle')

    <div class="nawa-auth-shell">
        <aside class="nawa-auth-brand" aria-hidden="true">
            <div class="nawa-auth-brand-inner">
                @include('filament.partials.nawa-full-logo')
            </div>
        </aside>

        <div class="nawa-auth-form-wrap">
            <div class="nawa-auth-mobile-logo">
                @include('filament.partials.nawa-full-logo', ['compact' => true])
            </div>

            <div class="fi-simple-layout w-full">
                <div class="fi-simple-main-ctn">
                    <main class="fi-simple-main fi-width-lg">
                        {{ $slot }}
                    </main>
                </div>
            </div>
        </div>
    </div>
</x-filament-panels::layout.base>
