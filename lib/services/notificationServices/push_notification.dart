import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_cropper/image_cropper.dart';

class PushNotification {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  //request notification permission

  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    //get device fcm token
    final token = await _firebaseMessaging.getToken().then((value) {
      devtools.log("Token2: $value");
    });
  }

  initInfo() {
    var androidInit =
        const AndroidInitializationSettings('@mipmap-hdpi/launcher_icon');
    var iOSInit = const DarwinInitializationSettings();
    var initSettings =
        InitializationSettings(android: androidInit, iOS: iOSInit);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
        // TODO: Handle this case.
      }
    });
  }
}
