import 'package:wealth_calculator/modals/WealthDataModal.dart';

class Equity extends WealthPrice {
  final String currentPrice;
  final String volume;
  final String changeAmount;

  Equity({
    required this.currentPrice,
    required this.volume,
    required this.changeAmount,
    required String title,
    required String buyingPrice,
    required String sellingPrice,
    required String change,
    required String time,
    required PriceType type,
  }) : super(
          title: title,
          buyingPrice: buyingPrice,
          sellingPrice: sellingPrice,
          change: change,
          time: time,
          type: type,
        );

  // Convert Equity to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'change': change,
      'time': time,
      'type': type.index, // Converts PriceType enum to its index
      'currentPrice': currentPrice,
      'volume': volume,
      'changeAmount': changeAmount, // Added property
    };
  }

  // Create an Equity object from a map
  factory Equity.fromMap(Map<String, dynamic> map) {
    return Equity(
      title: map['title'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      change: map['change'],
      time: map['time'],
      type: PriceType
          .values[map['type']], // Converts index back to PriceType enum
      currentPrice: map['currentPrice'],
      volume: map['volume'],
      changeAmount: map['changeAmount'], // Added property
    );
  }
}
