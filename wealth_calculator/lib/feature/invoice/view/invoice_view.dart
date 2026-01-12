import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_state.dart';
import 'package:wealth_calculator/feature/invoice_form/view/invoice_adding_view.dart';
import 'package:wealth_calculator/product/utility/invoice_utils.dart';
import 'package:wealth_calculator/product/widget/InvoiceWidgets/build_list.dart';
import 'package:wealth_calculator/product/widget/InvoiceWidgets/popup_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

class InvoiceView extends StatelessWidget {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return BlocProvider(
      create: (context) => InvoiceBloc()..add(LoadInvoices()),
      child: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
                backgroundColor: colorScheme.deleteBackground,
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
                backgroundColor: colorScheme.primaryContainer,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: colorScheme.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: colorScheme.onPrimaryContainer),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    LocaleKeys.invoice.tr(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        popupMenuTheme: PopupMenuThemeData(
                          color: colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.sort,
                            color: colorScheme.onPrimaryContainer),
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
                              'importance',
                              LocaleKeys.priorities.tr(),
                              Icons.priority_high,
                              context),
                          buildPopupMenuItem('date', LocaleKeys.sortByDate.tr(),
                              Icons.date_range, context),
                          buildPopupMenuItem(
                              'amount',
                              LocaleKeys.sortByAmount.tr(),
                              Icons.monetization_on,
                              context),
                          buildPopupMenuItem(
                              'amount_date',
                              '${LocaleKeys.amount_pure.tr()} + ${LocaleKeys.date.tr()}',
                              Icons.sort,
                              context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  bottom: TabBar(
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    labelColor: colorScheme.onPrimaryContainer,
                    unselectedLabelColor:
                        colorScheme.onPrimaryContainer.withAlpha(153),
                    tabs: [
                      Tab(text: LocaleKeys.unpaidInvoices.tr()),
                      Tab(text: LocaleKeys.paidInvoices.tr()),
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
                          child: const InvoiceAddingView(),
                        ),
                      ),
                    ).then((_) {
                      BlocProvider.of<InvoiceBloc>(context).add(LoadInvoices());
                    });
                  },
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(Icons.add,
                      size: 32, color: colorScheme.onSecondaryContainer),
                ),
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.gradientStart,
                        colorScheme.gradientEnd,
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
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          );
        },
      ),
    );
  }
}
