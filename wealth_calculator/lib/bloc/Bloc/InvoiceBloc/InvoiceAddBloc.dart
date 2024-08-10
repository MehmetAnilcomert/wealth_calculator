// bloc/fatura_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

// Bloc events
abstract class FaturaEklemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFaturalar extends FaturaEklemeEvent {}

class AddFaturaEvent extends FaturaEklemeEvent {
  final Fatura fatura;

  AddFaturaEvent(this.fatura);

  @override
  List<Object?> get props => [fatura];
}

// Bloc states
abstract class FaturaEklemeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FaturaEklemeInitial extends FaturaEklemeState {}

class FaturaEklemeLoading extends FaturaEklemeState {}

class FaturaEklemeSuccess extends FaturaEklemeState {
  final List<Fatura> faturalar;

  FaturaEklemeSuccess(this.faturalar);

  @override
  List<Object?> get props => [faturalar];
}

class FaturaEklemeError extends FaturaEklemeState {
  final String message;

  FaturaEklemeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class FaturaEklemeBloc extends Bloc<FaturaEklemeEvent, FaturaEklemeState> {
  FaturaEklemeBloc() : super(FaturaEklemeInitial()) {
    on<LoadFaturalar>((event, emit) async {
      emit(FaturaEklemeLoading());

      try {
        // Simulate fetching data
        await Future.delayed(Duration(seconds: 2));
        // Replace with actual data fetching
        List<Fatura> faturalar = []; // Fetch your data here
        emit(FaturaEklemeSuccess(faturalar));
      } catch (e) {
        emit(FaturaEklemeError('Failed to load data'));
      }
    });

    on<AddFaturaEvent>((event, emit) async {
      // Handle adding the invoice here
      try {
        // Simulate adding the invoice
        await Future.delayed(Duration(seconds: 1));
        // Optionally, fetch updated data after adding
        // List<Fatura> updatedFaturalar = []; // Fetch your data here
        emit(FaturaEklemeSuccess([])); // Replace with actual data
      } catch (e) {
        emit(FaturaEklemeError('Failed to add invoice'));
      }
    });
  }
}
