import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

abstract class PricesState extends Equatable {
  const PricesState();

  @override
  List<Object?> get props => [];
}

class PricesLoading extends PricesState {}

class PricesLoaded extends PricesState {
  final List<WealthPrice> commodityPrices;
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final List<WealthPrice> equityPrices;
  final List<WealthPrice> customPrices;
  
  // New fields for the offline banner and sync info
  final DateTime? lastUpdatedAt;
  final bool isFromCache;

  const PricesLoaded({
    required this.commodityPrices,
    required this.goldPrices,
    required this.currencyPrices,
    required this.equityPrices,
    required this.customPrices,
    this.lastUpdatedAt,
    this.isFromCache = false,
  });

  PricesLoaded copyWith({
    List<WealthPrice>? commodityPrices,
    List<WealthPrice>? goldPrices,
    List<WealthPrice>? currencyPrices,
    List<WealthPrice>? equityPrices,
    List<WealthPrice>? customPrices,
    DateTime? lastUpdatedAt,
    bool? isFromCache,
  }) {
    return PricesLoaded(
      commodityPrices: commodityPrices ?? this.commodityPrices,
      goldPrices: goldPrices ?? this.goldPrices,
      currencyPrices: currencyPrices ?? this.currencyPrices,
      equityPrices: equityPrices ?? this.equityPrices,
      customPrices: customPrices ?? this.customPrices,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
        commodityPrices,
        goldPrices,
        currencyPrices,
        equityPrices,
        customPrices,
        lastUpdatedAt,
        isFromCache,
      ];
}

class PricesError extends PricesState {
  final String message;

  const PricesError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomPriceDuplicateError extends PricesState {
  final String message;

  const CustomPriceDuplicateError(this.message);

  @override
  List<Object?> get props => [message];
}
