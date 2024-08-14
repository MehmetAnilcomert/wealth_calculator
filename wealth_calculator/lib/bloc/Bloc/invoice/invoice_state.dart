import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

abstract class FaturaState extends Equatable {
  const FaturaState();

  @override
  List<Object> get props => [];
}

class FaturaInitial extends FaturaState {}

class FaturaLoading extends FaturaState {}

class FaturaLoaded extends FaturaState {
  final List<Fatura> odememisFaturalar;
  final List<Fatura> odenmisFaturalar;

  const FaturaLoaded({
    required this.odememisFaturalar,
    required this.odenmisFaturalar,
  });

  @override
  List<Object> get props => [odememisFaturalar, odenmisFaturalar];
}

class FaturaError extends FaturaState {
  final String message;

  const FaturaError(this.message);

  @override
  List<Object> get props => [message];
}
