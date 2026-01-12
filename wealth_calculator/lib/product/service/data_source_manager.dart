import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_source_strategy.dart';
import 'package:wealth_calculator/product/service/firebase_data_service.dart';

/// Veri kaynağı yöneticisi
/// Strategy pattern ile farklı veri kaynaklarını yönetir
class DataSourceManager {
  static final DataSourceManager _instance = DataSourceManager._internal();
  factory DataSourceManager() => _instance;
  DataSourceManager._internal();

  // Aktif veri kaynağı stratejisi
  DataSourceStrategy _strategy = FirebaseDataService();

  /// Veri kaynağı stratejisini değiştirir
  void setStrategy(DataSourceStrategy strategy) {
    _strategy = strategy;
  }

  /// Aktif stratejiyi döndürür
  DataSourceStrategy get strategy => _strategy;

  // Veri çekme metodları
  Future<List<WealthPrice>> fetchGoldPrices() => _strategy.fetchGoldPrices();
  Future<List<WealthPrice>> fetchCurrencyPrices() =>
      _strategy.fetchCurrencyPrices();
  Future<List<WealthPrice>> fetchCommodityPrices() =>
      _strategy.fetchCommodityPrices();
  Future<List<WealthPrice>> fetchEquityData() => _strategy.fetchEquityData();
}
