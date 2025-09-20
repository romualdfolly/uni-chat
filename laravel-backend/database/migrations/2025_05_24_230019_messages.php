<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();

            // Foreign keys
            $table->foreignId('sender_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('receiver_id')->constrained('users')->onDelete('cascade');

            // Encrypted content and AES encryption parameters
            $table->longText('ciphertext');
            $table->text('c_nonce');
            $table->text('c_mac');

            $table->longText('aes_key_encrypted');
            $table->text('key_nonce');
            $table->text('key_mac');

            // Local key reference
            $table->integer('kref')->comment('key reference');

            // Hash and digital signature
            $table->longText('hash');
            $table->longText('digital_signature');

            // Sender’s Ed25519 and X25519 public keys
            $table->text('sender_edpk');
            $table->text('sender_xpk');

            // HKDF Nonce for key derivation
            $table->text('hkdf_nonce')->comment('Nonce used for HKDF key derivation');

            // id of local message on sender device
            $table->integer('remote_ref')->default(0);

            // Flags for read/deleted status
            $table->boolean('is_read')->default(false);
            $table->boolean('is_deleted')->default(false);

            // Timestamps
            $table->timestamps();

            // Indexes
            $table->index('sender_id');
            $table->index('receiver_id');
            $table->index('kref');
            $table->index('is_read');
            $table->index('is_deleted');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Disable foreign key checks to safely drop table
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        Schema::dropIfExists('messages');
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
};
