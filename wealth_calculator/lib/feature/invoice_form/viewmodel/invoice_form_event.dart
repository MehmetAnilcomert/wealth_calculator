import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';

abstract class InvoiceFormEvent extends Equatable {
  const InvoiceFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeForm extends InvoiceFormEvent {
  final Invoice? invoice;

  const InitializeForm({this.invoice});

  @override
  List<Object?> get props => [invoice];
}

class DateChanged extends InvoiceFormEvent {
  final DateTime date;

  const DateChanged(this.date);

  @override
  List<Object> get props => [date];
}

class AmountChanged extends InvoiceFormEvent {
  final String amount;

  const AmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

class DescriptionChanged extends InvoiceFormEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class ImportanceLevelChanged extends InvoiceFormEvent {
  final OnemSeviyesi level;

  const ImportanceLevelChanged(this.level);

  @override
  List<Object> get props => [level];
}

class PaidStatusChanged extends InvoiceFormEvent {
  final bool isPaid;

  const PaidStatusChanged(this.isPaid);

  @override
  List<Object> get props => [isPaid];
}

class NotificationStatusChanged extends InvoiceFormEvent {
  final bool isEnabled;

  const NotificationStatusChanged(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class SubmitForm extends InvoiceFormEvent {
  const SubmitForm();
}

class ValidateForm extends InvoiceFormEvent {
  const ValidateForm();
}
