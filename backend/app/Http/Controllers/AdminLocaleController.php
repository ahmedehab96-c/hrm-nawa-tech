<?php

namespace App\Http\Controllers;

use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class AdminLocaleController extends Controller
{
    private const SUPPORTED = ['en', 'ar'];

    public function __invoke(Request $request, string $locale): RedirectResponse
    {
        if (! in_array($locale, self::SUPPORTED, true)) {
            $locale = 'en';
        }

        $request->session()->put('admin_locale', $locale);

        return redirect()->back();
    }
}
