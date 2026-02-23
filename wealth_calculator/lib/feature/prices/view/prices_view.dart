import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen/gen.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_event.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_screen_cubit.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_state.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/utility/prices_screen_utils.dart';
import 'package:wealth_calculator/product/widget/PricesWidgets/build_tab.dart';
import 'package:wealth_calculator/product/widget/PricesWidgets/prices_section.dart';
import 'package:wealth_calculator/product/widget/wealth_card.dart';
import 'package:wealth_calculator/product/widget/custom_list.dart';
import 'package:wealth_calculator/product/widget/drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';

part 'widget/top_price_card.dart';
part 'widget/prices_app_bar.dart';

class PricesView extends StatefulWidget {
  const PricesView({super.key});

  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<PricesScreenCubit>().initTabController(this);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return BlocListener<PricesBloc, PricesState>(
      listener: (context, state) {
        if (state is PricesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CustomPriceDuplicateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<PricesScreenCubit, PricesScreenState>(
        builder: (context, screenState) {
          final cubit = context.read<PricesScreenCubit>();
          final showSearch = screenState.currentTabIndex != 4;

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            endDrawer: const AppDrawer(),
            body: Column(
              children: [
                // Custom AppBar with embedded search bar
                _PricesAppBar(
                  currentTabIndex: screenState.currentTabIndex,
                  onSearchChanged: (query) {
                    cubit.updateSearchQuery(query);
                  },
                  showSearchBar: showSearch,
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: cubit.tabController,
                    children: [
                      // Gold tab — with top price card
                      _buildGoldSection(context, screenState.searchQuery),
                      buildPricesSection(
                          context, 'currencyPrices', screenState.searchQuery),
                      buildPricesSection(
                          context, 'equityPrices', screenState.searchQuery),
                      buildPricesSection(
                          context, 'commodityPrices', screenState.searchQuery),
                      BlocBuilder<PricesBloc, PricesState>(
                        builder: (context, state) {
                          if (state is PricesLoaded) {
                            return CustomPricesWidget(
                              customPrices: state.customPrices,
                              onAddPressed: () =>
                                  PricesScreenUtils.onAddPressed(context),
                              query: screenState.searchQuery,
                              onDeletePrice: (WealthPrice wealthPrice) {
                                context
                                    .read<PricesBloc>()
                                    .add(DeleteCustomPrice(wealthPrice));
                              },
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.blackOverlay10.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: TabBar(
                  controller: cubit.tabController,
                  indicator: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  tabs: [
                    buildTab(Icons.monetization_on_outlined,
                        LocaleKeys.gold.tr(), context),
                    buildTab(Icons.currency_exchange, LocaleKeys.currency.tr(),
                        context),
                    buildTab(Icons.show_chart, LocaleKeys.stocks.tr(), context),
                    buildTab(Icons.diamond_outlined,
                        LocaleKeys.commodities.tr(), context),
                    buildTab(Icons.account_balance_wallet_outlined,
                        LocaleKeys.portfolio.tr(), context),
                  ],
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Gold section with the top price card followed by the grid of
  /// remaining gold prices.
  Widget _buildGoldSection(BuildContext context, String query) {
    return BlocBuilder<PricesBloc, PricesState>(
      builder: (context, state) {
        if (state is PricesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PricesError) {
          return Center(
            child: Text('${LocaleKeys.error.tr()}: ${state.message}'),
          );
        } else if (state is PricesLoaded) {
          final allGoldPrices = state.goldPrices;
          if (allGoldPrices.isEmpty) {
            return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
          }

          // Find "Gram Altın" for the top card
          final gramGoldIndex = allGoldPrices
              .indexWhere((p) => p.title.toLowerCase().contains('gram'));
          final gramGold = gramGoldIndex != -1
              ? allGoldPrices[gramGoldIndex]
              : allGoldPrices.first;

          // Build remaining list (filtered by search)
          final remainingPrices = allGoldPrices
              .where((price) =>
                  price.title.toLowerCase().contains(query.toLowerCase()))
              .toList();

          // Noop for long press (gold prices are not deletable)
          dynamic noop(WealthPrice price) => 0;

          final colorScheme = context.general.colorScheme;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Top price card for Gram Altın
                _TopPriceCard(gramGoldPrice: gramGold),
                const SizedBox(height: 20),
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    LocaleKeys.goldPrices.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Grid of remaining gold prices
                buildEquityPricesTab(remainingPrices, noop),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
        return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
      },
    );
  }
}
