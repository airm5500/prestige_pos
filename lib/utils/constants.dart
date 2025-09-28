import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Laborex';
  static const String finalyseLabel = 'Finaliser';
  static const String finalysePreventeLabel = 'Finaliser';
  static const String terminerLabel = 'Terminer';
  static const String saisirQtyLabel = 'Saissir la quantité';
  static const String qunatityLabel = 'Quantité';
  static const String btnAnnuler = 'Annuler';
  static const String btnValider = 'Valider';
  static const String totalVenteLabel = 'Total vente';
  static const String printReciptTitle = 'Imprimer le reçu?';
  static const String printReciptMessage = 'Voulez-vous imprimer un reçu?';

  static const String btnAdd = 'Ajouter';
  static const String btnNon = 'Non';
  static const String btnPrint = 'Imprimer';
  static const String totalPayer = 'Total à payer';
  static const String newBtnLabel = 'Nouvelle vente';
  static const String remisePlaceHolder = 'Appliquer une remise';
  static const String remise = 'Remise';
  static const String canUpdatePrice = 'canUpdatePrice';
  static const String progressStatut = 'PROGRESS';
  static const String closedStatut = 'CLOSED';
  static const String venteTitle = 'Nouvelle vente';
  static const String venteTab = 'Ventes';
  static const String preventeTab = 'Pré-ventes';
  static const String showStock = 'showStock';
  static const String homeBtnVenteLabel = 'Pré/Vente';
  static const String homeBtnProductEvalLabel = 'Évaluation vente article';
  static const String homeBtnProductSearchLabel = 'Recherche article';
  static const String title = 'Prestige Vente';
  static const String preventeAlertTitle = 'Imprimer le ticket de pré-vente?';
  static const String preventeReceiptLabel = 'Voulez-vous imprimer le ticket pour cette pré-vente?';

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
