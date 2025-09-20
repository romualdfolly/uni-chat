import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/utils/app_themes.dart';

class SendMessageTextFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final ScrollController scrollController;

  const SendMessageTextFieldWidget({
    super.key,
    required this.textEditingController,
    required this.scrollController,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SendMessageTextFieldWidgetState createState() =>
      _SendMessageTextFieldWidgetState();
}

class _SendMessageTextFieldWidgetState
    extends State<SendMessageTextFieldWidget> {
  bool _emojiOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Emoji button
        IconButton(
          onPressed: () {
            //
          },
          icon: Icon(
            _emojiOpen ? Iconsax.keyboard : Iconsax.emoji_happy,
            color: (isDark
                    ? AppThemes.cardBackgroundLight
                    : AppThemes.cardBackgroundDark)
                .withValues(alpha: 0.7),
          ),
        ),

        // TextField
        Expanded(
          child: Scrollbar(
            controller: widget.scrollController,
            radius: const Radius.circular(5),
            child: Padding(
              padding: const EdgeInsets.only(right: 0.5),
              child: TextField(
                controller: widget.textEditingController,
                minLines: 1,
                maxLines: 6,
                style: TextStyle(
                  color: isDark ? AppThemes.cardBackgroundLight : AppThemes.cardBackgroundDark,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(),
                  border: InputBorder.none,
                  hintText: 'Message',
                  hintStyle: TextStyle(
                    color: (isDark
                            ? AppThemes.cardBackgroundLight
                            : AppThemes.cardBackgroundDark)
                        .withValues(alpha: 0.4),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _emojiOpen = false;
                  });
                },
              ),
            ),
          ),
        ),

        // Attachment button
        IconButton(
          onPressed: () {
            Fluttertoast.showToast(msg: 'Show Picker');
          },
          icon: Icon(
            Iconsax.paperclip_2,
            color: (isDark
                    ? AppThemes.cardBackgroundLight
                    : AppThemes.cardBackgroundDark)
                .withValues(alpha: 0.7),
          ),
        ),

        // Camera button
        IconButton(
          onPressed: () {
            Fluttertoast.showToast(msg: 'Camera');
          },
          icon: Icon(
            Iconsax.camera,
            color: (isDark
                    ? AppThemes.cardBackgroundLight
                    : AppThemes.cardBackgroundDark)
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
