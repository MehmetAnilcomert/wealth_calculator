import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/converter/model/conversion_result_model.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Base state for converter feature
abstract class ConverterState extends Equatable {
  const ConverterState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConverterInitial extends ConverterState {}

/// Loading state
class ConverterLoading extends ConverterState {}

/// Loaded state with prices data
class ConverterLoaded extends ConverterState {
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final List<ConversionResult> conversionResults;
  final double tlAmount;
  final PriceType selectedType;

  const ConverterLoaded({
    required this.goldPrices,
    required this.currencyPrices,
    required this.conversionResults,
    required this.tlAmount,
    required this.selectedType,
  });

  @override
  List<Object?> get props => [
        goldPrices,
        currencyPrices,
        conversionResults,
        tlAmount,
        selectedType,
      ];

  /// Create a copy with updated values
  ConverterLoaded copyWith({
    List<WealthPrice>? goldPrices,
    List<WealthPrice>? currencyPrices,
    List<ConversionResult>? conversionResults,
    double? tlAmount,
    PriceType? selectedType,
  }) {
    return ConverterLoaded(
      goldPrices: goldPrices ?? this.goldPrices,
      currencyPrices: currencyPrices ?? this.currencyPrices,
      conversionResults: conversionResults ?? this.conversionResults,
      tlAmount: tlAmount ?? this.tlAmount,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

/// Error state
class ConverterError extends ConverterState {
  final String message;

  const ConverterError(this.message);

  @override
  List<Object?> get props => [message];
}
