import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Application initialization manager
/// Handles all initialization tasks before app starts
@immutable
final class ApplicationInitialize {
  const ApplicationInitialize._();

  /// Initialize all required services
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize timezone data
    tz.initializeTimeZones();

    // Initialize notification service
    await NotificationService.init();

    // Initialize database
    await DbHelper.instance.database;
  }
}
