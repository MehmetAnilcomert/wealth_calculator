import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/custom_sliver_appbar.dart';
import 'package:wealth_calculator/product/widget/CommonWidgets/total_price.dart';
import 'package:wealth_calculator/product/widget/InvoiceWidgets/invoice_list.dart';

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
