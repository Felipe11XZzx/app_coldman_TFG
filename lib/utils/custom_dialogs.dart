import 'package:flutter/material.dart';


class CustomDialogs {
  static Future<void> showLoadingSpinner(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = "Confirmar",
    String cancelText = "Cancelar", required Text style,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message,
      {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
