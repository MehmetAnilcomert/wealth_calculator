import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class TempInventoryEvent extends Equatable {
  const TempInventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventoryData extends TempInventoryEvent {
  const LoadInventoryData();
}

class AddOrUpdateWealth extends TempInventoryEvent {
  final SavedWealths wealth;
  final int amount;

  const AddOrUpdateWealth(this.wealth, this.amount);

  @override
  List<Object> get props => [wealth, amount];
}

class DeleteWealth extends TempInventoryEvent {
  final int id;

  const DeleteWealth(this.id);

  @override
  List<Object> get props => [id];
}
