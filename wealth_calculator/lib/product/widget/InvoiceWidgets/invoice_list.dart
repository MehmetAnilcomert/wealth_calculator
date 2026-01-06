import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/feature/invoice_form/view/invoice_adding_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

class InvoiceListWidget extends StatelessWidget {
  final List<Invoice> invoices;
  final Map<String, MaterialColor> colors = {
    "yuksek": Colors.red,
    "orta": Colors.orange,
    "dusuk": Colors.yellow
  };

  InvoiceListWidget({super.key, required this.invoices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final fatura = invoices[index];
        final color = colors[fatura.onemSeviyesi.toString().split('.').last];

        return Dismissible(
          key: Key(fatura.id.toString()),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                const Icon(Icons.delete_outline, color: Colors.white, size: 28),
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
                    Colors.white.withAlpha(26),
                    Colors.white.withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withAlpha(26),
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
                                color: color!.withAlpha(77),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${fatura.tutar} ${LocaleKeys.currency.tr()}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${LocaleKeys.date.tr()}: ${DateFormat('dd.MM.yyyy').format(fatura.tarih)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: fatura.odendiMi
                                ? Colors.green.withAlpha(51)
                                : Colors.red.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            fatura.odendiMi
                                ? Icons.check_circle
                                : Icons.warning_rounded,
                            color: fatura.odendiMi ? Colors.green : Colors.red,
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
