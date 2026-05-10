import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/Screens/Workout/workout_detail.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class Workout extends StatefulWidget {
  const Workout({super.key});

  @override
  State<Workout> createState() => _WorkoutState();
}

class _WorkoutState extends State<Workout> {
  int limit = 20;
  List<Map<String, dynamic>> visibleWorkouts = [];
  DocumentSnapshot? lastDocument;

  Future<void> fetchWorkouts() async {
    if (lastDocument == null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("exercises")
          .orderBy("name")
          .limit(limit)
          .get();
      List<DocumentSnapshot> workouts = snapshot.docs;
      lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      List<Map<String, dynamic>> w = [];
      for (var workout in workouts) {
        w.add(workout.data() as Map<String, dynamic>);
      }
      setState(() {
        visibleWorkouts.addAll(w);
      });
    } else {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("exercises")
          .orderBy("name")
          .startAfterDocument(lastDocument!)
          .limit(limit)
          .get();
      List<DocumentSnapshot> workouts = snapshot.docs;
      lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      List<Map<String, dynamic>> w = [];
      for (var workout in workouts) {
        w.add(workout.data() as Map<String, dynamic>);
      }
      setState(() {
        visibleWorkouts.addAll(w);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            title: Text(
              "Workout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: StandardData.backgroundColor1,
                  hintText: "Search an Exercise",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text(
                "Available Workouts",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: visibleWorkouts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(children: [Text("Fetching Workouts...")]),
                  )
                : Column(
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.only(top: 10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: visibleWorkouts.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetail(
                                    workout: visibleWorkouts[index],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 10,
                                left: 10,
                                right: 10,
                              ),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: StandardData.backgroundColor1,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. ${visibleWorkouts[index]["name"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "Category: ${visibleWorkouts[index]["category"]}",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        "Equipment: ${visibleWorkouts[index]["equipment"] ?? "none"}",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 30,
                          left: MediaQuery.of(context).size.width * 0.3,
                          right: MediaQuery.of(context).size.width * 0.3,
                        ),
                        child: TextButton(
                          onPressed: () {
                            fetchWorkouts();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: StandardData.primaryColor
                                .withAlpha(200),
                          ),
                          child: Text("View More"),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
