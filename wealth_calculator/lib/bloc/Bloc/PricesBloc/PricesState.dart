// prices_state.dart
import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

abstract class GoldPricesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GoldPricesLoading extends GoldPricesState {}

class GoldPricesLoaded extends GoldPricesState {
  final List<WealthPrice> goldPrices;
  final List<WealthPrice> currencyPrices;

  GoldPricesLoaded({required this.goldPrices, required this.currencyPrices});

  @override
  List<Object?> get props => [goldPrices, currencyPrices];
}

class GoldPricesError extends GoldPricesState {
  final String message;

  GoldPricesError(this.message);

  @override
  List<Object?> get props => [message];
}
