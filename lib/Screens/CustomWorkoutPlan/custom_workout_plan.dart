import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Map<String, dynamic>> customWorkouts = [];

void initCustomWorkouts(int numberOfDays) {
  customWorkouts = List.generate(numberOfDays, (index) {
    return {
      "day": index + 1,
      "dayName": "",
      "exercises": <Map<String, dynamic>>[],
    };
  });
}

class CustomWorkoutPlan extends StatefulWidget {
  const CustomWorkoutPlan({super.key});

  @override
  State<CustomWorkoutPlan> createState() => _CustomWorkoutPlanState();
}

class _CustomWorkoutPlanState extends State<CustomWorkoutPlan> {
  final _formKey = GlobalKey<FormState>();
  bool isDaysDecided = false;
  int numberOfDays = 0;
  final Map<String, TextEditingController> _controllers = {};
  final List<Map<String, dynamic>> content = [
    {"name": "Workout Plan Name", "type": "text"},
    {"name": "Frequency (eg. 6 days / week )", "type": "number"},
  ];

  @override
  void initState() {
    super.initState();
    for (var i in content) {
      _controllers[i["name"]] = TextEditingController();
    }
  }

  Future<void> saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_controllers[content[0]["name"]]!.text.isEmpty) {
      StandardData.normalSnackbar(context, "Workout Name cannot be empty!");
      return;
    }
    if (!isDaysDecided) {
      StandardData.normalSnackbar(context, "Number of days cannot be empty!");
      return;
    }
    for (var day in customWorkouts) {
      if (day["dayName"] == null || (day["dayName"] as String).isEmpty) {
        StandardData.normalSnackbar(context, "Name of a day cannot be empty!");
        return;
      }
      if (day["exercises"] == null || (day["exercises"] as List).isEmpty) {
        StandardData.normalSnackbar(context, "Exercise list cannot be empty!");
        return;
      }
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("customWorkouts")
          .add({
            "name": _controllers[content[0]["name"]]!.text,
            "frequency": _controllers[content[1]["name"]]!.text,
            "workouts": customWorkouts,
          });
      Navigator.pop(context);
      StandardData.normalSnackbar(context, "Workout Plan created!");
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Custom Workout Plan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).primaryColor,
        scrolledUnderElevation: 0,
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
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Text(
                "Create your own custom workout plan!",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ...content.map((data) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        margin: EdgeInsets.only(bottom: 15),
                        child: TextFormField(
                          keyboardType: data["type"] == "number"
                              ? TextInputType.number
                              : TextInputType.text,
                          inputFormatters: data["type"] == "number"
                              ? [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[1-7]'),
                                  ),
                                ]
                              : null,
                          controller: _controllers[data["name"]],
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                isDaysDecided = false;
                                numberOfDays = 0;
                                initCustomWorkouts(0);
                                return;
                              }
                              if (data["type"] == "number") {
                                isDaysDecided = true;
                                numberOfDays = int.parse(value);
                                initCustomWorkouts(numberOfDays);
                                print(customWorkouts);
                              }
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: StandardData.backgroundColor2,
                            labelText: data["name"],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: StandardData.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (isDaysDecided)
                      for (int i = 1; i <= numberOfDays; i++)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("For Day $i"),
                              SizedBox(height: 15),
                              DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  hintText: customWorkouts[i - 1]["dayName"],
                                  filled: true,
                                  fillColor: StandardData.backgroundColor1,
                                  labelText: "Select Day",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                                isExpanded: true,
                                items:
                                    [
                                      "Sun",
                                      "Mon",
                                      "Tue",
                                      "Wed",
                                      "Thu",
                                      "Fri",
                                      "Sat",
                                    ].map((day) {
                                      bool isDisabled = customWorkouts
                                          .asMap()
                                          .entries
                                          .any(
                                            (entry) =>
                                                entry.key != i - 1 &&
                                                entry.value["dayName"] == day,
                                          );
                                      return DropdownItem<String>(
                                        value: day,
                                        enabled: !isDisabled,
                                        child: Text(
                                          "$day ${isDisabled ? " (Already Taken)" : ""}",
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    customWorkouts[i - 1]["dayName"] = value!;
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (builder) {
                                      return AddExercise(
                                        day: i,
                                        onExerciseAdded: () {
                                          setState(() {});
                                        },
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: StandardData.primaryColor
                                      .withAlpha(100),
                                ),
                                child: Text("Add Exercise"),
                              ),
                              if (customWorkouts[i - 1]["exercises"].isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(10),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: StandardData.backgroundColor1,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Selected Exercises"),
                                      ...customWorkouts[i - 1]["exercises"].map(
                                        (exercise) {
                                          return Text(
                                            "- ${exercise["name"]}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              Divider(color: StandardData.borderStrong),
                            ],
                          ),
                        ),
                    TextButton(
                      onPressed: () {
                        saveWorkout();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: StandardData.primaryColor.withAlpha(
                          100,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("Save Workout!"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddExercise extends StatefulWidget {
  final int day;
  final VoidCallback onExerciseAdded;
  const AddExercise({
    super.key,
    required this.day,
    required this.onExerciseAdded,
  });

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  List<Map<String, dynamic>> workouts = [];
  List<Map<String, dynamic>> filteredWorkouts = [];

  Future<void> _fetchWorkout() async {
    final workoutDocs = await FirebaseFirestore.instance
        .collection("exercises")
        .get();
    setState(() {
      workouts = workoutDocs.docs.map((doc) {
        return doc.data();
      }).toList();
      filteredWorkouts = workouts;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: StandardData.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredWorkouts = workouts;
                  } else {
                    filteredWorkouts = workouts.where((workout) {
                      return workout["name"].toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  }
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: StandardData.backgroundColor1,
                hintText: "Search for Workout",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: StandardData.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredWorkouts.isEmpty
                  ? Center(child: Text("Fetching Workout"))
                  : ListView.builder(
                      itemCount: filteredWorkouts.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredWorkouts[index]["name"]),
                          trailing:
                              (customWorkouts.length >= widget.day &&
                                  (customWorkouts[widget.day - 1]["exercises"]
                                          as List)
                                      .any(
                                        (w) =>
                                            w["name"] ==
                                            filteredWorkouts[index]["name"],
                                      ))
                              ? TextButton(
                                  onPressed: () {
                                    setState(() {
                                      customWorkouts[widget.day -
                                              1]["exercises"]
                                          .removeWhere(
                                            (w) =>
                                                w["name"] ==
                                                filteredWorkouts[index]["name"],
                                          );
                                    });
                                    widget.onExerciseAdded();
                                  },
                                  child: Text("Remove"),
                                )
                              : TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: StandardData.primaryColor
                                        .withAlpha(100),
                                  ),
                                  onPressed: () {
                                    if (customWorkouts[widget.day -
                                                1]["exercises"]
                                            .length >
                                        14) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Only 15 workout per day is allowed!",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      customWorkouts[widget.day -
                                              1]["exercises"]
                                          .add({
                                            "name":
                                                filteredWorkouts[index]["name"],
                                          });
                                    });
                                    widget.onExerciseAdded();
                                  },
                                  child: Text("Add"),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
