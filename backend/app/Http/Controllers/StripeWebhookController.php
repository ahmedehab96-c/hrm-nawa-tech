<?php

namespace App\Http\Controllers;

use App\Services\BillingWebhookHandler;
use App\Services\StripeWebhookVerifier;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use RuntimeException;

class StripeWebhookController extends Controller
{
    public function __invoke(Request $request, StripeWebhookVerifier $verifier, BillingWebhookHandler $handler): Response
    {
        try {
            $event = $verifier->verify($request);
        } catch (RuntimeException $e) {
            return response($e->getMessage(), 400);
        }

        $handler->handleStripeEvent($event);

        return response('ok', 200);
    }
}
