import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/services/WealthPricesDao.dart';

class PriceFetcher {
  final WealthPricesDao _wealthPricesDao = WealthPricesDao();

  // Fetch all prices from the internet and save them to the database if successful
  // and return the prices from the database if there is an internet connection error
  Future<List<List<WealthPrice>>> fetchPrices() async {
    try {
      // Fetch prices from different sources
      final goldPrices = await fetchGoldPrices();
      final currencyPrices = await fetchCurrencyPrices();
      final equityPrices = await fetchEquityData();
      final commodityPrices = await fetchCommodityPrices();

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
      print('Error occurred while fetching from internet: $e');

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
      print('Error occurred while categorizing prices: $e');
      return []; // Return an empty list in case of error
    }
  }
}
