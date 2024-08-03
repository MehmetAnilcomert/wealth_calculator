import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';

class InvoiceListScreen extends StatelessWidget {
  final List<InvoiceModal> invoices;

  InvoiceListScreen({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fatura Listesi'),
      ),
      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text(invoice.name ?? 'Fatura Adı Yok'),
            subtitle: Text('Tutar: ${invoice.amount} TL'),
            trailing: Icon(
                invoice.isPaid == true ? Icons.check_circle : Icons.pending),
            onTap: () {
              // Fatura detaylarını görmek veya düzenlemek için kullanılabilir
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddInvoiceScreen(invoice: invoice)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni fatura ekleme sayfasına yönlendirir
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInvoiceScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Yeni Fatura Ekle',
      ),
    );
  }
}
