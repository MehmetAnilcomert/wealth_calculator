import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_state.dart';
import 'package:wealth_calculator/services/InvoiceService.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/views/invoice_adding.dart';
import 'package:wealth_calculator/widgets/InvoiceWidgets/invoice_list.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';

class InvoiceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoiceBloc()..add(LoadInvoices()),
      child: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is InvoiceLoaded) {
            // Faturalar için segment ve renkleri hesapla
            // Calculate needed segments and colors for invoices total amounts
            final segments =
                InvoiceService.calculateSegments(state.nonPaidInvoices);
            final colors = segments
                .map(
                    (segment) => InvoiceService.getImportanceColor(segment.key))
                .toList();
            final paidSegments =
                InvoiceService.calculateSegments(state.paidInvoices);
            final paidColors = paidSegments
                .map(
                    (segment) => InvoiceService.getImportanceColor(segment.key))
                .toList();
            //--------------------------------------------------------------------------
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Faturalar'),
                  backgroundColor: Colors.blueGrey,
                  bottom: TabBar(
                    tabs: [
                      Tab(text: 'Ödenmemiş Faturalar'),
                      Tab(text: 'Ödenmiş Faturalar'),
                    ],
                    labelColor: Colors.black,
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'importance') {
                          context.read<InvoiceBloc>().add(SortByImportance());
                        } else if (value == 'date') {
                          context.read<InvoiceBloc>().add(SortByDate());
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'importance',
                          child: Text('Önem Sırası'),
                        ),
                        PopupMenuItem(
                          value: 'date',
                          child: Text('Tarih Sırası'),
                        ),
                      ],
                    ),
                  ],
                ),
                body: TabBarView(
                  children: [
                    CustomScrollView(
                      slivers: [
                        CustomSliverAppBar(
                          expandedHeight: 200.0,
                          collapsedHeight: 250,
                          flexibleSpaceBackground: TotalPrice(
                            totalPrice: segments.fold(
                                0, (sum, entry) => sum + entry.value),
                            segments:
                                segments.map((entry) => entry.value).toList(),
                            colors: colors,
                          ),
                          onAddPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: BlocProvider.of<InvoiceBloc>(context),
                                  child: InvoiceAddUpdateScreen(),
                                ),
                              ),
                            ).then((_) {
                              BlocProvider.of<InvoiceBloc>(context)
                                  .add(LoadInvoices());
                            });
                          },
                          bloc: context.read<InvoiceBloc>(),
                        ),
                        SliverFillRemaining(
                          child: InvoiceListWidget(
                            invoices: state.nonPaidInvoices,
                          ),
                        ),
                      ],
                    ),
                    CustomScrollView(
                      slivers: [
                        CustomSliverAppBar(
                          expandedHeight: 200.0,
                          collapsedHeight: 250,
                          flexibleSpaceBackground: TotalPrice(
                            totalPrice: paidSegments.fold(
                                0, (sum, entry) => sum + entry.value),
                            segments: paidSegments
                                .map((entry) => entry.value)
                                .toList(),
                            colors: paidColors,
                          ),
                          onAddPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: BlocProvider.of<InvoiceBloc>(context),
                                  child: InvoiceAddUpdateScreen(),
                                ),
                              ),
                            ).then((_) {
                              BlocProvider.of<InvoiceBloc>(context)
                                  .add(LoadInvoices());
                            });
                          },
                          bloc: context.read<InvoiceBloc>(),
                        ),
                        SliverFillRemaining(
                          child:
                              InvoiceListWidget(invoices: state.paidInvoices),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
