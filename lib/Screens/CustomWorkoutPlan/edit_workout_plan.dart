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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final workoutPlanDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("customWorkouts")
        .get();

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = userDoc.data();
    activePlanName = (data != null && data.containsKey("activeWorkoutPlan"))
        ? data["activeWorkoutPlan"] ?? ""
        : "";

    setState(() {
      isPlanFetched = true;
      workoutPlans = workoutPlanDocs.docs.map((doc) => doc.data()).toList();
    });
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
        title: Text(
          "Edit Workout Plans",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
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
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Workout Plans",
                    style: TextStyle(color: Colors.grey),
                  ),
                  isPlanFetched
                      ? workoutPlans.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/empty-list.png'),
                                      Text(
                                        "Empty List",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: workoutPlans.length,
                                padding: EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: StandardData.backgroundColor1,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        width: 1,
                                        color: StandardData.borderStrong,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: index % 2 == 0
                                                        ? StandardData
                                                              .amberColor
                                                        : StandardData
                                                              .primaryColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: index % 2 == 0
                                                      ? StandardData.amberTint
                                                      : StandardData.purpleTint,
                                                ),
                                                child: Icon(
                                                  Icons.sports_martial_arts,
                                                  color: index % 2 == 0
                                                      ? StandardData.amberColor
                                                      : StandardData
                                                            .primaryColor,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      workoutPlans[index]["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${workoutPlans[index]["workouts"].length}x per week",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: StandardData
                                                        .borderStrong,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: StandardData
                                                      .backgroundColor2,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    StandardData.normalSnackbar(
                                                      context,
                                                      "feature not yet added!",
                                                    );
                                                  },
                                                  iconSize: 16,
                                                  style: IconButton.styleFrom(
                                                    padding: EdgeInsets.all(0),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: StandardData
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: StandardData
                                                        .borderStrong,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: StandardData
                                                      .backgroundColor2,
                                                ),
                                                child: IconButton(
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
                                                              child: Text(
                                                                "Yes",
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            TextButton(
                                                              onPressed: () {
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
                                                    minimumSize: Size.zero,
                                                    tapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color:
                                                        StandardData.amberColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          color: StandardData.borderStrong,
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: StandardData.days.map((
                                            day,
                                          ) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    (workoutPlans[index]["workouts"]
                                                            as List)
                                                        .any(
                                                          (workout) =>
                                                              workout["dayName"] ==
                                                              day,
                                                        )
                                                    ? StandardData.purpleTint
                                                    : StandardData
                                                          .backgroundColor2,
                                              ),
                                              child: Text(
                                                day,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      (workoutPlans[index]["workouts"]
                                                              as List)
                                                          .any(
                                                            (workout) =>
                                                                workout["dayName"] ==
                                                                day,
                                                          )
                                                      ? StandardData
                                                            .primaryColor
                                                      : Colors.grey,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        SizedBox(height: 10),
                                        workoutPlans[index]["name"] ==
                                                activePlanName
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    width: 1,
                                                    color:
                                                        StandardData.tealColor,
                                                  ),
                                                  color: StandardData.tealTint,
                                                ),
                                                width: double.infinity,
                                                child: Center(
                                                  child: Text(
                                                    "Active Plan",
                                                    style: TextStyle(
                                                      color: StandardData
                                                          .tealColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  _setAsDefaultWorkout(
                                                    workoutPlans[index]["name"],
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    color: StandardData
                                                        .backgroundColor2,
                                                    border: Border.all(
                                                      width: 1,
                                                      color: StandardData
                                                          .borderStrong,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Set as Active Plan",
                                                    ),
                                                  ),
                                                ),
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
          ),
        ],
      ),
    );
  }
}
