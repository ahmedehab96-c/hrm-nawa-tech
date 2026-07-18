@php
    $user = auth()->user();
    $companyName = $user?->company?->name ?? config('app.name', 'Nawa Tech HRM');
@endphp

<div class="nawa-company-chip" title="{{ $companyName }}">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5M4.5 21V7.5a2.25 2.25 0 0 1 2.25-2.25h10.5A2.25 2.25 0 0 1 19.5 7.5V21M9 10.5h1.5M9 14.25h1.5M13.5 10.5H15M13.5 14.25H15" />
    </svg>
    <span>{{ $companyName }}</span>
</div>
