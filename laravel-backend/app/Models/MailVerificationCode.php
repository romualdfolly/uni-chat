<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MailVerificationCode extends Model
{
    use HasFactory;

    public $timestamps = false;
    
    protected $fillable = [
        'user_id', 'code',
        'sent_at',
        'expires_at'
    ];

    protected $table = 'mail_verification_codes';
}
