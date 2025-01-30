import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/bloc/PricesBloc/PricesState.dart';
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/CustomListDao.dart';
import 'package:wealth_calculator/widgets/PricesWidgets/prices_section.dart';
import 'package:wealth_calculator/widgets/custom_list.dart';
import 'package:wealth_calculator/widgets/drawer.dart';
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
        backgroundColor: Color(0xFFF5F7FA),
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
            decoration: BoxDecoration(
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
                _getAppBarTitle(_tabController.index),
                style: TextStyle(
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
                  return Center(
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
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(Icons.menu, color: Colors.white),
                  ),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        endDrawer: const AppDrawer(),
        body: Column(
          children: [
            if (_tabController.index != 4)
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
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
                        _customListDao.deleteWealthPrice(wealthPrice.title);
                      });
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
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF3498DB),
                    width: 3,
                  ),
                ),
              ),
              tabs: [
                _buildTab(Icons.monetization_on_outlined, 'Altın'),
                _buildTab(Icons.currency_exchange, 'Döviz'),
                _buildTab(Icons.show_chart, 'Hisse'),
                _buildTab(Icons.diamond_outlined, 'Emtia'),
                _buildTab(Icons.account_balance_wallet_outlined, 'Portföy'),
              ],
              labelColor: Color(0xFF3498DB),
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      icon: Icon(icon, size: 24),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
