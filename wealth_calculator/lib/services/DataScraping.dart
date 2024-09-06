import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:wealth_calculator/modals/EquityModal.dart';
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

Future<void> fetchCommodityPrices() async {
  // Verilen URL'den HTML veriyi çek
  const url = 'https://tr.investing.com/commodities/real-time-futures';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // HTML içeriğini parse et
    final document = parse(response.body);

    // tbody içindeki tüm tr etiketlerini seç
    final tbody = document.querySelector('.datatable-v2_body__8TXQk');

    if (tbody != null) {
      final rows = tbody.querySelectorAll('tr');

      for (var row in rows) {
        // Her bir tr içerisindeki td etiketlerini seç
        final cells = row.querySelectorAll('td');

        // Verileri al ve yazdır
        final data = cells.map((cell) => cell.text.trim()).toList();
        print(data);
      }
    } else {
      print('tbody element bulunamadı.');
    }
  } else {
    print('İstek başarısız oldu: ${response.statusCode}');
  }
}

Future<List<WealthPrice>> fetchEquityData() async {
  final url = 'https://tr.investing.com/equities/turkey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = parse(response.body);
    final rows = document.querySelectorAll(
        'tr.datatable-v2_row__hkEus.dynamic-table-v2_row__ILVMx');

    final data = <WealthPrice>[];
    for (var row in rows) {
      final name = row.querySelector('td:nth-child(1) a')?.text.trim() ?? '';
      final price1 =
          row.querySelector('td:nth-child(2) span')?.text.trim() ?? '';
      final price2 = row.querySelector('td:nth-child(3)')?.text.trim() ?? '';
      final price3 = row.querySelector('td:nth-child(4)')?.text.trim() ?? '';
      final change = row.querySelector('td:nth-child(5)')?.text.trim() ?? '';
      final changePercent =
          row.querySelector('td:nth-child(6)')?.text.trim() ?? '';
      final volume = row.querySelector('td:nth-child(7)')?.text.trim() ?? '';
      final date = row.querySelector('td:nth-child(8) time')?.text.trim() ?? '';

      // Create Equity instance
      final equity = Equity(
        title: name,
        buyingPrice: price2,
        sellingPrice: price3,
        change: changePercent,
        changeAmount: change,
        time: date,
        type: PriceType.equity, // Assuming all rows are of type 'equity'
        currentPrice: price1,
        volume: volume,
      );

      data.add(equity);
    }

    return data;
  } else {
    throw Exception('Failed to load data');
  }
}
