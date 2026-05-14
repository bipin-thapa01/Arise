import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/CustomWorkoutPlan/custom_workout_plan.dart';
import 'package:fitness/Screens/CustomWorkoutPlan/edit_workout_plan.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class HomePageWorkout extends StatefulWidget {
  const HomePageWorkout({super.key});

  @override
  State<HomePageWorkout> createState() => _HomePageWorkoutState();
}

class _HomePageWorkoutState extends State<HomePageWorkout> {
  int listCount = 0;
  bool isEmpty = true;
  List<Map<String, dynamic>> workoutPlans = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Custom Workout Plan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditWorkoutPlan()),
                  );
                },
                child: Text(
                  "View all",
                  style: TextStyle(
                    color: StandardData.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("customWorkouts")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Fetching...");
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No workout plans found",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              }

              final workouts = snapshot.data!.docs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  ...workouts.asMap().entries.map((entry) {
                    int index = entry.key;
                    var data = entry.value.data();

                    return Container(
                      padding: EdgeInsetsGeometry.all(10),
                      margin: EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: StandardData.backgroundColor1,
                        border: Border.all(
                          width: 1,
                          color: StandardData.borderStrong,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(data["name"])),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: index % 2 == 0
                                  ? StandardData.purpleTint
                                  : StandardData.amberTint,
                            ),
                            child: Text(
                              "${data["workouts"].length} Days",
                              style: TextStyle(
                                color: index % 2 == 0
                                    ? StandardData.primaryColor
                                    : StandardData.amberColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
