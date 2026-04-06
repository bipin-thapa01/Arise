import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/CustomWorkoutPlan/today_workout_plan.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class HomePageNotification extends StatefulWidget {
  const HomePageNotification({super.key});

  @override
  State<HomePageNotification> createState() => _HomePageNotificationState();
}

class _HomePageNotificationState extends State<HomePageNotification> {
  DateTime now = DateTime.now();
  bool noWorkoutToday = false;
  String? activeWorkoutPlan;
  List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  late String today = days[now.weekday % 7];
  Stream<Map<String, dynamic>> getCombinedStream() {
    final workoutPlanStream = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("customWorkouts")
        .snapshots();
    final userData = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    return Rx.combineLatest2(workoutPlanStream, userData, (
      workoutPlanStream,
      userData,
    ) {
      return {"workoutPlan": workoutPlanStream, "userData": userData};
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getCombinedStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }

        if (!snapshot.hasData) {
          return Container();
        }

        final workoutPlansSnapshot = snapshot.data!["workoutPlan"];
        final workoutPlans = workoutPlansSnapshot.docs
            .map((doc) => doc.data())
            .toList();
        final userDataSnapshot = snapshot.data!["userData"];
        final activePlan = userDataSnapshot.data()!["activeWorkoutPlan"];

        if (activePlan == null) {
          return Container();
        }

        final activeWorkoutPlan = workoutPlans.firstWhere(
          (plan) => plan["name"] == activePlan,
          orElse: () => {},
        );

        final workouts = activeWorkoutPlan["workouts"];

        final todayWorkouts = workouts.firstWhere(
          (workout) => workout["dayName"] == today,
          orElse: () => {},
        );

        return Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: StandardData.backgroundColor1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Workout Notification",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("Plan: $activePlan"),
              Text("Day: $today"),
              todayWorkouts.isEmpty
                  ? Text("Rest Day 😴")
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodayWorkoutPlan(
                              todayWorkout: (todayWorkouts["exercises"] as List)
                                  .map((e) => Map<String, String>.from(e))
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: StandardData.primaryColor.withAlpha(
                          100,
                        ),
                      ),
                      child: Text("View Today Workout"),
                    ),
            ],
          ),
        );
      },
    );
  }
}
