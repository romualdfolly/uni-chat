<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\PublicKeyController;
use App\Http\Controllers\PusherAuthController;

// AUTHENTIFICATION
Route::prefix('auth')->name('api.auth.')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->name('login');
    Route::post('/register', [AuthController::class, 'register'])->name('register');
    

    Route::middleware('auth:sanctum')->group(function () {
        // verify and update password
        Route::post('/verify', [AuthController::class, 'verify_mail'])->name('verify');
        Route::post('/update-password', [AuthController::class, 'update_password'])->name('update_password');

        // Account deletion
        Route::prefix('/deletion')->name('deletion.')->group(function () {
            Route::post('/verify-password', [AuthController::class, 'deletion_verify_password'])->name('verify-password');
            Route::post('/delete-account', [AuthController::class, 'delete_account'])->name('delete_account');
        });

        // Logout
        Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    });
});



Route::middleware('auth:sanctum')->name('api.')->group(function () {
    //=====================================================//
      // ================   KEYS MANAGEMENT ================ //
    //=====================================================//
    Route::prefix('key')->name('key.')->group(function() {
        Route::post('/store', [PublicKeyController::class, 'store'])->name('store');
        Route::post('/update', [PublicKeyController::class, 'store'])->name('update');                    # Not Yet
    });

    
    //=====================================================//
      // =================      CONTACTS    ================ //
    //=====================================================//
    Route::prefix('contact')->name('contact.')->group(function() {
        Route::post('/check', [ContactController::class, 'check_contact'])->name('check');
        Route::get('/get/{id}', [ContactController::class, 'get_contact_infos_by_id'])->name('get_contact')->whereNumber('id');
    });


    //=====================================================//
      // =================       PUSHER     ================ //
    //=====================================================//
    Route::prefix('pusher')->name('pusher.')->group(function() {
        Route::post('/auth', [PusherAuthController::class, 'auth'])->name('auth');
    });


    //=====================================================//
      // =================      MESSAGES    ================ //
    //=====================================================//
    Route::prefix('message')->name('message.')->group(function() {
        // Fetch unreaded messages for the authenticated user
        Route::get('/fetch', [MessageController::class, 'readUnreadedMessages'])->name('fetch');

        // Fetch all messages for the authenticated
        Route::get('/fetch_all',  [MessageController::class, 'fetchAll'])->name('fetchAll');
        
        // get and store a message
        Route::post('/send', [MessageController::class, 'store'])->name('send');

        // get and store list of messages
        Route::post('/send/messages', [MessageController::class, 'store_messages'])->name('mulisend');
        
        // Update a specific message
        Route::post('/update_reading', [MessageController::class, 'setAsReaded'])->name('update_reading');                         # Not Yet
        
        // Delete a specific message
        Route::delete('/{id}', [MessageController::class, 'destroy'])->name('destroy');                    # Not Yet
    });
});
