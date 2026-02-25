---
name: clean_flutter_development
description: Complete project-specific guide for AI agents to develop features in this Flutter application. Covers architecture, conventions, file patterns, DI, routing, database, state management, theming, localization, and step-by-step feature implementation checklist.
---

# Wealth Calculator — Project Development Guide

> **Purpose**: This document provides AI agents with everything needed to implement features, fix bugs, and refactor code in this project **without guessing**. Follow it step-by-step.

---

## Table of Contents

1. Project Overview
2. Directory Structure
3. Feature Implementation Checklist
4. Model Layer
5. Database Layer (SQLite)
6. DAO (Data Access Object) Layer
7. State Management (Cubit / Bloc)
8. Dependency Injection (GetIt)
9. BlocProvider Registration
10. Routing (Navigation)
11. View Layer (part/part-of Mixin Pattern)
12. Theming & Styling
13. Localization (i18n)
14. Shared Widgets
15. Naming & Coding Conventions
16. Common Pitfalls & Rules
17. Git Workflow

---

## 1. Project Overview

| Aspect | Detail |
|---|---|
| **Framework** | Flutter (Dart) |
| **Architecture** | Feature-first Clean Architecture + shared `product` layer |
| **State Management** | `flutter_bloc` — both `Cubit` and `Bloc` patterns via custom base classes |
| **DI** | `get_it` wrapped in `ProductContainer` |
| **Database** | `sqflite` with singleton `DbHelper` and DAO-per-table |
| **Navigation** | Navigator 1.0 with typed `AppRoutes` enum and `AppRouter` |
| **Theming** | Material 3, light/dark, `CustomColors` extension on `ColorScheme` |
| **Localization** | `easy_localization` with generated `LocaleKeys` constants |
| **Caching** | Hive (via `core` module) for theme/preferences |

### Boot Sequence (`main.dart`)

```
main() →
  1. ApplicationInitialize().startApplication()
     ├── WidgetsFlutterBinding.ensureInitialized()
     ├── EasyLocalization.ensureInitialized()
     ├── ProductContainer.setUp()          ← GetIt registration
     ├── DbHelper.instance.database       ← SQLite init
     ├── NotificationService init
     └── Load saved theme from cache
  2. runApp(
       ProductLocalization(              ← EasyLocalization wrapper
         StateInitialize(                ← MultiBlocProvider
           WealthCalculator()            ← MaterialApp with AppRouter
         )
       )
     )
```

---

## 2. Directory Structure

```
lib/
├── main.dart
├── feature/                           # Feature modules (vertical slices)
│   └── <feature_name>/
│       ├── <feature_name>.dart        # Optional barrel export
│       ├── model/                     # Data models
│       │   └── <name>_model.dart
│       ├── view/                      # UI widgets
│       │   ├── <feature>_view.dart    # Main view (build method only)
│       │   ├── mixin/                 # View logic split via part/part-of
│       │   │   └── <feature>_view_mixin.dart
│       │   └── widget/               # Feature-specific sub-widgets (optional)
│       └── viewmodel/                 # State management
│           ├── <feature>_cubit.dart   # OR <feature>_bloc.dart
│           ├── <feature>_event.dart   # Only for Bloc pattern
│           └── <feature>_state.dart
│
└── product/                           # Shared infrastructure
    ├── cache/                         # Hive cache
    ├── init/                          # App initialization
    │   ├── application_initialize.dart
    │   ├── state_initialize.dart      # MultiBlocProvider
    │   ├── product_localization.dart
    │   └── language/
    │       └── locale_keys.g.dart     # GENERATED — do not edit
    ├── navigation/
    │   └── app_router.dart            # Route definitions
    ├── service/                       # DAOs + services
    │   ├── database_helper.dart       # Singleton SQLite manager
    │   ├── <name>_dao.dart            # One DAO per table
    │   └── manager/                   # Network manager, error handler
    ├── state/
    │   ├── base/                      # BaseCubit, BaseBloc, BaseState
    │   ├── container/
    │   │   ├── product_state_container.dart  # GetIt registration
    │   │   └── product_state_items.dart      # Static accessors
    │   └── viewmodel/                 # Product-level viewmodel
    ├── theme/
    │   ├── custom_colors.dart         # ColorScheme extension
    │   ├── light_theme/ dark_theme/   # Theme implementations
    ├── utility/
    │   ├── extensions/context_extension.dart
    │   ├── padding/product_padding.dart
    │   └── constants/, mixin/
    └── widget/                        # Shared reusable widgets
        ├── drawer.dart
        └── ...
```

