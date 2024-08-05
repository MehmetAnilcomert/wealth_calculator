import 'package:flutter/material.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> invoice;

  InvoiceDetailScreen({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fatura Detayları')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Kategori: ${invoice['category']}'),
            Text('Tutar: ${invoice['amount']} TL'),
            Text('Ödendi: ${invoice['is_paid'] ? 'Evet' : 'Hayır'}'),
            Text('Önem Sırası: ${invoice['priority']}'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddInvoiceScreen(invoice: invoice),
                  ),
                );
              },
              child: Text('Düzenle'),
            ),
          ],
        ),
      ),
    );
  }
}
