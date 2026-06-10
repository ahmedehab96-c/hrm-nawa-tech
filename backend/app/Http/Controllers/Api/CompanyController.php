<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    public function show(Request $request)
    {
        $user    = $request->user();
        $company = Company::find($user->company_id);

        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        return response()->json($this->format($company));
    }

    public function update(Request $request)
    {
        $user    = $request->user();
        $company = Company::find($user->company_id);

        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $request->validate([
            'name'      => 'sometimes|string|max:255',
            'email'     => 'nullable|email|max:255',
            'phone'     => 'nullable|string|max:64',
            'address'   => 'nullable|string|max:500',
            'wifi_ssid' => 'nullable|string|max:128',
        ]);

        $company->fill($request->only(['name', 'email', 'phone', 'address', 'wifi_ssid']));
        $company->save();

        return response()->json(['message' => 'Settings saved', 'data' => $this->format($company)]);
    }

    private function format(Company $company): array
    {
        return [
            'id'        => $company->id,
            'name'      => $company->name,
            'email'     => $company->email,
            'phone'     => $company->phone,
            'address'   => $company->address,
            'wifi_ssid' => $company->wifi_ssid,
            'status'    => $company->status,
        ];
    }
}
