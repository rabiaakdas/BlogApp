import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        alignLabelWithHint: (maxLines ?? 1) > 1,
      ),
      validator: validator,
    );
  }
}
