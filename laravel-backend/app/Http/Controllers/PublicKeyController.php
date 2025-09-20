<?php

namespace App\Http\Controllers;

use App\Http\Requests\KeysStoreRequest;
use App\Http\Requests\KeysDeactivateRequest;
use App\Models\PublicKey;

class PublicKeyController extends Controller
{
    /**
     * Store a newly created resource in storage.
     */
    public function store(KeysStoreRequest $request)
    {
        // Validation
        $validated = $request->validated();

        // deactivation of all keys of the user before saving the new
        PublicKey::where('user_id', $request->input('user_id'))
                   ->where('is_active', true)
                   ->update(['is_active' => false]);

        // saving in database
        PublicKey::create([
            'user_id' => $request->input('user_id'),
            'key_id' => $request->input('key_id'),
            'e_key' => $request->input('e_key'),
            'x_key' => $request->input('x_key'),
            'is_active' => $request->input('is_active'),
            'created_at' => $request->input('created_at'),
            'valid_until' => $request->input('valid_until'),
        ]);


        return response()->json([
            'success' => true
        ], 201);
    }

    public function deactivate(KeysDeactivateRequest $request)
    {
        // Validation
        $validated = $request->validated();

        // saving in database
        $keys = PublicKey::where('user_id', $request->input('user_id'))
                            ->where('key_id', $request->input('key_id'))
                            ->where('created_at', $request->input('created_at'))
                            ->get();
        //
        return response()->json([
            'success' => true,
            'message' => $keys
        ], 201);
    }
}
