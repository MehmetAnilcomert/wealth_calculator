import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DataScraping.dart';
import 'package:wealth_calculator/services/WealthPricesDao.dart';

class PriceFetcher {
  final WealthPricesDao _wealthPricesDao = WealthPricesDao();

  // Fetch all prices from the internet and save them to the database if successful
  // and return the prices from the database if there is an internet connection error
  Future<List<WealthPrice>> fetchPrices() async {
    try {
      final goldPrices = await fetchGoldPrices();
      final currencyPrices = await fetchCurrencyPrices();
      final equityPrices = await fetchEquityData();
      final commodityPrices = await fetchCommodityPrices();

      // Save all prices to the database
      List<WealthPrice> allPrices = [
        ...goldPrices,
        ...currencyPrices,
        ...equityPrices,
        ...commodityPrices,
      ];

      await _wealthPricesDao.insertPrices(allPrices);

      return allPrices;
    } catch (e) {
      print('Error occurred while fetching from internet: $e');

      // If there is an internet connection error, return the prices from the database
      return await _wealthPricesDao.getAllPrices();
    }
  }
}
