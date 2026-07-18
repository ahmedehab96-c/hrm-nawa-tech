<?php

namespace App\Services;

use Illuminate\Http\Request;
use RuntimeException;

class StripeWebhookVerifier
{
    private const TOLERANCE_SECONDS = 300;

    public function verify(Request $request): array
    {
        $secret = config('services.stripe.webhook_secret');
        $payload = $request->getContent();

        if (! filled($secret)) {
            $event = json_decode($payload, true);
            if (! is_array($event)) {
                throw new RuntimeException('Invalid Stripe payload.');
            }

            return $event;
        }

        $signature = $request->header('Stripe-Signature');
        if (! is_string($signature) || $signature === '') {
            throw new RuntimeException('Missing Stripe-Signature header.');
        }

        $timestamp = null;
        $signatures = [];
        foreach (explode(',', $signature) as $part) {
            [$key, $value] = array_pad(explode('=', trim($part), 2), 2, null);
            if ($key === 't') {
                $timestamp = $value;
            }
            if ($key === 'v1' && is_string($value)) {
                $signatures[] = $value;
            }
        }

        if ($timestamp === null || $signatures === []) {
            throw new RuntimeException('Malformed Stripe-Signature header.');
        }

        if (abs(time() - (int) $timestamp) > self::TOLERANCE_SECONDS) {
            throw new RuntimeException('Stripe webhook timestamp outside tolerance.');
        }

        $signedPayload = $timestamp.'.'.$payload;
        $expected = hash_hmac('sha256', $signedPayload, (string) $secret);
        $valid = false;
        foreach ($signatures as $sig) {
            if (hash_equals($expected, $sig)) {
                $valid = true;
                break;
            }
        }

        if (! $valid) {
            throw new RuntimeException('Invalid Stripe webhook signature.');
        }

        $event = json_decode($payload, true);
        if (! is_array($event)) {
            throw new RuntimeException('Invalid Stripe payload.');
        }

        return $event;
    }
}
