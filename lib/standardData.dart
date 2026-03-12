import 'package:flutter/material.dart';

class StandardData {
  //name part
  static const String appName = "App Name";

  //colors part
  static const Color primaryColor = Colors.deepPurpleAccent;
  static const Color backgroundColor1 = Color(0xFF292929);
  static const Color mainColor = Color(0xFF151515);
  static const Color buttonColor1 = Color(0xFF333333);
  static const Color iconColor1 = Colors.blueAccent;
  static const Color iconColor2 = Colors.orangeAccent;

  //url
  static const String homeIp = "192.168.1.67";
  static const String emulatorIp = "10.0.2.2";
  static const String baseUrl = "http://$homeIp:8080";

  static void errorSnackbar(final context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error Fetching Data!")));
  }
}
