class WealthPrice {
  final String title;
  final String buyingPrice;
  final String sellingPrice;
  final String change;
  final String time;
  final int? type;

  WealthPrice(
      {required this.title,
      required this.buyingPrice,
      required this.sellingPrice,
      required this.change,
      required this.time,
      this.type});

  // Convert WealthPrice object to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'change': change,
      'time': time,
      'type': type,
    };
  }

  // Create a WealthPrice object from a map
  factory WealthPrice.fromMap(Map<String, dynamic> map) {
    return WealthPrice(
      title: map['title'],
      buyingPrice: map['buyingPrice'],
      sellingPrice: map['sellingPrice'],
      change: map['change'],
      time: map['time'],
      type: map['type'],
    );
  }
}
