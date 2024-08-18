import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

abstract class InvoiceService {
  static List<MapEntry<OnemSeviyesi, double>> calculateSegments(
      List<Invoice> invoices) {
    final Map<OnemSeviyesi, double> groupedSegments = {};

    for (var invoice in invoices) {
      final onemSeviyesi = invoice.onemSeviyesi;
      final amount = invoice.tutar;

      if (groupedSegments.containsKey(onemSeviyesi)) {
        groupedSegments[onemSeviyesi] = groupedSegments[onemSeviyesi]! + amount;
      } else {
        groupedSegments[onemSeviyesi] = amount;
      }
    }

    return groupedSegments.entries.toList();
  }

  static Color getImportanceColor(OnemSeviyesi onemSeviyesi) {
    switch (onemSeviyesi) {
      case OnemSeviyesi.yuksek:
        return Color.fromARGB(255, 165, 38, 9);
      case OnemSeviyesi.orta:
        return Color(0xFFFF7E00);
      case OnemSeviyesi.dusuk:
        return Color(0xFFFFF103);
      default:
        return Colors.grey;
    }
  }
}
