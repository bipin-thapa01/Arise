import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotification {
  final msgService = FirebaseMessaging.instance;

  initFCM() async {
    await msgService.requestPermission();
    var token = await msgService.getToken();
    FirebaseMessaging.onBackgroundMessage(handleNotification);
    FirebaseMessaging.onMessage.listen(handleNotification);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"fcmToken": token});
  }
}

Future<void> handleNotification(RemoteMessage msg) async {}
