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
                'gemini-1.5-flash' => [
                    'input_per_million' => (float) env('AI_PRICE_GEMINI_15_FLASH_INPUT', 0.075),
                    'output_per_million' => (float) env('AI_PRICE_GEMINI_15_FLASH_OUTPUT', 0.30),
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
        'model' => env('GEMINI_MODEL', 'gemini-1.5-flash'),
    ],

];
