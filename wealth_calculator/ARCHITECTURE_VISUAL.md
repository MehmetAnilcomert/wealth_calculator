# Wealth Calculator - Görsel Mimari Kılavuzu

## 🏗️ Klasör Yapısı

```
wealth_calculator/
│
├── 📱 lib/
│   │
│   ├── 🎯 feature/                    # Özellik Modülleri
│   │   │
│   │   ├── 💰 prices/                 # Fiyat takibi
│   │   │   ├── view/
│   │   │   ├── viewmodel/             # PricesBloc
│   │   │   └── model/
│   │   │
│   │   ├── 📦 inventory/              # Envanter yönetimi
│   │   │   ├── view/
│   │   │   ├── viewmodel/             # InventoryBloc
│   │   │   └── model/
│   │   │
│   │   ├── 🧾 invoice/                # Fatura yönetimi
│   │   │   ├── view/
│   │   │   ├── viewmodel/             # InvoiceBloc
│   │   │   └── model/
│   │   │
│   │   ├── 📝 invoice_form/           # Fatura formu
│   │   │   └── view/
│   │   │
│   │   ├── 🧮 calculator/             # Hesap makinesi
│   │   │   ├── view/
│   │   │   └── viewmodel/             # CalculatorCubit
│   │   │
│   │   ├── 👤 profile/                # Profil
│   │   │   ├── view/
│   │   │   ├── viewmodel/             # ProfileCubit
│   │   │   └── model/
│   │   │
│   │   ├── ⚙️ settings/               # Ayarlar
│   │   │   └── view/
│   │   │
│   │   └── 🚀 splash/                 # Başlangıç ekranı
│   │       └── view/
│   │
│   ├── 🎨 product/                    # Paylaşılan Katman
│   │   │
│   │   ├── init/                      # Başlatma
│   │   │   ├── application_initialize.dart
│   │   │   └── state_initialize.dart
│   │   │
│   │   ├── navigation/                # Yönlendirme
│   │   │   └── app_router.dart
│   │   │
│   │   ├── state/                     # Global State
│   │   │   ├── base/                  # BaseCubit, BaseState
│   │   │   ├── container/             # ProductContainer (DI)
│   │   │   └── viewmodel/             # ProductViewmodel
│   │   │
│   │   ├── theme/                     # Tema Sistemi
│   │   │   ├── light_theme/
│   │   │   ├── dark_theme/
│   │   │   └── custom_colors.dart
│   │   │
│   │   ├── cache/                     # Cache yönetimi
│   │   │
│   │   ├── service/                   # Servisler
│   │   │   ├── database_helper.dart
│   │   │   ├── notification_service.dart
│   │   │   └── *Dao.dart
│   │   │
│   │   ├── utility/                   # Yardımcılar
│   │   │   ├── constants/
│   │   │   ├── extensions/
│   │   │   └── *_utils.dart
│   │   │
│   │   └── widget/                    # Paylaşılan Widget'lar
│   │       ├── CommonWidgets/
│   │       ├── InventoryWidgets/
│   │       ├── InvoiceWidgets/
│   │       └── PricesWidgets/
│   │
│   └── 🎬 main.dart
│
├── 📄 assets/
│   └── translations/
│       ├── en.json
│       └── tr.json
│
└── 📚 Dokümantasyon/
    ├── ARCHITECTURE.md
    └── ARCHITECTURE_VISUAL.md
```


## 🔄 Veri Akışı Diyagramı

```
┌─────────────────────────────────────────────────────────────┐
│                      KULLANICI ARAYÜZLERİ                    │
│                        (Feature Views)                       │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│ Prices   │Inventory │ Invoice  │Calculator│Settings/Profile │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
      ↕          ↕         ↕          ↕            ↕
┌─────────────────────────────────────────────────────────────┐
│                     İŞ MANTIK KATMANI                        │
│                  (BLoC/Cubit Pattern)                        │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│PricesBloc│Inventory │ Invoice  │Calculator│  ProfileCubit   │
│          │   Bloc   │   Bloc   │  Cubit   │                 │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
      ↕          ↕         ↕          ↕            ↕
┌─────────────────────────────────────────────────────────────┐
│                       VERİ MODELLERİ                         │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│ Wealth   │  Saved   │ Invoice  │Calculator│   Profile       │
│  Price   │ Wealths  │          │   Data   │                 │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
      ↕          ↕         ↕          
┌─────────────────────────────────────────────────────────────┐
│                     SERVİSLER & DAO                          │
├──────────┬──────────┬──────────┬──────────────────────────┐ │
│PriceDao  │WealthsDao│InvoiceDao│ DatabaseHelper           │ │
└──────────┴──────────┴──────────┴──────────────────────────┘ │
      ↕                                                         │
┌─────────────────────────────────────────────────────────────┐
│                      VERİ KAYNAKLARI                         │
│              (SQLite, API, SharedPreferences)                │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Bağımlılık Akışı

```
┌─────────────────────────┐
│   Feature Layer         │  ← Bağımsız özellikler
│   (prices, inventory)   │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│   Product Layer         │  ← Paylaşılan kod
│   (state, service)      │
└───────────┬─────────────┘
            ↓
┌─────────────────────────┐
│   External Packages     │  ← Flutter, BLoC, etc.
└─────────────────────────┘
```

**Temel Kural**: Feature'lar birbirine değil, sadece product layer'a bağlıdır.

## 📦 Design Pattern'ler

### 1. BLoC Pattern (State Management)
```
User Event  →  BLoC  →  New State  →  UI Rebuild

