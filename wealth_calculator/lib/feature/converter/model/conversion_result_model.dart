import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Model to hold the result of a TL to wealth conversion
class ConversionResult {
  final WealthPrice wealth;
  final double amount;
  final double tlAmount;

  const ConversionResult({
    required this.wealth,
    required this.amount,
    required this.tlAmount,
  });

  /// Calculate the amount of wealth that can be bought with the given TL amount
  factory ConversionResult.fromTLAmount(WealthPrice wealth, double tlAmount) {
    final buyingPrice = double.tryParse(
          wealth.buyingPrice.replaceAll(',', '.').replaceAll('₺', '').trim(),
        ) ??
        0.0;

    final amount = buyingPrice > 0 ? tlAmount / buyingPrice : 0.0;

    return ConversionResult(
      wealth: wealth,
      amount: amount,
      tlAmount: tlAmount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionResult &&
          runtimeType == other.runtimeType &&
          wealth == other.wealth &&
          tlAmount == other.tlAmount;

  @override
  int get hashCode => wealth.hashCode ^ tlAmount.hashCode;
}
