import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_state.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/product/service/invoice_dao.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceDao _invoiceDao = InvoiceDao();

  InvoiceBloc() : super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<AddInvoice>(_onAddInvoice);
    on<UpdateInvoice>(_onUpdateInvoice);
    on<DeleteInvoice>(_onDeleteInvoice);
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
    // Group invoices by month and year
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
    // Each group is sorted by amount in descending order
    groupedInvoices.forEach((key, group) {
      group.sort((a, b) => b.tutar.compareTo(a.tutar));
    });

    // Grupları (ayları) tarihe göre artan sırada sırala
    // Sort groups (months) by date in ascending order
    final sortedKeys = groupedInvoices.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Sıralanmış grupları düz bir listeye dönüştür
    // Convert sorted groups to a flat list
    final sortedInvoices =
        sortedKeys.expand((key) => groupedInvoices[key]!).toList();

    return sortedInvoices;
  }

  Future<void> _onLoadInvoices(
      LoadInvoices event, Emitter<InvoiceState> emit) async {
    emit(InvoiceLoading());
    try {
      final invoices = await _invoiceDao.getAllInvoices();
      final nonPaidInvoices = invoices.where((f) => !f.odendiMi).toList();
      final paidInvoices = invoices.where((f) => f.odendiMi).toList();

      emit(InvoiceLoaded(
        nonPaidInvoices: nonPaidInvoices,
        paidInvoices: paidInvoices,
      ));
    } catch (e) {
      emit(InvoiceError('Faturalar yüklenirken hata oluştu: $e'));
    }
  }

  Future<void> _onAddInvoice(
      AddInvoice event, Emitter<InvoiceState> emit) async {
    try {
      await _invoiceDao.addInvoice(event.fatura);
      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError('Fatura eklenirken hata oluştu: $e'));
    }
  }

  Future<void> _onUpdateInvoice(
      UpdateInvoice event, Emitter<InvoiceState> emit) async {
    try {
      await _invoiceDao.updateInvoice(event.fatura);
      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError('Fatura güncellenirken hata oluştu: $e'));
    }
  }

  Future<void> _onDeleteInvoice(
      DeleteInvoice event, Emitter<InvoiceState> emit) async {
    try {
      NotificationService.cancelNotification(event.id);
      await _invoiceDao.deleteInvoice(event.id);
      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError('Fatura silinirken hata oluştu: $e'));
    }
  }
}
