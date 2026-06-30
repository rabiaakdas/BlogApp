import 'package:flutter/material.dart';

import 'app_snackbar.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  showAppSuccessSnackBar(context, message);
}

void showErrorSnackBar(BuildContext context, String message) {
  showAppErrorSnackBar(context, message);
}
