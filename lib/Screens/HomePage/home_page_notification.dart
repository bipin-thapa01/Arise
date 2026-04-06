import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/CustomWorkoutPlan/today_workout_plan.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class HomePageNotification extends StatefulWidget {
  const HomePageNotification({super.key});

  @override
  State<HomePageNotification> createState() => _HomePageNotificationState();
}

class _HomePageNotificationState extends State<HomePageNotification> {
  DateTime now = DateTime.now();
  bool isFetching = true;
  bool isWorkoutPlanSet = false;
  bool noWorkoutToday = false;
  String? activeWorkoutPlan;
  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  late String today = days[now.weekday % 7];
  List<Map<String, dynamic>> workoutPlans = [];
  List<Map<String, String>> todayWorkout = [];

  Future<void> _fetchWorkout() async {
    User? user = FirebaseAuth.instance.currentUser;
    final userDetails = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    activeWorkoutPlan = userDetails.get("activeWorkoutPlan");
    if (activeWorkoutPlan != null) {
      final workoutDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("customWorkouts")
          .get();
      setState(() {
        workoutPlans = workoutDoc.docs.map((data) {
          return data.data();
        }).toList();
      });
      final activePlan = workoutPlans.firstWhere(
        (plan) => plan["name"] == activeWorkoutPlan,
        orElse: () => {},
      );
      if (activePlan.isNotEmpty) {
        List workouts = activePlan["workouts"];
        final todayData = workouts.firstWhere(
          (w) => w["dayName"] == today,
          orElse: () => null,
        );
        if (todayData != null) {
          setState(() {
            isWorkoutPlanSet = true;
            todayWorkout = List<Map<String, String>>.from(
              todayData["exercises"].map((e) => {"name": e["name"].toString()}),
            );
          });
        } else {
          setState(() {
            isWorkoutPlanSet = true;
            noWorkoutToday = true;
          });
        }
      }
    }
    setState(() {
      isFetching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return isWorkoutPlanSet
        ? Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: StandardData.backgroundColor1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Workout Remainder",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                noWorkoutToday
                    ? Text("Day: $today | Rest Day 😴")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Plan: $activeWorkoutPlan"),
                          Text("Day: $today"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TodayWorkoutPlan(
                                    todayWorkout: todayWorkout,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: StandardData.primaryColor
                                  .withAlpha(100),
                            ),
                            child: Text("View Today Workout"),
                          ),
                        ],
                      ),
              ],
            ),
          )
        : Container();
  }
}
