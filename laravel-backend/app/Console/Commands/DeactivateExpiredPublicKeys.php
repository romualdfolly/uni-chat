<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\PublicKey;
use Carbon\Carbon;

class DeactivateExpiredPublicKeys extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'keys:deactivate-expired-public-keys';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Deactivates public keys that has expired';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $now = Carbon::now();

        $expiredKeys = PublicKey::where('valid_until', '<=', $now)
            ->where('is_active', true)
            ->get();

        foreach ($expiredKeys as $key) {
            $key->is_active = false;
            $key->save();
        }


        $this->info("{$expiredKeys->count()} expried keys are deactivated");
    }
}
