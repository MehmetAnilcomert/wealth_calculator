import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';

enum FormStatus { initial, valid, invalid, submitting, success, error }

class InvoiceFormState extends Equatable {
  final Invoice? originalInvoice;
  final DateTime selectedDate;
  final String amount;
  final String description;
  final OnemSeviyesi importanceLevel;
  final bool isPaid;
  final bool isNotificationEnabled;
  final FormStatus status;
  final String? errorMessage;
  final bool isAmountValid;
  final bool canEnableNotification;

  const InvoiceFormState({
    this.originalInvoice,
    required this.selectedDate,
    this.amount = '',
    this.description = '',
    this.importanceLevel = OnemSeviyesi.orta,
    this.isPaid = false,
    this.isNotificationEnabled = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.isAmountValid = false,
    this.canEnableNotification = true,
  });

  factory InvoiceFormState.initial() {
    return InvoiceFormState(
      selectedDate: DateTime.now(),
    );
  }

  factory InvoiceFormState.fromInvoice(Invoice invoice) {
    final isPastDate = invoice.tarih.isBefore(DateTime.now());
    return InvoiceFormState(
      originalInvoice: invoice,
      selectedDate: invoice.tarih,
      amount: invoice.tutar.toString(),
      description: invoice.aciklama,
      importanceLevel: invoice.onemSeviyesi,
      isPaid: invoice.odendiMi,
      isNotificationEnabled:
          invoice.isNotificationEnabled && !isPastDate && !invoice.odendiMi,
      isAmountValid: true,
      canEnableNotification: !isPastDate && !invoice.odendiMi,
    );
  }

  InvoiceFormState copyWith({
    Invoice? originalInvoice,
    DateTime? selectedDate,
    String? amount,
    String? description,
    OnemSeviyesi? importanceLevel,
    bool? isPaid,
    bool? isNotificationEnabled,
    FormStatus? status,
    String? errorMessage,
    bool? isAmountValid,
    bool? canEnableNotification,
  }) {
    return InvoiceFormState(
      originalInvoice: originalInvoice ?? this.originalInvoice,
      selectedDate: selectedDate ?? this.selectedDate,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      isPaid: isPaid ?? this.isPaid,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isAmountValid: isAmountValid ?? this.isAmountValid,
      canEnableNotification:
          canEnableNotification ?? this.canEnableNotification,
    );
  }

  bool get isEditing => originalInvoice != null;

  bool get isFormValid => isAmountValid && amount.isNotEmpty;

  Invoice toInvoice() {
    return Invoice(
      id: originalInvoice?.id,
      tarih: selectedDate,
      tutar: double.parse(amount),
      aciklama: description,
      onemSeviyesi: importanceLevel,
      odendiMi: isPaid,
      isNotificationEnabled: isNotificationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        originalInvoice,
        selectedDate,
        amount,
        description,
        importanceLevel,
        isPaid,
        isNotificationEnabled,
        status,
        errorMessage,
        isAmountValid,
        canEnableNotification,
      ];
}
