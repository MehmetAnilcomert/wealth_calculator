// prices_event.dart
import 'package:equatable/equatable.dart';

abstract class GoldPricesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGoldPrices extends GoldPricesEvent {}

class LoadCurrencyPrices extends GoldPricesEvent {}
