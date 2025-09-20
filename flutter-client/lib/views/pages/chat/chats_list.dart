import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/controllers/contact_controller.dart';
import 'package:unichat_flutter/controllers/message_controller.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/utils/app_data.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/views/pages/chat/chat_content.dart';
import 'package:unichat_flutter/views/widgets/text_field.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final currentUser = Get.find<User>(tag: 'currentUser');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //
    final chatController = Get.find<ChatController>();

    // =====================================

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppData.app_name.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lock_rounded, color: Colors.white, size: 28),
            onPressed: () => Get.toNamed('/pincode'),
          ),
          SizedBox(width: 20),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return showBottomSheet(context, _identifierController, _formKey);
        },
        mouseCursor: MouseCursor.defer,
        backgroundColor: Colors.teal,
        child: Icon(Iconsax.user_add, size: 30),
      ),

      body: Column(
        children: [
          SizedBox(height: 15),
          //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFieldWidget(
              label: 'Search',
              prefixIcon: Iconsax.search_favorite,
            ),
          ),

          //* /
          Expanded(
            child: Obx(() {
              //
              return GroupedListView<Chat, DateTime>(
                padding: const EdgeInsets.all(8),
                elements: chatController.chatsAndMessagesList.keys.toList(),
                groupBy: (chat) {
                  // last message time stamp
                  final lastMessageTimestamp =
                      (chatController.chatsAndMessagesList[chat]?.isNotEmpty ??
                              false)
                          ? chatController
                              .chatsAndMessagesList[chat]!
                              .last
                              .timestamp
                          : DateTime.now();

                  // order by YYYYMMDD
                  return DateTime(
                    lastMessageTimestamp.year,
                    lastMessageTimestamp.month,
                    lastMessageTimestamp.day,
                  );
                },
                groupHeaderBuilder: (Chat chat) => SizedBox(),
                itemBuilder: (context, Chat chat) {
                  // Get the other participant informations
                  final otherParticipant = chat.participants.firstWhere(
                    (participant) => participant.userId != currentUser.user_id,
                  );
                  //
                  final lastMessage =
                      chatController.chatsAndMessagesList[chat]?.last;
                  //
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          otherParticipant.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color:
                                isDark
                                    ? AppThemes.pageBackgroundLight
                                    : AppThemes.pageBackgroundDark,
                          ),
                        ),
                        subtitle: FutureBuilder<String?>(
                          future: MessageController.decryptLocalMessage(
                            lastMessage!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Loading...");
                            } else if (snapshot.hasError) {
                              return const Text("[Error 🔐]");
                            } else {
                              return Text(
                                snapshot.data ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                        ),

                        leading: CircleAvatar(
                          child: Text(
                            otherParticipant.name
                                .split(' ')
                                .map((part) => part[0])
                                .join("")
                                .substring(0, 2),
                          ), // initials of the name
                        ),

                        trailing: Column(
                          children: [
                            Text(
                              DateFormat.yMd().format(lastMessage.timestamp),
                            ),

                            SizedBox(height: 5),

                            CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.lightGreen,
                              /*
                              child: Text(
                                '1',
                                style: TextStyle(color: Colors.black),
                              ),
                              / / */
                            ),
                          ],
                        ),

                        mouseCursor: SystemMouseCursors.click,

                        // onTap
                        onTap: () {
                          // navigate to chat content
                          print("[+] >> Go to Chat content");
                          Get.to(ChatContentScreen(chat: chat));
                        },
                      ),

                      // * /
                      Divider(color: Colors.blueGrey.withValues(alpha: 0.1)),
                    ],
                  );
                },
              );
            }),
          ),

        ],
      ),
    );
  }
}

// Bottom sheet
void showBottomSheet(
  BuildContext context,
  TextEditingController textEditingController,
  GlobalKey<FormState> formKey,
) {
  final contactController = ContactController(); // Contact Controller
  final currentUser = Get.find<User>(tag: 'currentUser');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // This makes height shrink-wrap its children
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  "Add New Contact",
                  style: AppTextStyles.withColor(
                    AppTextStyles.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                SizedBox(height: 20),

                Obx(() {
                  if (contactController.isAddingContact.value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (textEditingController.text !=
                          contactController.contactData.value!.name) {
                        textEditingController.text =
                            contactController.contactData.value!.name;
                      }
                    });
                  }

                  return TextFieldWidget(
                    label:
                        contactController.isAddingContact.value
                            ? "Name (you can Edit)"
                            : "Email or Username",
                    prefixIcon: Iconsax.user,
                    controller: textEditingController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email or Username';
                      }
                      if (value.trim() == currentUser.username ||
                          value.trim() == currentUser.email) {
                        return "You can't add yourself as contact";
                      }
                      return null;
                    },
                  );
                }),

                SizedBox(height: 20),

                Obx(() {
                  return !contactController.isAddingContact.value
                      ? SizedBox()
                      : Column(
                        children: [
                          // Contact Email : non-editable
                          TextFieldWidget(
                            label: "Email",
                            prefixIcon: Icons.mail_outline,
                            readOnly: true,
                            initialValue:
                                contactController.contactData.value?.email ??
                                '',
                          ),

                          SizedBox(height: 20),

                          // Contact username : non-editable
                          TextFieldWidget(
                            label: "Username",
                            prefixIcon: Iconsax.user,
                            readOnly: true,
                            initialValue:
                                contactController.contactData.value?.username ??
                                '',
                          ),

                          const SizedBox(height: 24),
                        ],
                      );
                }),

                // Button or loading state depending on isLoading
                Obx(() {
                  if (contactController.isLoading.value) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // check if account exists
                          if (formKey.currentState?.validate() ?? false) {
                            // Validate the form before calling login
                            contactController.checkIfContactAccountExists(
                              textEditingController.text,
                            );
                          }
                        },
                        //_handleLogin, // Trigger login logic when pressed
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          contactController.isAddingContact.value
                              ? 'Save Contact'
                              : 'Verify Account Existence',
                          style: AppTextStyles.withColor(
                            AppTextStyles.buttomMedium,
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
  );
}
