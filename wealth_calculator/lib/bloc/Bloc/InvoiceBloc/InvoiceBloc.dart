import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

// Events
abstract class FaturaListesiEvent {}

class LoadFaturalar extends FaturaListesiEvent {}

class AddFatura extends FaturaListesiEvent {
  final Fatura fatura;
  AddFatura(this.fatura);
}

// States
abstract class FaturaListesiState {}

class FaturaListesiLoading extends FaturaListesiState {}

class FaturaListesiLoaded extends FaturaListesiState {
  final List<Fatura> faturalar;
  FaturaListesiLoaded(this.faturalar);
}

class FaturaListesiError extends FaturaListesiState {
  final String message;
  FaturaListesiError(this.message);
}

// Bloc
class FaturaListesiBloc extends Bloc<FaturaListesiEvent, FaturaListesiState> {
  FaturaListesiBloc() : super(FaturaListesiLoading());

  @override
  Stream<FaturaListesiState> mapEventToState(FaturaListesiEvent event) async* {
    if (event is LoadFaturalar) {
      try {
        final db = await openDatabase('my_database.db');
        final List<Map<String, dynamic>> maps = await db.query('fatura');
        final faturalar =
            List.generate(maps.length, (i) => Fatura.fromMap(maps[i]));
        yield FaturaListesiLoaded(faturalar);
      } catch (e) {
        yield FaturaListesiError('Veriler yüklenirken hata oluştu.');
      }
    } else if (event is AddFatura) {
      try {
        final db = await openDatabase('my_database.db');
        await db.insert('fatura', event.fatura.toMap());
        add(LoadFaturalar()); // Refresh list
      } catch (e) {
        yield FaturaListesiError('Fatura eklenirken hata oluştu.');
      }
    }
  }
}
