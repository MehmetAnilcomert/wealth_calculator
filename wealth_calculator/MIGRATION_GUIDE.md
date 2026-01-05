# Architecture Refactoring - Quick Reference

## Common Import Patterns

### Prices Feature
```dart
// Old
import 'package:wealth_calculator/bloc/PricesBloc/pricesBloc.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/views/prices_screen.dart';

// New
import 'package:wealth_calculator/feature/prices/prices.dart';
// OR individually:
import 'package:wealth_calculator/feature/prices/viewmodel/prices_bloc.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:wealth_calculator/feature/prices/view/prices_view.dart';
```

### Inventory Feature
```dart
// Old
import 'package:wealth_calculator/bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';

// New
import 'package:wealth_calculator/feature/inventory/inventory.dart';
```

### Invoice Feature
```dart
// Old
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/views/invoice_screen.dart';

// New
import 'package:wealth_calculator/feature/invoice/invoice.dart';
```

### Services
```dart
// Old
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/services/Notification.dart';
import 'package:wealth_calculator/services/CustomListDao.dart';

// New
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
import 'package:wealth_calculator/product/service/CustomListDao.dart';
```

### Widgets
```dart
// Old
import 'package:wealth_calculator/widgets/drawer.dart';
import 'package:wealth_calculator/widgets/wealth_card.dart';

// New
import 'package:wealth_calculator/product/widget/drawer.dart';
import 'package:wealth_calculator/product/widget/wealth_card.dart';
```

### Utilities
```dart
// Old
import 'package:wealth_calculator/utils/price_utils.dart';
import 'package:wealth_calculator/utils/inventory_utils.dart';

// New
import 'package:wealth_calculator/product/utility/price_utils.dart';
import 'package:wealth_calculator/product/utility/inventory_utils.dart';
```

## Navigation

### Old Way
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => PricesScreen()),
);
```

### New Way
```dart
// Using AppRouter
AppRouter.push(context, AppRoutes.prices);

// Or with named routes
Navigator.pushNamed(context, '/prices');
```

## State Management

### Old Way
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => PricesBloc()..add(LoadPrices())),
    // ... more providers
  ],
  child: MyApp(),
)
```

### New Way
```dart
StateInitialize(
  child: BlocBuilder<LocalizationCubit, Locale>(
    builder: (context, locale) => MaterialApp(...),
  ),
)
```

## Initialization

### Old Way
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();
  final databaseHelper = DbHelper.instance;
  runApp(MyApp());
}
```

### New Way
```dart
Future<void> main() async {
  await ApplicationInitialize.init();
  runApp(const MyApp());
}
```

## File Naming Conventions

- Views: `*_view.dart` (e.g., `prices_view.dart`)
- ViewModels: `*_bloc.dart`, `*_cubit.dart` (e.g., `prices_bloc.dart`)
- Models: `*_model.dart` (e.g., `wealth_data_model.dart`)
- Services: `*_service.dart` or `*Dao.dart` (e.g., `database_helper.dart`)
- Utilities: `*_utils.dart` (e.g., `price_utils.dart`)
- Widgets: `*.dart` (descriptive names like `drawer.dart`, `wealth_card.dart`)

## Barrel Files (Index Files)

Each feature module has a barrel file for convenient imports:

```dart
// lib/feature/prices/prices.dart
export 'view/prices_view.dart';
export 'viewmodel/prices_bloc.dart';
export 'viewmodel/prices_event.dart';
export 'viewmodel/prices_state.dart';
export 'model/wealth_data_model.dart';
```

Usage:
```dart
// Import everything from prices feature
import 'package:wealth_calculator/feature/prices/prices.dart';
```

## Constants Usage

```dart
// Old
const Duration splashDuration = Duration(seconds: 3);
const Locale('en');

// New
import 'package:wealth_calculator/product/utility/constants/app_constants.dart';

AppConstants.splashDuration
AppConstants.supportedLocales
AppColors.primaryBlue
```
