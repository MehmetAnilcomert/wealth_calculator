import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class LoadCalculatorData extends CalculatorEvent {
  const LoadCalculatorData();
}

class AddOrUpdateCalculatorWealth extends CalculatorEvent {
  final SavedWealths wealth;
  final int amount;

  const AddOrUpdateCalculatorWealth(this.wealth, this.amount);

  @override
  List<Object> get props => [wealth, amount];
}

class DeleteCalculatorWealth extends CalculatorEvent {
  final int id;

  const DeleteCalculatorWealth(this.id);

  @override
  List<Object> get props => [id];
}
