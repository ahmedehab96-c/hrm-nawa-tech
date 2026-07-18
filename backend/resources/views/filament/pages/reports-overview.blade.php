@php
    use App\Support\AdminTrans;
    $metrics = $this->getMetrics();
    $labels = [
        'employees_total' => AdminTrans::blade('metric_total_employees'),
        'employees_active' => AdminTrans::blade('metric_active_employees'),
        'attendance_present' => AdminTrans::blade('metric_present'),
        'attendance_late' => AdminTrans::blade('metric_late'),
        'attendance_absent' => AdminTrans::blade('metric_absent'),
        'leave_pending' => AdminTrans::blade('metric_pending_leave'),
        'leave_approved_in_period' => AdminTrans::blade('metric_approved_leave'),
        'payroll_processed' => AdminTrans::blade('metric_payroll_processed'),
    ];
    $visuals = [
        'employees_total' => ['heroicon-o-users', '#2563eb'],
        'employees_active' => ['heroicon-o-user-group', '#059669'],
        'attendance_present' => ['heroicon-o-check-circle', '#16a34a'],
        'attendance_late' => ['heroicon-o-clock', '#d97706'],
        'attendance_absent' => ['heroicon-o-x-circle', '#dc2626'],
        'leave_pending' => ['heroicon-o-calendar-days', '#7c3aed'],
        'leave_approved_in_period' => ['heroicon-o-calendar', '#0891b2'],
        'payroll_processed' => ['heroicon-o-banknotes', '#0f766e'],
    ];
@endphp

<x-filament-panels::page>
    <div class="space-y-6">
        <x-filament::section class="nawa-report-period">
            <x-slot name="heading">{{ AdminTrans::blade('reports_period') }}</x-slot>
            <x-slot name="description">
                {{ $periodStart }} → {{ $periodEnd }} {{ AdminTrans::blade('reports_period_hint') }}
            </x-slot>
            <p class="text-sm text-gray-500 dark:text-gray-400">
                {{ AdminTrans::blade('reports_empty_hint') }}
            </p>
        </x-filament::section>

        @if (count($metrics) > 0)
            <div class="nawa-report-grid">
                @foreach ($metrics as $key => $value)
                    @php([$icon, $color] = $visuals[$key] ?? ['heroicon-o-chart-bar', '#2563eb'])
                    <article class="nawa-report-card" style="--metric-color: {{ $color }}">
                        <span class="nawa-report-card-icon">
                            <x-filament::icon :icon="$icon" />
                        </span>
                        <p class="nawa-report-card-label">{{ $labels[$key] ?? $key }}</p>
                        <p class="nawa-report-card-value">{{ number_format($value) }}</p>
                    </article>
                @endforeach
            </div>
        @endif

        <div class="nawa-report-footer">
            <span class="text-sm text-gray-500 dark:text-gray-400">
                {{ AdminTrans::blade('saved_reports') }}
            </span>
            <a href="{{ \App\Filament\Resources\ReportSummaries\ReportSummaryResource::getUrl() }}" class="text-primary-600 underline">
                {{ AdminTrans::blade('saved_reports_link') }}
            </a>
        </div>
    </div>
</x-filament-panels::page>
