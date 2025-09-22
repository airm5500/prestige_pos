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
        Constants.showSnack(context, "Impossible de se lier à l'imprimante ");
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
    ModeReglement modeReglement, {
    int copies = 2,
  }) async {
    if (!await _ensurePrinter(context)) return false;

    final officineResponse = await _officineService.find();
    final officine = officineResponse.data;
    if (officine == null) {
      Constants.showSnack(
        context,
        "Impossible de récupérer les infos de l'officine",
      );
      return false;
    }

    try {
      for (int i = 0; i < copies; i++) {
        await SunmiPrinter.startTransactionPrint(true);

        const int cols = 32;
        String line([String ch = '-']) => List.filled(cols, ch).join();
        String fit(String s, int len) {
          final t = s.replaceAll("\n", " ");
          if (t.runes.length <= len) return t.padRight(len);
          return String.fromCharCodes(t.runes.take(len));
        }

        String r(int v, int len) => Constants.formatNumber(v).padLeft(len);
        String printText(int v) => Constants.formatNumber(v);

        // --- HEADER ---
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        final head = officine.name;
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
          final tag = ' *(${item.quantity})';
          final maxName = cols - tag.length;
          final name = fit(item.produitName, maxName);
          await SunmiPrinter.printText(
            name + tag,
            style: SunmiStyle(fontSize: SunmiFontSize.SM),
          );
          final left = ' ' * 20;
          final pu = r(item.unitPrice, 5);
          final tot = r(item.amount, 7);
          await SunmiPrinter.printText(left + pu + tot);
        }
        await SunmiPrinter.printText(line());

        // --- TOTALS ---
        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        await SunmiPrinter.printText('Total: ${printText(currentSale.amount)}');
        if ((currentSale.discount ?? 0) > 0) {
          await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
          await SunmiPrinter.printText(
            'Remise: ${printText(currentSale.discount!)}',
          );
        }
        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        await SunmiPrinter.printText(
          'NET A PAYER: ${printText(currentSale.montantNet ?? currentSale.amount)}',
          style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
        );
        await SunmiPrinter.printText(line());

        await SunmiPrinter.printText(
          'REGLEMENT: ${fit(modeReglement.libelle, 10)}',
          style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
        );

        await SunmiPrinter.printText(line());

        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        if (currentSale.transactionNumber != null) {
          await SunmiPrinter.printQRCode(currentSale.transactionNumber!);
          await SunmiPrinter.printText(currentSale.transactionNumber!);
        }

        await SunmiPrinter.lineWrap(3);
        try {
          await SunmiPrinter.cut();
        } catch (_) {}

        await SunmiPrinter.exitTransactionPrint(true);
      }
    } catch (e) {
      Constants.showSnack(context, 'Impression ticket: $e');
      return false;
    }

    return true;
  }
}
