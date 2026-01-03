import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefixIcon;

  const TextInput({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  OutlineInputBorder _outline(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: _outline(theme.colorScheme.primary, 2.0),
        enabledBorder: _outline(Colors.grey.shade400, 1.5),
        focusedBorder: _outline(theme.colorScheme.primary, 2.0),
        errorBorder: _outline(Colors.red.shade700, 2.0),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.all(16.0),
      ),
      validator: validator,
      keyboardType: TextInputType.text,
      enabled: enabled,
    );
  }
}
