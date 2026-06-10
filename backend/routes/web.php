<?php

use App\Http\Controllers\PasswordResetController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// صفحة إعادة تعيين كلمة المرور (تُفتح من رابط البريد الإلكتروني)
Route::get('/reset-password', [PasswordResetController::class, 'showForm'])
    ->name('password.reset');
Route::post('/reset-password', [PasswordResetController::class, 'submit'])
    ->name('password.update');
