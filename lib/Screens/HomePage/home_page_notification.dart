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
  late String today = StandardData.days[now.weekday % 7];
  late String todayFull = StandardData.daysFull[now.weekday % 7];
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

        print(workouts);
        print(today);

        final todayWorkouts = workouts.firstWhere(
          (workout) => workout["dayName"] == today,
          orElse: () => {},
        );

        print(todayWorkouts);

        return Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today\'s Workout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: 5,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: StandardData.tealColor),
                  borderRadius: BorderRadius.circular(20),
                  color: StandardData.tealTint,
                ),
                child: Text(
                  "$todayFull . $activePlan",
                  style: TextStyle(
                    fontSize: 12,
                    color: StandardData.tealColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsetsGeometry.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1,
                    color: StandardData.borderStrong,
                  ),
                  color: StandardData.backgroundColor1,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsetsGeometry.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: StandardData.purpleTint,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: StandardData.iconColor3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$activePlan",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          todayWorkouts.isEmpty
                              ? Text(
                                  "Rest Day . No Workout Today",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: StandardData.secondaryTextColor,
                                  ),
                                )
                              : Text(
                                  "$todayFull session. Tap to view workouts",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: StandardData.secondaryTextColor,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    todayWorkouts.isNotEmpty
                        ? TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TodayWorkoutPlan(
                                    todayWorkout:
                                        (todayWorkouts["exercises"] as List)
                                            .map(
                                              (e) =>
                                                  Map<String, String>.from(e),
                                            )
                                            .toList(),
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: StandardData.purpleTint,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "View >",
                              style: TextStyle(
                                fontSize: 12,
                                color: StandardData.primaryColor,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
