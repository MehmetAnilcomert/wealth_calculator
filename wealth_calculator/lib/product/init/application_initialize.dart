import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/init/config/product_environment.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:easy_logger/easy_logger.dart';
import 'package:wealth_calculator/product/state/container/product_state_container.dart';

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

    _setupConfigAndGetit();

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize notification service
    await NotificationService.init();

    // Initialize database
    await DbHelper.instance.database;
  }

  /// Burada çağırılma sıraları önemlidir. Env değişkenleri Getit içinde kullanılabilir olmalıdır.
  void _setupConfigAndGetit() {
    /// Set up environment configurations
    ProductEnvironment.general();

    /// Initialize Getit
    ProductContainer.setUp();
  }
}
