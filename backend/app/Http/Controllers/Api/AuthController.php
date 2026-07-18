<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Role;
use App\Models\User;
use App\Services\CompanyRegistrationService;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'company_name' => 'sometimes|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $result = app(CompanyRegistrationService::class)->register(
            adminName: $validated['name'],
            email: $validated['email'],
            password: $validated['password'],
            companyName: $request->input('company_name') ?: $validated['name'],
        );

        $user = $result['user'];
        $company = $result['company'];
        $demoEmployees = $result['demo_employees'];

        try {
            $user->sendEmailVerificationNotification();
        } catch (\Throwable) {
            // Mail may be log/unavailable in local — registration still succeeds.
        }

        $token = $user->createToken('hrm-flutter')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'company_id' => $user->company_id,
                'email_verified' => $user->hasVerifiedEmail(),
            ],
            'company' => [
                'id' => $company->id,
                'name' => $company->name,
                'plan' => $company->plan,
                'trial_ends_at' => $company->trial_ends_at?->toIso8601String(),
                'employee_limit' => $company->employeeLimit(),
            ],
            'demo_employees' => $demoEmployees,
        ], 201);
    }

    public function verifyEmail(Request $request, string $id, string $hash)
    {
        $user = User::query()->findOrFail($id);

        if (! hash_equals(sha1($user->getEmailForVerification()), $hash)) {
            return response()->json(['message' => 'Invalid verification link.', 'code' => 'invalid_hash'], 403);
        }

        if (! $user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
        }

        return response()->json(['message' => 'Email verified successfully.', 'email_verified' => true]);
    }

    public function resendVerification(Request $request)
    {
        $user = $request->user();
        if ($user->hasVerifiedEmail()) {
            return response()->json(['message' => 'Email already verified.']);
        }

        $user->sendEmailVerificationNotification();

        return response()->json(['message' => 'Verification link sent.']);
    }

    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'company_id' => $user->company_id,
                'email_verified' => $user->hasVerifiedEmail(),
            ],
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink($request->only('email'));

        if ($status === Password::ResetLinkSent) {
            return response()->json(['message' => 'Reset link sent to your email.']);
        }

        // نُعيد استجابة ناجحة حتى لو البريد غير موجود (لأسباب أمنية)
        return response()->json(['message' => 'If that email exists, a reset link was sent.']);
    }

    public function logout(Request $request)
    {
        // إبطال الـ token الحالي فقط (لا كل الـ tokens)
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out']);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'token'                 => 'required|string',
            'email'                 => 'required|email',
            'password'              => 'required|string|min:8|confirmed',
            'password_confirmation' => 'required|string',
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill(['password' => Hash::make($password)])
                     ->setRememberToken(Str::random(60));
                $user->save();
                event(new PasswordReset($user));
            }
        );

        if ($status === Password::PasswordReset) {
            return response()->json(['message' => 'Password reset successfully.']);
        }

        return response()->json(['message' => __($status)], 422);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (! Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        /** @var User $user */
        $user = Auth::user();
        $this->syncUserRole($user);
        $user->tokens()->delete();
        $token = $user->createToken('hrm-flutter')->plainTextToken;

        $company = $user->company_id
            ? Company::query()->find($user->company_id)
            : null;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'company_id' => $user->company_id,
                'email_verified' => $user->hasVerifiedEmail(),
            ],
            'company' => $company ? [
                'id' => $company->id,
                'name' => $company->name,
                'plan' => $company->plan,
                'trial_ends_at' => $company->trial_ends_at?->toIso8601String(),
                'employee_limit' => $company->employeeLimit(),
                'employee_count' => $company->employeeCount(),
            ] : null,
        ]);
    }

    private function syncUserRole(User $user): void
    {
        $role = Role::query()->where('name', $user->role)->first();
        if (! $role) {
            return;
        }
        $user->roles()->syncWithoutDetaching([$role->id]);
    }
}
