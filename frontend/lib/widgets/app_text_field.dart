import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.enabled,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final int? minLines;
  final int? maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        alignLabelWithHint: (maxLines ?? 1) > 1,
      ),
    );
  }
}
