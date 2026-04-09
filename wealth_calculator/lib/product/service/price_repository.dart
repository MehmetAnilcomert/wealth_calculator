import 'package:flutter/foundation.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_scraping_service.dart';
import 'package:wealth_calculator/product/service/wealth_prices_dao.dart';

/// Central repository for managing all wealth price data.
/// Handles caching, database synchronization, and offline fallback.
class PriceRepository {
  PriceRepository({
    required DataScrapingService dataScrapingService,
    required WealthPricesDao wealthPricesDao,
  })  : _dataScrapingService = dataScrapingService,
        _wealthPricesDao = wealthPricesDao;

  final DataScrapingService _dataScrapingService;
  final WealthPricesDao _wealthPricesDao;

  // In-memory cache
  List<WealthPrice> _goldPrices = [];
  List<WealthPrice> _currencyPrices = [];
  List<WealthPrice> _equityPrices = [];
  List<WealthPrice> _commodityPrices = [];

  DateTime? _lastUpdatedAt;
  bool _isFromCache = false;

  // Getters
  List<WealthPrice> get goldPrices => _goldPrices;
  List<WealthPrice> get currencyPrices => _currencyPrices;
  List<WealthPrice> get equityPrices => _equityPrices;
  List<WealthPrice> get commodityPrices => _commodityPrices;
  DateTime? get lastUpdatedAt => _lastUpdatedAt;
  bool get isFromCache => _isFromCache;

  /// Initialize the repository by loading data. 
  /// Tries internet first, falls back to DB.
  Future<void> init() async {
    await refresh();
  }

  /// Forces a fresh fetch from the internet. 
  /// Updates memory cache and database on success.
  /// On failure, loads from database.
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _dataScrapingService.fetchGoldPrices(),
        _dataScrapingService.fetchCurrencyPrices(),
        _dataScrapingService.fetchEquityData(),
        _dataScrapingService.fetchCommodityPrices(),
      ]);

      _goldPrices = results[0];
      _currencyPrices = results[1];
      _equityPrices = results[2];
      _commodityPrices = results[3];

      // Perform complex calculations (like Silver Gram TL)
      _processSpecialPrices();

      // Combine and save to DB
      final allPrices = [
        ..._goldPrices,
        ..._currencyPrices,
        ..._equityPrices,
        ..._commodityPrices,
      ];
      await _wealthPricesDao.insertPrices(allPrices);

      _lastUpdatedAt = DateTime.now();
      _isFromCache = false;
    } catch (e) {
      debugPrint('PriceRepository: Fetch failed, falling back to DB: $e');
      await _loadFromDatabase();
    }
  }

  Future<void> _loadFromDatabase() async {
    final allPrices = await _wealthPricesDao.getAllPrices();
    
    if (allPrices.isEmpty) return;

    _goldPrices = allPrices.where((p) => p.type == PriceType.gold).toList();
    _currencyPrices = allPrices.where((p) => p.type == PriceType.currency).toList();
    _equityPrices = allPrices.where((p) => p.type == PriceType.equity).toList();
    _commodityPrices = allPrices.where((p) => p.type == PriceType.commodity).toList();

    // Extract last update time from the first record if available
    final firstRecord = allPrices.first;
    if (firstRecord.lastUpdatedDate != null && firstRecord.lastUpdatedTime != null) {
      _lastUpdatedAt = DateTime.tryParse('${firstRecord.lastUpdatedDate}T${firstRecord.lastUpdatedTime}');
    }

    _isFromCache = true;
  }

  /// Handles special derived prices like Silver (Ounce to Gram TL conversion)
  void _processSpecialPrices() {
    // 1. Find USD rate for conversion
    final usdPrice = _currencyPrices.firstWhere(
      (p) => p.title.toLowerCase().contains('dolar'),
      orElse: () => WealthPrice(
          title: 'USD',
          buyingPrice: '1',
          sellingPrice: '1',
          change: '',
          time: '',
          type: PriceType.currency),
    );

    double usdRate = double.tryParse(
            usdPrice.sellingPrice.replaceAll('.', '').replaceAll(',', '.')) ??
        1.0;

    // 2. Convert Silver Ounce to Gram TL
    const double ounceToGram = 31.1034768;
    int silverIdx = _commodityPrices.indexWhere((p) => p.title.toLowerCase().contains('gümüş'));

    if (silverIdx != -1) {
      final silver = _commodityPrices[silverIdx];
      // Note: currentPrice is used for commodities in this app's logic
      double ouncePrice = double.tryParse(
              silver.currentPrice?.replaceAll('.', '').replaceAll(',', '.') ??
                  '') ??
          0.0;

      if (ouncePrice > 0) {
        double gramTL = (ouncePrice * usdRate) / ounceToGram;
        String gramTLStr = gramTL.toStringAsFixed(2).replaceAll('.', ',');

        _commodityPrices[silverIdx] = silver.copyWith(
          title: 'Gümüş (TL/GR)',
          buyingPrice: gramTLStr,
          sellingPrice: gramTLStr,
          currentPrice: gramTLStr,
        );
      }
    }
  }
}