---

## 3. Feature Implementation Checklist

When adding a new feature, follow these steps **in order**. Each step references the corresponding section below.

### Phase 1 — Data Layer
- [ ] **Step 1: Model** — Create `lib/feature/<name>/model/<name>_model.dart` (see Section 4)
- [ ] **Step 2: Database Migration** — Add table DDL + bump version in `database_helper.dart` (see Section 5)
- [ ] **Step 3: DAO** — Create `lib/product/service/<name>_dao.dart` (see Section 6)

### Phase 2 — State Layer
- [ ] **Step 4: State** — Create `lib/feature/<name>/viewmodel/<name>_state.dart` (see Section 7)
- [ ] **Step 5: Cubit/Bloc** — Create `lib/feature/<name>/viewmodel/<name>_cubit.dart` (see Section 7)
- [ ] **Step 6: DI Registration** — Register DAO + Cubit in `product_state_container.dart` and `product_state_items.dart` (see Section 8)
- [ ] **Step 7: BlocProvider** — Add `BlocProvider` in `state_initialize.dart` (see Section 9)

### Phase 3 — Presentation Layer
- [ ] **Step 8: View** — Create `lib/feature/<name>/view/<name>_view.dart` with `part` directive (see Section 11)
- [ ] **Step 9: View Mixin** — Create `lib/feature/<name>/view/mixin/<name>_view_mixin.dart` with `part of` (see Section 11)

### Phase 4 — Integration
- [ ] **Step 10: Route** — Add enum value + switch case in `app_router.dart` (see Section 10)
- [ ] **Step 11: Translations** — Add keys to `en.json` and `tr.json`, then regenerate (see Section 13)
- [ ] **Step 12: Wire Up** — Add navigation trigger (drawer menu item, settings card, etc.)
- [ ] **Step 13: Dependencies** — Add any new packages to `pubspec.yaml` and run `flutter pub get`

### Phase 5 — Verification
- [ ] **Step 14: Error Check** — Run `flutter analyze` to ensure zero new errors
- [ ] **Step 15: Build Test** — Run `flutter build apk --debug` to verify compilation

---

## 4. Model Layer

**Location**: `lib/feature/<name>/model/<name>_model.dart`

### Template

```dart
import 'package:equatable/equatable.dart';

/// Represents a <description>.
class ExampleModel extends Equatable {
  final int? id;
  final String title;
  final String? optionalField;

  const ExampleModel({
    this.id,
    required this.title,
    this.optionalField,
  });

  /// Empty/default instance.
  factory ExampleModel.empty() => const ExampleModel(title: '');

  /// Whether this model has meaningful data.
  bool get isEmpty => title.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Immutable copy.
  ExampleModel copyWith({
    int? id,
    String? title,
    String? optionalField,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      optionalField: optionalField ?? this.optionalField,
    );
  }

  /// Serialize to SQLite map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'optionalField': optionalField,
    };
  }

  /// Deserialize from SQLite map.
  factory ExampleModel.fromMap(Map<String, dynamic> map) {
    return ExampleModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      optionalField: map['optionalField'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, optionalField];
}
```

### Rules
- Always extend `Equatable` with `props`.
- Use `const` constructor when possible.
- Provide `empty()` factory + `isEmpty` getter for empty-state checks.
- Use `toMap()` / `fromMap()` for SQLite serialization (NOT `toJson`/`fromJson`).
- `copyWith()` for immutable state updates.
- Exclude `id` from `toMap()` when null (auto-increment).

---

## 5. Database Layer (SQLite)

**File**: `lib/product/service/database_helper.dart`

