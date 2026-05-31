import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Standard browser-like HTTP headers to bypass bot protection (e.g. Cloudflare / 403 Forbidden).
const Map<String, String> _headers = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
  'Accept':
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
  'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
  'Cache-Control': 'no-cache',
  'Pragma': 'no-cache',
};

/// Parses a single `<tr>` row from Bigpara's new table layout into a [WealthPrice].
///
/// Column mapping (0-based td index):
///   0 → Symbol cell (contains `a.symbol-cell > div > div*2`)
///   1 → Sparkline chart (skipped)
///   2 → Current price
///   3 → Change percentage (e.g. "%0,85")
///   4 → Change amount
///   5 → Buying price (Alış)
///   6 → Selling price (Satış)
///   7 → Daily high (skipped)
///   8 → Daily low (skipped)
String _cleanPrice(String price) {
  // Remove thousands separators (.) and replace decimal commas (,) with dots (.)
  return price.replaceAll('.', '').replaceAll(',', '.').trim();
}

WealthPrice? _parseBigparaRow(dom.Element row, PriceType type, String time) {
  final cells = row.querySelectorAll('td');
  if (cells.length < 7) return null;

  // --- Title ---
  // Structure: td > span > a.symbol-cell > div > div:first-child (short name)
  final symbolLink = cells[0].querySelector('a.symbol-cell');
  final titleDivs = symbolLink?.querySelectorAll('div > div') ?? [];
  // First div = short code/name, Second div = full description
  // Use the short name (first div) as it matches the old scraper output format
  final title =
      titleDivs.isNotEmpty ? titleDivs.first.text.trim() : cells[0].text.trim();

  if (title.isEmpty) return null;

  // --- Buying & Selling ---
  final buyingPrice = _cleanPrice(cells[5].text);
  final sellingPrice = _cleanPrice(cells[6].text);

  // --- Change (%) ---
  // The cell contains an icon span + a text span like "%0,85"
  final change = cells[3].text.trim();

  return WealthPrice(
    title: title,
    buyingPrice: buyingPrice,
    sellingPrice: sellingPrice,
    change: change,
    time: time,
    type: type,
  );
}

/// Extracts the global "Son Güncelleme" time text from a Bigpara page.
///
/// The time string is rendered once on the page (not per-row) and typically
/// looks like "31 Mayıs, 00:01:10".
String _extractUpdateTime(dom.Document document) {
  // The update time is typically near the page header area.
  // Strategy: search all text nodes for a pattern like "DD Month, HH:MM:SS"
  // It usually lives in a sibling element to the title.
  // Look for elements containing "Son Güncelleme" text or date-like patterns.

  String rawTime = '';

  // Approach 1: Find by known text pattern near "Son Güncelleme"
  final allElements = document.querySelectorAll('*');
  for (final el in allElements) {
    if (el.text.contains('Son Güncelleme') && el.children.isEmpty) {
      // The time is usually in the next sibling or parent's next child
      final parent = el.parent;
      if (parent != null) {
        final siblings = parent.children;
        final idx = siblings.indexOf(el);
        if (idx >= 0 && idx + 1 < siblings.length) {
          rawTime = siblings[idx + 1].text.trim();
          break;
        }
      }
    }
  }

  if (rawTime.isEmpty) {
    // Approach 2: Look for a standalone time-like text in the header area
    final timeRegex = RegExp(r'\d{1,2}\s+\w+,\s+\d{2}:\d{2}:\d{2}');
    for (final el in allElements) {
      if (el.children.isEmpty) {
        final match = timeRegex.firstMatch(el.text.trim());
        if (match != null) {
          rawTime = match.group(0) ?? '';
          break;
        }
      }
    }
  }

  // Clean rawTime to remove the seconds (e.g. HH:MM:SS -> HH:MM)
  if (rawTime.isNotEmpty) {
    final secondsRegex = RegExp(r'(\d{2}:\d{2}):\d{2}');
    final match = secondsRegex.firstMatch(rawTime);
    if (match != null) {
      return rawTime.replaceFirst(match.group(0)!, match.group(1)!);
    }
  }

  return rawTime;
}

