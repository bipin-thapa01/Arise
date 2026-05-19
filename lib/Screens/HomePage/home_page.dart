import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/FoodBarcode/food_barcode.dart';
import 'package:fitness/Screens/FoodSearch/food_search.dart';
import 'package:fitness/Screens/HomePage/home_page_appbar.dart';
import 'package:fitness/Screens/HomePage/home_page_calorie.dart';
import 'package:fitness/Screens/HomePage/home_page_log.dart';
import 'package:fitness/Screens/HomePage/home_page_notification.dart';
import 'package:fitness/Screens/HomePage/home_page_skill.dart';
import 'package:fitness/Screens/HomePage/home_page_workout.dart';
import 'package:fitness/Screens/LoginPage/login_page.dart';
import 'package:fitness/Screens/More/more.dart';
import 'package:fitness/Screens/Progress/calendar.dart';
import 'package:fitness/Screens/Workout/workout.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? data;
  Map<String, dynamic> dailyDetails = {"consumed": 0.0, "water": 0, "steps": 0};
  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _checkDetails(final id) async {
    try {
      //for fetching daily details
      String today = DateTime.now().toIso8601String().split("T")[0];
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("dailyDetails")
          .doc(today)
          .get();

      if (doc.exists) {
        setState(() {
          dailyDetails = doc.data() ?? dailyDetails;
        });
      } else {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .collection("dailyDetails")
            .doc(today)
            .set({
              "consumed": 0.0,
              "water": 0.0,
              "steps": 0,
              "date": today,
              "createdAt": FieldValue.serverTimestamp(),
              "habitsCompleted": 0,
            });
        setState(() {
          dailyDetails = {
            "consumed": 0.0,
            "water": 0.0,
            "steps": 0,
            "date": today,
            "createdAt": FieldValue.serverTimestamp(),
            "habitsCompleted": 0,
          };
        });
      }

      //for fetching habits
      final habitsDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("habits")
          .get();
      if (habitsDoc.docs.isNotEmpty) {
        setState(() {
          habits = habitsDoc.docs
              .map(
                (doc) => {
                  "name": doc.data()["name"],
                  "currentStreak": doc.data()["currentStreak"],
                },
              )
              .toList();
        });
      } else {}
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  Future<void> _fetch() async {
    setState(() {
      dailyDetails = {
        'calorieExpend': 0.0,
        'calorieConsumed': 0.0,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };
    });
    final bool isAlreadySet = await storage.containsKey(key: "dailyDetails");
    if (!isAlreadySet) {
      storage.write(
        key: "dailyDetails",
        value: jsonEncode({
          'calorieExpend': 0.0,
          'calorieConsumed': 0.0,
          'date': DateTime.now().toIso8601String().split('T')[0],
        }),
      );
    }
    String today = DateTime.now().toIso8601String().split('T')[0];

    User? user = FirebaseAuth.instance.currentUser;

    final id = user?.uid;

    _checkDetails(id);

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .get();

    if (user == null || !userDoc.exists) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }

    final initialDoc = await FirebaseFirestore.instance
        .collection("initialData")
        .doc(id)
        .get();

    if (!initialDoc.exists) {}

    setState(() {
      data = {
        "email": userDoc.data()!["email"],
        "name": userDoc.data()!['displayName'],
      };
      dailyDetails = initialDoc.data() ?? dailyDetails;
    });
    if (initialDoc.data() != null) {
      await storage.write(
        key: "dailyDetails",
        value: initialDoc.data().toString(),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Scaffold(
        body: Center(
          child: SpinKitThreeBounce(
            color: StandardData.primaryColor,
            size: 30.0,
          ),
        ),
      );
    }

    bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      floatingActionButton: keyboardOpen
          ? null
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: StandardData.primaryColor.withAlpha(200),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 30,
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.35,
                        expand: false,
                        builder: (context, scrollController) {
                          return HomePageQRPopup();
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.qr_code_scanner),
                style: IconButton.styleFrom(
                  backgroundColor: StandardData.primaryColor,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: Theme.of(context).primaryColor,
        indicatorColor: Theme.of(context).primaryColor,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard,
              color: StandardData.primaryColor,
            ),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: StandardData.primaryColor,
            ),
            label: "Workout",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month,
              color: StandardData.primaryColor,
            ),
            label: "Calendar",
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(
              Icons.more_horiz,
              color: StandardData.primaryColor,
            ),
            label: "More",
          ),
        ],
      ),
      body: <Widget>[
        CustomScrollView(
          slivers: [
            HomePageAppbar(data: data),
            SliverToBoxAdapter(
              child: HomePageCalorie(dailyDetails: dailyDetails),
            ),
            SliverToBoxAdapter(child: HomePageLog()),
            SliverToBoxAdapter(child: HomePageNotification()),
            SliverToBoxAdapter(child: HomePageWorkout()),
            SliverToBoxAdapter(child: HomePageSkill(data: habits)),
          ],
        ),
        Workout(),
        Calendar(),
        More(),
      ][_selectedIndex],
    );
  }
}

class HomePageQRPopup extends StatefulWidget {
  const HomePageQRPopup({super.key});

  @override
  State<HomePageQRPopup> createState() => _HomePageQRPopupState();
}

class _HomePageQRPopupState extends State<HomePageQRPopup> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> popupButtons = [
      {
        'key1': 'Food Barcode',
        'value1': Icon(Icons.qr_code, color: StandardData.iconColor2),
        'key2': 'Search Food',
        'value2': Icon(Icons.search, color: StandardData.iconColor1),
        'onTap1': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodBarcode()),
          );
        },
        'onTap2': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodSearch()),
          );
        },
      },
      {
        'key1': 'Scan Meal',
        'value1': Icon(Icons.camera_alt, color: StandardData.iconColor1),
        'key2': 'Add Meal',
        'value2': Icon(Icons.add, color: StandardData.iconColor2),
        'onTap1': () {
          StandardData.normalSnackbar(context, "feature not added yet");
        },
        'onTap2': () {
          StandardData.normalSnackbar(context, "feature not added yet");
        },
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 35,
              height: 6,
              decoration: BoxDecoration(
                color: StandardData.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              spacing: 20,
              children: [
                ...popupButtons.map((item) {
                  return Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: item['onTap1'],
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: StandardData.backgroundColor1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [item['value1'], Text(item['key1'])],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: item['onTap2'],
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: StandardData.backgroundColor1,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [item['value2'], Text(item['key2'])],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
