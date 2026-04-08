import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_scraping.dart' as scraping;

/// Service for scraping wealth price data from external sources.
/// 
/// Refactored from global functions to allow for dependency injection and mocking in tests.
class DataScrapingService {
  Future<List<WealthPrice>> fetchGoldPrices() => scraping.fetchGoldPrices();
  Future<List<WealthPrice>> fetchCurrencyPrices() => scraping.fetchCurrencyPrices();
  Future<List<WealthPrice>> fetchCommodityPrices() => scraping.fetchCommodityPrices();
  Future<List<WealthPrice>> fetchEquityData() => scraping.fetchEquityData();
}
