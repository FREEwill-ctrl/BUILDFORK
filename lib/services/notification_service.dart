import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo_model.dart';

class NotificationService {
  static NotificationService? _instance;
  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }
  NotificationService._internal();

  static void setInstance(NotificationService instance) {
    _instance = instance;
  }

  final fln.FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    try {
      print('Creating notification channels...');
      
      // Create Pomodoro notification channel
      const fln.AndroidNotificationChannel pomodoroChannel = fln.AndroidNotificationChannel(
        'pomodoro_channel',
        'Pomodoro Notifications',
        description: 'Notifications for Pomodoro timer',
        importance: fln.Importance.max,
        playSound: true,
        sound: fln.RawResourceAndroidNotificationSound('bell_notification'),
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(pomodoroChannel);

      print('Pomodoro notification channel created successfully');

      // Create Todo notification channel
      const fln.AndroidNotificationChannel todoChannel = fln.AndroidNotificationChannel(
        'todo_channel',
        'Todo Notifications',
        description: 'Notifications for todo reminders',
        importance: fln.Importance.max,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(todoChannel);

      print('Todo notification channel created successfully');
    } catch (e) {
      print('Error creating notification channels: $e');
    }
  }

  void _onDidReceiveNotificationResponse(fln.NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo reminders',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
      sound: const fln.RawResourceAndroidNotificationSound('notification'),
    );

    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleTaskReminder(Todo todo) async {
    if (todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now())) {
      // Schedule notification 1 hour before due date
      final reminderTime = todo.dueDate!.subtract(const Duration(hours: 1));

      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: todo.id ?? 0,
          title: 'Task Reminder',
          body: 'Task "${todo.title}" is due in 1 hour',
          scheduledDate: reminderTime,
        );
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'todo_channel',
      'Todo Notifications',
      channelDescription: 'Notifications for todo reminders',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Show notification for Pomodoro session transitions
  Future<void> showPomodoroNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      print('Showing Pomodoro notification: $title - $body');
      
      final fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
          fln.AndroidNotificationDetails(
        'pomodoro_channel',
        'Pomodoro Notifications',
        channelDescription: 'Notifications for Pomodoro timer',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        playSound: true,
        sound: const fln.RawResourceAndroidNotificationSound('bell_notification'),
        enableVibration: true,
        enableLights: true,
        channelShowBadge: true,
      );

      final fln.NotificationDetails platformChannelSpecifics =
          fln.NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
      
      print('Pomodoro notification sent successfully');
    } catch (e) {
      print('Error showing Pomodoro notification: $e');
    }
  }
}