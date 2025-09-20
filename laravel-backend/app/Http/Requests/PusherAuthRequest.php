<?php

namespace App\Http\Requests;

use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class PusherAuthRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = Auth::user();
        // Check if the authenticated user corresponds to the user ID provided in the request.
        return $user && $user->id == $this->input('user_id');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'socket_id' => ['required', 'string', 'regex:/^\d+\.\d+$/'], // Pusher socket_id format (ex: 123.456)
            'channel_name' => [
                'required',
                'string',
                'regex:/^private-chat-\d+$/', // Format private-chat-X (X is the user ID)
                function ($attribute, $value, $fail) {
                    // Extract the user ID from the channel name
                    $ids = explode('-', str_replace('private-chat-', '', $value));
                    
                    // Check if the user ID from the request matches the authenticated user
                    if (count($ids) !== 1 || !in_array(Auth::user()->id, $ids)) {
                        $fail("You are Unauthorized to this channel");
                    }
                },
            ],
            'user_id' => ['required', 'string', Rule::in([Auth::user()->id])], // User ID must match the authenticated user's ID
        ];
    }

    /**
     * Get custom error messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'socket_id.required' => 'The socket ID is required.',
            'socket_id.regex' => 'The socket ID is invalid.',
            'channel_name.required' => 'The channel name is required.',
            'channel_name.regex' => 'The channel name must be in the format private-chat-X.',
            'user_id.required' => 'The user ID is required.',
            'user_id.in' => 'The user ID is invalid.',
        ];
    }

    /**
     * Handle failed validation.
     *
     * @param \Illuminate\Contracts\Validation\Validator $validator
     * @throws \Illuminate\Http\Exceptions\HttpResponseException
     */
    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'errors' => $validator->errors(),
        ], 422));
    }
}
