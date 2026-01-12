import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen/gen.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice_form/viewmodel/invoice_form_bloc.dart';
import 'package:wealth_calculator/feature/invoice_form/viewmodel/invoice_form_event.dart';
import 'package:wealth_calculator/feature/invoice_form/viewmodel/invoice_form_state.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/snackbar_helper.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class InvoiceAddingView extends StatelessWidget {
  final Invoice? fatura;

  const InvoiceAddingView({this.fatura, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InvoiceFormBloc()..add(InitializeForm(invoice: fatura)),
      child: InvoiceAddingContent(fatura: fatura),
    );
  }
}

class InvoiceAddingContent extends StatelessWidget {
  final Invoice? fatura;

  const InvoiceAddingContent({this.fatura, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceFormBloc, InvoiceFormState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          final invoice = state.toInvoice();
          if (fatura == null) {
            context.read<InvoiceBloc>().add(AddInvoice(invoice));
          } else {
            context.read<InvoiceBloc>().add(UpdateInvoice(invoice));
          }
          Navigator.pop(context, true);
        } else if (state.status == FormStatus.error) {
          if (state.errorMessage != null) {
            SnackbarHelper.showError(context, state.errorMessage!);
          }
        }
      },
      builder: (context, formState) {
        return _buildScaffold(context, formState);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        title: Text(
          fatura == null
              ? LocaleKeys.add_invoice.tr()
              : LocaleKeys.update_invoice.tr(),
          style: TextStyle(
              color: colorScheme.onSecondary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: 200,
                child: Assets.lottie.animBill.lottie(
                  package: "gen",
                  fit: BoxFit.contain,
                  repeat: false,
                  animate: true,
                )),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateField(context, formState),
                    const SizedBox(height: 20),
                    _buildAmountField(context, formState),
                    const SizedBox(height: 20),
                    _buildDescriptionField(context, formState),
                    const SizedBox(height: 20),
                    _buildDropdown(context, formState),
                    const SizedBox(height: 20),
                    _buildPaidSwitch(context, formState),
                    const SizedBox(height: 10),
                    _buildNotificationSwitch(context, formState),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: formState.status == FormStatus.submitting
                            ? null
                            : () {
                                context
                                    .read<InvoiceFormBloc>()
                                    .add(const SubmitForm());
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: formState.status == FormStatus.submitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.onPrimary),
                                ),
                              )
                            : Text(
                                fatura == null
                                    ? LocaleKeys.save_invoice.tr()
                                    : LocaleKeys.update_invoice.tr(),
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        labelText: LocaleKeys.due_date.tr(),
        prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat('dd.MM.yyyy').format(formState.selectedDate),
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: formState.selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          context.read<InvoiceFormBloc>().add(DateChanged(picked));
        }
      },
    );
  }

  Widget _buildAmountField(BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        labelText: LocaleKeys.enter_amount.tr(),
        prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorText: formState.amount.isNotEmpty && !formState.isAmountValid
            ? LocaleKeys.enter_amount.tr()
            : null,
      ),
      keyboardType: TextInputType.number,
      initialValue: formState.amount,
      onChanged: (value) {
        context.read<InvoiceFormBloc>().add(AmountChanged(value));
      },
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        labelText: LocaleKeys.explanation.tr(),
        prefixIcon: Icon(Icons.description, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      initialValue: formState.description,
      onChanged: (value) {
        context.read<InvoiceFormBloc>().add(DescriptionChanged(value));
      },
    );
  }

  Widget _buildDropdown(BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return DropdownButtonFormField<OnemSeviyesi>(
      value: formState.importanceLevel,
      onChanged: (OnemSeviyesi? newValue) {
        if (newValue != null) {
          context.read<InvoiceFormBloc>().add(ImportanceLevelChanged(newValue));
        }
      },
      items: OnemSeviyesi.values.map((OnemSeviyesi onemSeviyesi) {
        IconData icon;
        Color color;
        switch (onemSeviyesi) {
          case OnemSeviyesi.dusuk:
            icon = Icons.arrow_downward;
            color = colorScheme.tertiary;
            break;
          case OnemSeviyesi.orta:
            icon = Icons.remove;
            color = colorScheme.warning;
            break;
          case OnemSeviyesi.yuksek:
            icon = Icons.arrow_upward;
            color = colorScheme.error;
            break;
        }
        return DropdownMenuItem<OnemSeviyesi>(
          value: onemSeviyesi,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                onemSeviyesi.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: LocaleKeys.importance_level.tr(),
        prefixIcon: Icon(Icons.priority_high, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
      dropdownColor: colorScheme.surface,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
    );
  }

  Widget _buildPaidSwitch(BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(
          LocaleKeys.is_paid_invoice.tr(),
          style: const TextStyle(fontSize: 16),
        ),
        value: formState.isPaid,
        onChanged: (value) {
          context.read<InvoiceFormBloc>().add(PaidStatusChanged(value));
          if (value) {
            SnackbarHelper.showCustom(
              context,
              LocaleKeys.invoice_paid_message.tr(),
              backgroundColor: colorScheme.secondary,
            );
          }
        },
        activeThumbColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildNotificationSwitch(
      BuildContext context, InvoiceFormState formState) {
    final colorScheme = context.general.colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(
          LocaleKeys.notification_send_permission.tr(),
          style: const TextStyle(fontSize: 16),
        ),
        value: formState.isNotificationEnabled,
        onChanged: formState.canEnableNotification
            ? (value) {
                context
                    .read<InvoiceFormBloc>()
                    .add(NotificationStatusChanged(value));
              }
            : null,
        activeThumbColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
