import 'package:flutter_test/flutter_test.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

void main() {
  group('WealthPrice Model Tests', () {
    final Map<String, dynamic> sampleMap = {
      'title': 'Gram Altın',
      'buyingPrice': '2.500,00',
      'sellingPrice': '2.550,00',
      'change': '1%',
      'time': '12:00',
      'type': PriceType.gold.index,
      'currentPrice': null,
      'volume': null,
      'changeAmount': null,
      'lastUpdatedDate': '2024-01-01',
      'lastUpdatedTime': '12:00',
    };

    test('fromMap creates valid WealthPrice object', () {
      final wealthPrice = WealthPrice.fromMap(sampleMap);

      expect(wealthPrice.title, 'Gram Altın');
      expect(wealthPrice.buyingPrice, '2.500,00');
      expect(wealthPrice.type, PriceType.gold);
      expect(wealthPrice.lastUpdatedDate, '2024-01-01');
    });

    test('toMap serializes WealthPrice object correctly', () {
      final wealthPrice = WealthPrice(
        title: 'Euro',
        buyingPrice: '35,00',
        sellingPrice: '35,50',
        change: '0.2%',
        time: '15:00',
        type: PriceType.currency,
      );

      final map = wealthPrice.toMap();

      expect(map['title'], 'Euro');
      expect(map['buyingPrice'], '35,00');
      expect(map['type'], PriceType.currency.index);
    });

    test('Equality and HashCode should be based on title', () {
      final price1 = WealthPrice(
        title: 'Gram Altın',
        buyingPrice: '10',
        sellingPrice: '11',
        change: '1',
        time: '1',
        type: PriceType.gold,
      );
      final price2 = WealthPrice(
        title: 'Gram Altın',
        buyingPrice: '99', // Different price, but same title
        sellingPrice: '99',
        change: '9',
        time: '9',
        type: PriceType.gold,
      );
      final price3 = WealthPrice(
        title: 'Euro',
        buyingPrice: '10',
        sellingPrice: '11',
        change: '1',
        time: '1',
        type: PriceType.currency,
      );

      // We are testing our custom == implementation which only checks 'title'
      expect(price1, price2); 
      expect(price1 == price3, false);
      expect(price1.hashCode, price2.hashCode);
    });

    test('PriceType enum indexes work correctly', () {
      expect(PriceType.gold.index, 0);
      expect(PriceType.currency.index, 1);
      
      final mapGold = {'type': 0, 'title': 'G', 'buyingPrice': '0', 'sellingPrice': '0', 'change': '0', 'time': '0'};
      final mapCurrency = {'type': 1, 'title': 'C', 'buyingPrice': '0', 'sellingPrice': '0', 'change': '0', 'time': '0'};

      expect(WealthPrice.fromMap(mapGold).type, PriceType.gold);
      expect(WealthPrice.fromMap(mapCurrency).type, PriceType.currency);
    });
  });
}
