import 'package:intl/intl.dart';

import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

class ReceiptService {
  Future<bool> _ensurePrinter() async {
    try {
      final ok = await SunmiPrinter.bindingPrinter();
      if (!ok!) {
        //   Constants.showSnack(context, "Impossible de se lier à l'imprimante Sunmi");
        return false;
      }
      try {
        await SunmiPrinter.initPrinter();
      } catch (_) {}
      return true;
    } catch (e) {
      // showSnack(context, 'Sunmi non disponible: $e');
      return false;
    }
  }

  Future<void> _testPrint() async {
    if (!await _ensurePrinter()) return;
    try {
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText(
        '*** TEST IMPRESSION ***',
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      await SunmiPrinter.printText('Modèle interne Sunmi', style: SunmiStyle());
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      //  showSnack(context, 'Test impression: $e');
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}
    }
  }

  Future<void> _printTicket() async {
    if (!await _ensurePrinter()) return;
    try {
      const int cols = 32;
      String line([String ch = '-']) => List.filled(cols, ch).join();
      String fit(String s, int len) {
        final t = s.replaceAll("\n", " ");
        if (t.runes.length <= len) return t.padRight(len);
        return String.fromCharCodes(t.runes.take(len));
      }

      String r(int v, int len) => v.toString().padLeft(len);

      await SunmiPrinter.startTransactionPrint(true);

      final now = DateTime.now();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      // >>> Entête: NOM PHARMACIE (nomComplet), pas le pharmacien
      final head = ' NOM PHARMACIE ';
      await SunmiPrinter.printText(
        head.toUpperCase(),
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      /* if (appSession.address.isNotEmpty) {
        await SunmiPrinter.printText(appSession.address, style: SunmiStyle());
      }*/
      /*  if (appSession.phone.isNotEmpty) {
        await SunmiPrinter.printText(
          'Tél: 000000',
          style: SunmiStyle(),
        );
      }*/

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText(line());
      await SunmiPrinter.printText(
        "Date: ${DateFormat("dd/MM/yyyy HH:mm").format(now)}",
      );
      await SunmiPrinter.printText(line());

      // En-têtes colonnes (32: 18 | 2 | 5 | 7) — nous affichons Qt sur la 1ère ligne avec *(n)
      await SunmiPrinter.printText(
        fit('Article', 18) + fit('Qt', 2) + fit('PU', 5) + fit('Total', 7),
        style: SunmiStyle(bold: true),
      );
    }catch(e) {
      // showSnack(context, 'Impression ticket: $e');
    }
  }
}
