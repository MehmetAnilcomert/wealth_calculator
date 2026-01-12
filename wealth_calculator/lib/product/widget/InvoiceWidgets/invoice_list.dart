import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/feature/invoice_form/view/invoice_adding_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class InvoiceListWidget extends StatelessWidget {
  final List<Invoice> invoices;

  const InvoiceListWidget({super.key, required this.invoices});

  Color _getImportanceColor(BuildContext context, String importance) {
    final colorScheme = context.general.colorScheme;
    switch (importance) {
      case 'yuksek':
        return colorScheme.error;
      case 'orta':
        return colorScheme.warning;
      case 'dusuk':
        return colorScheme.tertiary;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final fatura = invoices[index];
        final color = _getImportanceColor(
            context, fatura.onemSeviyesi.toString().split('.').last);

        return Dismissible(
          key: Key(fatura.id.toString()),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.deleteBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete_outline,
                color: colorScheme.onError, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            BlocProvider.of<InvoiceBloc>(context)
                .add(DeleteInvoice(fatura.id!));
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: BlocProvider.of<InvoiceBloc>(context),
                    child: InvoiceAddingView(fatura: fatura),
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  BlocProvider.of<InvoiceBloc>(context).add(LoadInvoices());
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.whiteOverlay10,
                    colorScheme.whiteOverlay05,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: colorScheme.whiteOverlay10,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(77),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fatura.aciklama,
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${fatura.tutar} ${LocaleKeys.tl.tr()}",
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${LocaleKeys.date.tr()}: ${DateFormat('dd.MM.yyyy').format(fatura.tarih)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onPrimaryContainer
                                      .withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: fatura.odendiMi
                                ? colorScheme.tertiary.withAlpha(51)
                                : colorScheme.error.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            fatura.odendiMi
                                ? Icons.check_circle
                                : Icons.warning_rounded,
                            color: fatura.odendiMi
                                ? colorScheme.tertiary
                                : colorScheme.error,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
