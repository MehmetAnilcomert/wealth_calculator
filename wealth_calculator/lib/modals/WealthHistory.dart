class WealthHistory {
  final int id;
  final DateTime date;
  final double totalPrice;

  WealthHistory({
    required this.id,
    required this.date,
    required this.totalPrice,
  });

  factory WealthHistory.fromMap(Map<String, dynamic> map) {
    return WealthHistory(
      id: map['id'] as int,
      date: DateTime.parse(map['date'].toString()),
      totalPrice: (map['totalPrice'] as num).toDouble(),
    );
  }
}
