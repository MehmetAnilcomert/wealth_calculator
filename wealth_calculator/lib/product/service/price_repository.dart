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
    // Pre-populate memory cache from DB if empty, to allow partial updates without losing cached data
    if (_goldPrices.isEmpty &&
        _currencyPrices.isEmpty &&
        _equityPrices.isEmpty &&
        _commodityPrices.isEmpty) {
      await _loadFromDatabase();
    }

    try {
      final results = await Future.wait([
        _dataScrapingService.fetchGoldPrices().catchError((e) {
          debugPrint('PriceRepository: Gold prices fetch failed: $e');
          return <WealthPrice>[];
        }),
        _dataScrapingService.fetchCurrencyPrices().catchError((e) {
          debugPrint('PriceRepository: Currency prices fetch failed: $e');
          return <WealthPrice>[];
        }),
        _dataScrapingService.fetchEquityData().catchError((e) {
          debugPrint('PriceRepository: Equity data fetch failed: $e');
          return <WealthPrice>[];
        }),
        _dataScrapingService.fetchCommodityPrices().catchError((e) {
          debugPrint('PriceRepository: Commodity prices fetch failed: $e');
          return <WealthPrice>[];
        }),
      ]);

      final fetchedGold = results[0];
      final fetchedCurrency = results[1];
      final fetchedEquity = results[2];
      final fetchedCommodity = results[3];

      // Update memory cache only with successfully fetched data
      if (fetchedGold.isNotEmpty) _goldPrices = fetchedGold;
      if (fetchedCurrency.isNotEmpty) _currencyPrices = fetchedCurrency;
      if (fetchedEquity.isNotEmpty) _equityPrices = fetchedEquity;
      if (fetchedCommodity.isNotEmpty) _commodityPrices = fetchedCommodity;

      // If all scrapers failed and memory cache is still empty, throw to trigger fallback
      if (_goldPrices.isEmpty &&
          _currencyPrices.isEmpty &&
          _equityPrices.isEmpty &&
          _commodityPrices.isEmpty) {
        throw Exception('All scrapers failed and no offline cached data is available.');
      }

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

    // Extract the latest update time from all records to be accurate
    DateTime? latestTime;
    for (var p in allPrices) {
      if (p.lastUpdatedDate != null && p.lastUpdatedTime != null) {
        final parsed = DateTime.tryParse('${p.lastUpdatedDate}T${p.lastUpdatedTime}');
        if (parsed != null && (latestTime == null || parsed.isAfter(latestTime))) {
          latestTime = parsed;
        }
      }
    }
    _lastUpdatedAt = latestTime;

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
