<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'ai' => [
        'default_provider' => env('AI_DEFAULT_PROVIDER', 'openai'),
        'timeout_seconds' => env('AI_TIMEOUT_SECONDS', 25),
        'slack_webhook_url' => env('AI_SLACK_WEBHOOK_URL'),
        'pricing' => [
            'openai' => [
                'gpt-4o-mini' => [
                    'input_per_million' => (float) env('AI_PRICE_OPENAI_GPT4O_MINI_INPUT', 0.15),
                    'output_per_million' => (float) env('AI_PRICE_OPENAI_GPT4O_MINI_OUTPUT', 0.60),
                ],
            ],
            'gemini' => [
                'gemini-3.5-flash' => [
                    'input_per_million' => (float) env('AI_PRICE_GEMINI_35_FLASH_INPUT', 1.50),
                    'output_per_million' => (float) env('AI_PRICE_GEMINI_35_FLASH_OUTPUT', 9.00),
                ],
            ],
        ],
    ],

    'openai' => [
        'key' => env('OPENAI_API_KEY'),
        'model' => env('OPENAI_MODEL', 'gpt-4o-mini'),
    ],

    'gemini' => [
        'key' => env('GEMINI_API_KEY'),
        'model' => env('GEMINI_MODEL', 'gemini-3.5-flash'),
    ],

    'stripe' => [
        'secret' => env('STRIPE_SECRET_KEY'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
        'price_starter' => env('STRIPE_PRICE_STARTER'),
        'price_growth' => env('STRIPE_PRICE_GROWTH'),
        'price_enterprise' => env('STRIPE_PRICE_ENTERPRISE'),
    ],

    'moyasar' => [
        'secret' => env('MOYASAR_SECRET_KEY'),
        'webhook_secret' => env('MOYASAR_WEBHOOK_SECRET'),
        'currency' => env('MOYASAR_CURRENCY', 'SAR'),
        'amount_starter' => env('MOYASAR_AMOUNT_STARTER'),
        'amount_growth' => env('MOYASAR_AMOUNT_GROWTH'),
        'amount_enterprise' => env('MOYASAR_AMOUNT_ENTERPRISE'),
    ],

    'billing' => [
        'default_provider' => env('BILLING_DEFAULT_PROVIDER', 'stripe'),
    ],

    'fcm' => [
        'server_key' => env('FCM_SERVER_KEY'),
    ],

];
