import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/LoginPage/login_page.dart';
import 'package:fitness/standardData.dart';
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
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("View Logs")],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: StandardData.primaryColor.withAlpha(100),
              ),
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
        ),
      ],
    );
  }
}
