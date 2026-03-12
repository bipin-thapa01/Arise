import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/LoginPage/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final storage = FlutterSecureStorage();

  Future<void> _logout() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: Text("Settings")),
        SliverToBoxAdapter(
          child: ElevatedButton(
            onPressed: () {
              _logout();
              storage.delete(key: 'user');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            child: Text("Logout"),
          ),
        ),
      ],
    );
  }
}
