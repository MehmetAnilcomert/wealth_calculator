# Wealth Calculator Architecture Refactoring Guide

## Overview
This project has been successfully refactored from a flat structure to a **feature-first architecture** with clean separation of concerns.

## New Architecture Structure

```
lib/
├── feature/                      # Feature modules (business logic + UI)
│   ├── prices/                  # Price tracking feature
│   │   ├── view/                # UI screens
│   │   │   └── prices_view.dart
│   │   ├── viewmodel/           # BLoC/Cubit (business logic)
│   │   │   ├── prices_bloc.dart
│   │   │   ├── prices_event.dart
│   │   │   ├── prices_state.dart
│   │   │   └── prices_screen_cubit.dart
│   │   ├── model/               # Data models
│   │   │   └── wealth_data_model.dart
│   │   └── prices.dart          # Barrel file for exports
│   │
│   ├── inventory/               # Inventory management feature
│   │   ├── view/
│   │   │   └── inventory_view.dart
│   │   ├── viewmodel/
│   │   │   ├── inventory_bloc.dart
│   │   │   ├── inventory_event.dart
│   │   │   └── inventory_state.dart
│   │   ├── model/
│   │   │   ├── wealths_model.dart
│   │   │   └── wealth_history_model.dart
│   │   └── inventory.dart
│   │
│   ├── invoice/                 # Invoice management feature
│   │   ├── view/
│   │   │   ├── invoice_view.dart
│   │   │   └── invoice_adding_view.dart
│   │   ├── viewmodel/
│   │   │   ├── invoice_bloc.dart
│   │   │   ├── invoice_event.dart
│   │   │   └── invoice_state.dart
│   │   ├── model/
│   │   │   └── invoice_model.dart
│   │   └── invoice.dart
│   │
│   ├── settings/                # Settings feature
│   │   ├── view/
│   │   │   ├── settings_view.dart
│   │   │   ├── profile_view.dart
│   │   │   └── temp_calculator_view.dart
│   │   └── settings.dart
│   │
│   └── splash/                  # Splash screen feature
│       ├── view/
│       │   └── splash_view.dart
│       └── splash.dart
│
├── product/                      # Shared product layer
│   ├── init/                    # App initialization
│   │   ├── application_initialize.dart
│   │   └── state_initialize.dart
│   │
│   ├── navigation/              # Navigation configuration
│   │   └── app_router.dart
│   │
│   ├── state/                   # Global state management
│   │   └── localization_cubit.dart
│   │
│   ├── service/                 # Services (DAO, API, etc.)
│   │   ├── database_helper.dart
│   │   ├── notification_service.dart
│   │   ├── CustomListDao.dart
│   │   ├── InvoiceDao.dart
│   │   ├── PriceHistoryDao.dart
│   │   ├── Wealthsdao.dart
│   │   └── DataScraping.dart
│   │
│   ├── utility/                 # Utilities & helpers
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── extensions/
│   │   ├── inventory_utils.dart
│   │   ├── invoice_utils.dart
│   │   ├── prices_screen_utils.dart
│   │   └── price_utils.dart
│   │
│   ├── widget/                  # Shared widgets
│   │   ├── drawer.dart
│   │   ├── wealth_card.dart
│   │   ├── CommonWidgets/
│   │   ├── InventoryWidgets/
│   │   ├── InvoiceWidgets/
│   │   └── PricesWidgets/
│   │
│   └── product.dart             # Barrel file for product layer
│
├── l10n/                         # Localization files
└── main.dart                     # Application entry point
```

## Key Architecture Principles

### 1. **Feature-First Organization**
- Each major feature (prices, inventory, invoice, settings) has its own module
- Features are self-contained with their own views, business logic, and models
- Easy to understand, test, and maintain each feature independently

### 2. **Clean Separation of Concerns**
- **View**: UI components and widgets (presentation layer)
- **ViewModel**: Business logic with BLoC pattern (application layer)
- **Model**: Data structures and entities (domain layer)

### 3. **Product Layer**
- Shared code that can be reused across all features
- **init**: Handles app initialization
- **navigation**: Centralized routing
- **state**: Global state management
- **service**: Data access and external services
- **utility**: Helper functions and constants
- **widget**: Reusable UI components

### 4. **Dependency Flow**
```
Features → Product Layer
   ↓
Views → ViewModels → Models
   ↓         ↓
 Widgets   Services
```

## Migration Changes

### Old Structure → New Structure

