<?php

namespace App\Support\Tenant;

use App\Models\Company;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;

/**
 * Shared helpers for resolving the tenant company from the authenticated user.
 * Pivot roles remain the source of truth for authorization; this trait only
 * centralizes the repeated "load the company or 404" pattern used across API
 * controllers.
 */
trait ResolvesCompany
{
    protected function currentCompany(Request $request): ?Company
    {
        $companyId = $request->user()?->company_id;
        if ($companyId === null) {
            return null;
        }

        return Company::query()->find($companyId);
    }

    /**
     * Resolve the company for the authenticated user or abort with the same
     * JSON 404 payload the controllers previously returned inline.
     */
    protected function requireCompany(Request $request): Company
    {
        $company = $this->currentCompany($request);
        if ($company === null) {
            throw new HttpResponseException(
                response()->json(['message' => 'Company not found'], 404)
            );
        }

        return $company;
    }
}
