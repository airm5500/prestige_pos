import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/service/officine_service.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class ReceiptService {
  final OfficineService _officineService;
  final SunmiPrinterPlus _printer = SunmiPrinterPlus();

  ReceiptService({required OfficineService officineService})
    : _officineService = officineService;

  String mapPrinterStatus(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.READY:
        return "Imprimante prête";
      case PrinterStatus.ERR_PAPER_OUT:
        return "Pas de papier";
      case PrinterStatus.ERR_PAPER_JAM:
        return "Bourrage papier";
      case PrinterStatus.ERR_PRINTER_HOT:
      case PrinterStatus.ERR_MOTOR_HOT:
        return "Imprimante en surchauffe";
      case PrinterStatus.ERR_COVER:
        return "Couvercle ouvert";
      case PrinterStatus.OFFLINE:
        return "Imprimante hors-ligne";
      case PrinterStatus.COMM:
        return "Problème de communication";
      default:
        return "Statut imprimante inconnu";
    }
  }

  Future<PrinterStatus> _checkPrinterStatus() async {
    try {
      final status = await _printer.getStatus();

      if (status is String) {
        return PrinterStatus.values.firstWhere(
          (e) => e.toString() == 'PrinterStatus.$status',
          orElse: () => PrinterStatus.UNKNOWN,
        );
      }

      return PrinterStatus.UNKNOWN;
    } catch (e) {
      try {
        final rebind = await _printer.rebindPrinter();
        if (rebind == true) {
          final statusRetry = await _printer.getStatus();
          return PrinterStatus.values.firstWhere(
            (e) => e.toString() == 'PrinterStatus.$statusRetry',
            orElse: () => PrinterStatus.UNKNOWN,
          );
        }
      } catch (_) {}
      return PrinterStatus.UNKNOWN;
    }
  }

  Future<bool> printTicket(
    BuildContext context,
    CreateResponse currentSale,
    ModeReglement modeReglement,
  ) async {
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
      // Vérification du statut
      final status = await _checkPrinterStatus();
      if (status != PrinterStatus.READY) {
        Constants.showSnack(
          context,
          "Imprimante : ${mapPrinterStatus(status)}",
        );
        return false;
      }

      const int cols = 32;
      String line([String ch = '-']) => List.filled(cols, ch).join();
      String fit(String s, int len) {
        final t = s.replaceAll("\n", " ");
        if (t.runes.length <= len) return t.padRight(len);
        return String.fromCharCodes(t.runes.take(len));
      }

      String r(int v, int len) => Constants.formatNumber(v).padLeft(len);

      // --- HEADER ---
      final head = officine.name;
      await _printer.printText(
        text: head.toUpperCase(),
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
          fontSize: 24,
        ),
      );
      if ((officine.address ?? '').isNotEmpty) {
        await _printer.printText(
          text: officine.address!,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
      }
      if ((officine.phone ?? '').isNotEmpty) {
        await _printer.printText(
          text: 'Tél: ${officine.phone!}',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        );
      }

      await _printer.printText(text: line());
      await _printer.printText(
        text: "Date: ${DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now())}",
      );
      if ((currentSale.transactionNumber ?? '').isNotEmpty) {
        await _printer.printText(
          text: "Ticket: ${currentSale.transactionNumber}",
        );
      }
      await _printer.printText(text: line());

      // --- ITEMS ---
      await _printer.printText(
        text:
            fit('Article', 18) + fit('Qt', 2) + fit('PU', 5) + fit('Total', 7),
        style: SunmiTextStyle(bold: true),
      );
      await _printer.printText(text: line('.'));

      for (final item in currentSale.items.content) {
        final name = fit(item.produitName, 18);
        final qty = r(item.quantity, 2);
        final pu = r(item.unitPrice, 5);
        final total = r(item.amount, 7);
        await _printer.printText(text: name + qty + pu + total);
      }
      await _printer.printText(text: line());

      // --- TOTALS ---
      await _printer.printText(
        text: 'Total: ${r(currentSale.amount, 10)}',
        style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
      );
      if ((currentSale.discount ?? 0) > 0) {
        await _printer.printText(
          text: 'Remise: ${r(currentSale.discount!, 10)}',
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        );
      }
      await _printer.printText(
        text:
            'NET A PAYER: ${r(currentSale.montantNet ?? currentSale.amount, 10)}',
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.RIGHT,
          fontSize: 24,
        ),
      );
      await _printer.printText(text: line());

      await _printer.printText(
        text: 'REGLEMENT: ${fit(modeReglement.libelle, 10)}',
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
          fontSize: 24,
        ),
      );
      await _printer.printText(text: line());

      // --- FOOTER ---
      await _printer.printText(
        text: '${officine.note ?? ''} Merci de votre visite',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
      );
      await _printer.lineWrap(times: 3);
      await _printer.cutPaper();
    } catch (e) {
      Constants.showSnack(context, 'Impression ticket: $e');
      return false;
    }

    return true;
  }
}
