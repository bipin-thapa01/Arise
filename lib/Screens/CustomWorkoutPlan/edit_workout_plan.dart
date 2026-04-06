import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditWorkoutPlan extends StatefulWidget {
  const EditWorkoutPlan({super.key});

  @override
  State<EditWorkoutPlan> createState() => _EditWorkoutPlanState();
}

class _EditWorkoutPlanState extends State<EditWorkoutPlan> {
  bool isPlanFetched = false;
  List<Map<String, dynamic>> workoutPlans = [];
  String activePlanName = "";

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    final workoutPlanDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("customWorkouts")
        .get();
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    activePlanName = userDoc.data()!["activeWorkoutPlan"];

    setState(() {
      isPlanFetched = true;
      workoutPlans = workoutPlanDocs.docs.map((doc) {
        return doc.data();
      }).toList();
    });
    print(workoutPlans);
  }

  Future<void> _deleteWorkoutPlan(String planName) async {
    final deleteWorkout = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("customWorkouts")
        .where("name", isEqualTo: planName)
        .get();
    for (var doc in deleteWorkout.docs) {
      await doc.reference.delete();
    }
    setState(() {
      workoutPlans.removeWhere((plan) => plan["name"] == planName);
    });
    StandardData.normalSnackbar(context, "Workout Plan Delete");
  }

  Future<void> _setAsDefaultWorkout(String name) async {
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"activeWorkoutPlan": name});
      setState(() {
        activePlanName = name;
      });
      StandardData.normalSnackbar(context, "Active Workout Plan changed!");
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Edit Workout Plans"),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Text(
                  "Your Workout Plans",
                  style: TextStyle(color: Colors.grey),
                ),
                isPlanFetched
                    ? workoutPlans.isEmpty
                          ? Text("No workout plans found")
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: workoutPlans.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 20,
                                  ),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: StandardData.backgroundColor1,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              workoutPlans[index]["name"],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            iconSize: 16,
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.all(0),
                                            ),
                                            icon: Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            iconSize: 16,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(
                                                    "Are you sure you want to delete the Plan?",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  content: Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          _deleteWorkoutPlan(
                                                            workoutPlans[index]["name"],
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        style: TextButton.styleFrom(
                                                          padding:
                                                              EdgeInsets.all(
                                                                10,
                                                              ),
                                                          backgroundColor:
                                                              StandardData
                                                                  .primaryColor
                                                                  .withAlpha(
                                                                    100,
                                                                  ),
                                                        ),
                                                        child: Text("Yes"),
                                                      ),
                                                      SizedBox(width: 10),
                                                      TextButton(
                                                        onPressed: () {},
                                                        style: TextButton.styleFrom(
                                                          padding:
                                                              EdgeInsets.all(
                                                                10,
                                                              ),
                                                          backgroundColor:
                                                              StandardData
                                                                  .backgroundColor2,
                                                        ),
                                                        child: Text("No"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.all(0),
                                            ),
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Text(
                                        "Frequency: ${workoutPlans[index]["frequency"]}",
                                      ),
                                      Row(
                                        children: [
                                          Text("Days: "),
                                          ...workoutPlans[index]["workouts"]
                                              .map((workout) {
                                                return Text(
                                                  "${workout["dayName"]} ",
                                                );
                                              }),
                                        ],
                                      ),
                                      workoutPlans[index]["name"] ==
                                              activePlanName
                                          ? TextButton(
                                              onPressed: () {},
                                              style: TextButton.styleFrom(
                                                backgroundColor: StandardData
                                                    .backgroundColor2,
                                              ),
                                              child: Text("Active Plan"),
                                            )
                                          : TextButton(
                                              onPressed: () {
                                                _setAsDefaultWorkout(
                                                  workoutPlans[index]["name"],
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor: StandardData
                                                    .primaryColor
                                                    .withAlpha(100),
                                              ),
                                              child: Text("Set as Active Plan"),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: SpinKitThreeBounce(
                            color: StandardData.primaryColor,
                            size: 30.0,
                          ),
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
