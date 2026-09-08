import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../notifications/notification_messages.dart';

/// Service managing native Android notifications and scheduled daily/trolling reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'skilltwin_daily_reminders';
  static const String channelName = 'SkillTwin Daily & Trolling Reminders';
  static const String channelDesc =
      'High-yield morning practice reminders and end-of-day trolling notifications to keep you on schedule.';

  bool _isInitialized = false;

  /// Initializes timezone data, Android notification channel, and requests Android 13+ permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('User tapped notification: ${response.payload}');
        },
      );

      // Create high-importance notification channel on Android
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

        // Request POST_NOTIFICATIONS permission on Android 13+ (API 33+)
        if (Platform.isAndroid) {
          await androidImplementation.requestNotificationsPermission();
        }
      }

      _isInitialized = true;
      debugPrint('NotificationService successfully initialized.');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Triggers an immediate native notification with a random trolling roast.
  /// Used for instant user testing and interactive verification.
  Future<void> showInstantTrollNotification({
    String? topicTitle,
    int? backlogCount,
    int? dailyMinutes,
  }) async {
    await initialize();

    final msg = (backlogCount != null && backlogCount > 0)
        ? NotificationMessages.getRandomMessage(
            NotificationCategory.backlogRoast,
            topic: topicTitle,
            backlog: backlogCount,
            mins: dailyMinutes,
          )
        : NotificationMessages.getRandomMessage(
            NotificationCategory.endOfDayTrolling,
            topic: topicTitle,
            backlog: backlogCount,
            mins: dailyMinutes,
          );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(msg.body),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 999, // instant test notification ID
      title: msg.title,
      body: msg.body,
      notificationDetails: notificationDetails,
      payload: 'action_topic_test',
    );
  }

  /// Schedules daily native reminders on Android:
  /// - Morning Reminder at 10:00 AM: Motivates daily practice on the pending topic.
  /// - Evening Trolling Roast at 9:00 PM: Sarcastic notification if today's study is not finished.
  Future<void> scheduleDailyStudyReminders({
    required String pendingTopicTitle,
    int backlogCount = 0,
    int dailyMinutes = 30,
  }) async {
    await initialize();

    final morningMsg = NotificationMessages.getRandomMessage(
      NotificationCategory.morningTaskReminder,
      topic: pendingTopicTitle,
      backlog: backlogCount,
      mins: dailyMinutes,
    );

    final eveningMsg = (backlogCount > 0)
        ? NotificationMessages.getRandomMessage(
            NotificationCategory.backlogRoast,
            topic: pendingTopicTitle,
            backlog: backlogCount,
            mins: dailyMinutes,
          )
        : NotificationMessages.getRandomMessage(
            NotificationCategory.endOfDayTrolling,
            topic: pendingTopicTitle,
            backlog: backlogCount,
            mins: dailyMinutes,
          );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(morningMsg.body),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule 10:00 AM Morning Reminder
    try {
      await _notificationsPlugin.zonedSchedule(
        id: 1001, // morning notification ID
        title: morningMsg.title,
        body: morningMsg.body,
        scheduledDate: _nextInstanceOfTime(10, 0),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'morning_study_reminder',
      );

      // Schedule 9:00 PM Evening Trolling Notification
      final eveningAndroidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(eveningMsg.body),
      );

      await _notificationsPlugin.zonedSchedule(
        id: 1002, // evening trolling notification ID
        title: eveningMsg.title,
        body: eveningMsg.body,
        scheduledDate: _nextInstanceOfTime(21, 0),
        notificationDetails: NotificationDetails(android: eveningAndroidDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'evening_trolling_reminder',
      );

      debugPrint('Scheduled morning reminder (10:00 AM) and evening roast (9:00 PM).');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  /// Triggers a notification for an incoming remote message (e.g. Firebase Cloud Messaging).
  Future<void> showRemoteNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(body),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload ?? 'fcm_remote_message',
    );
  }

  /// Cancels all scheduled reminders.
  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Computes the next occurrence of [hour]:[minute] in the local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
