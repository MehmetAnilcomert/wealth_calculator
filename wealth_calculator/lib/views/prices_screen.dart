import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/utils/prices_screen_utils.dart';
import 'package:wealth_calculator/widgets/PricesWidgets/buildTab.dart';
import 'package:wealth_calculator/widgets/PricesWidgets/prices_section.dart';
import 'package:wealth_calculator/widgets/custom_list.dart';
import 'package:wealth_calculator/widgets/drawer.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Bloc üzerinden tüm fiyatları (web ve custom) yükle
    context.read<PricesBloc>().add(LoadPrices());
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // AppBar başlığını güncellemek için yeniden çizdiriyoruz
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PricesBloc, PricesState>(
      listener: (context, state) {
        if (state is PricesLoaded) {
          context.read<InventoryBloc>().add(LoadInventoryData());
        } else if (state is PricesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CustomPriceDuplicateError) {
          // If there is already that price in the list, shows a snackbar to warn the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Image.asset("images/logo2.png"),
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
                PricesScreenUtils.getAppBarTitle(_tabController.index),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Güncel Piyasa Verileri',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }
                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
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
            if (_tabController.index != 4)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Ara...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  buildPricesSection(context, 'goldPrices', _searchQuery),
                  buildPricesSection(context, 'currencyPrices', _searchQuery),
                  buildPricesSection(context, 'equityPrices', _searchQuery),
                  buildPricesSection(context, 'commodityPrices', _searchQuery),
                  BlocBuilder<PricesBloc, PricesState>(
                    builder: (context, state) {
                      if (state is PricesLoaded) {
                        return CustomPricesWidget(
                          customPrices: state.customPrices,
                          onAddPressed: () =>
                              PricesScreenUtils.onAddPressed(context),
                          query: _searchQuery,
                          onDeletePrice: (WealthPrice wealthPrice) {
                            context
                                .read<PricesBloc>()
                                .add(DeleteCustomPrice(wealthPrice));
                          },
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF3498DB),
                    width: 3,
                  ),
                ),
              ),
              tabs: [
                buildTab(Icons.monetization_on_outlined, 'Altın'),
                buildTab(Icons.currency_exchange, 'Döviz'),
                buildTab(Icons.show_chart, 'Hisse'),
                buildTab(Icons.diamond_outlined, 'Emtia'),
                buildTab(Icons.account_balance_wallet_outlined, 'Portföy'),
              ],
              labelColor: const Color(0xFF3498DB),
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
