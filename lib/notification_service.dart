import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

final FlutterLocalNotificationsPlugin localNotifs =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: android);
  await localNotifs.initialize(settings: settings);
}

Future<void> checkAppVersion(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ),
  );
  await remoteConfig.fetchAndActivate();

  final latestVersion = remoteConfig.getString("latestVersion");

  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  if (_isOutdated(currentVersion, latestVersion)) {
    await _showUpdateNotification();
    if (context.mounted) {
      _showUpdateDialog(context);
    }
  }
}

Future<void> _showUpdateNotification() async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'update_channel',
      'App Updates',
      channelDescription: 'Notifications for app updates',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  await localNotifs.show(
    id: 0,
    title: 'Update Available 🎉',
    body: 'A new version of the app is available. Please update!',
    notificationDetails: details,
  );
}

void _showUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Update Available 🎉'),
      content: const Text(
        'A new version of the app is available. '
        'Please update to continue using the app.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            launchUrl(
              Uri.parse("https://github.com/bipin-thapa01/Arise/releases"),
            );
          },
          child: const Text('Update Now'),
        ),
      ],
    ),
  );
}

bool _isOutdated(String current, String latest) {
  final c = current.split(".").map(int.parse).toList();
  final l = latest.split(".").map(int.parse).toList();
  for (int i = 0; i < l.length; i++) {
    final cv = i < c.length ? c[i] : 0;
    final lv = l[i];
    if (cv < lv) return true;
    if (cv > lv) return false;
  }
  return false;
}
