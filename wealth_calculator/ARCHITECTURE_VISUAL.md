# Architecture Visual Guide

## 🏗️ Project Structure Tree

```
wealth_calculator/
│
├── 📱 lib/
│   │
│   ├── 🎯 feature/                    # Feature Modules (Business Logic + UI)
│   │   │
│   │   ├── 💰 prices/
│   │   │   ├── view/
│   │   │   │   └── prices_view.dart
│   │   │   ├── viewmodel/
│   │   │   │   ├── prices_bloc.dart
│   │   │   │   ├── prices_event.dart
│   │   │   │   ├── prices_state.dart
│   │   │   │   └── prices_screen_cubit.dart
│   │   │   ├── model/
│   │   │   │   └── wealth_data_model.dart
│   │   │   └── prices.dart           # Barrel file
│   │   │
│   │   ├── 📦 inventory/
│   │   │   ├── view/
│   │   │   ├── viewmodel/
│   │   │   ├── model/
│   │   │   └── inventory.dart
│   │   │
│   │   ├── 🧾 invoice/
│   │   │   ├── view/
│   │   │   ├── viewmodel/
│   │   │   ├── model/
│   │   │   └── invoice.dart
│   │   │
│   │   ├── ⚙️ settings/
│   │   │   ├── view/
│   │   │   └── settings.dart
│   │   │
│   │   └── 🚀 splash/
│   │       ├── view/
│   │       └── splash.dart
│   │
│   ├── 🎨 product/                    # Shared Product Layer
│   │   │
│   │   ├── init/                      # Initialization
│   │   │   ├── application_initialize.dart
│   │   │   └── state_initialize.dart
│   │   │
│   │   ├── navigation/                # Routing
│   │   │   └── app_router.dart
│   │   │
│   │   ├── state/                     # Global State
│   │   │   └── localization_cubit.dart
│   │   │
│   │   ├── service/                   # Services & DAOs
│   │   │   ├── database_helper.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── CustomListDao.dart
│   │   │   ├── InvoiceDao.dart
│   │   │   ├── PriceHistoryDao.dart
│   │   │   ├── Wealthsdao.dart
│   │   │   └── DataScraping.dart
│   │   │
│   │   ├── utility/                   # Utilities & Constants
│   │   │   ├── constants/
│   │   │   │   └── app_constants.dart
│   │   │   ├── extensions/
│   │   │   ├── inventory_utils.dart
│   │   │   ├── invoice_utils.dart
│   │   │   ├── prices_screen_utils.dart
│   │   │   └── price_utils.dart
│   │   │
│   │   ├── widget/                    # Shared Widgets
│   │   │   ├── drawer.dart
│   │   │   ├── wealth_card.dart
│   │   │   ├── CommonWidgets/
│   │   │   ├── InventoryWidgets/
│   │   │   ├── InvoiceWidgets/
│   │   │   └── PricesWidgets/
│   │   │
│   │   └── product.dart               # Barrel file
│   │
│   ├── 🌍 l10n/                        # Localization
│   │   └── app_localizations.dart
│   │
│   └── 🎬 main.dart                    # Entry Point
│
├── 📚 Documentation/
│   ├── ARCHITECTURE.md
│   ├── MIGRATION_GUIDE.md
│   ├── REFACTORING_COMPLETE.md
│   └── POST_REFACTORING_CHECKLIST.md
│
└── 🛠️ Scripts/
    ├── migrate_imports.py
    └── cleanup_old_folders.ps1
```

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                       │
│                    (Feature Views Layer)                     │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ PricesView   │ InventoryView│ InvoiceView  │ SettingsView   │
└──────────────┴──────────────┴──────────────┴────────────────┘
       ↕              ↕               ↕              ↕
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC                            │
│               (Feature ViewModels - BLoC)                    │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ PricesBloc   │ InventoryBloc│ InvoiceBloc  │ SettingsCubit  │
└──────────────┴──────────────┴──────────────┴────────────────┘
       ↕              ↕               ↕              ↕
┌─────────────────────────────────────────────────────────────┐
│                       DATA MODELS                            │
│                  (Feature Models Layer)                      │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ WealthPrice  │ SavedWealths │ Invoice      │ Settings       │
└──────────────┴──────────────┴──────────────┴────────────────┘
       ↕              ↕               ↕              ↕
┌─────────────────────────────────────────────────────────────┐
│                    SERVICES & DAOs                           │
│                  (Product Service Layer)                     │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ PriceDao     │ WealthsDao   │ InvoiceDao   │ DatabaseHelper │
└──────────────┴──────────────┴──────────────┴────────────────┘
       ↕              ↕               ↕              ↕
