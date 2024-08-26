import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_state.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final DbHelper _dbHelper = DbHelper.instance;

  InvoiceBloc() : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadFaturalar);
    on<AddInvoice>(_onAddFatura);
    on<UpdateInvoice>(_onUpdateFatura);
    on<DeleteInvoice>(_onDeleteFatura);
    on<SortByImportance>(_onSortByImportance);
    on<SortByDate>(_onSortByDate);
  }

  Future<void> _onSortByImportance(
      SortByImportance event, Emitter<InvoiceState> emit) async {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;
      final sortedNonPaid = List<Invoice>.from(currentState.nonPaidInvoices)
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));
      final sortedPaid = List<Invoice>.from(currentState.paidInvoices)
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));
      emit(InvoiceLoaded(
        nonPaidInvoices: sortedNonPaid,
        paidInvoices: sortedPaid,
      ));
    }
  }

  Future<void> _onSortByDate(
      SortByDate event, Emitter<InvoiceState> emit) async {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;
      final sortedNonPaid = List<Invoice>.from(currentState.nonPaidInvoices)
        ..sort((a, b) => a.tarih.compareTo(b.tarih));
      final sortedPaid = List<Invoice>.from(currentState.paidInvoices)
        ..sort((a, b) => a.tarih.compareTo(b.tarih));
      emit(InvoiceLoaded(
        nonPaidInvoices: sortedNonPaid,
        paidInvoices: sortedPaid,
      ));
    }
  }

  Future<void> _onLoadFaturalar(
      LoadInvoices event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      final db = await _dbHelper.faturaDatabase;
      final List<Map<String, dynamic>> maps = await db.query('fatura');
      final List<Invoice> faturalar =
          maps.map((map) => Invoice.fromMap(map)).toList();

      // Faturaları ayırma ve sıralama işlemi
      final List<Invoice> odememisFaturalar = faturalar
          .where((f) => !f.odendiMi)
          .toList()
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));

      final List<Invoice> odenmisFaturalar = faturalar
          .where((f) => f.odendiMi)
          .toList()
        ..sort((a, b) => a.onemSeviyesi.index.compareTo(b.onemSeviyesi.index));

      // Sıralanmış faturaları yüklüyoruz
      emit(InvoiceLoaded(
        nonPaidInvoices: odememisFaturalar,
        paidInvoices: odenmisFaturalar,
      ));
    } catch (e) {
      emit(InvoiceError('Faturalar yüklenirken bir hata oluştu: $e'));
    }
  }

  Future<void> _onAddFatura(
      AddInvoice event, Emitter<InvoiceState> emit) async {
    try {
      final db = await _dbHelper.faturaDatabase;
      await db.insert('fatura', event.fatura.toMap());
      print('Invoice added successfully'); // Debug print
      add(LoadInvoices());
    } catch (e) {
      print('Error adding invoice: $e'); // Debug print
      emit(InvoiceError('Fatura eklenirken bir hata oluştu: $e'));
    }
  }

  Future<void> _onUpdateFatura(
      UpdateInvoice event, Emitter<InvoiceState> emit) async {
    final currentState = state;
    if (currentState is InvoiceLoaded) {
      try {
        final db = await _dbHelper.faturaDatabase;
        await db.update(
          'fatura',
          event.fatura.toMap(),
          where: 'id = ?',
          whereArgs: [event.fatura.id],
        );

        // Güncellenen faturayı bulun
        List<Invoice> updatedOdememisFaturalar =
            List.from(currentState.nonPaidInvoices);
        List<Invoice> updatedOdenmisFaturalar =
            List.from(currentState.paidInvoices);

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
        emit(InvoiceLoaded(
          nonPaidInvoices: updatedOdememisFaturalar,
          paidInvoices: updatedOdenmisFaturalar,
        ));
      } catch (e) {
        emit(InvoiceError('Fatura güncellenirken bir hata oluştu: $e'));
      }
    }
  }

  Future<void> _onDeleteFatura(
      DeleteInvoice event, Emitter<InvoiceState> emit) async {
    final currentState = state;
    if (currentState is InvoiceLoaded) {
      try {
        final db = await _dbHelper.faturaDatabase;
        await db.delete(
          'fatura',
          where: 'id = ?',
          whereArgs: [event.id],
        );
        add(LoadInvoices());
      } catch (e) {
        emit(InvoiceError('Fatura silinirken bir hata oluştu: $e'));
      }
    }
  }
}
