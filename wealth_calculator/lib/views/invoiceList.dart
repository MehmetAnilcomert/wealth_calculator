import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/invoice/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/invoice/invoice_event.dart';
import 'package:wealth_calculator/bloc/Bloc/invoice/invoice_state.dart';
import 'package:wealth_calculator/services/InvoiceService.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/TotalPrice.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';
import 'package:wealth_calculator/widgets/InvoiceWidgets/invoice_list.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';

class FaturaListesi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvoiceBloc()..add(LoadFaturalar()),
      child: BlocConsumer<InvoiceBloc, FaturaState>(
        listener: (context, state) {
          if (state is FaturaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is FaturaLoaded) {
            // Faturalar için segment ve renkleri hesapla
            // Calculate needed segments and colors for invoices total amounts
            final segments =
                InvoiceService.calculateSegments(state.odememisFaturalar);
            final colors = segments
                .map(
                    (segment) => InvoiceService.getImportanceColor(segment.key))
                .toList();
            final paidSegments =
                InvoiceService.calculateSegments(state.odenmisFaturalar);
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
                                  child: FaturaEklemeGuncellemeEkrani(),
                                ),
                              ),
                            ).then((_) {
                              BlocProvider.of<InvoiceBloc>(context)
                                  .add(LoadFaturalar());
                            });
                          },
                          bloc: context.read<InvoiceBloc>(),
                        ),
                        SliverFillRemaining(
                          child: InvoiceListWidget(
                              faturalar: state.odememisFaturalar),
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
                                  child: FaturaEklemeGuncellemeEkrani(),
                                ),
                              ),
                            ).then((_) {
                              BlocProvider.of<InvoiceBloc>(context)
                                  .add(LoadFaturalar());
                            });
                          },
                          bloc: context.read<InvoiceBloc>(),
                        ),
                        SliverFillRemaining(
                          child: InvoiceListWidget(
                              faturalar: state.odenmisFaturalar),
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
