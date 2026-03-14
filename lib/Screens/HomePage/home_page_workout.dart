import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class HomePageWorkout extends StatefulWidget {
  const HomePageWorkout({super.key});

  @override
  State<HomePageWorkout> createState() => _HomePageWorkoutState();
}

class _HomePageWorkoutState extends State<HomePageWorkout> {
  final List<Map<String, dynamic>> workoutPlans = [];
  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlan();
  }

  Future<void> _fetchWorkoutPlan() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;
      final workoutDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("workoutPlans")
          .get();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
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
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: StandardData.primaryColor.withAlpha(100),
            ),
            child: Text("Create Workout Plan"),
          ),
        ],
      ),
    );
  }
}
