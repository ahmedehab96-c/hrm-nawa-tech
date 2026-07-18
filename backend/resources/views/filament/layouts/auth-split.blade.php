<x-filament-panels::layout.base :livewire="$livewire">
    @include('filament.partials.locale-toggle')

    <div class="nawa-auth-shell">
        <aside class="nawa-auth-brand" aria-hidden="true">
            <div class="nawa-auth-brand-inner">
                <img src="{{ asset('images/hrm_logo.png') }}" alt="{{ __('admin.brand.name') }}">
                <h1>{{ __('admin.auth.title') }}</h1>
                <p>{{ __('admin.auth.subtitle') }}</p>
            </div>
        </aside>

        <div class="nawa-auth-form-wrap">
            <div class="nawa-auth-mobile-logo">
                <img src="{{ asset('images/hrm_logo.png') }}" alt="{{ __('admin.brand.name') }}">
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
