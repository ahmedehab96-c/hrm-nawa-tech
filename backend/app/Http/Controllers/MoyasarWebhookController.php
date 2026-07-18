<?php

namespace App\Http\Controllers;

use App\Services\BillingWebhookHandler;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class MoyasarWebhookController extends Controller
{
    public function __invoke(Request $request, BillingWebhookHandler $handler): Response
    {
        $payload = $request->all();
        if ($payload === []) {
            $decoded = json_decode($request->getContent(), true);
            if (is_array($decoded)) {
                $payload = $decoded;
            }
        }

        $secret = config('services.moyasar.webhook_secret');
        if (filled($secret)) {
            $token = $payload['secret_token'] ?? $request->header('X-Moyasar-Secret');
            if (! is_string($token) || ! hash_equals((string) $secret, $token)) {
                return response('Invalid webhook secret', 401);
            }
        }

        if (isset($payload['data']) && is_array($payload['data'])) {
            $handler->handleMoyasarInvoice($payload['data']);
        } elseif (isset($payload['status'])) {
            $handler->handleMoyasarInvoice($payload);
        }

        return response('ok', 200);
    }
}
