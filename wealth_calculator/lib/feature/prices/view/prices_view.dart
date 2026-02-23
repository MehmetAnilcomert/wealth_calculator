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
          final tabIdx = screenState.currentTabIndex;
          final showSearch = tabIdx != 4;

          return BlocBuilder<PricesBloc, PricesState>(
            builder: (context, pricesState) {
              // Resolve the highlighted price for the current tab
              final cardInfo = _resolveCardInfo(
                pricesState,
                tabIdx,
                colorScheme,
              );

              return Scaffold(
                backgroundColor: colorScheme.surfaceContainerLow,
                endDrawer: const AppDrawer(),
                body: Column(
                  children: [
                    // Custom AppBar with search bar + top card stacked inside
                    _PricesAppBar(
                      currentTabIndex: tabIdx,
                      onSearchChanged: (query) {
                        cubit.updateSearchQuery(query);
                      },
                      showSearchBar: showSearch,
                      highlightedPrice: cardInfo?.price,
                      iconLabel: cardInfo?.label,
                      iconColor: cardInfo?.color,
                    ),
                    // Tab content — grid only (card is in AppBar now)
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: cubit.tabController,
                        children: [
                          _buildGridSection(
                            pricesState,
                            (s) => s.goldPrices,
                            screenState.searchQuery,
                            LocaleKeys.goldPrices.tr(),
                          ),
                          _buildGridSection(
                            pricesState,
                            (s) => s.currencyPrices,
                            screenState.searchQuery,
                            LocaleKeys.currencyPrices.tr(),
                          ),
                          _buildGridSection(
                            pricesState,
                            (s) => s.equityPrices,
                            screenState.searchQuery,
                            LocaleKeys.stocksBist.tr(),
                          ),
                          _buildGridSection(
                            pricesState,
                            (s) => s.commodityPrices,
                            screenState.searchQuery,
                            LocaleKeys.commoditiesPrices.tr(),
                          ),
                          // Portfolio tab
                          _buildPortfolioSection(
                            pricesState,
                            screenState.searchQuery,
                            colorScheme,
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
                        buildTab(Icons.currency_exchange,
                            LocaleKeys.currency.tr(), context),
                        buildTab(
                            Icons.show_chart, LocaleKeys.stocks.tr(), context),
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
          );
        },
      ),
    );
  }

  // ── Card info resolver ─────────────────────────────────────────────────

  _CardInfo? _resolveCardInfo(
    PricesState state,
    int tabIdx,
    ColorScheme colorScheme,
  ) {
    if (state is! PricesLoaded || tabIdx == 4) return null;

    switch (tabIdx) {
      case 0: // Gold
        final p = _findByKeyword(state.goldPrices, 'gram');
        return p != null
            ? _CardInfo(price: p, label: 'Au', color: colorScheme.gold)
            : null;
      case 1: // Currency
        final p = _findByKeyword(state.currencyPrices, 'dolar');
        return p != null
            ? _CardInfo(price: p, label: 'USD', color: colorScheme.dollar)
            : null;
      case 2: // Stocks
        final prices = state.equityPrices;
        return prices.isNotEmpty
            ? _CardInfo(
                price: prices.first, label: 'BIST', color: colorScheme.primary)
            : null;
      case 3: // Commodities
        final p = _findByKeyword(state.commodityPrices, 'gümüş');
        return p != null
            ? _CardInfo(price: p, label: 'Ag', color: colorScheme.blueGrey)
            : null;
      default:
        return null;
    }
  }

  WealthPrice? _findByKeyword(List<WealthPrice> prices, String keyword) {
    final idx =
        prices.indexWhere((p) => p.title.toLowerCase().contains(keyword));
    return idx != -1 ? prices[idx] : (prices.isNotEmpty ? prices.first : null);
  }

  // ── Grid-only section (card is now in AppBar) ──────────────────────────

  Widget _buildGridSection(
    PricesState state,
    List<WealthPrice> Function(PricesLoaded s) selector,
    String query,
    String sectionTitle,
  ) {
    if (state is PricesLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PricesError) {
      return Center(
        child: Text('${LocaleKeys.error.tr()}: ${state.message}'),
      );
    } else if (state is PricesLoaded) {
      final allPrices = selector(state);
      if (allPrices.isEmpty) {
        return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
      }

      final filteredPrices = allPrices
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      dynamic noop(WealthPrice price) => 0;
      final colorScheme = context.general.colorScheme;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
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
            buildEquityPricesTab(filteredPrices, noop),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    return Center(child: Text(LocaleKeys.noDataAvailable.tr()));
  }

  Widget _buildPortfolioSection(
    PricesState state,
    String query,
    ColorScheme colorScheme,
  ) {
    if (state is PricesLoaded) {
      return CustomPricesWidget(
        customPrices: state.customPrices,
        onAddPressed: () => PricesScreenUtils.onAddPressed(context),
        query: query,
        onDeletePrice: (WealthPrice wealthPrice) {
          context.read<PricesBloc>().add(DeleteCustomPrice(wealthPrice));
        },
      );
    }
    return Center(
      child: CircularProgressIndicator(color: colorScheme.primary),
    );
  }
}

/// Simple data class to pass card configuration around.
class _CardInfo {
  const _CardInfo({
    required this.price,
    required this.label,
    required this.color,
  });

  final WealthPrice price;
  final String label;
  final Color color;
}
