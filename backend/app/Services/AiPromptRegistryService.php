<?php

namespace App\Services;

use App\Models\AiPromptVersion;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class AiPromptRegistryService
{
    /**
     * @return array{prompt:string,version_id:int|null,version_label:string|null}
     */
    public function resolvePrompt(
        int $companyId,
        string $featureKey,
        string $fallbackPrompt,
    ): array {
        $active = AiPromptVersion::query()
            ->where('company_id', $companyId)
            ->where('feature_key', $featureKey)
            ->where('is_active', true)
            ->latest('id')
            ->first();

        if (! $active) {
            return [
                'prompt' => $fallbackPrompt,
                'version_id' => null,
                'version_label' => null,
            ];
        }

        return [
            'prompt' => (string) $active->system_prompt,
            'version_id' => (int) $active->id,
            'version_label' => (string) $active->version_label,
        ];
    }

    /**
     * @return Collection<int, AiPromptVersion>
     */
    public function list(int $companyId, ?string $featureKey = null): Collection
    {
        $query = AiPromptVersion::query()
            ->where('company_id', $companyId)
            ->orderByDesc('id');

        if ($featureKey !== null && $featureKey !== '') {
            $query->where('feature_key', $featureKey);
        }

        return $query->limit(200)->get();
    }

    public function create(
        int $companyId,
        ?int $userId,
        string $featureKey,
        string $versionLabel,
        string $systemPrompt,
        bool $activate = false,
    ): AiPromptVersion {
        return DB::transaction(function () use ($companyId, $userId, $featureKey, $versionLabel, $systemPrompt, $activate) {
            if ($activate) {
                AiPromptVersion::query()
                    ->where('company_id', $companyId)
                    ->where('feature_key', $featureKey)
                    ->update(['is_active' => false]);
            }

            return AiPromptVersion::query()->create([
                'company_id' => $companyId,
                'created_by' => $userId,
                'feature_key' => $featureKey,
                'version_label' => $versionLabel,
                'system_prompt' => $systemPrompt,
                'is_active' => $activate,
            ]);
        });
    }

    public function activate(int $companyId, int $versionId): ?AiPromptVersion
    {
        return DB::transaction(function () use ($companyId, $versionId) {
            $version = AiPromptVersion::query()
                ->where('company_id', $companyId)
                ->find($versionId);
            if (! $version) {
                return null;
            }

            AiPromptVersion::query()
                ->where('company_id', $companyId)
                ->where('feature_key', $version->feature_key)
                ->update(['is_active' => false]);

            $version->is_active = true;
            $version->save();

            return $version;
        });
    }
}
