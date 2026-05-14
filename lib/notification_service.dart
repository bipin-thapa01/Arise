// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final NotificationService instance = NotificationService._internal();
//
//   factory NotificationService() {
//     return instance;
//   }
//
//   NotificationService._internal();
//
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   Future<void> initNotification() async {
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidInitializationSettings);
//
//     await notificationsPlugin.initialize(settings: initializationSettings);
//
//     tz.initializeTimeZones();
//   }
//
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     await notificationsPlugin.zonedSchedule(
//       id: id,
//       title: title,
//       body: body,
//       scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
//       notificationDetails: const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'task_channel',
//           'Task Notifications',
//           channelDescription: 'Notification for tasks and events',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }
//
//   Future<void> scheduleDailyNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime time,
//   }) async {
//     final now = DateTime.now();
//
//     DateTime scheduledDate = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//
//     await notificationsPlugin.zonedSchedule(
//       id: id,
//       title: title,
//       body: body,
//       scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
//       notificationDetails: const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_channel',
//           'Daily Notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   Future<void> cancelNotification(int id) async {
//     await notificationsPlugin.cancel(id: id);
//   }
//
//   Future<void> cancelAllNotifications() async {
//     await notificationsPlugin.cancelAll();
//   }
// }
