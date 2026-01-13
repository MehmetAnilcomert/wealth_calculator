import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice_form/viewmodel/invoice_form_event.dart';
import 'package:wealth_calculator/feature/invoice_form/viewmodel/invoice_form_state.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';

class InvoiceFormBloc extends BaseBloc<InvoiceFormEvent, InvoiceFormState> {
  InvoiceFormBloc() : super(InvoiceFormState.initial()) {
    on<InitializeForm>(_onInitializeForm);
    on<DateChanged>(_onDateChanged);
    on<AmountChanged>(_onAmountChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<ImportanceLevelChanged>(_onImportanceLevelChanged);
    on<PaidStatusChanged>(_onPaidStatusChanged);
    on<NotificationStatusChanged>(_onNotificationStatusChanged);
    on<SubmitForm>(_onSubmitForm);
    on<ValidateForm>(_onValidateForm);
  }

  void _onInitializeForm(InitializeForm event, Emitter<InvoiceFormState> emit) {
    if (event.invoice != null) {
      emit(InvoiceFormState.fromInvoice(event.invoice!));
    } else {
      emit(InvoiceFormState.initial());
    }
  }

  void _onDateChanged(DateChanged event, Emitter<InvoiceFormState> emit) {
    final isPastDate = event.date.isBefore(DateTime.now());
    final canEnableNotification = !isPastDate && !state.isPaid;

    emit(state.copyWith(
      selectedDate: event.date,
      canEnableNotification: canEnableNotification,
      isNotificationEnabled:
          canEnableNotification ? state.isNotificationEnabled : false,
    ));
  }

  void _onAmountChanged(AmountChanged event, Emitter<InvoiceFormState> emit) {
    final isValid = _isValidAmount(event.amount);
    emit(state.copyWith(
      amount: event.amount,
      isAmountValid: isValid,
    ));
  }

  void _onDescriptionChanged(
      DescriptionChanged event, Emitter<InvoiceFormState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onImportanceLevelChanged(
      ImportanceLevelChanged event, Emitter<InvoiceFormState> emit) {
    emit(state.copyWith(importanceLevel: event.level));
  }

  void _onPaidStatusChanged(
      PaidStatusChanged event, Emitter<InvoiceFormState> emit) {
    final canEnableNotification =
        !event.isPaid && !state.selectedDate.isBefore(DateTime.now());

    emit(state.copyWith(
      isPaid: event.isPaid,
      canEnableNotification: canEnableNotification,
      isNotificationEnabled:
          canEnableNotification ? state.isNotificationEnabled : false,
    ));
  }

  Future<void> _onNotificationStatusChanged(
    NotificationStatusChanged event,
    Emitter<InvoiceFormState> emit,
  ) async {
    if (!state.canEnableNotification) {
      return;
    }

    emit(state.copyWith(
      isNotificationEnabled: event.isEnabled,
      status: FormStatus.initial,
    ));

    if (event.isEnabled) {
      // Schedule notification
      try {
        final notificationId = state.originalInvoice?.id ?? 0;
        DateTime scheduledDate = DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
          9,
          30,
        );

        await NotificationService.scheduleNotification(
          notificationId,
          "Hatırlatma!",
          "${state.amount} TL tutarında olan ${state.description} faturanızı ödemiş miydiniz?",
          scheduledDate,
        );
      } catch (error) {
        emit(state.copyWith(
          isNotificationEnabled: false,
          status: FormStatus.error,
          errorMessage: 'Bildirim planlanırken hata oluştu: $error',
        ));
      }
    } else {
      // Cancel notification
      try {
        final notificationId = state.originalInvoice?.id ?? 0;
        await NotificationService.cancelNotification(notificationId);
      } catch (error) {
        emit(state.copyWith(
          isNotificationEnabled: true,
          status: FormStatus.error,
          errorMessage: 'Bildirim iptal edilirken hata oluştu: $error',
        ));
      }
    }
  }

  void _onValidateForm(ValidateForm event, Emitter<InvoiceFormState> emit) {
    if (state.isFormValid) {
      emit(state.copyWith(status: FormStatus.valid));
    } else {
      emit(state.copyWith(status: FormStatus.invalid));
    }
  }

  Future<void> _onSubmitForm(
      SubmitForm event, Emitter<InvoiceFormState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: FormStatus.invalid,
        errorMessage: 'Lütfen tüm gerekli alanları doldurun',
      ));
      return;
    }

    try {
      emit(state.copyWith(status: FormStatus.submitting));

      // Date parsing validation
      if (state.selectedDate.isBefore(DateTime(2000)) ||
          state.selectedDate.isAfter(DateTime(2100))) {
        emit(state.copyWith(
          status: FormStatus.error,
          errorMessage: 'Geçersiz tarih',
        ));
        return;
      }

      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  bool _isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    final parsed = double.tryParse(amount);
    return parsed != null && parsed > 0;
  }
}
