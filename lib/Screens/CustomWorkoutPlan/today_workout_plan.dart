import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/Screens/Workout/workout_detail.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class TodayWorkoutPlan extends StatefulWidget {
  final List<Map<String, String>> todayWorkout;
  const TodayWorkoutPlan({super.key, required this.todayWorkout});

  @override
  State<TodayWorkoutPlan> createState() => _TodayWorkoutPlanState();
}

class _TodayWorkoutPlanState extends State<TodayWorkoutPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        titleSpacing: 0,
        title: Text(
          "Today's Workout",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.todayWorkout.map((workout) {
                    return GestureDetector(
                      onTap: () async {
                        final doc = await FirebaseFirestore.instance
                            .collection("exercises")
                            .where("name", isEqualTo: workout["name"])
                            .get();
                        Map<String, dynamic> w = doc.docs[0].data();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkoutDetail(workout: w),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: StandardData.backgroundColor1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(workout["name"]!),
                            Text(
                              "View Details > ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
