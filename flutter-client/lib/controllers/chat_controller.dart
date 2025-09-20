import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/message_controller.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/message.dart';
import 'package:unichat_flutter/objectbox.g.dart';

class ChatController extends GetxController {
  // will contain chats and linked messages
  var chatsAndMessagesList = <Chat, RxList<Message>>{}.obs;
  RxList<int> remoteRefsList = <int>[].obs;
  final databaseController = Get.find<DatabaseController>();
  final MessageController messageController = MessageController();

  Future<void> loadLocalChatsAndMessages() async {
    print("[+] >>> Loading local chats messages");
    // 1 - we make sure variable is empty
    chatsAndMessagesList.clear();
    remoteRefsList.clear();

    // 2 - load all chats
    final List<Chat> localChats = databaseController.chatBox.getAll();

    // 3 - load messages for each chat
    for (final chat in localChats) {
      final messages = databaseController.getMessagesByChat(chat.id);
      await addChatAndMessagesToList(chat, messages);
    }
    print("[+] >>> Loading Finished");

    // messages from server
    messageController.fetchAndSendUnsentMessagesIfNeeded();
  }

  Future<int> addChatAndMessagesToList(
    Chat chat,
    List<Message> messages,
  ) async {
    // check if chat is in list
    if (chatsAndMessagesList.keys.contains(chat)) {
      chatsAndMessagesList[chat]!.addAll(messages);
    } else {
      // create index and add
      chatsAndMessagesList[chat] = RxList<Message>.of(messages);
    }

    // add of refs
    remoteRefsList.addAll(messages.map((message) => message.remoteRef));

    // refresh
    chatsAndMessagesList.refresh();

    final int indexAt = chatsAndMessagesList[chat]!.length;

    if (messages.isEmpty) return -2;
    if (messages.isNotEmpty && messages.length == 1) return indexAt;
    return -1;
  }

  /// checks if chat exists
  Chat? findExistingChat(List<Contact> chatContactsList) {
    try {
      return chatsAndMessagesList.keys.firstWhere(
        (chat) => chat.containsSameParticipants(chatContactsList),
      );
    } catch (_) {
      return null;
    }
  }

  ///
  Future<Chat?> checkOrCreateChatWith(
    Contact otherContact, {
    bool isGroup = false,
  }) async {
    final chatBox = Get.find<DatabaseController>().chatBox;
    final meAsContact = Get.find<Contact>(tag: 'meAsContact');

    // check if otherContact is Me
    if (otherContact.userId == meAsContact.userId) {
      Get.snackbar("Error", "You cannot chat with yourself.");
      return null;
    }

    // simple chats : not Groups
    final chats = chatBox.query(Chat_.isGroup.equals(isGroup)).build().find();

    var chat = chats.firstWhereOrNull((chat) {
      final parts = chat.participants;
      return (!isGroup && parts.length == 2) &&
          parts.any((c) => c.userId == meAsContact.userId) &&
          parts.any((c) => c.userId == otherContact.userId);
    });

    if (chat == null) {
      final newChat = Chat(isGroup: isGroup)
        ..participants.addAll([meAsContact, otherContact]);

      final chatId = chatBox.put(newChat);
      chat = newChat..id = chatId;
    }

    // return chat
    return chat;
  }

  //

  Future<void> addMessage({required Message message}) async {
    //
  }
}
