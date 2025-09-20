<?php

namespace App\Http\Controllers;

use App\Http\Requests\PusherAuthRequest;
use Illuminate\Support\Facades\Log;
use Pusher\Pusher;

class PusherAuthController extends Controller
{
    public function auth(PusherAuthRequest $request)
    {
        $socketId = $request->input('socket_id');
        $channelName = $request->input('channel_name');

        // Initialiser Pusher
        $pusher = new Pusher(
            config('broadcasting.connections.pusher.key'),
            config('broadcasting.connections.pusher.secret'),
            config('broadcasting.connections.pusher.app_id'),
            [
                'cluster' => config('broadcasting.connections.pusher.options.cluster'),
                'useTLS' => config('broadcasting.connections.pusher.options.useTLS'),
            ]
        );

        // Authenticated the user for the channel
        $auth = $pusher->authorizeChannel($channelName, $socketId);
        
        //Log::info('Authenticating Pusher', ['socket_id' => $socketId, 'channel_name' => $channelName, 'user_id' => $request->input('user_id')]);

        return response()->json(json_decode($auth, true), 200);
    }
}