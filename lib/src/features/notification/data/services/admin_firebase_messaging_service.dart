import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kc_admin/src/features/notification/data/repositories/admin_device_token_repository.dart';
import '../../../../../firebase_options.dart';

/// Top-level background message handler for FCM in Admin app.
@pragma('vm:entry-point')
Future<void> adminFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint('[FCM Admin Background] Received message: ${message.messageId}');
  }
}

/// Service handling FCM messaging initialization, permissions, and tokens for KC-Admin.
class AdminFirebaseMessagingService {
  AdminFirebaseMessagingService({
    FirebaseMessaging? messaging,
    AdminDeviceTokenRepository? deviceTokenRepository,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _deviceTokenRepository =
           deviceTokenRepository ?? AdminDeviceTokenRepository(),
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final AdminDeviceTokenRepository _deviceTokenRepository;
  final FlutterLocalNotificationsPlugin _localNotifications;

  String? _currentToken;
  bool _isInitialized = false;

  String? get currentToken => _currentToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'admin_updates',
    'Admin Notifications & Order Alerts',
    description:
        'Notifications for boutique admin management and new order alerts',
    importance: Importance.max,
  );

  Future<NotificationSettings> getPermissionStatus() async {
    return await _messaging.getNotificationSettings();
  }

  Future<NotificationSettings> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint(
          '[AdminFirebaseMessagingService] permission_handler status: $status',
        );
      }
      return await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AdminFirebaseMessagingService] Permission request failed: $e',
        );
      }
      return await _messaging.getNotificationSettings();
    }
  }

  Future<void> initialize({
    required String adminId,
    String? firebaseUid,
  }) async {
    if (_isInitialized) {
      if (adminId.isNotEmpty) {
        await _registerTokenForUser(adminId: adminId, firebaseUid: firebaseUid);
      }
      return;
    }

    try {
      // Auto request notification permission on initialization
      await requestPermission();

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _localNotifications.initialize(initSettings);

      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title =
            message.notification?.title ?? message.data['title'] as String?;
        final body =
            message.notification?.body ?? message.data['body'] as String?;

        if (kDebugMode) {
          debugPrint('[FCM Admin Foreground] Received: $title - $body');
        }

        if (title != null && title.isNotEmpty && !kIsWeb) {
          _localNotifications.show(
            message.hashCode,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      if (adminId.isNotEmpty) {
        await _registerTokenForUser(adminId: adminId, firebaseUid: firebaseUid);
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        _currentToken = newToken;
        if (adminId.isNotEmpty) {
          await _deviceTokenRepository.registerToken(
            uid: firebaseUid ?? adminId,
            role: 'admin',
            appId: 'kc_admin',
            token: newToken,
          );
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AdminFirebaseMessagingService] Initialization error: $e');
      }
    }
  }

  Future<void> _registerTokenForUser({
    required String adminId,
    String? firebaseUid,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _deviceTokenRepository.registerToken(
          uid: firebaseUid ?? user.uid,
          role: 'admin',
          appId: 'kc_admin',
          token: token,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AdminFirebaseMessagingService] Token registration failed: $e',
        );
      }
    }
  }

  Future<void> onLogout() async {
    if (_currentToken != null) {
      try {
        await _deviceTokenRepository.deactivateToken(_currentToken!);
      } catch (_) {}
      _currentToken = null;
    }
  }
}
