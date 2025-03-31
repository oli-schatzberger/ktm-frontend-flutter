import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Optional: handle local notification tapped when app is in foreground
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    // Combine Android & iOS
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      // Optional: handle notification tapped on Android/iOS
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Channel for default notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID (unique per notification)
      title,
      body,
      notificationDetails,
    );
  }

  /// iOS < 10 (optional, rarely needed nowadays)
  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle foreground notification tapped on iOS versions < 10
  }

  /// Called when the user taps on a notification
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    // Handle notification tap action (Android & iOS)
    final String? payload = notificationResponse.payload;
    // You can route to specific pages or perform actions here
  }
}
