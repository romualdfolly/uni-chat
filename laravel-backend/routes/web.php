<?php

use Illuminate\Support\Facades\Route;

use App\Events\MessageSent;

Route::get('/', function () {
    return view('welcome');
});


Route::get('/send-message', function () {
    //event(new MessageSent('Hello depuis Laravel'));
    broadcast(new MessageSent('Hello depuis Laravel'))->toOthers();

    return 'Event broadcasted!';
});