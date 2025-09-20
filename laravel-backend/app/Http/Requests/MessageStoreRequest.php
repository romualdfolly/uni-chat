<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MessageStoreRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // You can add additional logic if necessary to check if the user can send a message
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'sender_id' => ['required', 'exists:users,id', 'integer'],
            'receiver_id' => ['required', 'exists:users,id', 'integer'],
            'ciphertext' => ['required', 'string'],
            'c_nonce' => ['required', 'string'],
            'c_mac' => ['required', 'string'],
            'aes_key_encrypted' => ['required', 'string'],
            'key_nonce' => ['required', 'string'],
            'key_mac' => ['required', 'string'],
            'kref' => ['required', 'integer'],
            'hash' => ['required', 'string'],
            'digital_signature' => ['required', 'string'],
            'sender_edpk' => ['required', 'string'],
            'sender_xpk' => ['required', 'string'],
            'hkdf_nonce' => ['required', 'string'],
            'is_read' => ['nullable', 'boolean'],
            'is_deleted' => ['nullable', 'boolean'],
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
            'sender_id.required' => 'The sender ID is required.',
            'receiver_id.required' => 'The receiver ID is required.',
            'ciphertext.required' => 'The encrypted message content is required.',
            'c_nonce.required' => 'The nonce for the ciphertext is required.',
            'c_mac.required' => 'The MAC for the ciphertext is required.',
            'aes_key_encrypted.required' => 'The AES key is required.',
            'key_nonce.required' => 'The nonce for the key is required.',
            'key_mac.required' => 'The MAC for the key is required.',
            'kref.required' => 'The key reference is required.',
            'hash.required' => 'The hash of the message is required.',
            'digital_signature.required' => 'The digital signature is required.',
            'sender_edpk.required' => 'The sender\'s  public key is required.',
            'sender_xpk.required' => 'The sender\'s public key is required.',
            'hkdf_nonce.required' => 'The nonce for key derivation is required.',
            'is_read.boolean' => 'The read status must be a boolean.',
            'is_deleted.boolean' => 'The deleted status must be a boolean.',
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
