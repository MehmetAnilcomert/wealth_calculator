import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';

abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Invoice> nonPaidInvoices;
  final List<Invoice> paidInvoices;

  const InvoiceLoaded({
    required this.nonPaidInvoices,
    required this.paidInvoices,
  });

  @override
  List<Object> get props => [nonPaidInvoices, paidInvoices];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object> get props => [message];
}
