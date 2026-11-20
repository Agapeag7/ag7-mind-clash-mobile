import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static const int _reminderId = 7001;
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool remindersEnabled = true;
  static bool _initialized = false;
  static bool _permissionGranted = false;

  static Future<void> initialize({required bool enabled}) async {
    remindersEnabled = enabled;
    if (!_isSupportedPlatform) {
      remindersEnabled = false;
      return;
    }

    final initialized = await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    if (initialized != true) {
      throw StateError('Impossible d’initialiser les notifications locales.');
    }
    _initialized = true;

    if (enabled) {
      _permissionGranted = await _requestPermission();
      if (_permissionGranted) {
        await scheduleDailyReminder();
      } else {
        remindersEnabled = false;
      }
    }
  }

  static Future<bool> setEnabled(bool enabled) async {
    if (!_initialized) {
      throw StateError('Les notifications locales ne sont pas initialisées.');
    }

    if (!enabled) {
      remindersEnabled = false;
      await _plugin.cancel(id: _reminderId);
      return true;
    }

    _permissionGranted = await _requestPermission();
    if (!_permissionGranted) {
      remindersEnabled = false;
      return false;
    }

    remindersEnabled = true;
    await scheduleDailyReminder();
    return true;
  }

  static Future<void> scheduleDailyReminder() async {
    if (!remindersEnabled || !_permissionGranted || !_initialized) return;

    await _plugin.cancel(id: _reminderId);
    await _plugin.periodicallyShow(
      id: _reminderId,
      title: 'Une petite partie ?',
      body: 'AG7 Mind Clash t’attend pour un nouveau duel de calcul !',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_game_reminder',
          'Rappel quotidien',
          channelDescription: 'Un rappel pour faire une partie chaque jour.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<bool> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  static bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
