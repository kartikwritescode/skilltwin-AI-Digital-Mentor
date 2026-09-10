import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/storage/storage_provider.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  debugPrint('🔥 [FCM Background] Message ID: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sharedPreferences = await SharedPreferences.getInstance();
  await NotificationService.instance.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FCM Permissions & Configuration
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Fetch and store FCM Token
    final fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      await sharedPreferences.setString('fcm_token', fcmToken);
      debugPrint('\n======================================================');
      debugPrint('🔥 [FCM REGISTRATION TOKEN FOR TESTING]:');
      debugPrint(fcmToken);
      debugPrint('======================================================\n');
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground FCM messages via local notification banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔥 [FCM Foreground] Received: ${message.notification?.title}');
      final notification = message.notification;
      if (notification != null) {
        NotificationService.instance.showRemoteNotification(
          title: notification.title ?? 'SkillTwin Notification',
          body: notification.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handle tap on notification when app was opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔥 [FCM Opened] User tapped push notification: ${message.data}');
    });
  } catch (e) {
    debugPrint('Firebase/FCM setup notice: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SkillTwinApp(),
    ),
  );
}

class SkillTwinApp extends ConsumerWidget {
  const SkillTwinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SkillTwin',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
