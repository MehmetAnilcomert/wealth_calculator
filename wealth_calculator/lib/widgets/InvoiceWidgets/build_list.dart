import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/widgets/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/widgets/InvoiceWidgets/invoice_list.dart';

Widget buildInvoiceList(BuildContext context, List<Invoice> invoices,
    List<MapEntry<OnemSeviyesi, double>> segments, List<Color> colors) {
  return CustomScrollView(
    slivers: [
      CustomSliverAppBar(
        expandedHeight: 220.0,
        collapsedHeight: 280,
        flexibleSpaceBackground: TotalPrice(
          totalPrice: segments.fold(0, (sum, entry) => sum + entry.value),
          segments: segments.map((entry) => entry.value).toList(),
          colors: colors,
        ),
        onAddPressed: () {},
        bloc: context.read<InvoiceBloc>(),
      ),
      SliverFillRemaining(
        child: InvoiceListWidget(invoices: invoices),
      ),
    ],
  );
}
