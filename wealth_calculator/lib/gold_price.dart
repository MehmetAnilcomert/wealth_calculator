import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class GoldPrice {
  final String title;
  final String buyingPrice;
  final String sellingPrice;
  final String change;
  final String time;

  GoldPrice({
    required this.title,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.change,
    required this.time,
  });
}

Future<List<GoldPrice>> fetchGoldPrices() async {
  final url =
      'https://mbigpara.hurriyet.com.tr/altin/'; // Replace with the actual URL

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
      List<GoldPrice> goldPrices = [];

      for (var row in rows) {
        var columns = row.children;

        if (columns.isNotEmpty) {
          String title = columns[0].text.trim();
          String price1 = columns[1].text.trim();
          String price2 = columns[2].text.trim();
          String change = columns[3].text.trim();
          String time = columns[4].text.trim();

          goldPrices.add(GoldPrice(
            title: title,
            buyingPrice: price1,
            sellingPrice: price2,
            change: change,
            time: time,
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
