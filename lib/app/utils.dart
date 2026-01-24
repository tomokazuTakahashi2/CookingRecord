import 'package:flutter/material.dart';

// Global key for accessing ScaffoldMessenger from anywhere
final messengerKey = GlobalKey<ScaffoldMessengerState>();

// Global function to show SnackBar from anywhere in the app
void showSnack(String text, {Color? color, int seconds = 2}) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: Duration(seconds: seconds),
      ),
    );
}
