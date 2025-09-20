<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Helpers\Helper;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use App\Http\Requests\LoginRequest;
use Illuminate\Support\Facades\Hash;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\MailVerificationRequest;
use App\Http\Requests\UpdatePasswordResquest;
use App\Models\MailVerificationCode;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function login(LoginRequest $request) {

        $validated = $request->validated();


        // checking
        $user = User::where('email', $validated['identifier'])
            ->orWhere('username', $validated['identifier'])
            ->first();


        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid identifier or password',
            ], 401);
        }

        // token
        $token = $user->createToken(
            $request->input('password').now().Str::random(rand(10, 100))
        )->plainTextToken;

        // check if user is verified
        if (!$user->email_verified_at)
        {
            $code = $this->sendVerificationCode($user->id);
            return response()->json([
                'success' => true,
                'message' => 'Login successful. Verification code has been sent to you',
                'verification-code' => $code,
                'data' => $user->except(['password', 'email_verified_at']),
                'token' => $token
            ], 200);
        }
        else
        {
            // update last connection
            $user->last_connection_at = now();
            $user->update();
        }

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => $user->except(['password']),
            'token' => $token
        ], 200);
    }


    public function register(RegisterRequest $request) {
        //
        $request->validated();


        // creating user
        $user = User::create(
            [
                'username' => $request->input('username'),
                'name' => $request->input('name'),
                'email' => $request->input('email'),
                'password' => Hash::make($request->input('password')),
                'created_at' => now(),
                'updated_at' => now()
            ]
        );

        // verification code generation
        $code = $this->sendVerificationCode($user->id);

        $token = $user->createToken(
            $request->input('password').now().Str::random(rand(10, 100))
        )->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Verification code has been sent to you (Email)',
            'verification-code' => $code,
            'data' => $user->except(['password', 'email_verified_at']),
            'token' => $token
        ], 200);
    }


    public function verify_mail(MailVerificationRequest $request) {
        //
        $request->validated();
        $verification = MailVerificationCode::where('user_id', $request->input('user_id'))->first();

        // user not existing
        if (!$verification)
        {
            return response()->json([
                'success' => false,
                'message' => 'No verification record found for this user',
            ], 404);
        }

        // code has expired
        if ($verification->expires_at && now()->gt($verification->expires_at)) {
            $code = $this->sendVerificationCode($request->input('user_id'));
            return response()->json([
                'success' => false,
                'message' => 'The verification code has expired. New code has been sent to you',
                'code' => $code
            ], 410);  // Utilisation du code 410 (Gone) pour indiquer qu'un élément est expiré
        }

        // code not matcing
        if ($verification->code != $request->input('code'))
        {
            return response()->json([
                'success' => false,
                'message' => 'Incorrect verification code',
            ], 401);
        }

        // updation User infos
        $date_time = now();
        User::find($request->input('user_id'))->update([
            'email_verified_at' => $date_time,
            'last_connection_at' => $date_time
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Your Mail address is successfully verified',
            'data' => [
                'date_time' => $date_time
            ]
        ], 200);
    }



    public function deletion_verify_password(LoginRequest $request) {
        //
        $validated = $request->validated();
        $user = User::find($request->input('identifier'));

        // password verification
        if (!$user || !Hash::check($request->input('password'), $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Incorrect Password. Try again !',
            ], 401);
        }
        
        // code generation and sending
        $code = $this->sendVerificationCode($user->id);
        return response()->json([
            'success' => true,
            'message' => 'You passed verification.Confirmation code has been sent to you',
            'code' => $code
        ], 200);
    }

    public function delete_account(MailVerificationRequest $request) {
        //
        $request->validated();
        $verification = MailVerificationCode::where('user_id', $request->input('user_id'))->first();

        // user not existing
        if (!$verification)
        {
            return response()->json([
                'success' => false,
                'message' => 'No verification record found for this user',
            ], 404);
        }

        // code has expired
        if ($verification->expires_at && now()->gt($verification->expires_at)) {
            $code = $this->sendVerificationCode($request->input('user_id'));
            return response()->json([
                'success' => false,
                'message' => 'The verification code has expired. New code has been sent to you',
                'code' => $code
            ], 410);  // Utilisation du code 410 (Gone) pour indiquer qu'un élément est expiré
        }

        // code not matcing
        if ($verification->code != $request->input('code'))
        {
            return response()->json([
                'success' => false,
                'message' => 'Incorrect verification code',
            ], 401);
        }

        $user_id = $request->input('user_id');
        // user deletion
        User::find($user_id)->delete();
        
        // tokens deletion
        DB::table('personal_access_tokens')
                ->where('tokenable_id', $user_id)
                ->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Account successfully deleted',
        ], 200);
    }




    public function update_password(UpdatePasswordResquest $request) {
        //
        $validated = $request->validated();
        $user = User::find($validated['user_id']);

        if (!$user || !Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'The current password is incorrect',
            ], 401);
        }

        // update password
        $user->password = Hash::make($validated['password']);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password successfully updated',
        ], 200);
    }



    private function sendVerificationCode($user_id)
    {
        $code = Helper::generateVerificationCode();
        // saving / updating
        $mailVerification = MailVerificationCode::where('user_id', $user_id)->first();
        if ($mailVerification)
        {
            // UPDATE
            $mailVerification->code = $code;
            $mailVerification->sent_at = now();
            $mailVerification->expires_at = now()->addMinutes(Helper::$VERIFICATION_CODE_VALIDITY);
            $mailVerification->update();
        }
        else
        {
            // SAVING
            MailVerificationCode::create([
                'user_id' => $user_id,
                'code' => $code,
                'sent_at' => now(),
                'expires_at' => now()->addMinutes(Helper::$VERIFICATION_CODE_VALIDITY)
            ]);
        }

        return $code;
    }


    public function logout(Request $request) {

        $request->user()->tokens()->delete();

        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'You are successfully logged out',
            ], 200);
        }

        return redirect()->route('login');
    }
}
