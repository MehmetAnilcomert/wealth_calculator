import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Base event for converter feature
abstract class ConverterEvent extends Equatable {
  const ConverterEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial data (prices)
class LoadConverterData extends ConverterEvent {
  const LoadConverterData();
}

/// Event to convert TL amount to wealth amounts
class ConvertTLAmount extends ConverterEvent {
  final double tlAmount;
  final PriceType filterType;

  const ConvertTLAmount({
    required this.tlAmount,
    required this.filterType,
  });

  @override
  List<Object?> get props => [tlAmount, filterType];
}

/// Event to change price type filter
class ChangePriceTypeFilter extends ConverterEvent {
  final PriceType type;

  const ChangePriceTypeFilter(this.type);

  @override
  List<Object?> get props => [type];
}

/// Event to clear conversion results
class ClearConversion extends ConverterEvent {
  const ClearConversion();
}
