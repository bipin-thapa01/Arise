import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/Habits/habits.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePageSkill extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  const HomePageSkill({super.key, required this.data});

  @override
  State<HomePageSkill> createState() => _HomePageSkillState();
}

class _HomePageSkillState extends State<HomePageSkill> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: StandardData.backgroundColor1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Establish new habit",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            "Add new habit to level up!",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return AddNewHabit(
                    onHabitAdded: (newHabit) {
                      setState(() {
                        widget.data.add({"name": newHabit, "currentStreak": 0});
                      });
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StandardData.primaryColor.withOpacity(0.5),
            ),
            child: Text(
              "Add Habit",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Divider(color: Colors.grey[800], thickness: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your current habits",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              widget.data.isNotEmpty
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("habits")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Fetching...",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text(
                            "Empty Habits List!",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          );
                        }

                        final habits = snapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              padding: EdgeInsets.only(top: 5, bottom: 10),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: habits.length > 5 ? 5 : habits.length,
                              itemBuilder: (context, index) {
                                final habit =
                                    habits[index].data()
                                        as Map<String, dynamic>;

                                return Text("${index + 1}. ${habit["name"]}");
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Habits(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: StandardData.primaryColor
                                    .withOpacity(0.5),
                              ),
                              child: Text("View all"),
                            ),
                          ],
                        );
                      },
                    )
                  : Text(
                      "Empty Habits List!",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddNewHabit extends StatefulWidget {
  final Function(String)? onHabitAdded;
  const AddNewHabit({super.key, this.onHabitAdded});

  @override
  State<AddNewHabit> createState() => _AddNewHabitState();
}

class _AddNewHabitState extends State<AddNewHabit> {
  final storage = FlutterSecureStorage();
  final _key = GlobalKey<FormState>();
  final TextEditingController _habit = TextEditingController();
  String selectedValue = "Daily";

  @override
  Widget build(BuildContext context) {
    Future<void> addHabit() async {
      if (!_key.currentState!.validate()) return;
      final String habit = _habit.text;
      if (habit.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        final String? id = user?.uid;
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .collection("habits")
              .add({
                "name": habit,
                "createdAt": FieldValue.serverTimestamp(),
                "frequency": selectedValue,
                "currentStreak": 0,
                "bestStreak": 0,
                "lastCompleted": null,
              });
          if (widget.onHabitAdded != null) {
            widget.onHabitAdded?.call(habit);
          }
          Navigator.pop(context);
        } catch (e) {
          StandardData.errorSnackbar(context);
        }
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: StandardData.primaryColor,
              ),
            ),
            Text(
              "Add New Habit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Form(
              key: _key,
              child: Column(
                children: [
                  TextFormField(
                    controller: _habit,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).primaryColor,
                      hint: Text("New Habit"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: StandardData.primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    hint: Text(selectedValue),
                    items: ['Daily', 'Weekly', 'Monthly']
                        .map(
                          (item) => DropdownItem<String>(
                            value: item,
                            height: 40,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                    decoration: InputDecoration(border: InputBorder.none),
                    buttonStyleData: FormFieldButtonStyleData(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            addHabit();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StandardData.primaryColor
                                .withAlpha(90),
                          ),
                          child: Text("Save"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
