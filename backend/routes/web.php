<?php

use App\Http\Controllers\AdminLocaleController;
use App\Http\Controllers\PasswordResetController;
use App\Http\Controllers\MoyasarWebhookController;
use App\Http\Controllers\StripeWebhookController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/admin');

Route::get('/admin/locale/{locale}', AdminLocaleController::class)
    ->whereIn('locale', ['en', 'ar'])
    ->name('admin.locale');

Route::post('/stripe/webhook', StripeWebhookController::class)
    ->name('stripe.webhook');

Route::post('/moyasar/webhook', MoyasarWebhookController::class)
    ->name('moyasar.webhook');

// صفحة إعادة تعيين كلمة المرور (تُفتح من رابط البريد الإلكتروني)
Route::get('/reset-password', [PasswordResetController::class, 'showForm'])
    ->name('password.reset');
Route::post('/reset-password', [PasswordResetController::class, 'submit'])
    ->name('password.update');
