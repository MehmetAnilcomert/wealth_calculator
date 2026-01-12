import 'package:flutter/cupertino.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/data_source_manager.dart';
import 'package:wealth_calculator/product/service/wealth_prices_dao.dart';

class PriceFetcher {
  final WealthPricesDao _wealthPricesDao = WealthPricesDao();
  final _dataSource = DataSourceManager();

  // Fetch all prices from the internet and save them to the database if successful
  // and return the prices from the database if there is an internet connection error
  Future<List<List<WealthPrice>>> fetchPrices() async {
    try {
      // Fetch prices from different sources
      final goldPrices = await _dataSource.fetchGoldPrices();
      final currencyPrices = await _dataSource.fetchCurrencyPrices();
      final equityPrices = await _dataSource.fetchEquityData();
      final commodityPrices = await _dataSource.fetchCommodityPrices();

      // Combine all prices into one list
      List<WealthPrice> allPrices = [
        ...goldPrices,
        ...currencyPrices,
        ...equityPrices,
        ...commodityPrices,
      ];

      // Save all prices to the database
      await _wealthPricesDao.insertPrices(allPrices);

      return [
        goldPrices,
        currencyPrices,
        equityPrices,
        commodityPrices
      ]; // Return the combined list
    } catch (e) {
      debugPrint('Error occurred while fetching from internet: $e');

      // If there is an internet connection error, return the prices from the database
      final allPrices = await _wealthPricesDao.getAllPrices();

      // Categorize the prices before returning them
      return await _getCategorizedPrices(allPrices);
    }
  }

  // This method retrieves all prices and returns them separated into categories
  Future<List<List<WealthPrice>>> _getCategorizedPrices(
      List<WealthPrice> allPrices) async {
    try {
      // Categorize prices into their respective types
      final goldPrices =
          allPrices.where((price) => price.type == PriceType.gold).toList();
      final currencyPrices =
          allPrices.where((price) => price.type == PriceType.currency).toList();
      final equityPrices =
          allPrices.where((price) => price.type == PriceType.equity).toList();
      final commodityPrices = allPrices
          .where((price) => price.type == PriceType.commodity)
          .toList();

      // Return the categorized prices as a list of lists
      List<List<WealthPrice>> categorizedPrices = [
        goldPrices,
        currencyPrices,
        equityPrices,
        commodityPrices,
      ];

      return categorizedPrices;
    } catch (e) {
      debugPrint('Error occurred while categorizing prices: $e');
      return []; // Return an empty list in case of error
    }
  }
}
