import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_flavoring_demo/firebase_messaging_helper.dart';
import 'package:flutter_flavoring_demo/notification_helper_interface.dart';
import 'package:flutter_flavoring_demo/push_notifcation_repo.dart';
import 'package:flutter_flavoring_demo/push_notification_error.dart';
import 'package:rxdart/rxdart.dart';
class FirebasePushNotificationRepoImpl implements PushNotificationRepo{

  final PublishSubject<bool> _notificationReceiveSubject = PublishSubject<bool>();
  Stream<bool> get _notificationReceiveStream => _notificationReceiveSubject.stream;

  final NotificationHelperInterface notificationHelper;
  late FirebaseCloudMessagingHelper firebaseCloudMessagingHelper;

  FirebasePushNotificationRepoImpl({required this.notificationHelper}){
    firebaseCloudMessagingHelper =  FirebaseCloudMessagingHelper(notificationHelper: notificationHelper);
  }

  Future<Either<PushNotificationError, Stream<bool>>> setupFirebaseMessaging()async{
    await firebaseCloudMessagingHelper.setupFirebaseMessaging();
    firebaseCloudMessagingHelper.setInboxCallback(onNotificationReceive);
    try{
      return Right(_notificationReceiveStream);
    }on Exception catch(e){
      return Left(PushNotificationError(message: 'Cant setup push notification', pushNotificationError: 0, cause: e),);
    }
  }

  Either<PushNotificationError, String?> getToken(){
    return Right(firebaseCloudMessagingHelper.getToken());
  }

  Either<PushNotificationError, String?> getNotificationId(){
    return Right(firebaseCloudMessagingHelper.getNotificationId());
  }

  void onNotificationReceive(){
    if(!_notificationReceiveSubject.isClosed){
      _notificationReceiveSubject.add(true);
    }
  }

}