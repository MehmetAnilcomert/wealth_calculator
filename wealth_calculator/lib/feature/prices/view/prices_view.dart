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

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.whiteOverlay20),
                    ),
                    child: Assets.images.imgLogoNoBackground.image(
                      package: "gen",
                    ),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.gradientStart,
                        colorScheme.gradientEnd,
                      ],
                    ),
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PricesScreenUtils.getAppBarTitle(
                          screenState.currentTabIndex),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      LocaleKeys.marketData.tr(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                actions: [
                  BlocBuilder<PricesBloc, PricesState>(
                    builder: (context, state) {
                      if (state is PricesLoading) {
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      return IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.whiteOverlay20,
                          ),
                          child: Icon(Icons.menu,
                              color: colorScheme.onPrimaryContainer),
                        ),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            endDrawer: const AppDrawer(),
            body: Column(
              children: [
                // Search bar — visible on all tabs except portfolio (index 4)
                if (screenState.currentTabIndex != 4)
                  _buildSearchBar(context, cubit, colorScheme),
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

  /// Overlapping-style search bar matching the reference design
  Widget _buildSearchBar(
    BuildContext context,
    PricesScreenCubit cubit,
    ColorScheme colorScheme,
  ) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colorScheme.blackOverlay10.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (query) {
            cubit.updateSearchQuery(query);
          },
          decoration: InputDecoration(
            hintText: LocaleKeys.search.tr(),
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
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
                // "Popular Commodities" section header
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
