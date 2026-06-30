import 'package:flutter/material.dart';

void showAppSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: const Color(0xFF22C55E)),
  );
}

void showAppErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
  );
}
