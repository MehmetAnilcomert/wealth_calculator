import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/views/temp_calculator.dart';
import 'package:wealth_calculator/widgets/equity_card.dart';
import 'package:wealth_calculator/widgets/wealthCard.dart';
import 'package:wealth_calculator/modals/EquityModal.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Trigger a rebuild to update the AppBar title
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  String _getAppBarTitle(int index) {
    final titles = [
      'Altın Fiyatları',
      'Döviz Fiyatları',
      'Bist100 Endeksi',
      'Varlık Hesaplayıcı'
    ];
    return titles[index.clamp(0, 3)];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoldPricesBloc, GoldPricesState>(
      listener: (context, state) {
        if (state is GoldPricesLoaded) {
          context.read<InventoryBloc>().add(LoadInventoryData());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset("images/logo2.png"),
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
          title: Text(
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold),
              _getAppBarTitle(_tabController.index)),
          actions: [
            BlocBuilder<GoldPricesBloc, GoldPricesState>(
              builder: (context, state) {
                if (state is GoldPricesLoading) {
                  return CircularProgressIndicator();
                } else {
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceListScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.cases_outlined,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (context.read<GoldPricesBloc>().state
                              is GoldPricesLoaded) {
                            final goldPricesState = context
                                .read<GoldPricesBloc>()
                                .state as GoldPricesLoaded;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<InventoryBloc>()
                                    ..add(LoadInventoryData(
                                      goldPrices: goldPricesState.goldPrices,
                                      currencyPrices:
                                          goldPricesState.currencyPrices,
                                    )),
                                  child: InventoryScreen(),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Envanter verileri yüklenemedi.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.account_balance_wallet,
                            color: Colors.black),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<GoldPricesBloc, GoldPricesState>(
          builder: (context, state) {
            if (state is GoldPricesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veriler yüklenemedi:',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    Text(
                      'İnternet bağlantınızı kontrol edin',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            final goldPrices = (state is GoldPricesLoaded)
                ? (state as GoldPricesLoaded)
                    .goldPrices
                    .map((dynamic item) => item as WealthPrice)
                    .toList()
                : [];
            final currencyPrices = (state is GoldPricesLoaded)
                ? (state as GoldPricesLoaded)
                    .currencyPrices
                    .map((dynamic item) => item as WealthPrice)
                    .toList()
                : [];
            final equityPrices = (state is GoldPricesLoaded)
                ? (state as GoldPricesLoaded)
                    .equityPrices
                    .map((dynamic item) => item as Equity)
                    .toList()
                : [];

            return Column(
              children: [
                _tabController.index == 3
                    ? SizedBox()
                    : Padding(
                        padding:
                            const EdgeInsets.only(left: 4.0, right: 4, top: 4),
                        child: TextField(
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blueGrey,
                            hintText: 'Ara...',
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                      ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      buildPricesTab(goldPrices
                          .where((price) => price.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList()),
                      buildPricesTab(currencyPrices
                          .where((price) => price.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList()),
                      buildEquityPricesTab(equityPrices
                          .where((equity) => equity.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList()),
                      CalculatorScreen(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          color: Colors.blueGrey,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.gpp_good), text: 'Altın'),
              Tab(icon: Icon(Icons.attach_money), text: 'Döviz'),
              Tab(icon: Icon(Icons.equalizer), text: 'Hisse'),
              Tab(icon: Icon(Icons.calculate), text: 'Hesapla'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 142, 140, 140),
          ),
        ),
      ),
    );
  }
}
