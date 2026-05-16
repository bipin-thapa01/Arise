import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitness/Screens/no_internet.dart';
import 'package:fitness/Screens/splash_screen.dart';
import 'package:fitness/connectivity_service.dart';
import 'package:fitness/firebase_notification.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child;
  const ConnectivityGate({super.key, required this.child});

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  bool _isConnected = true;
  bool _hasChecked = false;
  late StreamSubscription<bool> _sub;

  @override
  void initState() {
    super.initState();

    // Immediate one-time check on open
    ConnectivityService.instance.checkNow().then((status) {
      if (mounted) {
        setState(() {
          _isConnected = status;
          _hasChecked = true;
        });
        if (status) FirebaseNotification().initFCM();
      }
    });

    // Listen for ongoing changes (WiFi drops mid-session etc.)
    _sub = ConnectivityService.instance.onStatusChange.listen((status) {
      if (mounted) {
        setState(() => _isConnected = status);
        if (status) FirebaseNotification().initFCM();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasChecked) return const SplashScreen();
    if (!_isConnected) return const NoInternet();
    return widget.child;
  }
}
