import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class FlushbarService {
  FlushbarService._();

  static final FlushbarService instance = FlushbarService._();

  void showFlushbar(BuildContext context, String title, String message, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        icon: Icon(
          color == Colors.green ? Icons.check : Icons.error,
          color: Colors.white,
        ),
        flushbarPosition: FlushbarPosition.TOP,
        title: title,
        message: message,
      ).show(context);
    });
  }
}