┌─────────────────────────────────────────────────────────────┐
│                       DATA SOURCES                           │
│              (Database, API, Local Storage)                  │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ SQLite DB    │ Web Scraping │ SharedPrefs  │ Notifications  │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

## 🎯 Dependency Flow

```
Feature Layer (Independent)
     ↓
Product Layer (Shared)
     ↓
External Dependencies (Packages)
```

**Key Principle**: Features never depend on each other, only on the product layer.

## 📦 Module Composition

### Feature Module Structure
```
feature/[feature_name]/
├── view/           # UI Components
│   └── [name]_view.dart
├── viewmodel/      # Business Logic
│   ├── [name]_bloc.dart
│   ├── [name]_event.dart
│   └── [name]_state.dart
├── model/          # Data Models
│   └── [name]_model.dart
└── [feature_name].dart  # Barrel export
```

### Product Layer Structure
```
product/
├── init/          # App bootstrapping
├── navigation/    # Routing & navigation
├── state/         # Global state
├── service/       # Data access & APIs
├── utility/       # Helpers & constants
├── widget/        # Reusable UI components
└── product.dart   # Barrel export
```

## 🚦 Application Lifecycle

```
1. main()
      ↓
2. ApplicationInitialize.init()
      ├── Database initialization
      ├── Notification setup
      └── Timezone configuration
      ↓
3. MyApp (MaterialApp)
      ↓
4. StateInitialize
      ├── LocalizationCubit
      ├── PricesBloc
      ├── InventoryBloc
      └── InvoiceBloc
      ↓
5. AppRouter
      ├── Initial Route: /splash
      └── Route generation
      ↓
6. SplashView
      ↓
7. PricesView (Home)
```

## 🔀 Navigation Flow

```
                    ┌─────────────┐
                    │ SplashView  │
                    └─────────────┘
                           ↓
                    ┌─────────────┐
            ┌───────│ PricesView  │──────┐
            │       │   (Home)    │      │
            │       └─────────────┘      │
            │              │             │
            ↓              ↓             ↓
    ┌──────────────┐ ┌──────────┐ ┌──────────┐
    │InventoryView │ │InvoiceView│ │ Settings │
    └──────────────┘ └──────────┘ └──────────┘
            │              │             │
            │              ↓             │
            │       ┌─────────────┐     │
            │       │InvoiceAdding│     │
            │       └─────────────┘     │
            │                            │
            └────────────────────────────┘
                         ↕
                   ┌──────────┐
                   │  Drawer  │
                   └──────────┘
```

## 🎨 UI Component Hierarchy

```
MaterialApp
  └── StateInitialize (BLoC Providers)
      └── BlocBuilder<LocalizationCubit>
          └── MaterialApp (with localization)
              └── AppRouter
                  └── Feature Views
                      ├── AppBar
                      ├── Drawer (Product Widget)
                      ├── Body
                      │   ├── Feature Widgets
                      │   └── Product Widgets
                      └── FloatingActionButton
```

## 🔐 State Management Pattern

```
View (UI)
  ↓ events
BLoC/Cubit
  ↓ states
View (rebuilds)

Example:
PricesView
  ↓ LoadPrices event
PricesBloc
  ├── fetches data from PriceFetcher
  ├── processes data
  └── emits PricesLoaded state
  ↓
PricesView rebuilds with new data
```

## 📋 Import Pattern Examples

### Feature Import (Recommended)
```dart
import 'package:wealth_calculator/feature/prices/prices.dart';
// Access: PricesView(), PricesBloc(), WealthPrice()
```

### Selective Feature Import
```dart
import 'package:wealth_calculator/feature/prices/view/prices_view.dart';
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
```

### Product Layer Import
```dart
import 'package:wealth_calculator/product/product.dart';
// Access: AppRouter, AppConstants, LocalizationCubit
```

### Service Import
```dart
import 'package:wealth_calculator/product/service/database_helper.dart';
```

### Widget Import
```dart
import 'package:wealth_calculator/product/widget/drawer.dart';
```

---

## 🎓 Key Concepts

### Feature-First Architecture
- Each feature is a vertical slice of the application
- Features are independent and self-contained
- Easy to understand, test, and maintain

### Product Layer
- Horizontal layer of shared functionality
- Services, utilities, widgets used by multiple features
- Single source of truth for shared code

### Clean Architecture Layers
1. **Presentation** (View): UI and user interaction
2. **Application** (ViewModel): Business logic and state
3. **Domain** (Model): Business entities and rules
4. **Data** (Service): Data access and external APIs

---

**This visual guide complements the detailed ARCHITECTURE.md documentation.**
