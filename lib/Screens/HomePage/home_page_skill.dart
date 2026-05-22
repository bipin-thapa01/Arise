import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
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
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  "Events & Tasks",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Habits()),
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
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection("eventsNRemainders")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Fetching...",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Empty List!",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsetsGeometry.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: StandardData.backgroundColor1,
                            border: Border.all(
                              width: 1,
                              color: StandardData.borderStrong,
                            ),
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return AddNewHabit(
                                    onHabitAdded: (newHabit) {
                                      setState(() {
                                        widget.data.add({
                                          "name": newHabit,
                                          "currentStreak": 0,
                                        });
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: StandardData.purpleTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    color: StandardData.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Add Event or Task",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Create your own custom schedule",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: StandardData.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final habits = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.only(top: 5),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: habits.length > 5 ? 5 : habits.length,
                        itemBuilder: (context, index) {
                          final habit =
                              habits[index].data() as Map<String, dynamic>;

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
                                Expanded(child: Text(habit["name"])),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: habit["type"] == "Task"
                                        ? StandardData.purpleTint
                                        : StandardData.amberTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    habit["type"],
                                    style: TextStyle(
                                      color: habit["type"] == "Task"
                                          ? StandardData.primaryColor
                                          : StandardData.amberColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: EdgeInsetsGeometry.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: StandardData.backgroundColor1,
                          border: Border.all(
                            width: 1,
                            color: StandardData.borderStrong,
                          ),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return AddNewHabit(
                                  onHabitAdded: (newHabit) {
                                    setState(() {
                                      widget.data.add({
                                        "name": newHabit,
                                        "currentStreak": 0,
                                      });
                                    });
                                  },
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: StandardData.purpleTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  color: StandardData.primaryColor,
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Event or Task",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Create your own custom schedule",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: StandardData.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
  String selectedSchedule = 'Does not Repeat';
  DateTime selectedDate = DateTime.now();
  String selectedType = "Event";
  DateTime selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Future<void> addHabit() async {
      if (!_key.currentState!.validate()) return;
      final String habit = _habit.text;
      if (habit.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        final String? id = user?.uid;
        try {
          Map<String, dynamic> content = {
            "name": habit,
            "type": selectedType,
            "createdAt": FieldValue.serverTimestamp(),
            "frequency": selectedSchedule,
            "eventDate": selectedSchedule == "Does not Repeat"
                ? selectedDate
                : selectedTime,
          };
          DocumentReference ref = await FirebaseFirestore.instance
              .collection("users")
              .doc(id)
              .collection("eventsNRemainders")
              .add(content);
          if (widget.onHabitAdded != null) {
            widget.onHabitAdded?.call(habit);
          }
          StandardData.normalSnackbar(context, "Event or Task created!");
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
                color: Colors.grey,
              ),
            ),
            Text(
              "Add New Event or Task",
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
                      fillColor: StandardData.backgroundColor1,
                      label: Text("Enter Title"),
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
                    hint: Text(selectedType),
                    items: ['Event', 'Task']
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
                        selectedType = value!;
                      });
                    },
                    decoration: InputDecoration(border: InputBorder.none),
                    buttonStyleData: FormFieldButtonStyleData(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: StandardData.backgroundColor1,
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
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    hint: Text(selectedSchedule),
                    items:
                        [
                              'Does not Repeat',
                              'Daily',
                              'Weekly',
                              'Monthly',
                              'Annually',
                            ]
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
                        selectedSchedule = value!;
                      });
                    },
                    decoration: InputDecoration(border: InputBorder.none),
                    buttonStyleData: FormFieldButtonStyleData(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: StandardData.backgroundColor1,
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
                  SizedBox(height: 10),
                  if (selectedSchedule == "Does not Repeat")
                    DateTimeFormField(
                      decoration: InputDecoration(
                        labelText: "Select Event/Task Date & Time",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: StandardData.backgroundColor1,
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      onChanged: (DateTime? value) {
                        setState(() {
                          selectedDate = value ?? selectedDate;
                        });
                      },
                    ),
                  if (selectedSchedule != "Does not Repeat")
                    DateTimeFormField(
                      mode: DateTimeFieldPickerMode.time,
                      decoration: InputDecoration(
                        labelText: "Select Event/Task Time",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).primaryColor,
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      onChanged: (DateTime? value) {
                        setState(() {
                          selectedTime = value ?? selectedDate;
                        });
                      },
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
