import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';

/// Firebase Firestore'dan veri çeken servis
/// market_assets collection'ından verileri okur
class FirebaseDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'market_assets';

  /// Altın fiyatlarını Firestore'dan çeker
  Future<List<WealthPrice>> fetchGoldPrices() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: 'gold')
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Firestore: gold verisi bulunamadı');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WealthPrice(
          title: data['title'] as String? ?? '',
          buyingPrice: data['buyingPrice'] as String? ?? '0',
          sellingPrice: data['sellingPrice'] as String? ?? '0',
          change: data['change'] as String? ?? '0',
          time: data['time'] as String? ?? '',
          type: PriceType.gold,
          currentPrice: data['currentPrice'] as String?,
          volume: data['volume'] as String?,
          changeAmount: data['changeAmount'] as String?,
          lastUpdatedDate: _formatTimestamp(data['lastUpdated']),
          lastUpdatedTime: data['time'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchGoldPrices hatası: $e');
      return [];
    }
  }

  /// Döviz fiyatlarını Firestore'dan çeker
  Future<List<WealthPrice>> fetchCurrencyPrices() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: 'currency')
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Firestore: currency verisi bulunamadı');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WealthPrice(
          title: data['title'] as String? ?? '',
          buyingPrice: data['buyingPrice'] as String? ?? '0',
          sellingPrice: data['sellingPrice'] as String? ?? '0',
          change: data['change'] as String? ?? '0',
          time: data['time'] as String? ?? '',
          type: PriceType.currency,
          currentPrice: data['currentPrice'] as String?,
          volume: data['volume'] as String?,
          changeAmount: data['changeAmount'] as String?,
          lastUpdatedDate: _formatTimestamp(data['lastUpdated']),
          lastUpdatedTime: data['time'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchCurrencyPrices hatası: $e');
      return [];
    }
  }

  /// Emtia fiyatlarını Firestore'dan çeker
  Future<List<WealthPrice>> fetchCommodityPrices() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: 'commodity')
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Firestore: commodity verisi bulunamadı');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WealthPrice(
          title: data['title'] as String? ?? '',
          buyingPrice: data['buyingPrice'] as String? ?? '0',
          sellingPrice: data['sellingPrice'] as String? ?? '0',
          change: data['change'] as String? ?? '0',
          time: data['time'] as String? ?? '',
          type: PriceType.commodity,
          currentPrice: data['currentPrice'] as String?,
          volume: data['volume'] as String?,
          changeAmount: data['changeAmount'] as String?,
          lastUpdatedDate: _formatTimestamp(data['lastUpdated']),
          lastUpdatedTime: data['time'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchCommodityPrices hatası: $e');
      return [];
    }
  }

  /// Hisse senedi verilerini Firestore'dan çeker
  Future<List<WealthPrice>> fetchEquityData() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('type', isEqualTo: 'equity')
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Firestore: equity verisi bulunamadı');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return WealthPrice(
          title: data['title'] as String? ?? '',
          buyingPrice: data['buyingPrice'] as String? ?? '0',
          sellingPrice: data['sellingPrice'] as String? ?? '0',
          change: data['change'] as String? ?? '0',
          time: data['time'] as String? ?? '',
          type: PriceType.equity,
          currentPrice: data['currentPrice'] as String?,
          volume: data['volume'] as String?,
          changeAmount: data['changeAmount'] as String?,
          lastUpdatedDate: _formatTimestamp(data['lastUpdated']),
          lastUpdatedTime: data['time'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchEquityData hatası: $e');
      return [];
    }
  }

  /// Firestore Timestamp'i String'e çevirir
  String? _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }
}

// Global fonksiyonlar - eski API'yi korumak için
final _firebaseService = FirebaseDataService();

Future<List<WealthPrice>> fetchGoldPrices() =>
    _firebaseService.fetchGoldPrices();
Future<List<WealthPrice>> fetchCurrencyPrices() =>
    _firebaseService.fetchCurrencyPrices();
Future<List<WealthPrice>> fetchCommodityPrices() =>
    _firebaseService.fetchCommodityPrices();
Future<List<WealthPrice>> fetchEquityData() =>
    _firebaseService.fetchEquityData();