/// Parses all data rows from a Bigpara table page.
///
/// Both /altin/ and /doviz/ pages share the same table structure:
/// `div.table-container > table > tbody > tr`
List<WealthPrice> _parseBigparaTable(dom.Document document, PriceType type) {
  final time = _extractUpdateTime(document);

  final tbody = document.querySelector('div.table-container table tbody');
  if (tbody == null) return [];

  final rows = tbody.querySelectorAll('tr');
  final List<WealthPrice> prices = [];

  for (final row in rows) {
    final parsed = _parseBigparaRow(row, type, time);
    if (parsed != null) {
      prices.add(parsed);
    }
  }

  return prices;
}

Future<List<WealthPrice>> fetchGoldPrices({http.Client? client}) async {
  const url =
      'https://mbigpara.hurriyet.com.tr/altin/'; // Website to scrape data from.

  final httpClient = client ?? http.Client();
  try {
    // Fetch the HTML document with custom browser-like headers
    final response = await httpClient.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      // Parse the HTML document
      dom.Document document = parse(response.body);
      return _parseBigparaTable(document, PriceType.gold);
    } else {
      debugPrint('Failed to load the gold prices webpage.');
    }
  } finally {
    // Only close if we created it internally
    if (client == null) httpClient.close();
  }

  return [];
}

Future<List<WealthPrice>> fetchCurrencyPrices({http.Client? client}) async {
  const url =
      'https://mbigpara.hurriyet.com.tr/doviz/'; // Website to scrape data from.

  final httpClient = client ?? http.Client();
  try {
    // Fetch the HTML document with custom browser-like headers
    final response = await httpClient.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      // Parse the HTML document
      dom.Document document = parse(response.body);
      return _parseBigparaTable(document, PriceType.currency);
    } else {
      debugPrint('Failed to load the currency prices webpage.');
    }
  } finally {
    // Only close if we created it internally
    if (client == null) httpClient.close();
  }

  return [];
}

Future<List<WealthPrice>> fetchCommodityPrices({http.Client? client}) async {
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
  final httpClient = client ?? http.Client();
  try {
    final response = await httpClient.get(Uri.parse(url));

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
  } finally {
    if (client == null) httpClient.close();
  }
}

WealthPrice? _parseRow(element, Set<String> necessaryCommodities) {
  final cells = element.querySelectorAll('td');
  if (cells.length < 8) return null;

  final titleWithDerived = cells[1].text.trim();
  if (!necessaryCommodities.contains(titleWithDerived)) return null;
  final title = titleWithDerived.replaceAll(' derived', '');
  return WealthPrice(
    title: title,
    currentPrice: _cleanPrice(cells[3].text),
    buyingPrice: _cleanPrice(cells[4].text),
    sellingPrice: _cleanPrice(cells[5].text),
    changeAmount: cells[6].text.trim(),
    change: cells[7].text.trim(),
    time: cells.length > 8 ? cells[8].text.trim() : '',
    type: PriceType.commodity,
  );
}

Future<List<WealthPrice>> fetchEquityData({http.Client? client}) async {
  const url = 'https://tr.investing.com/equities/turkey';
  final httpClient = client ?? http.Client();
  try {
    final response = await httpClient.get(Uri.parse(url));

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
        final date =
            row.querySelector('td:nth-child(8) time')?.text.trim() ?? '';

        // Create Equity instance
        final equity = WealthPrice(
          title: name,
          buyingPrice: _cleanPrice(price2),
          sellingPrice: _cleanPrice(price3),
          change: changePercent,
          changeAmount: change,
          time: date,
          type: PriceType.equity,
          currentPrice: _cleanPrice(price1),
          volume: volume,
        );

        data.add(equity);
      }

      return data;
    } else {
      throw Exception('Failed to load data');
    }
  } finally {
    if (client == null) httpClient.close();
  }
}
