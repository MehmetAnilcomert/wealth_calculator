import 'package:flutter/material.dart';
import 'package:wealth_calculator/views/invoiceDetail.dart';

class InvoiceListScreen extends StatefulWidget {
  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Map<String, dynamic>> invoices = [
    {
      'id': 1,
      'amount': 150.0,
      'category': 'Elektrik',
      'is_paid': false,
      'priority': 'Yüksek Önemde'
    },
    {
      'id': 2,
      'amount': 200.0,
      'category': 'Su',
      'is_paid': true,
      'priority': 'Orta Önemde'
    },
    // Diğer faturalar
  ];

  void _togglePaidStatus(int id) {
    setState(() {
      final invoice = invoices.firstWhere((inv) => inv['id'] == id);
      invoice['is_paid'] = !invoice['is_paid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Faturalar')),
      body: ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return ListTile(
            title: Text('${invoice['category']} - ${invoice['amount']} TL'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ödendi: ${invoice['is_paid'] ? 'Evet' : 'Hayır'}'),
                Text('Önem Sırası: ${invoice['priority']}'),
              ],
            ),
            trailing: Checkbox(
              value: invoice['is_paid'],
              onChanged: (bool? value) {
                _togglePaidStatus(invoice['id']);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceDetailScreen(invoice: invoice),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
