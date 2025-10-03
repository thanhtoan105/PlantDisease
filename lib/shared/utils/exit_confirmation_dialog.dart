import 'package:flutter/material.dart';
import 'custom_dialogs.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final shouldExit = await CustomDialogs.showConfirmDialog(
    context: context,
    title: 'Exit App',
    message: 'Do you really want to exit the app?',
    confirmText: 'Exit',
    cancelText: 'Cancel',
  );
  return shouldExit ?? false;
}
