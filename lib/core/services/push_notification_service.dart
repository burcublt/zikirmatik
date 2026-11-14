import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => FirebasePushNotificationService(),
);

abstract interface class PushNotificationService {
  Future<bool> enable();
  Future<void> restore();
  Future<void> disable();
}

class PushNotificationSetupException implements Exception {
  const PushNotificationSetupException();
}

class FirebasePushNotificationService implements PushNotificationService {
  static const _topic = 'announcements';
  static const _channel = AndroidNotificationChannel(
    _topic,
    'Announcements',
    description: 'Zikirmatik announcements',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future<void>? _localNotificationsInitialization;
  StreamSubscription<RemoteMessage>? _foregroundMessages;

  Future<FirebaseMessaging> _messaging() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw UnsupportedError(
        'Push notifications are supported on Android and iOS only.',
      );
    }

    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } on FirebaseException {
      throw const PushNotificationSetupException();
    }
    return FirebaseMessaging.instance;
  }

  Future<void> _initializeLocalNotifications() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_reminder'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
  }

  @override
  Future<bool> enable() async {
    final messaging = await _messaging();
    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return false;
    }

    await _activate(messaging);
    return true;
  }

  @override
  Future<void> restore() async {
    await _activate(await _messaging());
  }

  Future<void> _activate(FirebaseMessaging messaging) async {
    try {
      await (_localNotificationsInitialization ??=
          _initializeLocalNotifications());
    } catch (_) {
      _localNotificationsInitialization = null;
      rethrow;
    }
    await messaging.setAutoInitEnabled(true);
    try {
      await messaging.subscribeToTopic(_topic);
      _foregroundMessages ??= FirebaseMessaging.onMessage.listen(
        _showForegroundNotification,
      );
    } catch (_) {
      await messaging.setAutoInitEnabled(false);
      rethrow;
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    try {
      await _localNotifications.show(
        id:
            (message.messageId?.hashCode ??
                DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _topic,
            'Announcements',
            channelDescription: 'Zikirmatik announcements',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'push notifications',
          context: ErrorDescription('while showing a foreground message'),
        ),
      );
    }
  }

  @override
  Future<void> disable() async {
    final messaging = await _messaging();
    await messaging.unsubscribeFromTopic(_topic);
    await messaging.unregister();
    await messaging.setAutoInitEnabled(false);
    await _foregroundMessages?.cancel();
    _foregroundMessages = null;
  }
}
