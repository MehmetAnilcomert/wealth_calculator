import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

abstract class PricesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrices extends PricesEvent {}

class SearchPrices extends PricesEvent {
  final String query;

  SearchPrices(this.query);

  @override
  List<Object?> get props => [query];
}

class AddCustomPrice extends PricesEvent {
  final List<WealthPrice> wealthPrices;

  AddCustomPrice(this.wealthPrices);

  @override
  List<Object?> get props => [wealthPrices];
}

class DeleteCustomPrice extends PricesEvent {
  final WealthPrice wealthPrice;

  DeleteCustomPrice(this.wealthPrice);

  @override
  List<Object?> get props => [wealthPrice];
}
