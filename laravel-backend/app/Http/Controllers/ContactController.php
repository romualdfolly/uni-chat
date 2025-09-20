<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class ContactController extends Controller
{
    function check_contact(Request $request) {
        // validation : rules
        $validator = Validator::make($request->all(), [
            'identifier' => 'required|string',
        ]);

        // server response in case of failure
        if ($validator->fails()) {
            throw new HttpResponseException(
                response()->json([
                    'success' => false,
                    'errors' => $validator->errors(),
                ], 422)
            );
        }

        // identifier
        $identifier = $request->input('identifier');

        // check if user exists
        $user = User::where('email', $identifier)
                    ->orWhere('username', $identifier)
                    ->first();
                    

        // in case of non existence
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => "No Account found for user '".$identifier."'"
            ], 404);
        }

        // self checkking
        if ($user->id === Auth::user()->id) {
            return response()->json([
                'success' => false,
                'message' => "You can't add yourself as contact."
            ], 403);
        }

        // reading user keys infos
        $key = $user->publicKey()->where('is_active', 1)->first();

        // when key are null
        if ($key === null) {
            return response()->json([
                'success' => false,
                'message' => "Account is pending confirmation. Please try again later."
            ], 403);
        }
    
        return response()->json([
            'success' => true,
            'data' => [
                'userId'    => $user->id,
                'email'     => $user->email,
                'username'  => $user->username,
                'name'      => $user->name,
                'ePublicKey' => optional($key)->e_key,
                'xPublicKey' => optional($key)->x_key,
                'keyId' => optional($key)->key_id,
                'picture'   => $user->picture ?? '',
            ]
        ], 200);
    }

    function get_contact_infos_by_id($id) {
        // attempt reading data
        $user = User::find($id);


        // in case of non existence
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => "Error fetching contact. Not found"
            ], 404);
        }

        // self checkking
        if ($user->id === Auth::user()->id) {
            return response()->json([
                'success' => false,
                'message' => "You can't add yourself as contact."
            ], 403);
        }

        // reading user keys infos
        $key = $user->publicKey()->where('is_active', 1)->first();
    
        return response()->json([
            'success' => true,
            'data' => [
                'userId'    => $user->id,
                'email'     => $user->email,
                'username'  => $user->username,
                'name'      => $user->name,
                'ePublicKey' => optional($key)->e_key,
                'xPublicKey' => optional($key)->x_key,
                'keyId' => optional($key)->key_id,
                'picture'   => $user->picture ?? '',
            ]
        ], 200);
    }
}
