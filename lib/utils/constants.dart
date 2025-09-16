import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Laborex';
  static const defaultTypeVenteId = '1'; // AU COMPTANT
  static const defaultNatureVenteId = '1';

  static void showSnack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  static String formatCFA(int v) => NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  ).format(v);

}
