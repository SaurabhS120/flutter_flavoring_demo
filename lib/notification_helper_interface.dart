import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationHelperInterface{
  Future<void> setup();
  Future<void> showNotification(RemoteMessage message);
  void setInboxCallback(Function callback);
  String? getNotificationId();
  Future<String?> getInitialMessage();
}