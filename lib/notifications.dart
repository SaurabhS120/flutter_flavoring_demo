
import 'package:flutter_flavoring_demo/firebase_messaging_helper.dart';
import 'package:flutter_flavoring_demo/local_notification_helper.dart';
import 'package:flutter_flavoring_demo/notification_helper_interface.dart';
import 'package:flutter_flavoring_demo/push_notifcation_repo.dart';
import 'package:flutter_flavoring_demo/push_notification_repo_impl.dart';

class NotificationsDI{
  static NotificationHelperInterface? _notificationHelper;
  static NotificationHelperInterface getNotificationHelper(){
    if(_notificationHelper==null){
      _notificationHelper = LocalNotificationHelper();
    }
    return _notificationHelper!;
  }
  static FirebaseCloudMessagingHelper? _firebaseCloudMessagingHelper;
  static FirebaseCloudMessagingHelper getCloudMessagingHelper(){
    if(_firebaseCloudMessagingHelper==null){
      _firebaseCloudMessagingHelper = FirebaseCloudMessagingHelper(notificationHelper: NotificationsDI.getNotificationHelper());
    }
    return _firebaseCloudMessagingHelper!;
  }
}
//
// /// inject [BenefitPayRepo] provider
// var pushNotificationRepoProvider = Provider<PushNotificationRepo>(
//       (ref) => FirebasePushNotificationRepoImpl(notificationHelper: NotificationsDI.getNotificationHelper()),
// );