import 'package:http/http.dart' as http;
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_scraping.dart' as scraping;

/// Service for scraping wealth price data from external sources.
/// 
/// Refactored from global functions to allow for dependency injection and mocking in tests.
/// Accepts an optional [http.Client] for testability — when provided, the same
/// client is forwarded to every scraping function so HTTP calls can be mocked.
class DataScrapingService {
  DataScrapingService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<List<WealthPrice>> fetchGoldPrices() =>
      scraping.fetchGoldPrices(client: _client);

  Future<List<WealthPrice>> fetchCurrencyPrices() =>
      scraping.fetchCurrencyPrices(client: _client);

  Future<List<WealthPrice>> fetchCommodityPrices() =>
      scraping.fetchCommodityPrices(client: _client);

  Future<List<WealthPrice>> fetchEquityData() =>
      scraping.fetchEquityData(client: _client);
}
