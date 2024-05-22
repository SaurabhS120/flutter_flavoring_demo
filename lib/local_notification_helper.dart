
import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavoring_demo/notification_helper_interface.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotificationHelper extends NotificationHelperInterface{
  Function? _onInboxCallback;
  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  String? _recentPayload;

  Future<void> setupFlutterNotifications() async {
    debugPrint("setupFlutterNotifications");
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        requestCriticalPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    isFlutterLocalNotificationsInitialized = true;
  }
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    debugPrint('onDidReceiveNotificationResponse');
    final String? payload = notificationResponse.payload;
    this._recentPayload = payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    flutterLocalNotificationsPlugin.cancelAll();
    _onInboxCallback?.call();
  }
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint('onDidReceiveLocalNotification');
    debugPrint('notification payload: $payload');
  }
  void showFlutterNotification({required int id,required String? title,required String? body,required String? imageUrl, String? notificationId,}) async {
    // debugPrint("notificationUrl : ${imageUrl}");
    // final bool hasNotificationImage = imageUrl?.isNotEmpty??false;
    // final Directory directory = await getApplicationDocumentsDirectory();
    // final file_extension = imageUrl?.split('.').last;
    // final String NOTIFICATION_FILE_PATH = '${directory.path}/notification_picture.$file_extension';
    // if(hasNotificationImage){
    //   try {
    //     await _downloadAndSavePicture(imageUrl, NOTIFICATION_FILE_PATH);
    //   } catch (e) {
    //     debugPrint("****************************************");
    //     debugPrint("error - cant download notification image");
    //     debugPrint(e.toString());
    //     debugPrint("****************************************");
    //   }
    // }
    flutterLocalNotificationsPlugin.show(
      hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            priority: Priority.high,
            importance:Importance.high,
            styleInformation: _buildBigPictureStyleInformation(
                title??"",
                body??"",
                '',//NOTIFICATION_FILE_PATH,
                false,//hasNotificationImage
            ),

            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'ic_launcher',
            color: const Color(0xff002719),
        ),
        iOS: DarwinNotificationDetails(
            threadIdentifier: "thread1",
            attachments: null,
            // hasNotificationImage?<DarwinNotificationAttachment>[
            //   DarwinNotificationAttachment(NOTIFICATION_FILE_PATH,hideThumbnail: false,),
            // ]:null
        )
      ),
      payload:notificationId,
    );
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  Future<void> setup() async{
    await setupFlutterNotifications();
  }

  @override
  Future<void> showNotification(RemoteMessage message) async{
    debugPrint("notification payload : ${message.data.toString()}");
    String? notificationId = message.data["image"] as String?;
    debugPrint("notificationId : $notificationId");
    String? imageUrl = message.data["imageUrl"] as String?;
    String? title = message.data["title"] as String?;
    String? body = message.data["body"] as String?;
    String? click_action = message.data["click_action"] as String?;
    String? sender_id = message.data["sender_id"] as String?;
    showFlutterNotification(
      id:notificationId.hashCode,
      title:title,
      body:body,
      imageUrl: imageUrl,
      notificationId:notificationId,
    );
  }
  @override
  void setInboxCallback(Function callback){
    _onInboxCallback = callback;
  }
  @override
  String? getNotificationId(){
    return _recentPayload;
  }

  @override
  Future<String?> getInitialMessage() async{
    return (await FirebaseMessaging.instance.getInitialMessage())?.data['image'] as String?;
  }
}
String? _getImageUrl(RemoteNotification notification) {
  if (Platform.isIOS && notification.apple != null) return notification.apple?.imageUrl;
  if (Platform.isAndroid && notification.android != null) return notification.android?.imageUrl;
  return null;
}
// Future<String?> _downloadAndSavePicture(String? url, String filePath) async {
//   Uri? uri = (url !=null) ? Uri.tryParse(url) : null;
//   if(uri == null) return null;
//   final response = await get(uri);
//   final File file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }
BigPictureStyleInformation? _buildBigPictureStyleInformation(
    String title,
    String body,
    String? picturePath,
    bool showBigPicture,
    ) {
  if (picturePath == null) return null;
  final FilePathAndroidBitmap filePath = FilePathAndroidBitmap(picturePath);
  return BigPictureStyleInformation(
    showBigPicture ? filePath : const FilePathAndroidBitmap("empty"),
    largeIcon: filePath,
    contentTitle: title,
    htmlFormatContentTitle: true,
    summaryText: body,
    htmlFormatSummaryText: true,
  );
}