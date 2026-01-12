import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Veri kaynağı stratejisi için abstract sınıf
/// Farklı veri kaynaklarını (Firebase, REST API, Cache vb.) implement edebilir
abstract class DataSourceStrategy {
  Future<List<WealthPrice>> fetchGoldPrices();
  Future<List<WealthPrice>> fetchCurrencyPrices();
  Future<List<WealthPrice>> fetchCommodityPrices();
  Future<List<WealthPrice>> fetchEquityData();
}