### How It Works
- **Singleton**: `DbHelper._privateConstructor()` + `static final instance`.
- **Database name**: `app_database.db`.
- **Current version**: 8 (increment for each migration).
- Table DDLs are private `static const String` fields.
- `onCreate` creates ALL tables from scratch.
- `onUpgrade` applies incremental migrations using `if (oldVersion < N)` guards.

### Adding a New Table

1. Add the DDL as a private constant:
```dart
static const _createExampleTable = '''
  CREATE TABLE IF NOT EXISTS example (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    optionalField TEXT
  )
''';
```

2. Add to `onCreate`:
```dart
onCreate: (db, version) async {
  // ... existing tables ...
  await db.execute(_createExampleTable);  // ← ADD HERE
},
```

3. Add migration in `onUpgrade`:
```dart
if (oldVersion < 9) {  // ← next version number
  await db.execute(_createExampleTable);
}
```

4. Bump the version:
```dart
version: 9,  // ← was 8
```

### Column Modification Pattern (migrate existing table)
For column type changes (e.g., INTEGER → REAL), use the rename-recreate pattern:
```dart
if (oldVersion < N) {
  await db.execute('ALTER TABLE foo RENAME TO foo_old');
  await db.execute(_createFooTable);
  await db.execute('INSERT INTO foo (...) SELECT ... FROM foo_old');
  await db.execute('DROP TABLE foo_old');
}
```

---

## 6. DAO (Data Access Object) Layer

**Location**: `lib/product/service/<name>_dao.dart`

### Template

```dart
import 'package:wealth_calculator/feature/<name>/model/<name>_model.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';

/// Data access object for the `example` table.
class ExampleDao {
  static const String _tableName = 'example';

  Future<List<ExampleModel>> getAll() async {
    final db = await DbHelper.instance.database;
    final maps = await db.query(_tableName);
    return maps.map(ExampleModel.fromMap).toList();
  }

  Future<ExampleModel?> getById(int id) async {
    final db = await DbHelper.instance.database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ExampleModel.fromMap(maps.first);
  }

  Future<int> insert(ExampleModel model) async {
    final db = await DbHelper.instance.database;
    return db.insert(_tableName, model.toMap());
  }

  Future<int> update(ExampleModel model) async {
    final db = await DbHelper.instance.database;
    return db.update(
      _tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DbHelper.instance.database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Insert or update based on existence of id.
  Future<int> save(ExampleModel model) async {
    if (model.id != null) return update(model);
    return insert(model);
  }
}
```

### Rules
- One DAO per table.
- Plain class, no abstract/interface.
- Table name as `static const String _tableName`.
- Access DB via `DbHelper.instance.database`.
- Return model types, not raw maps.

---

## 7. State Management (Cubit / Bloc)

### When to Use Which
| Pattern | Use When | Examples |
|---|---|---|
| **Cubit** | Simple CRUD, single-trigger actions, no complex event transformations | Profile, Splash, Settings |
| **Bloc** | Event-driven logic, multiple event types, complex transformations | Prices, Inventory, Invoice |

### State Template

**Location**: `lib/feature/<name>/viewmodel/<name>_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/<name>/model/<name>_model.dart';

enum ExampleStatus { initial, loading, loaded, saving, saved, error }

class ExampleState extends Equatable {
  final ExampleStatus status;
  final ExampleModel data;
  final String? errorMessage;

  const ExampleState({
    required this.status,
    required this.data,
    this.errorMessage,
  });

  factory ExampleState.initial() => ExampleState(
        status: ExampleStatus.initial,
        data: ExampleModel.empty(),
      );

  bool get isLoading =>
      status == ExampleStatus.loading || status == ExampleStatus.saving;

  bool get hasData => data.isNotEmpty;

  ExampleState copyWith({
    ExampleStatus? status,
    ExampleModel? data,
    String? errorMessage,
  }) {
    return ExampleState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
```

### Cubit Template

**Location**: `lib/feature/<name>/viewmodel/<name>_cubit.dart`

