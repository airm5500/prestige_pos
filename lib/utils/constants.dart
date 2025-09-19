import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Laborex';
  static const String finalyseLabel = 'Finaliser';
  static const String terminerLabel = 'Terminer';
  static const String saisirQtyLabel = 'Saissir la quantité';
  static const String qunatityLabel = 'Quantité';
  static const String btnAnnuler = 'Annuler';
  static const String btnValider = 'Valider';
  static const String btnAdd = 'Ajouter';
  static const String totalPayer = 'Total à payer';
  static const String mettreEnAttente = 'Mettre en attente';
  static const String remisePlaceHolder = 'Appliquer une remise';


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
