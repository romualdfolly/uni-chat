import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/views/pages/chat/chats_list.dart';
import 'package:unichat_flutter/views/pages/profile/user_profile.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<ChatScreen> {
  int selectedIndex = 0;
  final List pages = [const ChatsListScreen(), const UserProfileSceen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: (isDark
                ? AppThemes.pageBackgroundLight
                : AppThemes.pageBackgroundDark)
            .withValues(alpha: 0.7),
        selectedItemColor:
            isDark
                ? AppThemes.pageBackgroundLight
                : AppThemes.pageBackgroundDark,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        elevation: 0,
        backgroundColor: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.9),
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.message), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

