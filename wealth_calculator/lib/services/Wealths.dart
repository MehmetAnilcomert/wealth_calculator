class SavedWealths {
  final int id;
  final String type;
  final int amount;

  SavedWealths({required this.id, required this.type, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
    };
  }

  factory SavedWealths.fromMap(Map<String, dynamic> map) {
    return SavedWealths(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
    );
  }
}
