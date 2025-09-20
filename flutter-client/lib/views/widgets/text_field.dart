import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unichat_flutter/utils/app_textstyles.dart';

class TextFieldWidget extends StatefulWidget {
  final String label;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final String initialValue;

  // Constructeur avec les paramètres nécessaires
  const TextFieldWidget({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.initialValue = ''
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 0.0,
      ), // Un peu de padding entre chaque champ
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.isPassword && _obscureText,
        validator: widget.validator,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        initialValue: widget.controller == null ? widget.initialValue : null,
        enabled: widget.controller != null,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTextStyles.withColor(
            AppTextStyles.bodyMedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(_obscureText ? Iconsax.eye_slash : Iconsax.eye),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[300]! : Colors.grey[700]!,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
        style: AppTextStyles.withColor(
          AppTextStyles.bodySmall,
          Theme.of(context).textTheme.bodyLarge!.color!,
        ),
      ),
    );
  }
}
