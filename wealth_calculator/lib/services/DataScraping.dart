import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';

Future<List<WealthPrice>> fetchGoldPrices() async {
  final url =
      'https://mbigpara.hurriyet.com.tr/altin/'; // Website to scrape data from.

  // Fetch the HTML document
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Parse the HTML document
    Document document = parse(response.body);

    // Select the specific part of the HTML document
    Element? wrapper = document.getElementById('wrapper');
    Element? mContent = wrapper?.querySelector('.mContent');
    Element? table = mContent?.querySelector('.table');

    if (table != null) {
      List<Element> rows = table.querySelectorAll('.tBody');
      List<WealthPrice> goldPrices = [];

      for (var row in rows) {
        var columns = row.children;

        if (columns.isNotEmpty) {
          String title = columns[0].text.trim();
          String price1 = columns[1].text.trim();
          String price2 = columns[2].text.trim();
          String change = columns[3].text.trim();
          String time = columns[4].text.trim();

          goldPrices.add(WealthPrice(
            title: title,
            buyingPrice: price1,
            sellingPrice: price2,
            change: change,
            time: time,
            type: PriceType.gold,
          ));
        }
      }

      return goldPrices;
    }
  } else {
    print('Failed to load the webpage.');
  }

  return [];
}

Future<List<WealthPrice>> fetchCurrencyPrices() async {
  final url =
      'https://mbigpara.hurriyet.com.tr/doviz/'; // Website to scrape data from.

  // Fetch the HTML document
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Parse the HTML document
    Document document = parse(response.body);

    // Select the specific part of the HTML document
    Element? table = document.querySelector('.table .tList');

    if (table != null) {
      List<Element> rows = table.querySelectorAll('.tBody');
      List<WealthPrice> currencyPrices = [];

      for (var row in rows) {
        var columns = row.children;

        if (columns.isNotEmpty) {
          String title =
              row.querySelector('span.hisse-name-text')?.text.trim() ?? '';
          String buyingPrice = columns[1].text.trim();
          String sellingPrice = columns[2].text.trim();
          String change = columns[3].text.trim();
          String time = columns[4].text.trim();

          currencyPrices.add(WealthPrice(
            title: title,
            buyingPrice: buyingPrice,
            sellingPrice: sellingPrice,
            change: change,
            time: time,
            type: PriceType.currency,
          ));
        }
      }

      return currencyPrices;
    }
  } else {
    print('Failed to load the webpage.');
  }

  return [];
}
