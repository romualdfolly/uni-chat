import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/message.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/views/pages/chat/chat_message.dart';
import 'package:unichat_flutter/views/widgets/chat_input_widget.dart';

class ChatContentScreen extends StatefulWidget {
  final Chat chat;

  const ChatContentScreen({super.key, required this.chat});

  @override
  State<ChatContentScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatContentScreen> {
  //
  final currentUser = Get.find<User>(tag: 'currentUser');

  @override
  Widget build(BuildContext context) {
    //
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Get the other contact
    final contact =
        widget.chat.participants
            .where((p) => p.userId != currentUser.user_id)
            .toList()
            .first;

    // set current contact
    Get.put<Contact>(contact, tag: 'conversationPeer');


    //
    final chatController = Get.find<ChatController>();

    return Scaffold(
      backgroundColor:
          isDark ? AppThemes.pageBackgroundDark : AppThemes.pageBackgroundLight,

      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Get.toNamed('/chats');
              },
              icon: Icon(
                Iconsax.arrow_left_2,
                color:
                    isDark
                        ? AppThemes.pageBackgroundLight
                        : AppThemes.pageBackgroundDark,
              ),
            ),

            SizedBox(width: 1),

            // profil photo
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.account_circle_outlined,
                size: 30,
                color:
                    isDark
                        ? AppThemes.pageBackgroundLight
                        : AppThemes.pageBackgroundDark,
              ),
            ),
            SizedBox(width: 5),
            Text(
              contact.name,
              style: TextStyle(
                color:
                    isDark
                        ? AppThemes.pageBackgroundLight
                        : AppThemes.pageBackgroundDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        backgroundColor:
            isDark
                ? AppThemes.pageBackgroundDark
                : AppThemes.pageBackgroundLight,

        actions: [
          IconButton(
            icon: Icon(
              Iconsax.search_status,
              color:
                  isDark
                      ? AppThemes.pageBackgroundLight
                      : AppThemes.pageBackgroundDark,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 20),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              //
              final messagesRxList =
                  chatController.chatsAndMessagesList[widget.chat];

              if (messagesRxList == null) {
                return Center(child: Text("No messages"));
              }
              //
              final messages = messagesRxList.toList();

              //
              return GroupedListView<Message, DateTime>(
                elements: messages,
                groupBy:
                    (message) => DateTime(
                      message.timestamp.year,
                      message.timestamp.month,
                      message.timestamp.day,
                    ),
                padding: const EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                itemComparator: (a, b) => a.timestamp.compareTo(b.timestamp),
                floatingHeader: true,

                // header
                groupHeaderBuilder:
                    (Message message) => SizedBox(
                      height: 40,
                      child: Center(
                        child: Card(
                          color:
                              isDark
                                  ? AppThemes.pageBackgroundDark
                                  : AppThemes.pageBackgroundLight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              DateFormat.yMMMd().format(message.timestamp),
                              style: TextStyle(
                                color:
                                    isDark
                                        ? AppThemes.pageBackgroundLight
                                        : AppThemes.pageBackgroundDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                // messages
                itemBuilder:
                    (context, Message message) => ChatMessage(message: message),
              );
            }),
          ),

          // to send message
          ChatInputWidget(),
        ],
      ),
    );
  }
}
