import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Laborex';
  static const String finalyseLabel = 'Finaliser la vente';
  static const String terminerLabel = 'Terminer la vente';
  static const String saisirQtyLabel = 'Saissir la quantité';
  static const String qunatityLabel = 'Quantité';
  static const String BtnAnnuler = 'Annuler';
  static const String BtnValider = 'Valider';
  static const String BtnAdd = 'Ajouter';


  static void showSnack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  static String formatCFA(int v) => NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  ).format(v);

  static String formatNumber(num? value) {
    if (value == null) {
      return '';
    }
    return NumberFormat(
      '#,##0',
      'fr_FR',
    ).format(value).replaceAll(',', '\u00A0');
  }

  static String format(int v) => NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  ).format(v);

}
