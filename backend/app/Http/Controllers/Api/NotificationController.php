<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $user  = $request->user();
        $query = AppNotification::query()
            ->where('company_id', $user->company_id)
            ->orderByDesc('created_at');

        if ($user->role === 'employee') {
            $query->whereHas('employee', fn ($q) => $q->where('user_id', $user->id));
        }

        $rows = $query->get();

        return response()->json(
            $rows->map(fn (AppNotification $n) => $this->format($n))->all()
        );
    }

    public function markRead(Request $request, string $id)
    {
        $n = $this->findForUser($request, $id);
        if (! $n) {
            return response()->json(['message' => 'Not found'], 404);
        }

        if (! $n->read_at) {
            $n->read_at = Carbon::now();
            $n->save();
        }

        return response()->json(['message' => 'Marked as read']);
    }

    public function markAllRead(Request $request)
    {
        $user  = $request->user();
        $query = AppNotification::query()
            ->where('company_id', $user->company_id)
            ->whereNull('read_at');

        if ($user->role === 'employee') {
            $query->whereHas('employee', fn ($q) => $q->where('user_id', $user->id));
        }

        $query->update(['read_at' => Carbon::now()]);

        return response()->json(['message' => 'All marked as read']);
    }

    public function destroy(Request $request, string $id)
    {
        $n = $this->findForUser($request, $id);
        if (! $n) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $n->delete();

        return response()->json(['message' => 'Deleted']);
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private function findForUser(Request $request, string $id): ?AppNotification
    {
        $user  = $request->user();
        $query = AppNotification::query()
            ->where('company_id', $user->company_id)
            ->where('id', $id);

        if ($user->role === 'employee') {
            $query->whereHas('employee', fn ($q) => $q->where('user_id', $user->id));
        }

        return $query->first();
    }

    private function format(AppNotification $n): array
    {
        return [
            'id'         => $n->id,
            'title'      => $n->title,
            'body'       => $n->body,
            'read_at'    => $n->read_at?->toIso8601String(),
            'created_at' => $n->created_at?->toIso8601String(),
            'type'       => $n->type,
        ];
    }
}
