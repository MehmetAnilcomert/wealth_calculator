import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_state.dart';
import 'package:wealth_calculator/feature/invoice/view/invoice_adding_view.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/product/utility/invoice_utils.dart';
import 'package:wealth_calculator/product/widget/InvoiceWidgets/build_list.dart';
import 'package:wealth_calculator/product/widget/InvoiceWidgets/popup_item.dart';

class InvoiceView extends StatelessWidget {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => InvoiceBloc()..add(LoadInvoices()),
      child: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.error}: ${state.message}'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
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
                backgroundColor: const Color(0xFF2C3E50),
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    l10n.invoice,
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
                          color: const Color(0xFF2C3E50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.sort, color: Colors.white),
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
                          buildPopupMenuItem('importance', l10n.priorities,
                              Icons.priority_high),
                          buildPopupMenuItem(
                              'date', l10n.sortByDate, Icons.date_range),
                          buildPopupMenuItem('amount', l10n.sortByAmount,
                              Icons.monetization_on),
                          buildPopupMenuItem('amount_date',
                              '${l10n.amount} + ${l10n.date}', Icons.sort),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: TabBar(
                    indicatorColor: const Color(0xFF3498DB),
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    tabs: [
                      Tab(text: l10n.unpaidInvoices),
                      Tab(text: l10n.paidInvoices),
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
                          child: InvoiceAddingView(),
                        ),
                      ),
                    ).then((_) {
                      BlocProvider.of<InvoiceBloc>(context).add(LoadInvoices());
                    });
                  },
                  backgroundColor: const Color.fromARGB(255, 90, 189, 255),
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
                body: Container(
                  decoration: const BoxDecoration(
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
