<?php

namespace App\Support;

class AdminTrans
{
    public static function field(string $key): string
    {
        return (string) trans('admin.fields.'.$key);
    }

    public static function section(string $key): string
    {
        return (string) trans('admin.sections.'.$key);
    }

    public static function page(string $key): string
    {
        return (string) trans('admin.pages.'.$key);
    }

    public static function action(string $key): string
    {
        return (string) trans('admin.actions.'.$key);
    }

    public static function notification(string $key, array $replace = []): string
    {
        return (string) trans('admin.notifications.'.$key, $replace);
    }

    public static function widget(string $key, array $replace = []): string
    {
        return (string) trans('admin.widgets.'.$key, $replace);
    }

    public static function navGroup(string $key): string
    {
        return (string) trans('admin.nav_groups.'.$key);
    }

    /**
     * @return array<string, string>
     */
    public static function options(string $group): array
    {
        $options = trans('admin.options.'.$group);

        return is_array($options) ? $options : [];
    }

    public static function onboarding(string $step, string $field): string
    {
        return (string) trans("admin.onboarding.steps.{$step}.{$field}");
    }

    public static function blade(string $key, array $replace = []): string
    {
        return (string) trans('admin.blade.'.$key, $replace);
    }

    public static function helpers(string $key): string
    {
        return (string) trans('admin.helpers.'.$key);
    }

    public static function billing(string $key, array $replace = []): string
    {
        return (string) trans('admin.billing.'.$key, $replace);
    }

    public static function optionLabel(string $group, string $value): string
    {
        return self::options($group)[$value] ?? $value;
    }
}
