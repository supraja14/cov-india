import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coronavirus_test/localization.dart';

viewHandNotification(context) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1', 'Wash Hand', 'Frequent nudging for Hand wash habit',
      importance: Importance.High,
      priority: Priority.High,
      enableVibration: true,
      style: AndroidNotificationStyle.BigText);
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0,
      AppLocalizations.of(context).translate('hand_wash_noti_title'),
      AppLocalizations.of(context).translate('hand_wash_noti_subtitle'),
      platformChannelSpecifics,
      payload: "noti_hand_wash");
}

scheduleHandNotification(context) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1', 'Wash Hand Notification', 'Frequent nudging for Hand wash habit',
      importance: Importance.High,
      priority: Priority.High,
      enableVibration: true,
      style: AndroidNotificationStyle.BigText);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      AppLocalizations.of(context).translate('hand_wash_noti_title'),
      AppLocalizations.of(context).translate('hand_wash_noti_subtitle'),
      RepeatInterval.Hourly,
      platformChannelSpecifics,
      payload: "noti_hand_wash");
}
