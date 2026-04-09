# 🧪 Flutter Feature Testing Guide & Reference

Bu belge, projedeki her bir "feature" (özellik) için yazılması gereken testlerin standartlarını, klasör yapısını ve `Calculator` örneği üzerinden uygulama detaylarını içerir.

---

## 🏗️ 1. Genel Test Mimarisi (Generic Standards)

Bir feature geliştirildiğinde tam kapsamlı (full coverage) olması için şu 3 seviyede test yazılmalıdır:

### A. Model Tests (Unit)
Modellerin veriyi hatasız işlediğinden emin olur.
- **Neler test edilir?**: `fromMap`, `toMap` (JSON serileştirme), `Equality` (iki model aynı mı?) ve `copyWith` (değişmezlik).
- **Mock Gerekmez**: Sadece ham Dart kodudur.

### B. ViewModel/Bloc Tests (Unit)
İş mantığının (Business Logic) kalbidir.
- **Neler test edilir?**: Başlangıç durumu, Event'ler tetiklendiğinde State değişimlerinin sırası ve hata yönetimi.
- **Gereken Mocklar**: Bloc'un bağımlı olduğu dış servisler (`ScrapingService`, `AuthService` vb.).
- **Araçlar**: `bloc_test`, `mocktail`.

### C. Widget Tests
UI'ın state'lere doğru tepki verdiğinden emin olur.
- **Neler test edilir?**: Loading animasyonu çıkıyor mu? Veri yüklendiğinde liste görünüyor mu? Hata durumunda SnackBar çıkıyor mu?
- **Gereken Mocklar**: Sahte (Mock) bir Bloc sınıfı. UI'ı "zorlamak" için kullanılır.

---

## 📁 2. Klasör Yapısı (Folder Structure)

Test klasörümüz, `/lib` altındaki klasör yapımızı birebir kopyalamalıdır. `Calculator` özelliği için şu yapıyı kurduk:

```text
test/
└── calculator_feature_tests/        # Özelliğe özel grup
    ├── model/                      # Model testleri
    │   ├── saved_wealths_test.dart
    │   └── wealth_price_test.dart
    ├── viewmodel/                  # Bloc / Mantık testleri
    │   └── calculator_bloc_test.dart
    └── widget/                     # UI testleri
        └── calculator_view_test.dart
```

---

## 📝 3. Uygulamalı Örneği: Calculator Feature

### 🛠️ Mock Stratejimiz
`Calculator` özelliğini izole etmek için şu mockları oluşturduk:
1. **`MockDataScrapingService`**: Bloc'u test ederken gerçek internete gitmemek için.
2. **`MockCalculatorBloc`**: Widget'ları test ederken gerçek hesaplama mantığını çalıştırmamak için.

### ✅ Neleri Test Ettik?

#### 1. Model Seviyesi
- `SavedWealths` modeline `copyWith` ekledik ve test ettik. Böylece varlık miktarı güncellenirken yanlışlıkla tüm nesnenin değişmesini veya `late initialization` hatası almayı engelledik.

#### 2. ViewModel (Bloc) Seviyesi
- **Load Scenarios**: Servis veri getirdiğinde `Loading -> Loaded` geçişini test ettik.
- **Calculation Logic**: Farklı para birimlerinin (USD, Altın) toplam fiyata doğru yansıyıp yansımadığını (örn: 10 gram altın * güncel fiyat) doğruladık.
- **Error Handling**: İnternet olmadığında servisin hata fırlatması ve Bloc'un `CalculatorError` durumuna geçmesi.

#### 3. Widget (UI) Seviyesi
- **Dependency Injection**: `CalculatorView`'a dışarıdan Bloc verebilme özelliği ekledik (`BaseView`).
- **Overflow Fix**: Test ekranını `800x1600` yaparak grafiklerin taşmadığını doğruladık.
- **Interaction**: "Ekle" butonunun (FAB) sadece veri yüklendiğinde görünür olduğunu garantiledik.

---

## 💡 İpuçları (Best Practices)
1. **Immutability Is Key**: Modellerinde mutlaka `copyWith` ve `Equatable` kullan. Test yazarken hayat kurtarır.
2. **Setup Your Surface**: Widget testlerde ekranın taşmaması için `tester.view.physicalSize` kullanmayı unutma.
3. **Wait for Animations**: UI testlerinde `pump()` yerine animasyonların bitmesini bekleyen `pumpAndSettle()` tercih et.
4. **BaseView Pattern**: Bloc DI işlemini her view'da elle yazmak yerine projedeki `BaseView` sarmalayıcısını kullan.

---
*Bu doküman projenin test disiplinini korumak amacıyla oluşturulmuştur.*
