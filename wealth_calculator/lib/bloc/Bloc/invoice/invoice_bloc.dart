import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/invoice/invoice_event.dart';
import 'package:wealth_calculator/bloc/Bloc/invoice/invoice_state.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class InvoiceBloc extends Bloc<FaturaEvent, FaturaState> {
  final DbHelper _dbHelper = DbHelper.instance;

  InvoiceBloc() : super(FaturaInitial()) {
    on<LoadFaturalar>(_onLoadFaturalar);
    on<AddFatura>(_onAddFatura);
    on<UpdateFatura>(_onUpdateFatura);
    on<DeleteFatura>(_onDeleteFatura);
  }

  Future<void> _onLoadFaturalar(
      LoadFaturalar event, Emitter<FaturaState> emit) async {
    emit(FaturaLoading());
    try {
      final db = await _dbHelper.faturaDatabase;
      final List<Map<String, dynamic>> maps = await db.query('fatura');
      final List<Fatura> faturalar =
          maps.map((map) => Fatura.fromMap(map)).toList();

      // Faturaları ayırma ve sıralama işlemi
      final List<Fatura> odememisFaturalar = faturalar
          .where((f) => !f.odendiMi)
          .toList()
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));

      final List<Fatura> odenmisFaturalar = faturalar
          .where((f) => f.odendiMi)
          .toList()
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));

      // Sıralanmış faturaları yüklüyoruz
      emit(FaturaLoaded(
        odememisFaturalar: odememisFaturalar,
        odenmisFaturalar: odenmisFaturalar,
      ));
    } catch (e) {
      emit(FaturaError('Faturalar yüklenirken bir hata oluştu: $e'));
    }
  }

  Future<void> _onAddFatura(AddFatura event, Emitter<FaturaState> emit) async {
    try {
      final db = await _dbHelper.faturaDatabase;
      await db.insert('fatura', event.fatura.toMap());
      print('Invoice added successfully'); // Debug print
      add(LoadFaturalar());
    } catch (e) {
      print('Error adding invoice: $e'); // Debug print
      emit(FaturaError('Fatura eklenirken bir hata oluştu: $e'));
    }
  }

  Future<void> _onUpdateFatura(
      UpdateFatura event, Emitter<FaturaState> emit) async {
    final currentState = state;
    if (currentState is FaturaLoaded) {
      try {
        final db = await _dbHelper.faturaDatabase;
        await db.update(
          'fatura',
          event.fatura.toMap(),
          where: 'id = ?',
          whereArgs: [event.fatura.id],
        );

        // Güncellenen faturayı bulun
        List<Fatura> updatedOdememisFaturalar =
            List.from(currentState.odememisFaturalar);
        List<Fatura> updatedOdenmisFaturalar =
            List.from(currentState.odenmisFaturalar);

        if (event.fatura.odendiMi) {
          // Fatura ödenmiş olarak güncellendiyse, ödenmemiş listeden çıkar ve ödenmiş listeye ekle
          updatedOdememisFaturalar.removeWhere((f) => f.id == event.fatura.id);
          updatedOdenmisFaturalar.add(event.fatura);
        } else {
          // Fatura ödenmemiş olarak güncellendiyse, ödenmiş listeden çıkar ve ödenmemiş listeye ekle
          updatedOdenmisFaturalar.removeWhere((f) => f.id == event.fatura.id);
          updatedOdememisFaturalar.add(event.fatura);
        }

        // Yeni durumu emit et
        emit(FaturaLoaded(
          odememisFaturalar: updatedOdememisFaturalar,
          odenmisFaturalar: updatedOdenmisFaturalar,
        ));
      } catch (e) {
        emit(FaturaError('Fatura güncellenirken bir hata oluştu: $e'));
      }
    }
  }

  Future<void> _onDeleteFatura(
      DeleteFatura event, Emitter<FaturaState> emit) async {
    final currentState = state;
    if (currentState is FaturaLoaded) {
      try {
        final db = await _dbHelper.faturaDatabase;
        await db.delete(
          'fatura',
          where: 'id = ?',
          whereArgs: [event.id],
        );
        add(LoadFaturalar());
      } catch (e) {
        emit(FaturaError('Fatura silinirken bir hata oluştu: $e'));
      }
    }
  }
}
