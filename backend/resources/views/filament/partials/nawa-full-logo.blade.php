{{-- Matches Flutter NawaTechFullLogo (login / splash identity) --}}
@props([
    'compact' => false,
])

<div {{ $attributes->class(['nawa-full-logo', 'nawa-full-logo--compact' => $compact]) }}>
    <div class="nawa-full-logo__n" aria-hidden="true">N</div>

    <div class="nawa-full-logo__wordmark" dir="ltr">
        <span class="nawa-full-logo__nawa">Nawa</span>
        <span class="nawa-full-logo__tech">Tech</span>
    </div>

    <div class="nawa-full-logo__tagline">
        <span class="nawa-full-logo__line" aria-hidden="true"></span>
        <span class="nawa-full-logo__tag">Smart IT Solutions, Better Future</span>
        <span class="nawa-full-logo__line" aria-hidden="true"></span>
    </div>

    <div class="nawa-full-logo__hex" aria-hidden="true">
        <svg viewBox="0 0 100 110" xmlns="http://www.w3.org/2000/svg" role="img">
            <defs>
                <linearGradient id="nawaHexGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" stop-color="#2DD4BF"/>
                    <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.92"/>
                </linearGradient>
            </defs>
            <path
                fill="url(#nawaHexGrad)"
                d="M50 4 L93 28 L93 82 L50 106 L7 82 L7 28 Z"
            />
            {{-- Three people (groups) --}}
            <g fill="#1A2B5E">
                <circle cx="50" cy="42" r="8"/>
                <path d="M32 72c0-10 8-16 18-16s18 6 18 16v2H32z"/>
                <circle cx="30" cy="46" r="6" opacity="0.75"/>
                <path d="M14 72c0-8 6-13 14-13 2.5 0 4.8.6 6.7 1.6-3.2 2.4-5.2 6-5.2 10.4v3H14z" opacity="0.75"/>
                <circle cx="70" cy="46" r="6" opacity="0.75"/>
                <path d="M66 60.6c1.9-1 4.2-1.6 6.7-1.6 8 0 14 5 14 13v3H71.5c0-4.4-2-8-5.5-10.4z" opacity="0.75"/>
            </g>
        </svg>
    </div>

    <div class="nawa-full-logo__hrm">HRM</div>
    <div class="nawa-full-logo__sub">Human Resource Management</div>
</div>