```dart
import 'package:wealth_calculator/feature/<name>/model/<name>_model.dart';
import 'package:wealth_calculator/feature/<name>/viewmodel/<name>_state.dart';
import 'package:wealth_calculator/product/service/<name>_dao.dart';
import 'package:wealth_calculator/product/state/base/base_cubit.dart';

/// Manages <feature> state.
class ExampleCubit extends BaseCubit<ExampleState> {
  ExampleCubit({required ExampleDao dao})
      : _dao = dao,
        super(ExampleState.initial()) {
    _load();  // Auto-load on creation
  }

  final ExampleDao _dao;

  Future<void> _load() async {
    emit(state.copyWith(status: ExampleStatus.loading));
    try {
      final items = await _dao.getAll();
      emit(state.copyWith(
        status: ExampleStatus.loaded,
        // ... populate data ...
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExampleStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> save(/* params */) async {
    emit(state.copyWith(status: ExampleStatus.saving));
    try {
      // ... DAO calls ...
      emit(state.copyWith(status: ExampleStatus.saved, /* updated data */));
    } catch (e) {
      emit(state.copyWith(
        status: ExampleStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
```

### Rules
- **Always extend `BaseCubit<T>`** (NOT raw `Cubit<T>`). `BaseCubit` has `isClosed` guard on `emit()`.
- **Always extend `BaseBloc<E, S>`** (NOT raw `Bloc<E, S>`).
- Accept DAO via constructor injection: `ExampleCubit({required ExampleDao dao})`.
- Use `state.copyWith()` for all state transitions.
- Wrap async operations in try/catch, emit `error` status on failure.
- Auto-load data in constructor when appropriate.

---

## 8. Dependency Injection (GetIt)

### File 1: `lib/product/state/container/product_state_container.dart`

This is where ALL services, DAOs, and cubits are registered.

```dart
final class ProductContainer {
  ProductContainer._();
  static final GetIt _getit = GetIt.I;

  static Future<void> setUp() async {
    // Phase 1: Core infrastructure
    _getit
      ..registerSingleton(ProductNetworkManager.base())
      ..registerSingleton(ProductCache(cacheManager: HiveCacheManager()));

    await _getit<ProductCache>().initialize();

    // Phase 2: ViewModels, DAOs, Cubits
    _getit
      ..registerLazySingleton(ProductViewmodel.new)
      ..registerSingleton(UserProfileDao())               // ← DAO as singleton
      ..registerLazySingleton(                             // ← Cubit with DAO injection
        () => UserProfileCubit(dao: _getit<UserProfileDao>()),
      );
  }

  static T read<T extends Object>() => _getit<T>();
}
```

### File 2: `lib/product/state/container/product_state_items.dart`

Static accessors for clean access throughout the app.

```dart
final class ProductStateItems {
  const ProductStateItems._();

  static ProductNetworkManager get networkManager =>
      ProductContainer.read<ProductNetworkManager>();
  static ProductCache get cacheManager => ProductContainer.read<ProductCache>();
  static ProductViewmodel get productViewModel =>
      ProductContainer.read<ProductViewmodel>();
  static UserProfileCubit get userProfileCubit =>
      ProductContainer.read<UserProfileCubit>();
}
```

### Registration Pattern for a New Feature

Add to `product_state_container.dart` inside `setUp()`:
```dart
..registerSingleton(ExampleDao())
..registerLazySingleton(
  () => ExampleCubit(dao: _getit<ExampleDao>()),
)
```

Add to `product_state_items.dart`:
```dart
static ExampleCubit get exampleCubit =>
    ProductContainer.read<ExampleCubit>();
```

### Rules
- **DAOs**: Register as `registerSingleton` (eager, stateless).
- **Cubits/Blocs managed by GetIt**: Register as `registerLazySingleton` (created on first access).
- **Feature Blocs** (created per app lifecycle, NOT shared globally): Do NOT register in GetIt — use `BlocProvider(create:)` directly in `StateInitialize`.
- Always inject dependencies via constructor, never use `GetIt.I` directly in business logic.

---

## 9. BlocProvider Registration

**File**: `lib/product/init/state_initialize.dart`

