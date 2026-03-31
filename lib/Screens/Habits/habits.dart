import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsState();
}

final List<Map<String, dynamic>> habits = [];
String updatedText = '';

class _HabitsState extends State<Habits> {
  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final habitsDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("habits")
        .get();
    if (habitsDoc.docs.isNotEmpty) {
      setState(() {
        habits.clear();
        habits.addAll(
          habitsDoc.docs.map((doc) {
            return {
              "id": doc.id,
              "bestStreak": doc.data()["bestStreak"],
              "currentStreak": doc.data()['currentStreak'],
              "name": doc.data()['name'],
              "createdAt": doc.data()['createdAt'],
            };
          }),
        );
      });
    }
  }

  Future<void> _deleteHabit(final id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("habits")
          .doc(id)
          .delete();
      setState(() {
        habits.removeWhere((item) => item['id'] == id);
      });
      Navigator.pop(context);
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Habits"),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new),
            ),
          ),
          habits.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/empty-list.png"),
                        Text(
                          "Empty List!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Text("Your habits"),
                        ListView.builder(
                          padding: EdgeInsets.only(top: 20),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: habits.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 15,
                                left: 12,
                                right: 12,
                              ),
                              decoration: BoxDecoration(
                                color: StandardData.backgroundColor1,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          habits[index]["name"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return EditHabit(
                                                habit: habits[index],
                                                updateHabit: () {
                                                  setState(() {
                                                    habits[index]["name"] =
                                                        updatedText;
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.edit),
                                        iconSize: 16,
                                        padding: EdgeInsets.all(0),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Are you sure you want to delete the habit?",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                content: Row(
                                                  spacing: 20,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        _deleteHabit(
                                                          habits[index]["id"],
                                                        );
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                            backgroundColor:
                                                                StandardData
                                                                    .primaryColor
                                                                    .withAlpha(
                                                                      200,
                                                                    ),
                                                          ),
                                                      child: Text("Yes"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            StandardData
                                                                .buttonColor1,
                                                      ),
                                                      child: Text("No"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        iconSize: 16,
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text("Streak"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Current: ${habits[index]["currentStreak"]}",
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Highest: ${habits[index]["bestStreak"]}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

class EditHabit extends StatefulWidget {
  final Map<String, dynamic> habit;
  final updateHabit;
  const EditHabit({super.key, required this.habit, required this.updateHabit});

  @override
  State<EditHabit> createState() => _EditHabitState();
}

class _EditHabitState extends State<EditHabit> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.habit["name"];
  }

  Future<void> _updateHabit(final id) async {
    if (_key.currentState != null && !_key.currentState!.validate()) return;
    final String changedHabit = _controller.text.trim();
    final String oldHabit = widget.habit["name"].toString().trim();
    if (changedHabit.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Edited habit name cannot be empty!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } else if (changedHabit == oldHabit) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No change found!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("habits")
          .doc(id)
          .update({"name": changedHabit});
      updatedText = changedHabit;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Habit successfully updated"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.updateHabit();
      Navigator.pop(context);
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.habit["name"]),
            SizedBox(height: 30),
            Form(
              key: _key,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: StandardData.backgroundColor1,
                      label: Text("Edit Habit"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 1,
                          color: StandardData.primaryColor,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.red, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    _updateHabit(widget.habit["id"]);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: StandardData.primaryColor.withAlpha(200),
                  ),
                  child: Text("Save Changes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: StandardData.buttonColor1,
                  ),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
