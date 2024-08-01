import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/bloc/Bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/views/inventory.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';
import 'package:wealth_calculator/views/invoiceList.dart';
import 'package:wealth_calculator/views/profile.dart';
import 'package:wealth_calculator/widgets/wealthCard.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fiyatlar'),
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
                        icon: Icon(Icons.cases_outlined),
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
                        icon: Icon(Icons.account_balance_wallet),
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
        body: BlocBuilder<GoldPricesBloc, GoldPricesState>(
          builder: (context, state) {
            if (state is GoldPricesLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GoldPricesError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is GoldPricesLoaded) {
              return TabBarView(
                children: [
                  buildPricesTab(state.goldPrices),
                  buildPricesTab(state.currencyPrices),
                ],
              );
            } else {
              return Center(child: Text('Unknown State'));
            }
          },
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.gpp_good), text: 'Altın'),
            Tab(icon: Icon(Icons.attach_money), text: 'Döviz'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
      ),
    );
  }
}
