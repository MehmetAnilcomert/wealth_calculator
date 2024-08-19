import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/views/temp_calculator.dart';
import 'package:wealth_calculator/widgets/wealthCard.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          // When tab changes, update the AppBar title
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoldPricesBloc, GoldPricesState>(
      listener: (context, state) {
        if (state is GoldPricesLoaded) {
          // GoldPrices yüklendiğinde InventoryData'yı yükleyin
          context.read<InventoryBloc>().add(LoadInventoryData());
        }
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset("images/logo2.png"),
            backgroundColor: Colors.blueGrey,
            title: Text(_getAppBarTitle(_tabController.index)),
            actions: [
              BlocBuilder<GoldPricesBloc, GoldPricesState>(
                builder: (context, state) {
                  if (state is GoldPricesLoading) {
                    return CircularProgressIndicator();
                  } else if (state is GoldPricesLoaded) {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InventoryScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.account_balance_wallet,
                              color: Colors.black),
                        ),
                      ],
                    );
                  } else if (state is GoldPricesError) {
                    return IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.error),
                      tooltip: 'Hata: ${state.message}',
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              buildPricesTab(BlocProvider.of<GoldPricesBloc>(context).state
                      is GoldPricesLoaded
                  ? (BlocProvider.of<GoldPricesBloc>(context).state
                          as GoldPricesLoaded)
                      .goldPrices
                  : []),
              buildPricesTab(BlocProvider.of<GoldPricesBloc>(context).state
                      is GoldPricesLoaded
                  ? (BlocProvider.of<GoldPricesBloc>(context).state
                          as GoldPricesLoaded)
                      .currencyPrices
                  : []),
              CalculatorScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.blueGrey,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.gpp_good), text: 'Altın'),
                Tab(icon: Icon(Icons.attach_money), text: 'Döviz'),
                Tab(icon: Icon(Icons.calculate), text: 'Hesapla'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromARGB(255, 142, 140, 140),
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Altın Fiyatları';
      case 1:
        return 'Döviz Fiyatları';
      case 2:
        return 'Hesapla';
      default:
        return 'Fiyatlar';
    }
  }
}
