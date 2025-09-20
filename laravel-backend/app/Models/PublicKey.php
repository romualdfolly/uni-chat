<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;


class PublicKey extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'key_id',
        'e_key',
        'x_key',
        'is_active',
        'created_at',
        'valid_until',
    ];
    

    // Relation avec l'utilisateur
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relation avec les messages (clé publique utilisée pour le chiffrement des messages)
    public function messages()
    {
        return $this->hasMany(Message::class);
    }
}
