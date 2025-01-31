import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

class InventoryUtils {
  // Renkleri tanımlayan statik harita
  static final Map<String, Color> colorMap = {
    'Altın (TL/GR)': Colors.yellow,
    'Cumhuriyet Altını': Colors.yellow,
    'Yarım Altın': Colors.yellow,
    'Çeyrek Altın': Colors.yellow,
    'ABD Doları': Colors.green,
    'Euro': Colors.blue,
    'İngiliz Sterlini': Colors.purple,
    'TL': Colors.red,
  };

  // Fiyat bulma fonksiyonu
  static double findPrice(String type, List<WealthPrice> goldPrices,
      List<WealthPrice> currencyPrices) {
    for (var gold in goldPrices) {
      if (gold.title == type) {
        return double.parse(gold.buyingPrice.replaceAll(',', '.').trim());
      }
    }
    for (var currency in currencyPrices) {
      if (currency.title == type) {
        return double.parse(currency.buyingPrice.replaceAll(',', '.').trim());
      }
    }
    return 0.0;
  }

  // Segment hesaplama fonksiyonu
  static List<double> calculateSegments(List<SavedWealths> savedWealths,
      List<WealthPrice> goldPrices, List<WealthPrice> currencyPrices) {
    double totalPrice = 0;
    List<double> segments = [];

    for (var wealth in savedWealths) {
      double price = findPrice(wealth.type, goldPrices, currencyPrices);
      double value = price * wealth.amount;
      totalPrice += value;
      segments.add(value);
    }

    if (totalPrice > 0) {
      segments =
          segments.map((segment) => (segment / totalPrice) * 360).toList();
    }

    return segments;
  }
}
