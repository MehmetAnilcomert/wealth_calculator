# Wealth Calculator Architecture

## Genel Bakış
Feature-first architecture ile temiz katmanlı mimari.

## Klasör Yapısı

```
lib/
├── feature/                  # Özellik modülleri (izole ve bağımsız)
│   ├── prices/              # Fiyat takibi
│   │   ├── view/           
│   │   ├── viewmodel/      
│   │   └── model/          
│   │
│   ├── inventory/           # Envanter yönetimi
│   │   ├── view/
│   │   ├── viewmodel/
│   │   └── model/
│   │
│   ├── invoice/             # Fatura yönetimi
│   │   ├── view/
│   │   ├── viewmodel/
│   │   └── model/
│   │
│   ├── invoice_form/        # Fatura formu
│   │   └── view/
│   │
│   ├── calculator/          # Hesap makinesi
│   │   ├── view/
│   │   └── viewmodel/
│   │
│   ├── profile/             # Profil yönetimi
│   │   ├── view/
│   │   ├── viewmodel/
│   │   └── model/
│   │
│   ├── settings/            # Ayarlar
│   │   └── view/
│   │
│   └── splash/              # Splash ekranı
│       └── view/
│
├── product/                  # Paylaşılan katman
│   ├── init/                # Uygulama başlatma
│   │   ├── application_initialize.dart
│   │   └── state_initialize.dart
│   │
│   ├── navigation/          # Yönlendirme
│   │   └── app_router.dart
│   │
│   ├── state/               # Global state yönetimi
│   │   ├── base/           # Base sınıflar
│   │   ├── container/      # Dependency injection
│   │   ├── viewmodel/      # ProductViewmodel & ProductState
│   │   └── state.dart
│   │
│   ├── theme/               # Tema sistemi
│   │   ├── light_theme/
│   │   ├── dark_theme/
│   │   ├── custom_colors.dart
│   │   └── custom_theme.dart
│   │
│   ├── cache/               # Cache yönetimi
│   │
│   ├── service/             # Servisler (DAO, API)
│   │   ├── database_helper.dart
│   │   ├── notification_service.dart
│   │   └── *Dao.dart
│   │
│   ├── utility/             # Yardımcı araçlar
│   │   ├── constants/
│   │   ├── extensions/
│   │   └── *_utils.dart
│   │
│   ├── widget/              # Paylaşılan widget'lar
│   │   ├── CommonWidgets/
│   │   ├── InventoryWidgets/
│   │   ├── InvoiceWidgets/
│   │   └── PricesWidgets/
│   │
│   └── product.dart
│
└── main.dart
```


## Mimari Prensipler

### 1. Feature-First (Özellik Öncelikli)
Her özellik bağımsız bir modül olarak organize edilir:
- **Bağımsızlık**: Feature'lar birbirine bağlı değildir
- **Tekrar Kullanılabilirlik**: Product layer üzerinden paylaşım
- **Test Edilebilirlik**: Her feature izole test edilebilir

### 2. Katmanlı Mimari
```
View (UI)
  ↓
ViewModel (Business Logic - BLoC/Cubit)
  ↓
Model (Data Structures)
  ↓
Service (Data Access)
```

### 3. Bağımlılık Yönü
```
Features ──→ Product Layer ──→ External Packages
```
Feature'lar sadece product layer'a bağımlıdır, birbirine asla.

## Design Pattern'ler

### 1. **BLoC Pattern** (State Management)
```dart
// Event → BLoC → State
View sends event → BLoC processes → Emits new state → View rebuilds
```
- **Bloc**: Karmaşık state yönetimi (prices, inventory, invoice)
- **Cubit**: Basit state yönetimi (settings, calculator)

### 2. **Repository Pattern** (Data Access)
```dart
// ViewModel → DAO → Database
```
- DAO sınıfları (CustomListDao, InvoiceDao, WealthsDao)
- Veri kaynağını soyutlar

### 3. **Singleton Pattern**
```dart
DatabaseHelper.instance  // Tek database instance'ı
NotificationService.instance
```
- Servisler için tek instance

### 4. **Dependency Injection**
```dart
// product/state/container/
ProductContainer.read<ProductViewmodel>()
```
- Custom DI container ile servis yönetimi

### 5. **Factory Pattern**
```dart
Model.fromJson(json)
Model.fromMap(map)
```
- Model oluşturma için factory constructor'lar

