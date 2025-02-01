import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_state.dart';
import 'package:wealth_calculator/utils/invoice_utils.dart';
import 'package:wealth_calculator/views/invoice_adding.dart';
import 'package:wealth_calculator/widgets/InvoiceWidgets/build_list.dart';
import 'package:wealth_calculator/widgets/InvoiceWidgets/popup_item.dart';

class InvoiceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoiceBloc()..add(LoadInvoices()),
      child: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoaded) {
            final segments =
                InvoiceUtils.calculateSegments(state.nonPaidInvoices);
            final colors = segments
                .map((segment) => InvoiceUtils.getImportanceColor(segment.key))
                .toList();
            final paidSegments =
                InvoiceUtils.calculateSegments(state.paidInvoices);
            final paidColors = paidSegments
                .map((segment) => InvoiceUtils.getImportanceColor(segment.key))
                .toList();

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: Color(0xFF2C3E50),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Faturalar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: Color(
                              0xFF2C3E50), // Background color of popup menu items
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.sort, color: Colors.white),
                        onSelected: (value) {
                          switch (value) {
                            case 'importance':
                              context
                                  .read<InvoiceBloc>()
                                  .add(SortByImportance());
                              break;
                            case 'date':
                              context.read<InvoiceBloc>().add(SortByDate());
                              break;
                            case 'amount':
                              context.read<InvoiceBloc>().add(SortByAmount());
                              break;
                            case 'amount_date':
                              context
                                  .read<InvoiceBloc>()
                                  .add(SortByAmountAndDate());
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          buildPopupMenuItem(
                              'importance', 'Önem Sırası', Icons.priority_high),
                          buildPopupMenuItem(
                              'date', 'Tarih Sırası', Icons.date_range),
                          buildPopupMenuItem(
                              'amount', 'Miktar Sırası', Icons.monetization_on),
                          buildPopupMenuItem(
                              'amount_date', 'Miktar + Tarih', Icons.sort),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  bottom: TabBar(
                    indicatorColor: Color(0xFF3498DB),
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    tabs: [
                      Tab(text: 'Ödenmemiş Faturalar'),
                      Tab(text: 'Ödenmiş Faturalar'),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<InvoiceBloc>(context),
                          child: InvoiceAddUpdateScreen(),
                        ),
                      ),
                    ).then((_) {
                      BlocProvider.of<InvoiceBloc>(context).add(LoadInvoices());
                    });
                  },
                  backgroundColor: Color.fromARGB(255, 90, 189, 255),
                  child: Icon(Icons.add, size: 32, color: Colors.white),
                ),
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2C3E50),
                        Color(0xFF3498DB),
                      ],
                    ),
                  ),
                  child: TabBarView(
                    children: [
                      buildInvoiceList(
                          context, state.nonPaidInvoices, segments, colors),
                      buildInvoiceList(context, state.paidInvoices,
                          paidSegments, paidColors),
                    ],
                  ),
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
            ),
          );
        },
      ),
    );
  }
}
