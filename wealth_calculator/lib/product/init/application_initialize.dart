import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
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
  static Future<void> _init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [LevelMessages.error];

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize notification service
    await NotificationService.init();

    // Initialize database
    await DbHelper.instance.database;
  }
}
