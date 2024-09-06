import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/CustomListDao.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';
import 'package:wealth_calculator/widgets/PricesWidgets/prices_section.dart';
import 'package:wealth_calculator/widgets/custom_list.dart';
import 'package:wealth_calculator/widgets/multi_item.dart';
import 'package:collection/collection.dart';

class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<WealthPrice> _customPrices = [];
  final CustomListDao _customListDao = CustomListDao();

  @override
  void initState() {
    super.initState();
    _loadCustomPrices().then((_) {
      _updateCustomPricesWithLatest(); // Custom prices listesini güncelle
    });
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  Future<void> _loadCustomPrices() async {
    try {
      final prices = await _customListDao.getWealthPrices();
      setState(() {
        _customPrices = prices;
      });
    } catch (e) {
      print('Error loading custom prices: $e');
    }
  }

  Future<void> _updateCustomPricesWithLatest() async {
    try {
      // Veritabanındaki customPrices listesini al
      final prices = await _customListDao.getWealthPrices();
      if (context.read<PricesBloc>().state is PricesLoaded) {
        final pricesState = context.read<PricesBloc>().state as PricesLoaded;

        // Güncel fiyatları al
        final List<WealthPrice> updatedCustomPrices = [];

        for (WealthPrice wealthPrice in prices) {
          // Altın fiyatlarını eşleştir
          WealthPrice? updatedPrice = pricesState.goldPrices
              .firstWhereOrNull((price) => price.title == wealthPrice.title);

          // Eğer altın fiyatları arasında yoksa döviz fiyatlarını kontrol et
          if (updatedPrice == null) {
            updatedPrice = pricesState.currencyPrices
                .firstWhereOrNull((price) => price.title == wealthPrice.title);
          }

          // Eğer döviz fiyatları arasında yoksa borsa fiyatlarını kontrol et
          if (updatedPrice == null) {
            updatedPrice = pricesState.equityPrices
                .firstWhereOrNull((price) => price.title == wealthPrice.title);
          }

          // Eğer döviz fiyatları arasında yoksa borsa fiyatlarını kontrol et
          if (updatedPrice == null) {
            updatedPrice = pricesState.commodityPrices
                .firstWhereOrNull((price) => price.title == wealthPrice.title);
          }
          // Eşleşen fiyat varsa listeye ekle, yoksa eski fiyatla devam et
          updatedCustomPrices.add(updatedPrice ?? wealthPrice);
        }

        // Güncellenen listeyi state'e ve veritabanına kaydet
        setState(() {
          _customPrices = updatedCustomPrices;
        });

        // Veritabanını güncelle
        await _customListDao.updateWealthPrices(updatedCustomPrices);
      }
    } catch (e) {
      print('Error updating custom prices: $e');
    }
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
      'Emtia',
      'Kişisel Portföy',
    ];
    return titles[index.clamp(0, 6)];
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onAddPressed() {
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
      context.read<PricesBloc>().state is PricesLoaded
          ? (context.read<PricesBloc>().state as PricesLoaded).commodityPrices
          : [],
      (List<WealthPrice> selectedWealths) {
        setState(() {
          for (WealthPrice wealthPrice in selectedWealths) {
            if (!_customPrices.contains(wealthPrice)) {
              _customPrices.add(wealthPrice);
              _customListDao.insertWealthPrice(wealthPrice);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${wealthPrice.title} zaten listede mevcut.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
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
                  buildPricesSection(context, 'commodityPrices', _searchQuery),
                  CustomPricesWidget(
                    customPrices: _customPrices,
                    onAddPressed: _onAddPressed,
                    query: _searchQuery,
                    onDeletePrice: (WealthPrice wealthPrice) {
                      setState(() {
                        _customPrices.remove(wealthPrice);
                        _customListDao.deleteWealthPrice(
                            wealthPrice.title); // Veritabanından silme
                      });
                    },
                  ),
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
              Tab(icon: Icon(Icons.oil_barrel), text: 'Emtia'),
              Tab(icon: Icon(Icons.dashboard_customize), text: 'Portföy'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 142, 140, 140),
          ),
        ),
      ),
    );
  }
}
