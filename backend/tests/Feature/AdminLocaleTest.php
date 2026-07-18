<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminLocaleTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_locale_route_stores_arabic_in_session(): void
    {
        $response = $this->from('/admin/login')
            ->get('/admin/locale/ar');

        $response->assertRedirect('/admin/login');
        $response->assertSessionHas('admin_locale', 'ar');
    }

    public function test_admin_locale_route_rejects_invalid_locale(): void
    {
        $response = $this->from('/admin/login')
            ->get('/admin/locale/fr');

        $response->assertNotFound();
    }

    public function test_arabic_locale_translates_leave_navigation_label(): void
    {
        app()->setLocale('ar');

        $this->assertSame('الإجازات', \App\Filament\Resources\LeaveRequests\LeaveRequestResource::getNavigationLabel());
    }

    public function test_arabic_locale_translates_filament_default_actions(): void
    {
        app()->setLocale('ar');

        $this->assertSame('حذف', __('filament-actions::delete.single.label'));
        $this->assertSame('تعديل', __('filament-actions::edit.single.label'));
        $this->assertSame('إلغاء', __('filament-actions::modal.actions.cancel.label'));
        $this->assertSame('حفظ', __('filament-panels::resources/pages/edit-record.form.actions.save.label'));
    }

    public function test_admin_login_page_renders_arabic_when_locale_is_ar(): void
    {
        $response = $this->withSession(['admin_locale' => 'ar'])
            ->get('/admin/login');

        $response->assertOk();
        $response->assertSee('تسجيل الدخول', false);
        $response->assertSee('dir="rtl"', false);
    }
}
