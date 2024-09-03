enum PriceType { gold, currency, equity }

class WealthPrice {
  final String title;
  final String buyingPrice;
  final String sellingPrice;
  final String change;
  final String time;
  final PriceType type;
  final String? currentPrice; // Nullable field
  final String? volume; // Nullable field
  final String? changeAmount; // Nullable field

  WealthPrice({
    required this.title,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.change,
    required this.time,
    required this.type,
    this.currentPrice,
    this.volume,
    this.changeAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'change': change,
      'time': time,
      'type': type.index, // Enum'u index olarak kaydediyoruz
      'currentPrice': currentPrice,
      'volume': volume,
      'changeAmount': changeAmount,
    };
  }

  // Optional: fromMap methodu
  static WealthPrice fromMap(Map<String, dynamic> map) {
    return WealthPrice(
      title: map['title'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      change: map['change'],
      time: map['time'],
      type: PriceType.values[map['type']],
      currentPrice: map['currentPrice'],
      volume: map['volume'],
      changeAmount: map['changeAmount'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WealthPrice &&
          runtimeType == other.runtimeType &&
          title == other.title;
}
