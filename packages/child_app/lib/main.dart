import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared/services/firebase_service.dart';
import 'package:shared/services/hive_service.dart';
import 'package:shared/utils/logger.dart';
import 'app.dart';
import 'core/services/work_manager_service.dart';

/// Global notification plugin instance for the child app.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// WorkManager callback dispatcher — must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await FirebaseService.instance.initialize();
      await Hive.initFlutter();
      await HiveService().initialize();

      return await WorkManagerService.handleBackgroundTask(
        taskName,
        inputData,
      );
    } catch (e, stackTrace) {
      AppLogger.e('WorkManager', 'Background task failed: $taskName', e, stackTrace);
      return false;
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for the child device
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await FirebaseService.instance.initialize();

  // Initialize Hive for local caching and pending sync queue
  await Hive.initFlutter();
  await HiveService().initialize();

  // Initialize local notifications (for foreground service notification)
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Initialize WorkManager for periodic background sync
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  runApp(const ProviderScope(child: StudyGuardianChildApp()));
}