```dart
final class StateInitialize extends StatelessWidget {
  const StateInitialize({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // GetIt-managed singletons → use .value
        BlocProvider<ProductViewmodel>.value(
          value: ProductStateItems.productViewModel,
        ),
        BlocProvider<UserProfileCubit>.value(
          value: ProductStateItems.userProfileCubit,
        ),

        // Feature blocs → create fresh
        BlocProvider(create: (context) => SplashCubit()),
        BlocProvider(create: (context) => PricesBloc()),
        BlocProvider(create: (context) => InventoryBloc()),
        BlocProvider(create: (context) => InvoiceBloc()),
      ],
      child: child,
    );
  }
}
```

### Decision Guide

| Registered in GetIt? | BlocProvider Pattern | When |
|---|---|---|
| **Yes** | `BlocProvider<T>.value(value: ProductStateItems.xxx)` | Shared state, needs DI injection, used across features |
| **No** | `BlocProvider(create: (_) => XxxBloc())` | Feature-scoped, no external dependencies, self-contained |

### Adding a New Provider

1. If GetIt-managed: Add `BlocProvider<ExampleCubit>.value(value: ProductStateItems.exampleCubit)` to the `providers` list.
2. If standalone: Add `BlocProvider(create: (_) => ExampleBloc())` to the `providers` list.
3. Import the cubit/bloc class at the top of the file.

---

## 10. Routing (Navigation)

**File**: `lib/product/navigation/app_router.dart`

### Structure

```dart
enum AppRoutes {
  splash('/'),
  prices('/prices'),
  inventory('/inventory'),
  invoice('/invoice'),
  invoiceAdd('/invoice/add'),
  settings('/settings'),
  converter('/converter'),
  calculator('/calculator'),
  profileEdit('/profile/edit');

  const AppRoutes(this.path);
  final String path;
}

final class AppRouter {
  const AppRouter._();
  static String get initialRoute => AppRoutes.splash.path;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(builder: (_) => const SplashView());
      case '/prices':
        return MaterialPageRoute<void>(builder: (_) => const PricesView());
      // ... etc
    }
  }

  static Future<T?> push<T>(BuildContext context, AppRoutes route) =>
      Navigator.pushNamed<T>(context, route.path);

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context, AppRoutes route, {TO? result}) =>
      Navigator.pushReplacementNamed<T, TO>(context, route.path, result: result);

  static void pop(BuildContext context) => Navigator.pop(context);
}
```

### Adding a New Route

1. Add enum value: `newFeature('/new-feature')` in `AppRoutes`.
2. Add switch case in `onGenerateRoute`:
```dart
case '/new-feature':
  return MaterialPageRoute<void>(
    builder: (_) => const NewFeatureView(),
  );
```
3. Add import for the view at the top.
4. Navigate from anywhere: `AppRouter.push(context, AppRoutes.newFeature)`.

### Rules
- **NEVER use direct `Navigator.push(MaterialPageRoute(...))` for new code.** Always use `AppRouter.push(context, AppRoutes.xxx)`.
- Use `AppRouter.pushReplacement` for replacing the current screen (e.g., splash → prices).
- Use `AppRouter.pop(context)` for going back.
- The `MaterialApp` uses `onGenerateRoute: AppRouter.onGenerateRoute`.

---

## 11. View Layer (part/part-of Mixin Pattern)

### Pattern A: StatelessWidget + Public Mixin

For settings-like screens with no local state.

**`lib/feature/<name>/view/<name>_view.dart`**:
```dart
import 'package:flutter/material.dart';
// ... all imports ...

part 'mixin/<name>_view_mixin.dart';

class ExampleView extends StatelessWidget with ExampleViewMixin {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return Scaffold(
      // ... use mixin methods: buildSectionTitle(), buildCard(), etc.
    );
  }
}
```

**`lib/feature/<name>/view/mixin/<name>_view_mixin.dart`**:
```dart
part of '../<name>_view.dart';

mixin ExampleViewMixin {
  Widget buildSectionTitle(BuildContext context, ...) { ... }
  Widget buildCard(BuildContext context, ...) { ... }
}
```

### Pattern B: StatefulWidget + Private Mixin

For screens with form controllers, local state, lifecycle methods.

**`lib/feature/<name>/view/<name>_view.dart`**:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
// ... all imports ...

part 'mixin/<name>_view_mixin.dart';

class ExampleView extends StatefulWidget {
  const ExampleView({super.key});

