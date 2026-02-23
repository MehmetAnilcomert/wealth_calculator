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
                      // Gold tab
                      _buildSectionWithCard(
                        context: context,
                        query: screenState.searchQuery,
                        priceListSelector: (s) => s.goldPrices,
                        highlightFinder: (prices) =>
                            _findByKeyword(prices, 'gram'),
                        iconLabel: 'Au',
                        iconColor: colorScheme.gold,
                        sectionTitle: LocaleKeys.goldPrices.tr(),
                      ),
                      // Currency tab
                      _buildSectionWithCard(
                        context: context,
                        query: screenState.searchQuery,
                        priceListSelector: (s) => s.currencyPrices,
                        highlightFinder: (prices) =>
                            _findByKeyword(prices, 'dolar'),
                        iconLabel: 'USD',
                        iconColor: colorScheme.dollar,
                        sectionTitle: LocaleKeys.currencyPrices.tr(),
                      ),
                      // Stocks tab
                      _buildSectionWithCard(
                        context: context,
                        query: screenState.searchQuery,
                        priceListSelector: (s) => s.equityPrices,
                        highlightFinder: (prices) =>
                            prices.isNotEmpty ? prices.first : null,
                        iconLabel: 'BIST',
                        iconColor: colorScheme.primary,
                        sectionTitle: LocaleKeys.stocksBist.tr(),
                      ),
                      // Commodities tab
                      _buildSectionWithCard(
                        context: context,
                        query: screenState.searchQuery,
                        priceListSelector: (s) => s.commodityPrices,
                        highlightFinder: (prices) =>
                            _findByKeyword(prices, 'gümüş'),
                        iconLabel: 'Ag',
                        iconColor: colorScheme.blueGrey,
                        sectionTitle: LocaleKeys.commoditiesPrices.tr(),
                      ),
                      // Portfolio tab
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

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Find a price by keyword in the title. Returns null if not found.
  WealthPrice? _findByKeyword(List<WealthPrice> prices, String keyword) {
    final idx =
        prices.indexWhere((p) => p.title.toLowerCase().contains(keyword));
    return idx != -1 ? prices[idx] : (prices.isNotEmpty ? prices.first : null);
  }

  /// Generic section builder: top card + grid list.
  /// Works for Gold, Currency, Stocks, Commodities tabs.
  Widget _buildSectionWithCard({
    required BuildContext context,
    required String query,
    required List<WealthPrice> Function(PricesLoaded state) priceListSelector,
    required WealthPrice? Function(List<WealthPrice> prices) highlightFinder,
    required String iconLabel,
    required Color iconColor,
    required String sectionTitle,
  }) {
    return BlocBuilder<PricesBloc, PricesState>(
      builder: (context, state) {
        if (state is PricesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PricesError) {
          return Center(
            child: Text('${LocaleKeys.error.tr()}: ${state.message}'),
          );
        } else if (state is PricesLoaded) {
          final allPrices = priceListSelector(state);
          if (allPrices.isEmpty) {
            return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
          }

          final highlighted = highlightFinder(allPrices);

          // Filtered list for grid
          final filteredPrices = allPrices
              .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
              .toList();

          dynamic noop(WealthPrice price) => 0;
          final colorScheme = context.general.colorScheme;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Highlighted top card
                if (highlighted != null)
                  _TopPriceCard(
                    price: highlighted,
                    iconLabel: iconLabel,
                    iconColor: iconColor,
                  ),
                const SizedBox(height: 20),
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Grid of prices
                buildEquityPricesTab(filteredPrices, noop),
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
