import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

abstract class TempInventoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadInventoryData extends TempInventoryEvent {}

class AddOrUpdateWealth extends TempInventoryEvent {
  final SavedWealths wealth;
  final int amount;

  AddOrUpdateWealth(this.wealth, this.amount);
}

class DeleteWealth extends TempInventoryEvent {
  final int id;

  DeleteWealth(this.id);
}
