import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

abstract class FaturaEvent extends Equatable {
  const FaturaEvent();

  @override
  List<Object> get props => [];
}

class LoadFaturalar extends FaturaEvent {}

class AddFatura extends FaturaEvent {
  final Fatura fatura;

  const AddFatura(this.fatura);

  @override
  List<Object> get props => [fatura];
}

class UpdateFatura extends FaturaEvent {
  final Fatura fatura;

  const UpdateFatura(this.fatura);

  @override
  List<Object> get props => [fatura];
}

class DeleteFatura extends FaturaEvent {
  final int id;

  const DeleteFatura(this.id);

  @override
  List<Object> get props => [id];
}
