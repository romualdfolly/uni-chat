<?php

namespace App\Helpers;

use Illuminate\Support\Str;

class Helper
{
    /**
     * Génère un code aléatoire de vérification
     *
     * @param int $length Longueur du code à générer
     * @return string
     */
    public static $VERIFICATION_CODE_VALIDITY = 15;

    public static function generateVerificationCode(int $length = 6): int
    {
        $min = pow(10, $length - 1);
        $max = pow(10, $length) - 1;

        return random_int($min, $max);
    }
}
