<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Media extends Model
{
    protected $fillable = ['message_id', 'media_encrypted', 'aes_key_encrypted', 'media_type'];

    // Relation polymorphique vers les messages
    public function messages()
    {
        return $this->belongsTo(Message::class, 'medias');
    }
}
