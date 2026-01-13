import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wealth_calculator/firebase_options.dart';
import 'package:wealth_calculator/product/init/config/product_environment.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
import 'package:wealth_calculator/product/cache/product_cache.dart';
import 'package:wealth_calculator/product/state/container/product_state_container.dart';
import 'package:wealth_calculator/product/state/viewmodel/product_viewmodel.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:easy_logger/easy_logger.dart';

/// Application initialization manager
/// Handles all initialization tasks before app starts
@immutable
final class ApplicationInitialize {
  /// Starts the application by initializing necessary configurations.
  Future<void> startApplication() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runZoned<Future<void>>(() async {
      await _init();
    });
  }

  /// Initialize all required services
  Future<void> _init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [LevelMessages.error];

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _setupConfigAndGetit();

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize notification service
    await NotificationService.init();

    // Initialize database
    await DbHelper.instance.database;

    // Load saved theme preference
    await _loadThemePreference();
  }

  /// Loads the saved theme preference from cache
  Future<void> _loadThemePreference() async {
    final productCache = ProductContainer.read<ProductCache>();
    final savedThemeMode = productCache.getThemeMode();

    if (savedThemeMode != null) {
      final productViewmodel = ProductContainer.read<ProductViewmodel>();
      productViewmodel.changeThemeMode(themeMode: savedThemeMode);
    }
  }

  /// Burada çağırılma sıraları önemlidir. Env değişkenleri Getit içinde kullanılabilir olmalıdır.
  Future<void> _setupConfigAndGetit() async {
    /// Set up environment configurations
    ProductEnvironment.general();

    /// Initialize Getit and cache
    ProductContainer.setUp();
  }
}
