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
import 'package:wealth_calculator/product/widget/custom_list.dart';
import 'package:wealth_calculator/product/widget/drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

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
    return BlocListener<PricesBloc, PricesState>(
      listener: (context, state) {
        if (state is PricesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CustomPriceDuplicateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${LocaleKeys.error.tr()}: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<PricesScreenCubit, PricesScreenState>(
        builder: (context, screenState) {
          final cubit = context.read<PricesScreenCubit>();

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Assets.images.imgLogoNoBackground.image(
                    package: "gen",
                  ),
                ),
              ),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2C3E50),
                      Color(0xFF3498DB),
                    ],
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PricesScreenUtils.getAppBarTitle(
                        screenState.currentTabIndex),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    LocaleKeys.marketData.tr(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(Icons.menu, color: Colors.white),
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            endDrawer: const AppDrawer(),
            body: Column(
              children: [
                if (screenState.currentTabIndex != 4)
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
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
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF3498DB)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: cubit.tabController,
                    children: [
                      buildPricesSection(
                          context, 'goldPrices', screenState.searchQuery),
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
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF3498DB)),
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: TabBar(
                  controller: cubit.tabController,
                  indicator: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF3498DB),
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
                  labelColor: const Color(0xFF3498DB),
                  unselectedLabelColor: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
