import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:blud_flutter/core/network/dio_client.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.notification?.title}');
      }
      // You can show a local notification here if needed
    });

    // Handle message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened from background: ${message.data}');
      }
      // Navigate to specific screen based on message data
    });
  }

  static Future<String?> getToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) return null;
      }
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  static Future<void> updateTokenOnServer() async {
    final token = await getToken();
    if (token != null) {
      try {
        final api = DioClient();
        await api.dio.post('/fcm-token', data: {'fcm_token': token});
        if (kDebugMode) {
          print('FCM Token updated on server: $token');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating FCM token on server: $e');
        }
      }
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
