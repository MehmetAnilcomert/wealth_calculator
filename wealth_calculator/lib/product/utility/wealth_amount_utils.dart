/// Wealth amount hesaplamaları için yardımcı fonksiyonlar
/// Floating point precision sorunlarını önlemek için tasarlanmıştır
class WealthAmountUtils {
  /// Amount'u 1 artırır (floating point precision fix ile)
  ///
  /// Örnek: 1.3 + 1.0 = 2.3 (değil 2.30000001)
  static double incrementAmount(double currentAmount) {
    return ((currentAmount * 100 + 100) / 100);
  }

  /// Amount'u 1 azaltır (floating point precision fix ile)
  ///
  /// Örnek: 2.3 - 1.0 = 1.3 (değil 1.2999999)
  static double decrementAmount(double currentAmount) {
    return ((currentAmount * 100 - 100) / 100);
  }

  /// Amount azaltılırken yeni değeri hesaplar
  ///
  /// Kurallar:
  /// - amount >= 1.0: Normal azaltma (1.0 çıkar)
  /// - 0 < amount < 1.0: Direkt 0.0 yap (negatif olmasın)
  /// - amount == 0: null döner (silinmeli)
  static double? calculateDecrementedAmount(double currentAmount) {
    if (currentAmount >= 1.0) {
      return decrementAmount(currentAmount);
    } else if (currentAmount > 0 && currentAmount < 1.0) {
      return 0.0;
    } else {
      return null; // null = item silinmeli
    }
  }

  /// Amount'un silinmesi gerekip gerekmediğini kontrol eder
  static bool shouldDelete(double currentAmount) {
    return currentAmount == 0;
  }
}
