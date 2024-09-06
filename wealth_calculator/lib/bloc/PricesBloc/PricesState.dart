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

  PricesLoaded({
    required this.commodityPrices,
    required this.goldPrices,
    required this.currencyPrices,
    required this.equityPrices,
  });

  @override
  List<Object?> get props => [goldPrices, currencyPrices, equityPrices];
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
