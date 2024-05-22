
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavoring_demo/notification_helper_interface.dart';
import 'package:flutter_flavoring_demo/notifications.dart';

class FirebaseCloudMessagingHelper{
  final NotificationHelperInterface notificationHelper;

  FirebaseCloudMessagingHelper({required this.notificationHelper});

  Future<void> setupFirebaseMessaging()async{

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint("FCM token : $token");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
        debugPrint('Message also contained a notification: ${message.notification}');
        firebaseMessagingBackgroundHandler(message);
    });
    // Set the background messaging handler  early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      await notificationHelper.setup();
    }
  }


  String old_msg_id = '';

  void setInboxCallback(Function callback){
    notificationHelper.setInboxCallback(callback);
  }

  String? getToken(){
    FirebaseMessaging.instance.getToken();
  }

  String? getNotificationId(){
    return notificationHelper.getNotificationId();
  }

  Future<String?> getInitialMessage(){
    return notificationHelper.getInitialMessage();
  }

}

//On Notification
// It must not be an anonymous function.
// It must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("_firebaseMessagingBackgroundHandler");
  await Firebase.initializeApp();
  NotificationHelperInterface notificationHelperInterface = NotificationsDI.getNotificationHelper();
  await notificationHelperInterface.setup();
  await notificationHelperInterface.showNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message ${message.messageId}');
}