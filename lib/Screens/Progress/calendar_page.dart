import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

User? user = FirebaseAuth.instance.currentUser;
List<Map<String, dynamic>> habits = [];

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool isAllHabitsDone = false;
  List<Map<String, dynamic>> dailyDetails = [];
  List<String> months = [
    "Jan",
    "Feb",
    "March",
    "April",
    "May",
    "June",
    "July",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec",
  ];
  DateTime selectedDay = DateTime.now();
  DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> getHabits() async {
    final habitsDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("habits")
        .get();
    setState(() {
      habits = habitsDoc.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data["id"] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> getDailyDetails() async {
    final dailyDetailsDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("dailyDetails")
        .get();
    setState(() {
      dailyDetails = dailyDetailsDoc.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  bool shouldShowHabit(Map<String, dynamic> habit, DateTime day) {
    DateTime start = normalize((habit["createdAt"] as Timestamp).toDate());

    if (day.isBefore(start)) return false;

    final frequency = habit["frequency"];

    if (frequency == "Daily") {
      return true;
    } else if (frequency == "Weekly") {
      return day.weekday == start.weekday;
    } else if (frequency == "Monthly") {
      return day.day == start.day;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    getHabits();
    getDailyDetails();
  }

  @override
  Widget build(BuildContext context) {
    return habits == []
        ? Center(child: Text("Fetching Data..."))
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                TableCalendar(
                  focusedDay: selectedDay,
                  firstDay: DateTime.utc(2026, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  rowHeight: 120,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  availableGestures: AvailableGestures.horizontalSwipe,
                  calendarStyle: CalendarStyle(
                    cellMargin: EdgeInsets.zero,
                    cellPadding: EdgeInsets.zero,
                  ),
                  onDaySelected: (day, focusedDay) {
                    setState(() {
                      selectedDay = day;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    todayBuilder: (context, day, focusedDay) =>
                        _buildDayCell(day, true),
                    defaultBuilder: (context, day, focusedDay) =>
                        _buildDayCell(day, false),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildDayCell(DateTime day, bool isToday) {
    final dayHabits = habits
        .where((habit) => shouldShowHabit(habit, normalize(day)))
        .toList();

    bool isActualToday = isSameDay(day, DateTime.now());

    isAllHabitsDone =
        dailyDetails.firstWhere(
          (data) => data["date"] == day.toIso8601String().split("T")[0],
          orElse: () => {},
        )["habitsCompleted"] ==
        dayHabits.length;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return HabitBottomSheet(
              day: day,
              dayHabits: dayHabits,
              isToday: isToday,
              habits: habits,
              updateHabits: (updatedHabits) {
                setState(() {
                  habits = updatedHabits;
                });
              },
              onHabitDone: () {
                getDailyDetails();
              },
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSameDay(day, selectedDay)
              ? StandardData.backgroundColor2
              : StandardData.backgroundColor1,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 2, right: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isActualToday ? Colors.blueAccent : null,
                  ),
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActualToday ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...dayHabits
                    .take(3)
                    .map(
                      (habit) => Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          habit["name"],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                if (dayHabits.length > 3)
                  Text(
                    "+${dayHabits.length - 3} more",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
            if (isAllHabitsDone)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.withAlpha(100)),
                child: Icon(
                  Icons.verified,
                  color: StandardData.iconColor2,
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HabitBottomSheet extends StatelessWidget {
  final VoidCallback onHabitDone;
  final DateTime day;
  final List<Map<String, dynamic>> dayHabits;
  final bool isToday;
  final List<Map<String, dynamic>> habits;
  final Function(List<Map<String, dynamic>>) updateHabits;

  const HabitBottomSheet({
    super.key,
    required this.day,
    required this.dayHabits,
    required this.isToday,
    required this.habits,
    required this.updateHabits,
    required this.onHabitDone,
  });

  @override
  Widget build(BuildContext context) {
    List<String> months = [
      "Jan",
      "Feb",
      "March",
      "April",
      "May",
      "June",
      "July",
      "Aug",
      "Sept",
      "Oct",
      "Nov",
      "Dec",
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: StandardData.primaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "${day.day} ${months[day.month - 1]} ${day.year}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Habits", style: TextStyle(color: Colors.grey)),

                  dayHabits.isEmpty
                      ? Text("Empty List!")
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dayHabits.length,
                          itemBuilder: (context, index) {
                            final habitData = dayHabits[index];

                            final lastCompleted =
                                habitData["lastCompleted"] as Timestamp?;

                            bool alreadyDone =
                                lastCompleted != null &&
                                isToday &&
                                isSameDay(
                                  lastCompleted.toDate(),
                                  DateTime.now(),
                                );

                            return _habitTile(context, habitData, alreadyDone);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _habitTile(
    BuildContext context,
    Map<String, dynamic> habitData,
    bool alreadyDone,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: StandardData.backgroundColor1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  habitData["name"],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "Frequency: ${habitData["frequency"]}",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),

          TextButton(
            onPressed: () async {
              await _handleMarkDone(context, habitData, alreadyDone);
            },
            style: TextButton.styleFrom(
              backgroundColor: alreadyDone
                  ? StandardData.backgroundColor2
                  : StandardData.primaryColor.withAlpha(200),
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            child: Text(
              alreadyDone ? "Done" : "Mark as Done",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkDone(
    BuildContext context,
    Map<String, dynamic> habitData,
    bool alreadyDone,
  ) async {
    if (!isToday) {
      Navigator.pop(context);
      StandardData.normalSnackbar(context, "Cannot mark past/future habits");
      return;
    }

    if (alreadyDone) {
      Navigator.pop(context);
      StandardData.normalSnackbar(context, "Already Done today!");
      return;
    }

    int currentStreak = habitData["currentStreak"];
    int bestStreak = habitData["bestStreak"];

    final lastCompleted = habitData["lastCompleted"] as Timestamp?;

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    if (lastCompleted != null) {
      DateTime last = lastCompleted.toDate();
      last = DateTime(last.year, last.month, last.day);

      DateTime yesterday = today.subtract(Duration(days: 1));

      if (last == yesterday) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else {
      currentStreak = 1;
      bestStreak = 1;
    }

    int i = habits.indexWhere((h) => h["id"] == habitData["id"]);
    if (i != -1) {
      habits[i]["currentStreak"] = currentStreak;
      habits[i]["bestStreak"] = bestStreak;
      habits[i]["lastCompleted"] = Timestamp.now();
      updateHabits(habits);
    }

    Navigator.pop(context);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("habits")
          .doc(habitData["id"])
          .update({
            "lastCompleted": FieldValue.serverTimestamp(),
            "currentStreak": currentStreak,
            "bestStreak": bestStreak,
          });

      final today = DateTime.now().toIso8601String().split("T")[0];

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("dailyDetails")
          .doc(today)
          .update({"habitsCompleted": FieldValue.increment(1)});

      onHabitDone();

      StandardData.normalSnackbar(context, "Successfully Updated!");
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }
}
