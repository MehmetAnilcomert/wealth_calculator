import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/views/temp_calculator.dart';
import 'package:wealth_calculator/widgets/PricesWidgets/prices_section.dart';
import 'package:wealth_calculator/widgets/custom_list.dart';
import 'package:wealth_calculator/widgets/wealth_card.dart';
import 'package:wealth_calculator/widgets/multi_item.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<WealthPrice> _customPrices = [];

  @override
  void initState() {
    super.initState();
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
        // Trigger a rebuild to update the AppBar title
      });
    }
  }

  String _getAppBarTitle(int index) {
    final titles = [
      'Altın Fiyatları',
      'Döviz Fiyatları',
      'Bist100 Endeksi',
      'Kişisel Portföy',
      'Varlık Hesaplayıcı'
    ];
    return titles[index.clamp(0, 4)];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onAddPressed() {
    // Multi-seçim yapılmasını sağlayan dialog çağırılır
    MultiItemDialogs.showMultiSelectItemDialog(
      context,
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).goldPrices
          : [],
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).currencyPrices
          : [],
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).equityPrices
          : [],
      (List<WealthPrice> selectedWealths) {
        setState(() {
          _customPrices.addAll(selectedWealths);
          selectedWealths = _customPrices; // Debugging
        });
      },
      hiddenItems: [
        'Altın (ONS/\$)',
        'Altın (\$/kg)',
        'Altın (Euro/kg)',
        'Külçe Altın (\$)',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PricesBloc, PricesState>(
      listener: (context, state) {
        if (state is PricesLoaded) {
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
            BlocBuilder<PricesBloc, PricesState>(
              builder: (context, state) {
                if (state is PricesLoading) {
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
                          if (context.read<PricesBloc>().state
                              is PricesLoaded) {
                            final goldPricesState = context
                                .read<PricesBloc>()
                                .state as PricesLoaded;
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
        body: Column(
          children: [
            _tabController.index == 4
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
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
                  buildPricesSection(context, 'goldPrices', _searchQuery),
                  buildPricesSection(context, 'currencyPrices', _searchQuery),
                  buildPricesSection(context, 'equityPrices', _searchQuery),
                  CustomPricesWidget(
                    customPrices: _customPrices,
                    onAddPressed: _onAddPressed,
                    query: _searchQuery,
                  ),
                  CalculatorScreen(),
                ],
              ),
            ),
          ],
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
              Tab(icon: Icon(Icons.dashboard_customize), text: 'Kişisel'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 142, 140, 140),
          ),
        ),
      ),
    );
  }
}
