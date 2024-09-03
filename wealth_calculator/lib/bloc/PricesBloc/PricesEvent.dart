import 'package:equatable/equatable.dart';

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
