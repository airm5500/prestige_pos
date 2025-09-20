import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/service/officine_service.dart';
import 'package:prestige_pos/utils/constants.dart';

import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

class ReceiptService {
  final OfficineService _officineService;

  ReceiptService({required OfficineService officineService})
    : _officineService = officineService;

  Future<bool> _ensurePrinter(BuildContext context) async {
    try {
      final ok = await SunmiPrinter.bindingPrinter();
      if (ok != true) {
        Constants.showSnack(
          context,
          "Impossible de se lier à l'imprimante ",
        );
        return false;
      }
      try {
        await SunmiPrinter.initPrinter();
      } catch (e) {
        Constants.showSnack(context, "Erreur d'initialisation de l'imprimante");
        return true;
      }
      return true;
    } catch (e) {
      Constants.showSnack(context, 'Sunmi non disponible: $e');
      return false;
    }
  }

  Future<bool> printTicket(
    BuildContext context,
    CreateResponse currentSale,
    ModeReglement modeReglement,
  ) async {
    if (!await _ensurePrinter(context)) return false;

    final officineResponse = await _officineService.find();
    final officine = officineResponse.data;
    if (officine == null) {
      Constants.showSnack(
        context,
        "Impossible de récupérer les infos de l'officine",
      );
      await SunmiPrinter.exitTransactionPrint(true);
      return false;
    }
    try {
      await SunmiPrinter.startTransactionPrint(true);

      const int cols = 32;
      String line([String ch = '-']) => List.filled(cols, ch).join();
      String fit(String s, int len) {
        final t = s.replaceAll("\n", " ");
        if (t.runes.length <= len) return t.padRight(len);
        return String.fromCharCodes(t.runes.take(len));
      }

      String r(int v, int len) => Constants.formatNumber(v).padLeft(len);

      // --- HEADER ---
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      final head = officine.name ;
      await SunmiPrinter.printText(
        head.toUpperCase(),
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      if ((officine.address ?? '').isNotEmpty) {
        await SunmiPrinter.printText(officine.address!, style: SunmiStyle());
      }
      if ((officine.phone ?? '').isNotEmpty) {
        await SunmiPrinter.printText(
          'Tél: ${officine.phone!}',
          style: SunmiStyle(),
        );
      }

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText(line());
      await SunmiPrinter.printText(
        "Date: ${DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now())}",
      );
      if ((currentSale.transactionNumber ?? '').isNotEmpty) {
        await SunmiPrinter.printText(
          "Ticket: ${currentSale.transactionNumber}",
        );
      }
      await SunmiPrinter.printText(line());

      // --- ITEMS ---
      await SunmiPrinter.printText(
        fit('Article', 18) + fit('Qt', 2) + fit('PU', 5) + fit('Total', 7),
        style: SunmiStyle(bold: true),
      );
      await SunmiPrinter.printText(line('.'));

      for (final item in currentSale.items.content) {
        final name = fit(item.produitName, 18);
        final qty = r(item.quantity, 2);
        final pu = r(item.unitPrice, 5);
        final total = r(item.amount, 7);
        await SunmiPrinter.printText(name + qty + pu + total);
      }
      await SunmiPrinter.printText(line());

      // --- TOTALS ---
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText('Total: ${r(currentSale.amount, 10)}');
      if ((currentSale.discount ?? 0) > 0) {
        await SunmiPrinter.printText('Remise: ${r(currentSale.discount!, 10)}');
      }
      await SunmiPrinter.printText(
        'NET A PAYER: ${r(currentSale.montantNet ?? currentSale.amount, 10)}',
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      await SunmiPrinter.printText(line());

      await SunmiPrinter.printText(
        'REGLEMENT: ${fit(modeReglement.libelle, 10)}',
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );

      await SunmiPrinter.printText(line());

      // --- FOOTER ---
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText(
        '${officine.note ?? ''} Merci de votre visite',
        style: SunmiStyle(),
      );
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      Constants.showSnack(context, 'Impression ticket: $e');
      return false;
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {

      }
    }
    return true;
  }
}
