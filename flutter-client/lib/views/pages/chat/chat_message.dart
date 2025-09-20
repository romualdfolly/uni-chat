import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:unichat_flutter/controllers/message_controller.dart';
import 'package:unichat_flutter/models/message.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';
import 'package:unichat_flutter/utils/app_themes.dart';

class ChatMessage extends StatelessWidget {
  final Message message;

  const ChatMessage({super.key, required this.message});

  Future<String?> _decryptMessage() async {
    return await MessageController.decryptLocalMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Get.find<User>(tag: 'currentUser');
    final isCurrentUser = message.sender.target!.userId == currentUser.user_id;
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,

      // Message will take at most 75% of the screen-width
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Card(
          elevation: 8,
          color:
              isCurrentUser
                  ? Theme.of(context).primaryColor
                  : (isDark
                      ? AppThemes.cardBackgroundDark
                      : AppThemes.cardBackgroundLight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FutureBuilder<String?>(
                  future: _decryptMessage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "Chargement...",
                        style: AppTextStyles.bodySmall,
                      );
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return Text(
                        "[Erreur décryptage]",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.red,
                        ),
                      );
                    } else {
                      final decryptedContent = snapshot.data!;
                      return Text(
                        decryptedContent,
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodySmall,
                          isCurrentUser
                              ? Colors.white
                              : (isDark
                                  ? AppThemes.pageBackgroundLight
                                  : AppThemes.pageBackgroundDark),
                        ),
                      );
                    }
                  },
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: DateFormat.Hm().format(message.timestamp),
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyXSmall,
                          isCurrentUser
                              ? Colors.white
                              : (isDark
                                  ? AppThemes.pageBackgroundLight
                                  : AppThemes.pageBackgroundDark),
                        ),
                      ),

                      // We show the ICON only for outgoing messages
                      if (isCurrentUser)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Icon(
                              message.isSent ? Icons.check : Icons.access_time,
                              size: AppTextStyles.bodyXSmall.fontSize,
                              color:
                                  message.content.isEmpty
                                      ? Colors.white
                                      : (isDark
                                          ? AppThemes.pageBackgroundLight
                                          : AppThemes.pageBackgroundDark),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
