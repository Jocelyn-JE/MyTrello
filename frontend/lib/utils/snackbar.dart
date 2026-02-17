import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {Color? color}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    ),
  );
}

void showSnackBarError(BuildContext context, String message) {
  showSnackBar(context, message, color: Colors.red);
}

void showSnackBarSuccess(BuildContext context, String message) {
  showSnackBar(context, message, color: Colors.green);
}

void showSnackBarWarning(BuildContext context, String message) {
  showSnackBar(context, message, color: Colors.orange);
}
