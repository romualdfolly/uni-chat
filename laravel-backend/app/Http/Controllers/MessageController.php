<?php

namespace App\Http\Controllers;

use App\Http\Requests\ListMessagesRequest;
use App\Http\Requests\MessageStoreRequest;
use App\Models\Message;
use App\Events\MessageSent;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class MessageController extends Controller
{
    /**
     * fetchs All messages
     * @return void
     */
    public function fetchAll() {
        // Authenticated User id
        $userId = Auth::user()->id;

        // reading
        $messages = Message::where("receiver_id", $userId)
                            ->get([
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
                                'created_at'
                            ]);
        
        // Update is_read to true
        Message::where('receiver_id', $userId)
                ->where('is_read', false)
                ->update(['is_read' => true]);

        // Return the selected attributes
        return response()->json($messages, 200);
    }


    /**
     * reads and send unreaded mesages to client
     */
    public function readUnreadedMessages()
    {
        // Authenticated User id
        $userId = Auth::user()->id;

        // Reading of unread messages
        $messages = Message::where("receiver_id", $userId)
                            ->where("is_read", false)
                            ->get([
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
                                'created_at'
                            ]);

        // Update is_read to true
        Message::where('receiver_id', $userId)
                ->where('is_read', false)
                ->update(['is_read' => true]);

        // Return the selected attributes
        return response()->json($messages, 200);
    }


    /**
     * Store a newly created resource in storage.
     */
    public function store(MessageStoreRequest $request)
    {
        // store the message
        $message = Message::create($request->validated());
        // $message = new Message($request->validated());

        // broad cast
        broadcast(new MessageSent($message));


        return response()->json([
            'success' => true,
            'message' => 'Message successfully sent',
            'remote_ref' => $message->id,
        ], 200);
    }


    /**
     * Store multiple messages in the database.
     *
     * @param  \App\Http\Requests\ListMessagesRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store_messages(ListMessagesRequest $request)
    {
        // Automatically validated messages (thanks to ListMessagesRequest)
        $messages = $request->validated()['messages'];

        // Store the messages in the database
        foreach ($messages as $messageData) {
            // store the message
            $message = Message::create($messageData);

            // broad cast
            broadcast(new MessageSent($message));
        }

        // Return a success response
        return response()->json([
            'success' => true,
            'message' => 'Messages have been successfully stored.',
        ], 200);
    }

    /**
     * Update messages as readed : get list of concerned messages ID.
     */
    public function setAsReaded(Request $request)
    {
        // Authenticated User ID
        $userId = Auth::user()->id;

        // IDs
        $messageIds = $request->input('message_ids');

        // update
        Message::where('receiver_id', $userId)
                ->whereIn('id', $messageIds)
                ->update(['is_read' => true]);
        
        //
        return response()->json([], 204);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
