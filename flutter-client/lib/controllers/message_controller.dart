import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cryptography/cryptography.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/controllers/contact_controller.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/key_pair.dart';
import 'package:unichat_flutter/controllers/keys_controller.dart';
import 'package:unichat_flutter/models/message.dart';
import 'package:unichat_flutter/models/online_message_format.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/objectbox.g.dart';
import 'package:unichat_flutter/services/message_service.dart';
import 'package:unichat_flutter/utils/http_response_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageController {
  //
  final keysController = KeysController();
  final databaseController = Get.find<DatabaseController>();
  final MessageService messageService = MessageService();

  /// fetchs and sends unsent messages from server
  Future<void> fetchAndSendUnsentMessagesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasFetchedMessages = prefs.getBool('hasFetchedMessages') ?? false;

    if (!hasFetchedMessages) {
      // for the first time we fetch messages
      await fetchMessagesFromServer();
      await sendUnsentMessagesToServer();

      // update indicator
      await prefs.setBool('hasFetchedMessages', true);
    }
    // await prefs.setBool('hasFetchedMessages', false);
  }

  Future<void> fetchMessagesFromServer() async {
    // get current User Data
    final currentUser = Get.find<User>(tag: 'currentUser');

    //
    try {
      //
      http.Response response = await messageService.fetchMessagesFromServer(
        token: currentUser.authToken,
      );

      if (response.statusCode == 200) {
        // response to json
        final List<dynamic> messagesData = jsonDecode(response.body);

        // Data processing
        for (var data in messagesData) {

          // OnlineMessageFormat object
          final onlineMessage = OnlineMessageFormat.fromJson(data);

          // update UI
          saveMessageLocallyAndUpdateUI(onlineMessage: onlineMessage);
        }
      } else {
        print("Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      print("[Error]: $e");
    }
  }

  /// sends local unsent messages to server
  Future<void> sendUnsentMessagesToServer() async {
    //
    final meAsContact = Get.find<Contact>(tag: "meAsContact");

    // load unsent messages
    final List<Message> unsentMessages =
        databaseController.messageBox
            .query(
              Message_.isSent
                  .equals(false)
                  .and(Message_.sender.equals(meAsContact.id)),
            )
            .build()
            .find();
    // do nothing if list is empty
    if (unsentMessages.isNotEmpty) {
      // We Decrypt to original messge then encrypt using 'x' and send to server
      List<OnlineMessageFormat> onlineMessages = [];

      for (Message message in unsentMessages) {
        // Decryption
        final messageContent = await decryptLocalMessage(message);
        // create online Message format
        final encryptedMessage = await encryptMessageForServer(
          message: messageContent!,
          receiver: message.receiver.target!,
        );

        // add to list
        onlineMessages.add(encryptedMessage!);

        // send to server
        try {
          // get current User Data
          final currentUser = Get.find<User>(tag: 'currentUser');
          //
          http.Response response = await messageService.sendLocalUnsentMessages(
            messagesList: onlineMessages,
            token: currentUser.authToken,
          );

          if (response.statusCode == 200) {
            //
            final chatController = Get.find<ChatController>();

            // update messages attribute isSent to true
            // 1 - message chat ID
            for (
              int index = 0;
              index < chatController.chatsAndMessagesList.values.length;
              index++
            ) {
              chatController
                  .chatsAndMessagesList
                  .values
                  .elementAt(index)[0]
                  .isSent = true;
            }
            chatController.chatsAndMessagesList.refresh();

            // update message in local Database
            for (Message message in unsentMessages) {
              message.isSent = true;
              databaseController.messageBox.put(message);
            }
          }
        } catch (e) {
          print("[-] $e");
        }
      }
    }
  }

  /// Decrypts message from server
  Future<OnlineMessageFormat?> encryptMessageForServer({
    required String message,
    required Contact receiver,
  }) async {
    //
    late final KeyPairEntity currentValidKeypairs;
    final currentUser = Get.find<User>(tag: 'currentUser');

    // try to get current valid key pairs
    try {
      // Attempt to find the current valid key pairs from Get
      currentValidKeypairs = Get.find<KeyPairEntity>(
        tag: 'currentValidKeypairs',
      );
    } catch (e) {
      // If not found, fetch the valid key pairs from the keysController
      currentValidKeypairs = (await databaseController.getValidKeyPairs())!;
      // Storage
      Get.put(currentValidKeypairs, tag: 'currentValidKeypairs');
    }

    // Get derived AES (will be used to decrypt private keys)
    final aesKeyFromPin = await KeysController.loadDerivedAES();

    // decryption of the Ed keys
    final edPrivKey = await KeysController.decryptWithAesGcm(
      aesKey: base64Decode(aesKeyFromPin),
      nonce: base64Decode(currentValidKeypairs.edPrivNonce),
      mac: base64Decode(currentValidKeypairs.edPrivMac),
      cipherText: base64Decode(currentValidKeypairs.edPrivCipher),
    );

    // x will be used to decrypt AESkey from server
    final xPrivKey = await KeysController.decryptWithAesGcm(
      aesKey: base64Decode(aesKeyFromPin),
      nonce: base64Decode(currentValidKeypairs.xPrivNonce),
      mac: base64Decode(currentValidKeypairs.xPrivMac),
      cipherText: base64Decode(currentValidKeypairs.xPrivCipher),
    );

    // Generate keyPairs
    final SimpleKeyPair myEdKeyPair =
        await KeysController.createKeyPairFromKeys(
          publicKeyBytes: base64Decode(currentValidKeypairs.edPubKey),
          privateKeyBytes: edPrivKey,
          keyPairType: KeyPairType.ed25519,
        );

    final SimpleKeyPair myXKeyPair = await KeysController.createKeyPairFromKeys(
      publicKeyBytes: base64Decode(currentValidKeypairs.xPubKey),
      privateKeyBytes: xPrivKey,
      keyPairType: KeyPairType.x25519,
    );

    /**
    // NOW WE CAN CREATE ONLINE MESSAGE OBJECT
    */
    // Generation of Data
    final (
      SecretBox messageSecretBox,
      SecretBox keySecretBox,
      List<int> hkdfNonce,
      List<int> hashBytes,
      List<int> signature,
    ) = await KeysController.generateAndEncryptAesGcmKeyAndMessageAndSignForServer(
      message: message,
      myEdKeyPair: myEdKeyPair,
      myXKeyPair: myXKeyPair,
      receiverXPublicKey: base64Decode(receiver.xPublicKey),
    );

    // OnlineMessageFormat Object
    final OnlineMessageFormat onlineMessageFormat = OnlineMessageFormat(
      senderId: currentUser.user_id,
      receiverId: receiver.userId,
      ciphertext: base64Encode(messageSecretBox.cipherText),
      cNonce: base64Encode(messageSecretBox.nonce),
      cMac: base64Encode(messageSecretBox.mac.bytes),
      aesKeyEncrypted: base64Encode(keySecretBox.cipherText),
      keyNonce: base64Encode(keySecretBox.nonce),
      keyMac: base64Encode(keySecretBox.mac.bytes),
      kref: receiver.keyId,
      hash: base64Encode(hashBytes),
      digitalSignature: base64Encode(signature),
      senderEdpk: base64Encode((await myEdKeyPair.extractPublicKey()).bytes),
      senderXpk: base64Encode((await myXKeyPair.extractPublicKey()).bytes),
      hkdfNonce: base64Encode(hkdfNonce),
      isRead: false,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return onlineMessageFormat;
  }

  /// Decrypts message from server
  Future<List<int>?> decryptMessageFromServer({
    required OnlineMessageFormat message,
  }) async {
    //
    // 1 - verify signature
    if (!await KeysController.verifySignature(
      messageHashBase64: message.hash,
      signatureBase64: message.digitalSignature,
      senderEdPublickeyBase64: message.senderEdpk,
    )) {
      // then alert of potential security issues
      print("[!] ---> Verification Failed");
      return null;
    } else {
      print("[+] ---> Verified");
    }

    // my key infos
    final myKeys = await keysController.getKeysById(message.kref);

    // Get derived AES
    final aesKeyFromPin = await KeysController.loadDerivedAES();

    // decryption of the X keys
    final xPrivKey = await KeysController.decryptWithAesGcm(
      aesKey: base64Decode(aesKeyFromPin),
      nonce: base64Decode(myKeys.xPrivNonce),
      mac: base64Decode(myKeys.xPrivMac),
      cipherText: base64Decode(myKeys.xPrivCipher),
    );

    //
    final SimpleKeyPair myXKeyPair = await KeysController.createKeyPairFromKeys(
      publicKeyBytes: base64Decode(myKeys.xPubKey),
      privateKeyBytes: xPrivKey,
      keyPairType: KeyPairType.x25519,
    );

    // 2 - now private keys are decrypted : Let's decrypt sent AESKey with our private key
    final decryptedAsKeyFromServer = await KeysController.decryptServerAesKey(
      aesKeyFromServerBase64: message.aesKeyEncrypted,
      senderXPublicKeyBase64: message.senderXpk,
      myXKeyPair: myXKeyPair,
      aesNonceBase64: message.keyNonce,
      aesMacBase64: message.keyMac,
      hkdfNonceBase64: message.hkdfNonce,
    );

    // we have the original AES key. Now, let us decrypt the message
    final decrypteMessage = await KeysController.decryptWithAesGcm(
      aesKey: decryptedAsKeyFromServer,
      nonce: base64Decode(message.cNonce),
      mac: base64Decode(message.cMac),
      cipherText: base64Decode(message.ciphertext),
    );

    return decrypteMessage;
  }

  /// sends message
  Future<void> sendMessage({required String message}) async {
    //
    RxBool isLoading = false.obs;
    final currentUser = Get.find<User>(tag: 'currentUser');

    //
    try {
      final conversationPeer = Get.find<Contact>(tag: 'conversationPeer');
      final onlineMessageFormat = await encryptMessageForServer(
        message: message,
        receiver: conversationPeer,
      );

      //* / save locally
      final (
        Chat? chat,
        int indexAt,
        int remoteRef,
      ) = await saveMessageLocallyAndUpdateUI(
        onlineMessage: onlineMessageFormat!,
        originalMessageBeforeEncryption: message,
        isEnteringMessage: false,
      );
      // */

      // send to server
      http.Response response = await messageService.sendMessage(
        message: onlineMessageFormat,
        token: currentUser.authToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //
        // update message attribute :isSent to True
        final chatController = Get.find<ChatController>();
        final message = chatController.chatsAndMessagesList[chat]![indexAt - 1];
        message.isSent = true;

        // update database
        message.remoteRef = jsonDecode(response.body)['remote_ref'] as int;
        databaseController.messageBox.put(message);
        

        // refresh UI
        chatController.chatsAndMessagesList.refresh();
      } else {
        handleResponse(response);
      }
    } catch (e) {
      print("[Error]: $e"); // Optionally log the error for debugging
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// receives messages
  Future<String?> receiveMessage({required OnlineMessageFormat message}) async {
    // proceed to message decryption
    final List<int>? decryptedMessage = await decryptMessageFromServer(
      message: message,
    );

    final String? originalMessage =
        decryptedMessage != null ? utf8.decode(decryptedMessage) : null;
    return originalMessage;
  }

  Future<Message> createMessageFromDecrypted({
    required String decryptedMessage,
    required DateTime messageCreatedAt,
    required bool isEnteringMessage,
    required int remoteRef,
  }) async {
    // 1. Generate AES-GCM keys and save
    final (
      SecretKey messageAesKey,
      SecretBox encryptedMessageBox,
    ) = await KeysController.encryptWithAesGcm(
      data: utf8.encode(decryptedMessage),
    );

    // 2. Reading the derived AES from PIN
    final derivedAesKey = base64Decode(await KeysController.loadDerivedAES());

    // 3. Encrypt the AES-GCM key with the derived AES from PIN
    final (
      SecretKey keyFromAesKey,
      SecretBox encryptedAesKeyBox,
    ) = await KeysController.encryptWithAesGcm(
      aesKey: derivedAesKey,
      data: await messageAesKey.extractBytes(),
    );

    // creates message object
    final int remoteReference = isEnteringMessage ? remoteRef : -1;
    final message = Message(
      content: base64Encode(encryptedMessageBox.cipherText),
      aesMac: base64Encode(encryptedMessageBox.mac.bytes),
      aesNonce: base64Encode(encryptedMessageBox.nonce),

      aesKey: base64Encode(encryptedAesKeyBox.cipherText),
      aesKeyMac: base64Encode(encryptedAesKeyBox.mac.bytes),
      aesKeyNonce: base64Encode(encryptedAesKeyBox.nonce),

      isReaded: true,
      isSent: isEnteringMessage,

      remoteRef: remoteReference,

      timestamp: messageCreatedAt,
    );

    return message;
  }

  /// saves the received message locally and updates the UI
  Future<(Chat?, int, int)> saveMessageLocallyAndUpdateUI({
    required OnlineMessageFormat onlineMessage,
    String originalMessageBeforeEncryption = '',
    bool isEnteringMessage = true,
  }) async {
    final chatController = Get.find<ChatController>();

    // we do nothing if remoteRef already exists in local
    if (chatController.remoteRefsList.contains(onlineMessage.id) &&
        onlineMessage.id != -1) {
      // we stop the operations
      print("======================================= NOTHING ===========");
      return (null, -2, -1);
    }

    String? originalMessage;
    // incoming or outcoming message
    if (isEnteringMessage) {
      // it is incomning
      // decryption of the message
      originalMessage = await receiveMessage(message: onlineMessage);
    } else {
      // it is outcomming message
      originalMessage = originalMessageBeforeEncryption;
    }

    // cration of Message object
    if (originalMessage == null) {
      return (null, -2, -1);
    }

    ///==============================
    //       CONTACTS COMPUTING
    ///==============================
    final contactController = ContactController();

    // 1. Me As Contact
    final meAsContact = Get.find<Contact>(tag: 'meAsContact');

    // 2. conversationPeer contact : getBy id
    final peerId =
        (meAsContact.userId == onlineMessage.receiverId)
            ? onlineMessage.senderId
            : onlineMessage.receiverId;

    final conversationPeer = contactController
        .checkIfContactExistsLocalyByUserId(peerId);

    // if null, we read on server database
    if (conversationPeer == null) {
      // Get contact
      final conversationPeer = await contactController
          .getContactInfosByIdFromServer(peerId);
      // save contact locally
      ContactController.saveContactIfNotExists(conversationPeer!);
      print(">>>> contact Added");
    }

    /// sender and receiver computing
    final senderContact =
        meAsContact.userId == onlineMessage.senderId
            ? meAsContact
            : conversationPeer;
    final receiverContact =
        meAsContact.userId != onlineMessage.senderId
            ? meAsContact
            : conversationPeer;

    ///==============================
    //       CHAT COMPUTING &| UPDATE
    ///==============================
    //
    var chat = Chat(isGroup: false);
    chat.participants.addAll([senderContact!, receiverContact!]);

    // we check if this chat exists already in memory : else create it
    final Chat? existingChat = chatController.findExistingChat(
      chat.participants.toList(),
    );

    if (existingChat == null) {
      // create and save the chat
      chat = (await chatController.checkOrCreateChatWith(conversationPeer!))!;
    } else {
      chat = existingChat;
    }

    ///==============================
    //       MESSAGE OBJECT COMPUTING
    ///==============================

    Message message = await createMessageFromDecrypted(
      decryptedMessage: originalMessage,
      messageCreatedAt: onlineMessage.createdAt,
      isEnteringMessage: isEnteringMessage,
      remoteRef: onlineMessage.id,
    );

    // Linkage of SENDER & RECEIVER
    message.sender.target = senderContact;
    message.receiver.target = receiverContact;

    // link chat <-> message
    message.chat.target = chat;

    // ====================================   UI  ==================================

    // 1. update UI
    final indexAt = await chatController.addChatAndMessagesToList(
      chat,
      <Message>[message],
    );

    // 2. save encrypted message locally in parallel
    databaseController.messageBox.put(message);
    //
    //
    return (chat, indexAt, message.id);
  }

  /// Decrypt a locally stored message using the derived AES key
  static Future<String?> decryptLocalMessage(Message message) async {
    try {
      // 1. Read the derived AES from PIN
      final derivedAesKey = base64Decode(await KeysController.loadDerivedAES());

      // 2. Decrypt the encrypted AES-GCM key
      final aesKeyBytes = await KeysController.decryptWithAesGcm(
        aesKey: derivedAesKey,
        nonce: base64Decode(message.aesKeyNonce),
        mac: base64Decode(message.aesKeyMac),
        cipherText: base64Decode(message.aesKey),
      );

      // Original AES-GCM Key
      final aesKey = SecretKey(aesKeyBytes);

      // 3. Decrypt the message content
      final decryptedMessageBytes = await KeysController.decryptWithAesGcm(
        aesKey: await aesKey.extractBytes(),
        nonce: base64Decode(message.aesNonce),
        mac: base64Decode(message.aesMac),
        cipherText: base64Decode(message.content),
      );

      return utf8.decode(decryptedMessageBytes);
    } catch (e) {
      print("[-] Decrypt Error : $e");
      return "[Erreur] $e";
    }
  }
}
