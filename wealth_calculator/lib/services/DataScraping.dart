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
          String price1 = columns[2].text.trim();
          String price2 = columns[1].text.trim();
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
          String buyingPrice = columns[2].text.trim();
          String sellingPrice = columns[1].text.trim();
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

Future<List<WealthPrice>> fetchCommodityPrices() async {
  final Set<String> necessaryCommodities = {
    "Gümüş derived",
    "Bakır derived",
    "Platin derived",
    "Paladyum derived",
    "Ham Petrol derived",
    "Brent Petrol derived",
    "Doğal Gaz derived",
    "Kalorifer Yakıtı derived",
    "Londra Gaz Yağı derived",
    "Alüminyum derived",
    "Çinko derived",
    "Nikel derived",
    "Amerikan Buğday derived",
    "Kaba Pirinç derived",
    "Amerikan Mısır derived",
    "Londra Kahve derived",
    "Amerikan Kakao derived",
    "Yulaf derived",
    "Kereste",
    "Besi Sığırı derived"
  };

  const url = 'https://tr.investing.com/commodities/real-time-futures';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('İstek başarısız oldu: ${response.statusCode}');
  }

  final document = parse(response.body);
  final tbody = document.querySelector('.datatable-v2_body__8TXQk');

  if (tbody == null) {
    throw Exception('tbody element bulunamadı.');
  }

  return tbody
      .querySelectorAll('tr')
      .map((row) => _parseRow(row, necessaryCommodities))
      .where((wealthPrice) => wealthPrice != null)
      .cast<WealthPrice>()
      .toList();
}

WealthPrice? _parseRow(element, Set<String> necessaryCommodities) {
  final cells = element.querySelectorAll('td');
  if (cells.length < 8) return null;

  final titleWithDerived = cells[1].text.trim();
  if (!necessaryCommodities.contains(titleWithDerived)) return null;
  final title = titleWithDerived.replaceAll(' derived', '');
  return WealthPrice(
    title: title,
    currentPrice: cells[3].text.trim(),
    buyingPrice: cells[4].text.trim(),
    sellingPrice: cells[5].text.trim(),
    changeAmount: cells[6].text.trim(),
    change: cells[7].text.trim(),
    time: cells.length > 8 ? cells[8].text.trim() : '',
    type: PriceType.commodity,
  );
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
      final equity = WealthPrice(
        title: name,
        buyingPrice: price2,
        sellingPrice: price3,
        change: changePercent,
        changeAmount: change,
        time: date,
        type: PriceType.equity,
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