Örnek:
LoadPrices event → PricesBloc → PricesLoaded → View güncellenir
```

### 2. Repository Pattern (Data Access)
```
ViewModel  →  DAO  →  Database

Örnek:
PricesBloc → PriceHistoryDao → SQLite
```

### 3. Singleton Pattern
```dart
DatabaseHelper.instance      // ✅ Tek instance
NotificationService.instance // ✅ Tek instance
```

### 4. Dependency Injection (DI)
```dart
ProductContainer.read<ProductViewmodel>()  // Service locator
```

### 5. Factory Pattern
```dart
Model.fromJson(json)   // Factory constructor
Model.fromMap(map)     // Factory constructor
```

### 6. Observer Pattern
```dart
BlocBuilder<Bloc, State>(...)  // Stream observer
```

## 🚦 Uygulama Yaşam Döngüsü

```
1. main()
      ↓
2. ApplicationInitialize.init()
      ├─ Database oluşturma
      ├─ Notification kurulumu
      └─ Timezone ayarları
      ↓
3. StateInitialize
      ├─ ProductViewmodel (global state)
      ├─ PricesBloc
      ├─ InventoryBloc
      ├─ InvoiceBloc
      └─ ProfileCubit
      ↓
4. MaterialApp (BlocBuilder ile)
      ├─ theme: CustomLightTheme
      ├─ darkTheme: CustomDarkTheme
      └─ themeMode: state.themeMode (reactive)
      ↓
5. SplashView
      ↓
6. PricesView (Ana Sayfa)
```

## 🔀 Navigasyon Akışı

```
                    ┌─────────────┐
                    │ SplashView  │
                    └─────────────┘
                           ↓
                    ┌─────────────┐
            ┌───────│ PricesView  │──────┐
            │       │  (Ana Sayfa)│      │
            │       └─────────────┘      │
            ↓              ↓             ↓
    ┌──────────┐    ┌──────────┐  ┌──────────┐
    │Inventory │    │ Invoice  │  │Calculator│
    └──────────┘    └──────────┘  └──────────┘
            │              │             │
            │       ┌─────────────┐      │
            │       │InvoiceForm  │      │
            │       └─────────────┘      │
            │                            │
            └──────────┬─────────────────┘
                       ↓
              ┌─────────────────┐
              │Settings/Profile │
              └─────────────────┘
```

## 🎨 State Management Yapısı

### Global State (Product Layer)
```dart
product/state/
├── base/                    # BaseCubit, BaseState
├── container/               # ProductContainer (DI)
├── viewmodel/
│   ├── product_viewmodel.dart    # Global ViewModel
│   └── product_state.dart        # Global State
└── state.dart
```

**ProductState İçeriği:**
- `ThemeMode` → Tema yönetimi (light/dark/system)
- `Locale` → Dil yönetimi (tr/en)

### Reactive State Update
```dart
// ❌ Non-reactive (tekil okuma)
ProductContainer.read<ProductViewmodel>().state.themeMode

// ✅ Reactive (stream subscription)
BlocBuilder<ProductViewmodel, ProductState>(
  builder: (context, state) => Text(state.themeMode),
)
```

## 🎨 Tema Sistemi

### Tema Mimarisi
```dart
product/theme/
├── light_theme/
│   └── custom_light_theme.dart      # LightColorScheme
├── dark_theme/
│   └── custom_dark_theme.dart       # DarkColorScheme
├── custom_colors.dart                # Extension: gold, euro
└── custom_theme.dart
```

### Tema Kullanımı
```dart
// Material 3 ColorScheme
context.colorScheme.primary
context.colorScheme.surface
context.colorScheme.onSurface

// Özel renkler
context.customColors.gold
context.customColors.euro
context.customColors.dollar
```

### Tema Değiştirme
```dart
// Settings'ten tema değiştir
ProductContainer.read<ProductViewmodel>()
  .changeThemeMode(themeMode: ThemeMode.dark);

// MaterialApp otomatik güncellenir (BlocBuilder sayesinde)
```

## 🔐 BLoC State Pattern

### Karmaşık State (Bloc)
```dart
// Çoklu event, karmaşık state geçişleri
PricesBloc, InventoryBloc, InvoiceBloc

Event → Bloc → State
```

### Basit State (Cubit)
```dart
// Tek fonksiyonla state değişimi
CalculatorCubit, ProfileCubit, ProductViewmodel

Method → Cubit → State
```

### State Immutability
```dart
class ProductState extends Equatable {
  const ProductState({required this.themeMode});
  
  final ThemeMode themeMode;
  
  // Immutable güncelleme
  ProductState copyWith({ThemeMode? themeMode}) {
    return ProductState(themeMode: themeMode ?? this.themeMode);
  }
}
```

## 📋 Temel Prensipler

### ✅ Feature İzolasyonu
- Feature'lar birbirine import etmez
- Sadece product layer'a bağımlıdır
- Her feature bağımsız test edilebilir

### ✅ Single Responsibility
- Her class tek bir sorumluluğa sahip
- View → UI
- ViewModel → Business Logic
- Model → Data Structure
- Service → Data Access

### ✅ Dependency Injection
- ProductContainer ile servis yönetimi
- Test edilebilir kod
- Gevşek bağlı (loosely coupled) yapı

### ✅ Reactive UI
- BlocBuilder ile otomatik güncelleme
- Stream-based state management
- Performanslı rebuild mekanizması

---

