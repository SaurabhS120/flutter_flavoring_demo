import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_flavoring_demo/push_notification_error.dart';

abstract class PushNotificationRepo{

  Future<Either<PushNotificationError, Stream<bool>>> setupFirebaseMessaging();

  Either<PushNotificationError, String?> getToken();

  Either<PushNotificationError, String?> getNotificationId();

}