import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object> get props => [];
}

class LoadInvoices extends InvoiceEvent {}

class SortByImportance extends InvoiceEvent {}

class SortByDate extends InvoiceEvent {}

class SortByAmount extends InvoiceEvent {}

class SortByAmountAndDate extends InvoiceEvent {}

class AddInvoice extends InvoiceEvent {
  final Invoice fatura;

  const AddInvoice(this.fatura);

  @override
  List<Object> get props => [fatura];
}

class UpdateInvoice extends InvoiceEvent {
  final Invoice fatura;

  const UpdateInvoice(this.fatura);

  @override
  List<Object> get props => [fatura];
}

class DeleteInvoice extends InvoiceEvent {
  final int id;

  const DeleteInvoice(this.id);

  @override
  List<Object> get props => [id];
}
