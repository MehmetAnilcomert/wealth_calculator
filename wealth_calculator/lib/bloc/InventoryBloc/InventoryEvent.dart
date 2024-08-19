import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadInventoryData extends InventoryEvent {}

class AddOrUpdateWealth extends InventoryEvent {
  final SavedWealths wealth;
  final int amount;

  AddOrUpdateWealth(this.wealth, this.amount);

  @override
  List<Object> get props => [wealth, amount];
}

class DeleteWealth extends InventoryEvent {
  final int id;

  DeleteWealth(this.id);

  @override
  List<Object> get props => [id];
}
