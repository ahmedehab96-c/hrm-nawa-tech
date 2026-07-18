@php
    use App\Support\AdminTrans;
@endphp

<x-filament-panels::page>
    <div class="space-y-4">
        <p class="text-sm text-gray-600 dark:text-gray-300">
            {{ AdminTrans::blade('roles_intro') }}
        </p>

        @foreach ($this->getRoles() as $role)
            <x-filament::section>
                <x-slot name="heading">{{ $role['display_name'] }}</x-slot>
                <x-slot name="description"><code class="text-xs">{{ $role['name'] }}</code></x-slot>

                @if (count($role['permissions']) === 0)
                    <p class="text-sm text-gray-500">{{ AdminTrans::blade('no_permissions') }}</p>
                @else
                    <div class="flex flex-wrap gap-2">
                        @foreach ($role['permissions'] as $permission)
                            <span class="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-medium text-gray-700 dark:bg-gray-800 dark:text-gray-200">
                                {{ $permission }}
                            </span>
                        @endforeach
                    </div>
                @endif
            </x-filament::section>
        @endforeach
    </div>
</x-filament-panels::page>
