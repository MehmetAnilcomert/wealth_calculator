import 'package:equatable/equatable.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class LoadCalculatorData extends CalculatorEvent {
  const LoadCalculatorData();
}

class AddOrUpdateCalculatorWealth extends CalculatorEvent {
  final dynamic wealth; // Can be SavedWealths or WealthPrice
  final double amount;

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
