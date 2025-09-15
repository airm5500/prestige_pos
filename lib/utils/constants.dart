import 'package:flutter/material.dart';

class Constants {
  static final  String appName = 'Laborex';
 static void showSnack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
