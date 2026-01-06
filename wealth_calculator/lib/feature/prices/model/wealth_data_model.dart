enum PriceType { gold, currency, equity, commodity }

// This modal is used to store the data of the prices of the wealth items
// They are gold, currency, equity, and commodity prices fetched from the websites
class WealthPrice {
  final String title;
  final String buyingPrice;
  final String sellingPrice;
  final String change;
  final String time;
  final PriceType type;
  final String? currentPrice;
  final String? volume;
  final String? changeAmount;
  final String? lastUpdatedDate;
  final String? lastUpdatedTime;

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
    this.lastUpdatedDate,
    this.lastUpdatedTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'change': change,
      'time': time,
      'type': type.index,
      'currentPrice': currentPrice,
      'volume': volume,
      'changeAmount': changeAmount,
      'lastUpdatedDate': lastUpdatedDate,
      'lastUpdatedTime': lastUpdatedTime,
    };
  }

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
      lastUpdatedDate: map['lastUpdatedDate'],
      lastUpdatedTime: map['lastUpdatedTime'],
    );
  }

  // equals methods to compare the objects
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WealthPrice &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
