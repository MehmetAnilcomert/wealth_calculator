import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/views/invoice_adding.dart';

class InvoiceListWidget extends StatelessWidget {
  final List<Invoice> invoices;
  final List<Color> colors;

  InvoiceListWidget({required this.invoices, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final fatura = invoices[index];
        final color = colors[index];
        return Dismissible(
          key: Key(fatura.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
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
                    child: InvoiceAddUpdateScreen(fatura: fatura),
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  BlocProvider.of<InvoiceBloc>(context).add(LoadInvoices());
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                border: Border.all(color: Colors.black, width: 0.6),
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fatura.aciklama,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        Row(
                          children: [
                            Text(
                              'Tutar:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            Text(
                              "  ${fatura.tutar} TL",
                              style: TextStyle(
                                  fontSize: 19.0, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "Son Ödeme Tarihi:",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "  ${DateFormat('dd.MM.yyyy').format(fatura.tarih)}",
                              style: TextStyle(
                                  fontSize: 17.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Icon(
                      fatura.odendiMi ? Icons.check : Icons.warning_rounded,
                      color: fatura.odendiMi ? Colors.green : Colors.red,
                      size: 33,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