  @override
  State<ExampleView> createState() => _ExampleViewState();
}

class _ExampleViewState extends State<ExampleView> with _ExampleViewMixin {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return Scaffold(
      body: BlocConsumer<ExampleCubit, ExampleState>(
        listener: _onStateChanged,      // from mixin
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, colorScheme),   // from mixin
              _buildForm(context, colorScheme),      // from mixin
            ],
          );
        },
      ),
    );
  }
}
```

**`lib/feature/<name>/view/mixin/<name>_view_mixin.dart`**:
```dart
part of '../<name>_view.dart';

mixin _ExampleViewMixin on State<ExampleView> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, ExampleState state) {
    if (state.status == ExampleStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(...);
      Navigator.of(context).pop();
    }
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) { ... }
  Widget _buildForm(BuildContext context, ColorScheme colorScheme) { ... }
}
```

### Rules
- **ALL imports** go in the main view file only. The mixin file uses `part of` and inherits all imports.
- **StatelessWidget** mixins: public name, no underscore prefix.
- **StatefulWidget** mixins: private name with underscore, constrained with `on State<T>`.
- The main view file contains ONLY `build()`. ALL logic, event handlers, controllers, and sub-builder methods go in the mixin.
- Use `context.general.colorScheme` for theming inside builders.

---

## 12. Theming & Styling

### Accessing Colors

```dart
final colorScheme = context.general.colorScheme;

// Standard Material colors
colorScheme.primary
colorScheme.surface
colorScheme.onSurface
colorScheme.error

