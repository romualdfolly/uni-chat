import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/utils/app_themes.dart';
import 'package:unichat_flutter/views/widgets/send_message_form/send_text_field_widget.dart';
import 'package:unichat_flutter/views/widgets/send_message_form/send_message_button.dart';

class ChatInputWidget extends StatefulWidget {
  
  const ChatInputWidget({super.key});

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  //
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  //
  @override
  Widget build(BuildContext context) {
    //
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
      child: Column(
        children: [
          Stack(
            children: [
              // main row
              Row(
                children: [
                  //
                  Expanded(
                    child: Card(
                      color:
                          isDark
                              ? AppThemes.cardBackgroundDark
                              : AppThemes.cardBackgroundLight,
                      margin: const EdgeInsets.only(right: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        children: [
                          // Front Widget
                          SendMessageTextFieldWidget(
                            textEditingController: _textEditingController,
                            scrollController: _scrollController
                          ),
                        ],
                      ),
                    ),
                  ),
                  //
                  IconButton(
                    onPressed: null,
                    icon: Icon(Iconsax.send, color: Colors.transparent),
                  ),
                ],
              ),
              //
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      const Spacer(),
                      SendMessageButtonWidget(
                        controller: _textEditingController,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5),
        ],
      ),
    );
  }
}
