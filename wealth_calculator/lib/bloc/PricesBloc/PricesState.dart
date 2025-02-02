import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

abstract class PricesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PricesLoading extends PricesState {}

class PricesLoaded extends PricesState {
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;
  final List<WealthPrice> equityPrices;
  final List<WealthPrice> commodityPrices;
  final List<WealthPrice> customPrices; // Eklenen özel fiyat listesi

  PricesLoaded({
    required this.commodityPrices,
    required this.goldPrices,
    required this.currencyPrices,
    required this.equityPrices,
    required this.customPrices,
  });

  @override
  List<Object?> get props =>
      [goldPrices, currencyPrices, equityPrices, commodityPrices, customPrices];

  // Copywith metodu, state nesnesinin kopyasını oluştururken, sadece değişen alanları güncellemek için kullanılır.
  // The copywith method is used to create a copy of the state object and update only the changing fields.
  PricesLoaded copyWith({
    List<WealthPrice>? goldPrices,
    List<WealthPrice>? currencyPrices,
    List<WealthPrice>? equityPrices,
    List<WealthPrice>? commodityPrices,
    List<WealthPrice>? customPrices,
  }) {
    return PricesLoaded(
      commodityPrices: commodityPrices ?? this.commodityPrices,
      goldPrices: goldPrices ?? this.goldPrices,
      currencyPrices: currencyPrices ?? this.currencyPrices,
      equityPrices: equityPrices ?? this.equityPrices,
      customPrices: customPrices ?? this.customPrices,
    );
  }
}

class PricesError extends PricesState {
  final String message;

  PricesError(this.message);

  @override
  List<Object?> get props => [message];
}

class PricesSearchResult extends PricesState {
  final List<WealthPrice> searchResults;

  PricesSearchResult(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class CustomPriceDuplicateError extends PricesState {
  final String message;

  CustomPriceDuplicateError(this.message);

  @override
  List<Object?> get props => [message];
}
