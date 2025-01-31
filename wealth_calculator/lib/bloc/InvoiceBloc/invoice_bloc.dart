import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_state.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/services/Notification.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final DbHelper _dbHelper = DbHelper.instance;

  InvoiceBloc() : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadFaturalar);
    on<AddInvoice>(_onAddFatura);
    on<UpdateInvoice>(_onUpdateFatura);
    on<DeleteInvoice>(_onDeleteFatura);
    on<SortByImportance>(_onSortByImportance);
    on<SortByDate>(_onSortByDate);
    on<SortByAmount>(_onSortByAmount);
    on<SortByAmountAndDate>(_onSortByAmountAndDate);
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

  Future<void> _onSortByAmount(
      SortByAmount event, Emitter<InvoiceState> emit) async {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;
      final sortedNonPaid = List<Invoice>.from(currentState.nonPaidInvoices)
        ..sort((a, b) => b.tutar.compareTo(a.tutar)); // Azalan sıralama
      final sortedPaid = List<Invoice>.from(currentState.paidInvoices)
        ..sort((a, b) => b.tutar.compareTo(a.tutar)); // Azalan sıralama
      emit(InvoiceLoaded(
        nonPaidInvoices: sortedNonPaid,
        paidInvoices: sortedPaid,
      ));
    }
  }

  Future<void> _onSortByAmountAndDate(
      SortByAmountAndDate event, Emitter<InvoiceState> emit) async {
    if (state is InvoiceLoaded) {
      final currentState = state as InvoiceLoaded;

      final sortedNonPaid = _sortByMonthAndAmount(currentState.nonPaidInvoices);
      final sortedPaid = _sortByMonthAndAmount(currentState.paidInvoices);

      emit(InvoiceLoaded(
        nonPaidInvoices: sortedNonPaid,
        paidInvoices: sortedPaid,
      ));
    }
  }

  List<Invoice> _sortByMonthAndAmount(List<Invoice> invoices) {
    // Faturaları ay ve yıla göre gruplama
    final groupedInvoices = <String, List<Invoice>>{};

    for (var invoice in invoices) {
      final key =
          "${invoice.tarih.year}-${invoice.tarih.month.toString().padLeft(2, '0')}";
      if (!groupedInvoices.containsKey(key)) {
        groupedInvoices[key] = [];
      }
      groupedInvoices[key]!.add(invoice);
    }

    // Her grubu miktara göre azalan sırada sırala
    groupedInvoices.forEach((key, group) {
      group.sort((a, b) => b.tutar.compareTo(a.tutar));
    });

    // Grupları (ayları) tarihe göre artan sırada sırala
    final sortedKeys = groupedInvoices.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Sıralanmış grupları düz bir listeye dönüştür
    final sortedInvoices =
        sortedKeys.expand((key) => groupedInvoices[key]!).toList();

    return sortedInvoices;
  }

  Future<void> _onLoadFaturalar(
      LoadInvoices event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      final db = await _dbHelper.database;
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
      final db = await _dbHelper.database;
      await db.insert('fatura', event.fatura.toMap());
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
        final db = await _dbHelper.database;
        int updatedRows = await db.update(
          'fatura',
          event.fatura.toMap(),
          where: 'id = ?',
          whereArgs: [event.fatura.id],
        );

        if (updatedRows == 0) {
          throw Exception('Fatura güncellenemedi. ID: ${event.fatura.id}');
        }

        List<Invoice> updatedOdememisFaturalar =
            List.from(currentState.nonPaidInvoices);
        List<Invoice> updatedOdenmisFaturalar =
            List.from(currentState.paidInvoices);

        updatedOdememisFaturalar.removeWhere((f) => f.id == event.fatura.id);
        updatedOdenmisFaturalar.removeWhere((f) => f.id == event.fatura.id);

        if (event.fatura.odendiMi) {
          updatedOdenmisFaturalar.add(event.fatura);
        } else {
          updatedOdememisFaturalar.add(event.fatura);
        }

        emit(InvoiceLoaded(
          nonPaidInvoices: updatedOdememisFaturalar,
          paidInvoices: updatedOdenmisFaturalar,
        ));
      } catch (e) {
        emit(InvoiceError('Fatura güncellenirken bir hata oluştu: $e'));
      }
    } else {
      emit(InvoiceError('Geçersiz durum. Faturalar yüklenemedi.'));
    }
  }

  Future<void> _onDeleteFatura(
      DeleteInvoice event, Emitter<InvoiceState> emit) async {
    final currentState = state;
    if (currentState is InvoiceLoaded) {
      try {
        // Bildirimi kaldır
        NotificationService.cancelNotification(event.id);

        final db = await _dbHelper.database;
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
