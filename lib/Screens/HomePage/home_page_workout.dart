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
      decoration: BoxDecoration(
        color: StandardData.backgroundColor1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Workout Plans",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "Create custom workout plans!",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          SizedBox(height: 6),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomWorkoutPlan()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: StandardData.primaryColor.withAlpha(100),
            ),
            child: Text("Create Workout Plan"),
          ),
          Divider(),
          Text(
            "Your current workout plans",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

                    return Text("${index + 1}. ${data["name"]}");
                  }),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditWorkoutPlan(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: StandardData.primaryColor.withAlpha(100),
                      padding: EdgeInsets.only(left: 20, right: 20),
                    ),
                    child: Text("View All"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
