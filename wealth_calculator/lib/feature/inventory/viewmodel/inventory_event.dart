import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventoryData extends InventoryEvent {
  final List<WealthPrice>? goldPrices;
  final List<WealthPrice>? currencyPrices;

  const LoadInventoryData({this.goldPrices, this.currencyPrices});
}

class AddOrUpdateWealth extends InventoryEvent {
  final SavedWealths wealth;
  final double amount;

  const AddOrUpdateWealth(this.wealth, this.amount);

  @override
  List<Object> get props => [wealth, amount];
}

class DeleteWealth extends InventoryEvent {
  final int id;

  const DeleteWealth(this.id);

  @override
  List<Object> get props => [id];
}