| Old Location | New Location | Purpose |
|-------------|--------------|---------|
| `lib/views/` | `lib/feature/*/view/` | Feature-specific views |
| `lib/bloc/` | `lib/feature/*/viewmodel/` | Feature-specific business logic |
| `lib/modals/` | `lib/feature/*/model/` | Feature-specific data models |
| `lib/services/` | `lib/product/service/` | Shared services |
| `lib/utils/` | `lib/product/utility/` | Shared utilities |
| `lib/widgets/` | `lib/product/widget/` | Shared widgets |

### Import Path Updates

**Before:**
```dart
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
```

**After:**
```dart
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
```

## New Features

### 1. **Centralized Initialization**
```dart
// lib/product/init/application_initialize.dart
ApplicationInitialize.init()  // Handles all initialization
```

### 2. **Type-Safe Navigation**
```dart
// lib/product/navigation/app_router.dart
AppRouter.push(context, AppRoutes.inventory);
AppRouter.pushReplacement(context, AppRoutes.prices);
```

### 3. **State Provider Wrapper**
```dart
// lib/product/init/state_initialize.dart
StateInitialize(child: ...)  // Wraps all BLoC providers
```

### 4. **Constants Management**
```dart
// lib/product/utility/constants/app_constants.dart
AppConstants.splashDuration
AppConstants.supportedLocales
AppColors.primaryBlue
```

### 5. **Barrel Files (Index Files)**
```dart
// Import entire feature
import 'package:wealth_calculator/feature/prices/prices.dart';

// Import entire product layer
import 'package:wealth_calculator/product/product.dart';
```

## Benefits of New Architecture

### 1. **Scalability**
- Easy to add new features without affecting existing code
- Each feature module is independent and self-contained

### 2. **Maintainability**
- Clear structure makes it easy to find and modify code
- Reduced coupling between components
- Better code organization

### 3. **Testability**
- Each layer can be tested independently
- Mock dependencies easily with clear interfaces
- Unit tests, widget tests, and integration tests are simpler

### 4. **Team Collaboration**
- Multiple developers can work on different features without conflicts
- Clear ownership of code modules
- Easier code reviews with feature-based PRs

### 5. **Reusability**
- Product layer contains all shared code
- Widgets, services, and utilities can be reused across features
- Reduced code duplication

## Usage Examples

### Creating a New Feature

1. Create feature folder structure:
```
lib/feature/new_feature/
├── view/
├── viewmodel/
├── model/
└── new_feature.dart (barrel file)
```

2. Add to navigation:
```dart
// lib/product/navigation/app_router.dart
enum AppRoutes {
  newFeature('/new-feature'),
}
```

3. Create view, viewmodel, and model files
4. Export in barrel file
5. Use throughout the app!

### Accessing Services

```dart
// From any feature
import 'package:wealth_calculator/product/service/database_helper.dart';

final db = await DbHelper.instance.database;
```

### Using Shared Widgets

```dart
// From any feature
import 'package:wealth_calculator/product/widget/drawer.dart';

AppDrawer()
```

## Migration Checklist

- [x] Created feature folder structure
- [x] Created product layer structure
- [x] Migrated prices feature
- [x] Migrated inventory feature
- [x] Migrated invoice feature
- [x] Migrated settings feature
- [x] Migrated splash screen
- [x] Moved services to product/service
- [x] Moved utilities to product/utility
- [x] Moved widgets to product/widget
- [x] Updated main.dart
- [x] Created barrel files
- [x] Updated imports in core files
- [ ] Update remaining view imports (in progress)
- [ ] Run tests
- [ ] Update documentation

## Next Steps

1. **Fix remaining imports**: Some view files still need import path updates
2. **Add unit tests**: Test each feature module independently
3. **Add integration tests**: Test feature interactions
4. **Documentation**: Add inline documentation for complex logic
5. **Performance optimization**: Profile and optimize if needed

## Code Quality Improvements

- Added `const` constructors where possible
- Used `@immutable` annotations
- Better null safety with explicit types
- Cleaner dependency injection
- Type-safe navigation with enums

## Tools & Patterns Used

- **BLoC Pattern**: For state management
- **Repository Pattern**: In DAO services
- **Singleton Pattern**: For database and services
- **Factory Pattern**: In model constructors
- **Observer Pattern**: Through BLoC streams

---

## References

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [BLoC Pattern Documentation](https://bloclibrary.dev)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Last Updated**: January 5, 2026
**Version**: 2.0.0 (Architecture Refactor)
