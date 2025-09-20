<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;
    public $channelName;

    public function __construct($message)
    {
        $this->message = $message;
        $this->channelName = 'private-chat-' . $message->receiver_id;
    }

    public function broadcastOn(): array
    {
        return [
            new Channel($this->channelName)
        ];
    }

    // Personnalisation du nom de l'événement
    public function broadcastAs()
    {
        return 'new_message';  // Au lieu de 'MessageSent'
    }

    public function broadcastWith()
    {
        return [
            'id' => $this->message->id,
            'sender_id' => $this->message->sender_id,
            'receiver_id' => $this->message->receiver_id,
            'ciphertext' => $this->message->ciphertext,
            'c_nonce' => $this->message->c_nonce,
            'c_mac' => $this->message->c_mac,
            'aes_key_encrypted' => $this->message->aes_key_encrypted,
            'key_nonce' => $this->message->key_nonce,
            'key_mac' => $this->message->key_mac,
            'kref' => $this->message->kref,
            'hash' => $this->message->hash,
            'digital_signature' => $this->message->digital_signature,
            'sender_edpk' => $this->message->sender_edpk,
            'sender_xpk' => $this->message->sender_xpk,
            'hkdf_nonce' => $this->message->hkdf_nonce,
            'is_read' => $this->message->is_read,
            'is_deleted' => $this->message->is_deleted,
            'created_at' => $this->message->created_at,
            'updated_at' => $this->message->updated_at,
        ];
    }

}
