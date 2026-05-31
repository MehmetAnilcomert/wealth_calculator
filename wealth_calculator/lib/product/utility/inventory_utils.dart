import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

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

  // Güvenli fiyat ayrıştırma yardımcısı (hem Türkçe hem de standart float formatları için)
  static double _parsePrice(String price) {
    price = price.trim();
    if (price.isEmpty) return 0.0;
    if (price.contains(',')) {
      return double.tryParse(price.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    }
    return double.tryParse(price) ?? 0.0;
  }

  // Fiyat bulma fonksiyonu
  static double findPrice(String type, List<WealthPrice> goldPrices,
      List<WealthPrice> currencyPrices) {
    for (var gold in goldPrices) {
      if (gold.title == type) {
        return _parsePrice(gold.buyingPrice);
      }
    }
    for (var currency in currencyPrices) {
      if (currency.title == type) {
        return _parsePrice(currency.buyingPrice);
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