### 6. **Observer Pattern**
```dart
BlocBuilder<Bloc, State>(...)  // Stream subscription
```
- BLoC stream'leri üzerinden reactive UI

### 7. **Strategy Pattern** (Data Source Management)
```dart
// Farklı veri kaynaklarını runtime'da değiştirme
abstract class DataSourceStrategy {
  Future<List<Price>> fetchPrices();
}

class FirebaseDataSource implements DataSourceStrategy { }
class LocalDataSource implements DataSourceStrategy { }
```
- Firebase ve yerel veritabanı arasında esnek geçiş
- Veri kaynağı soyutlama
- Test edilebilir data layer

## State Management Yapısı

### Global State (Product Layer)
```dart
product/state/
├── base/                    # BaseCubit, BaseState
├── container/               # ProductContainer (DI)
├── viewmodel/              
│   ├── product_viewmodel.dart   # Global ViewModel
│   └── product_state.dart       # Global State (theme, locale)
└── state.dart              # Exports
```

**ProductState**: Uygulama geneli state (tema, dil)
- ThemeMode (light/dark/system)
- Locale (tr/en)

### Feature State
Her feature kendi state'ini yönetir:
```dart
feature/prices/viewmodel/
├── prices_bloc.dart
├── prices_event.dart
└── prices_state.dart
```

## Tema Sistemi

### Theme Architecture
```dart
product/theme/
├── light_theme/            # Açık tema
│   └── custom_light_theme.dart
├── dark_theme/             # Koyu tema
│   └── custom_dark_theme.dart
├── custom_colors.dart      # Özel renkler (ColorScheme extension)
└── custom_theme.dart       # Theme yönetimi
```

### Tema Kullanımı
```dart
// ColorScheme'den renk alma
context.colorScheme.primary
context.colorScheme.surface

// Özel renklerden renk alma
context.customColors.gold
context.customColors.euro
```

### Tema Değiştirme
```dart
// ProductViewmodel üzerinden
ProductContainer.read<ProductViewmodel>()
  .changeThemeMode(themeMode: ThemeMode.dark);

// UI reaktif güncelleme
BlocBuilder<ProductViewmodel, ProductState>(
  builder: (context, state) => MaterialApp(
    themeMode: state.themeMode,  // ✅ Reactive
  ),
)
```

## Veri Akışı

### Prices Feature Örneği
```
1. User Action (PricesView)
   ↓
2. Event Dispatch (LoadPrices)
   ↓
3. BLoC Process (PricesBloc)
   ├→ PriceHistoryDao.fetch()
   └→ WealthsDao.fetch()
   ↓
4. State Emit (PricesLoaded)
   ↓
5. UI Rebuild (BlocBuilder)
```

### Database Flow
```
ViewModel → DAO → DatabaseHelper → SQLite
```

## Navigasyon

### Router Pattern
```dart
product/navigation/app_router.dart

// Named routes
AppRouter.pushNamed(context, '/inventory');

// Type-safe navigation
Navigator.push(context, MaterialPageRoute(...));
```

## Initialization Flow

```
main()
  ↓
ApplicationInitialize.init()
  ├→ Database
  ├→ Notifications
  └→ Timezone
  ↓
StateInitialize (BLoC Providers)
  ├→ ProductViewmodel
  ├→ PricesBloc
  ├→ InventoryBloc
  └→ InvoiceBloc
  ↓
MaterialApp (with BlocBuilder)
  ↓
SplashView → PricesView
```

## Önemli Kavramlar

### Reactive vs Non-Reactive
```dart
// ❌ Non-reactive (tek seferlik okuma)
final themeMode = ProductContainer.read<ProductViewmodel>().state.themeMode;

// ✅ Reactive (stream subscription ile otomatik güncelleme)
BlocBuilder<ProductViewmodel, ProductState>(
  builder: (context, state) => Text(state.themeMode.toString()),
)
```

### Feature İzolasyonu
- Feature'lar birbirini import etmez
- Sadece product layer'a bağımlıdır
- Paylaşılan kod product layer'da

### State Immutability
```dart
class ProductState extends Equatable {
  const ProductState({required this.themeMode});
  final ThemeMode themeMode;
  
  // Immutable update
  ProductState copyWith({ThemeMode? themeMode}) => ...;
}
```