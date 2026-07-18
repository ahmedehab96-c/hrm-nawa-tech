@php
    $locale = app()->getLocale();
@endphp

<div class="nawa-auth-locale">
    <div class="nawa-locale-toggle" role="group" aria-label="{{ __('admin.locale.switch_to') }}">
        <a
            href="{{ route('admin.locale', ['locale' => 'en']) }}"
            @class(['nawa-locale-btn', 'is-active' => $locale === 'en'])
        >{{ __('admin.locale.en') }}</a>
        <a
            href="{{ route('admin.locale', ['locale' => 'ar']) }}"
            @class(['nawa-locale-btn', 'is-active' => $locale === 'ar'])
        >{{ __('admin.locale.ar') }}</a>
    </div>
</div>
