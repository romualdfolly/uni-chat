import 'package:flutter/material.dart';
import 'package:unichat_flutter/controllers/message_controller.dart';

class SendMessageButtonWidget extends StatefulWidget {
  final TextEditingController controller;

  const SendMessageButtonWidget({super.key, required this.controller});

  @override
  // ignore: library_private_types_in_public_api
  _SendMessageButtonWidgetState createState() =>
      _SendMessageButtonWidgetState();
}

class _SendMessageButtonWidgetState extends State<SendMessageButtonWidget> {
  @override
  void initState() {
    super.initState();
    // Écouter les changements dans le texte du controller
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      // Mettre à jour l'état lorsque le texte change
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged); // Nettoyage
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    final messageController = MessageController();
    //
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
        child: IconButton(
          onPressed: () {
            if (widget.controller.text.isNotEmpty) {
              messageController.sendMessage(message: widget.controller.text);
              // clear text in the textfield
              widget.controller.text = "";
            }
          },
          icon: Icon(
            widget.controller.text.isEmpty
                ? Icons.camera_alt_outlined
                : Icons.send_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
