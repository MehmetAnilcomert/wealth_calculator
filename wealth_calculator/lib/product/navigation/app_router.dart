import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/splash/view/splash_view.dart';
import 'package:wealth_calculator/feature/prices/view/prices_view.dart';
import 'package:wealth_calculator/feature/inventory/view/inventory_view.dart';
import 'package:wealth_calculator/feature/invoice/view/invoice_view.dart';
import 'package:wealth_calculator/feature/invoice/view/invoice_adding_view.dart';
import 'package:wealth_calculator/feature/settings/view/settings_view.dart';

/// Application route names
enum AppRoutes {
  splash('/'),
  prices('/prices'),
  inventory('/inventory'),
  invoice('/invoice'),
  invoiceAdd('/invoice/add'),
  settings('/settings');

  const AppRoutes(this.path);
  final String path;
}

/// Application router configuration
@immutable
final class AppRouter {
  const AppRouter._();

  /// Get initial route
  static String get initialRoute => AppRoutes.splash.path;

  /// Generate routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute<void>(
          builder: (_) => const SplashView(),
        );
      case '/prices':
        return MaterialPageRoute<void>(
          builder: (_) => const PricesView(),
        );
      case '/inventory':
        return MaterialPageRoute<void>(
          builder: (_) => const InventoryView(),
        );
      case '/invoice':
        return MaterialPageRoute<void>(
          builder: (_) => const InvoiceView(),
        );
      case '/invoice/add':
        return MaterialPageRoute<void>(
          builder: (_) => const InvoiceAddingView(),
        );
      case '/settings':
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsView(),
        );
      default:
        return null;
    }
  }

  /// Navigate to a route
  static Future<T?> push<T>(BuildContext context, AppRoutes route) {
    return Navigator.pushNamed<T>(context, route.path);
  }

  /// Replace current route
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    AppRoutes route, {
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      route.path,
      result: result,
    );
  }

  /// Pop current route
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
