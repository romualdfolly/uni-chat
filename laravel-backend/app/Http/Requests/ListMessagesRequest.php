<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ListMessagesRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'messages' => 'required|array', // 'messages' must be an array
            'messages.*.sender_id' => ['required', 'exists:users,id', 'integer'],
            'messages.*.receiver_id' => ['required', 'exists:users,id', 'integer'],
            'messages.*.ciphertext' => ['required', 'string'],
            'messages.*.c_nonce' => ['required', 'string'],
            'messages.*.c_mac' => ['required', 'string'],
            'messages.*.aes_key_encrypted' => ['required', 'string'],
            'messages.*.key_nonce' => ['required', 'string'],
            'messages.*.key_mac' => ['required', 'string'],
            'messages.*.kref' => ['required', 'integer'],
            'messages.*.hash' => ['required', 'string'],
            'messages.*.digital_signature' => ['required', 'string'],
            'messages.*.sender_edpk' => ['required', 'string'],
            'messages.*.sender_xpk' => ['required', 'string'],
            'messages.*.hkdf_nonce' => ['required', 'string'],
            'messages.*.is_read' => ['nullable', 'boolean'],
            'messages.*.is_deleted' => ['nullable', 'boolean'],
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
            'messages.required' => 'The messages field is required.',
            'messages.array' => 'The messages field must be an array.',
            'messages.*.sender_id.required' => 'The sender ID is required.',
            'messages.*.receiver_id.required' => 'The receiver ID is required.',
            'messages.*.ciphertext.required' => 'The encrypted message content is required.',
            'messages.*.c_nonce.required' => 'The nonce for the ciphertext is required.',
            'messages.*.c_mac.required' => 'The MAC for the ciphertext is required.',
            'messages.*.aes_key_encrypted.required' => 'The AES key is required.',
            'messages.*.key_nonce.required' => 'The nonce for the key is required.',
            'messages.*.key_mac.required' => 'The MAC for the key is required.',
            'messages.*.kref.required' => 'The key reference is required.',
            'messages.*.hash.required' => 'The hash of the message is required.',
            'messages.*.digital_signature.required' => 'The digital signature is required.',
            'messages.*.sender_edpk.required' => 'The sender\'s public key is required.',
            'messages.*.sender_xpk.required' => 'The sender\'s public key is required.',
            'messages.*.hkdf_nonce.required' => 'The nonce for key derivation is required.',
            'messages.*.online_id.required' => 'The online ID is required.',
            'messages.*.is_read.boolean' => 'The read status must be a boolean.',
            'messages.*.is_deleted.boolean' => 'The deleted status must be a boolean.',
        ];
    }

    /**
     * Handle failed validation.
     *
     * @param \Illuminate\Contracts\Validation\Validator $validator
     * @return void
     */
    protected function failedValidation(\Illuminate\Contracts\Validation\Validator $validator)
    {
        throw new \Illuminate\Http\Exceptions\HttpResponseException(response()->json([
            'success' => false,
            'errors' => $validator->errors(),
        ], 422));
    }
}