// Custom extension colors (from custom_colors.dart)
colorScheme.gold
colorScheme.dollar
colorScheme.euro
colorScheme.pound
colorScheme.turkishLira
colorScheme.gradientStart
colorScheme.gradientEnd
colorScheme.blackOverlay10
colorScheme.blackOverlay20
colorScheme.blackOverlay30
colorScheme.whiteOverlay05
colorScheme.transparent
colorScheme.warning
colorScheme.success
colorScheme.danger
colorScheme.caution
colorScheme.disabledText
colorScheme.secondaryText
colorScheme.subtleText
colorScheme.chartBackground
colorScheme.blueGrey
colorScheme.deleteBackground
```

### Accessing Text Theme

```dart
context.general.textTheme.titleLarge
context.general.textTheme.bodyMedium
```

### Context Extensions

```dart
context.general.colorScheme     // ColorScheme
context.general.textTheme       // TextTheme
context.general.isDarkMode      // bool
context.general.isLightMode     // bool
context.general.theme           // ThemeData
context.width                   // screen width
context.height                  // screen height
context.mediaQuery              // MediaQueryData
context.isKeyboardVisible       // bool
```

### Padding

**NEVER** use raw `EdgeInsets.all(16)`. Always use `ProductPadding`:

```dart
const ProductPadding.allSmall()                    // 8
const ProductPadding.allMedium()                   // 16
const ProductPadding.allNormal()                   // 24
const ProductPadding.allLarge()                    // 32
const ProductPadding.symmetricHorizontalSmall()    // horizontal: 8
const ProductPadding.symmetricHorizontalMedium()   // horizontal: 16
const ProductPadding.symmetricHorizontalNormal()   // horizontal: 24
const ProductPadding.symmetricHorizontalLarge()    // horizontal: 32
const ProductPadding.symmetricVerticalSmall()      // vertical: 8
const ProductPadding.symmetricVerticalMedium()     // vertical: 16
const ProductPadding.symmetricVerticalNormal()     // vertical: 24
const ProductPadding.symmetricVerticalLarge()      // vertical: 32
const ProductPadding.symmetricVerticalExtraLarge() // vertical: 40
const ProductPadding.onlyTopExtraSmall()           // top: 4
const ProductPadding.onlyTopMedium()               // top: 16
const ProductPadding.onlyBottomSmall()             // bottom: 8
```

### Card / Container Styling Pattern

```dart
Container(
  padding: const ProductPadding.allMedium(),
  decoration: BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: colorScheme.blackOverlay10,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

### Rules
- **ZERO hardcoded colors.** Always use `colorScheme.xxx` or `colorScheme` extension.
- **ZERO hardcoded padding numbers.** Always use `ProductPadding`.
- **ZERO hardcoded text styles.** Use `textTheme` or create them with `colorScheme` colors.
- For `BoxDecoration`, shadows, and gradients — use `colorScheme.blackOverlay10/20` etc.
- Light/dark awareness is automatic — `CustomColors` extension checks `brightness`.

---

## 13. Localization (i18n)

### Adding New Translations

1. **Check for duplicates**: Search existing keys in `assets/translations/en.json` before adding.

2. **Add to both files simultaneously**:
   - `assets/translations/en.json`: `"newKey": "English text"`
   - `assets/translations/tr.json`: `"newKey": "Turkce metin"`

3. **Regenerate keys**:
```bash
dart run easy_localization:generate -O lib/product/init/language -f keys -o locale_keys.g.dart --source-dir assets/translations
```

4. **Use in code**:
```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

Text(LocaleKeys.newKey.tr())
```

### Parameterized Translations

In JSON:
```json
"greeting": "Hello {name}!"
```

In code:
```dart
LocaleKeys.greeting.tr(namedArgs: {'name': userName})
```

### Rules
- **NEVER** use raw strings for user-visible text. Always use `LocaleKeys.xxx.tr()`.
- JSON keys are camelCase.
- Always add to BOTH `en.json` and `tr.json` simultaneously.
- Run the generate command immediately after modifying JSON files.
- Turkish translations should use raw Turkish characters in the JSON file (not Unicode escapes).
- **NEVER** edit `locale_keys.g.dart` manually — it is auto-generated.

---

## 14. Shared Widgets

**Location**: `lib/product/widget/`

### Drawer (`drawer.dart`)
- `AppDrawer` — the main navigation drawer.
- Uses `BlocBuilder<UserProfileCubit, UserProfileState>` for profile display in header.
- Navigation via `_navigateToRoute(context, AppRoutes.xxx)`.
- To add a new menu item, add a `_buildMenuItem(...)` call in the `ListView`.

### Common UI Patterns
- Card containers: `borderRadius: BorderRadius.circular(16)`, surface color + shadow.
- List tile leading icons: wrapped in colored container with `colorScheme.primary.withAlpha(26)`.
- Circular avatars: `ClipOval` + `Image.file` with `errorBuilder` fallback to `Icon`.
- Gradient backgrounds: `LinearGradient` using `colorScheme.gradientStart` / `gradientEnd`.
- Section titles: `Row` with `Icon` + `Text` using `colorScheme.onPrimaryContainer`.
- Destructive actions: Use `colorScheme.error` for text, icon, and border colors.

---

## 15. Naming & Coding Conventions

| Element | Convention | Example |
|---|---|---|
| Feature folder | snake_case | `invoice_form/` |
| Model file | `<name>_model.dart` | `user_profile_model.dart` |
| Model class | PascalCase + `Model` suffix | `UserProfileModel` |
| DAO file | `<name>_dao.dart` | `user_profile_dao.dart` |
| DAO class | PascalCase + `Dao` suffix | `UserProfileDao` |
| State file | `<name>_state.dart` | `user_profile_state.dart` |
| State class | PascalCase + `State` suffix | `UserProfileState` |
| Cubit file | `<name>_cubit.dart` | `user_profile_cubit.dart` |
| Cubit class | PascalCase + `Cubit` suffix | `UserProfileCubit` |
| Bloc file | `<name>_bloc.dart` | `prices_bloc.dart` |
| Bloc class | PascalCase + `Bloc` suffix | `PricesBloc` |
| View file | `<name>_view.dart` | `profile_edit_view.dart` |
| View class | PascalCase + `View` suffix | `ProfileEditView` |
| Mixin file | `<name>_view_mixin.dart` | `profile_edit_view_mixin.dart` |
| Route path | kebab-case with `/` prefix | `/profile/edit` |
| Route enum | camelCase | `profileEdit` |
| Locale key | camelCase | `profileSaved` |
| DB table | snake_case | `user_profile` |
| DB column | camelCase | `imagePath` |

### Class Modifiers
- Use `final class` for utility/container classes that should not be extended (`AppRouter`, `ProductContainer`, `ProductStateItems`).
- Use `const` constructors for all widgets and models when possible.
- Use `@immutable` annotation on configuration classes.

### Import Ordering
1. `dart:` imports
2. `package:flutter/` imports
3. `package:` third-party imports (alphabetical)
4. `package:wealth_calculator/` project imports (alphabetical)

---

## 16. Common Pitfalls & Rules

### DO
- Always use `BaseCubit` / `BaseBloc` — never raw `Cubit` / `Bloc`.
- Always register DAO **before** Cubit in `ProductContainer.setUp()` (order matters for DI resolution).
- Always handle `isClosed` via base class emit guard.
- Always `copyWith()` for state transitions — never mutate.
- Always dispose controllers in StatefulWidget mixins.
- Always wrap async cubit methods in try/catch with error state emission.
- Always use `const` keyword for widget constructors.
- Always use `AppRouter.push()` for navigation.
- Always run `flutter pub get` after adding new dependencies.
- Always regenerate locale keys after modifying translation files.

### DO NOT
- Do NOT hardcode colors, padding, or user-facing strings.
- Do NOT use `Navigator.push(MaterialPageRoute(...))` — use `AppRouter.push()`.
- Do NOT register feature-scoped blocs in GetIt (use `BlocProvider(create:)` instead).
- Do NOT edit `locale_keys.g.dart` — it is generated.
- Do NOT access `GetIt.I` directly in feature code — use `ProductStateItems` or constructor injection.
- Do NOT put business logic in view files — move it to the mixin.
- Do NOT import files in `part of` mixin files — all imports go in the parent view file.
- Do NOT use Unicode escapes in `tr.json` — use raw Turkish characters.

---

## 17. Git Workflow

### Branch Naming
- Feature: `feature/<short-description>` (e.g., `feature/user-profile`)
- Bug fix: `fix/<short-description>` (e.g., `fix/drawer-crash`)
- Refactor: `refactor/<short-description>` (e.g., `refactor/routing`)

### Commit Message Format (Conventional Commits)
```
feat: add user profile CRUD with image picker
fix: resolve drawer profile image not loading
refactor: migrate navigation to AppRouter
chore: bump AGP to 8.9.3 and Gradle to 8.11.1
```

### Development Flow
1. Create issue describing the task.
2. Create branch from `main`.
3. Implement following the Feature Checklist (Section 3).
4. Run `flutter analyze` — fix all new warnings.
5. Commit incrementally after each working step.
6. Open PR with description of changes.

---

## Quick Reference: Full Feature Example

To add a "Notes" feature with local database storage:

```
1.  Create lib/feature/notes/model/note_model.dart           (Equatable, toMap, fromMap, copyWith)
2.  Edit   lib/product/service/database_helper.dart           (version 9, CREATE TABLE notes, onCreate + onUpgrade)
3.  Create lib/product/service/notes_dao.dart                 (CRUD operations)
4.  Create lib/feature/notes/viewmodel/notes_state.dart       (NotesStatus enum, state with copyWith)
5.  Create lib/feature/notes/viewmodel/notes_cubit.dart       (extends BaseCubit, inject NotesDao)
6.  Edit   lib/product/state/container/product_state_container.dart  (registerSingleton NotesDao + registerLazySingleton NotesCubit)
7.  Edit   lib/product/state/container/product_state_items.dart      (add notesCubit static getter)
8.  Edit   lib/product/init/state_initialize.dart                     (add BlocProvider<NotesCubit>.value)
9.  Create lib/feature/notes/view/notes_view.dart              (part 'mixin/notes_view_mixin.dart')
10. Create lib/feature/notes/view/mixin/notes_view_mixin.dart (part of, UI builder methods)
11. Edit   lib/product/navigation/app_router.dart              (notes('/notes') enum value + switch case + import)
12. Edit   assets/translations/en.json + tr.json               (add all new keys)
13. Run    dart run easy_localization:generate ...              (regenerate locale keys)
14. Edit   lib/product/widget/drawer.dart                      (add menu item with AppRoutes.notes)
15. Run    flutter pub get                                     (if new packages added)
16. Run    flutter analyze                                     (verify zero new errors)
```
