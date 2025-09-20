<?php

namespace App\Models; 

use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    protected $fillable = [
        'id',
        'sender_id',
        'receiver_id',
        'ciphertext',
        'c_nonce',
        'c_mac',
        'aes_key_encrypted',
        'key_nonce',
        'key_mac',
        'kref',
        'hash',
        'digital_signature',
        'sender_edpk',
        'sender_xpk',
        'hkdf_nonce',
        'is_read',
        'is_deleted',
        'online_id'
    ];
    

    /**
     * Get the sender of the message.
     */
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    /**
     * Get the receiver of the message.
     */
    public function receiver()
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    /**
     * Get the public key associated with the message.
     */
    public function publicKey()
    {
        return $this->belongsTo(PublicKey::class, 'public_key_id'); // Relation to PublicKey with the correct foreign key
    }

    /**
     * Get the media associated with the message.
     */
    public function medias()
    {
        return $this->hasMany(Media::class, 'message_id'); // Correct foreign key for the relation
    }
}
