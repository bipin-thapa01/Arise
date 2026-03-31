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

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.all(10),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Habits",
                              style: TextStyle(color: Colors.grey),
                            ),
                            dayHabits.isEmpty
                                ? Text("Empty List!")
                                : ListView.builder(
                                    padding: EdgeInsets.only(
                                      top: 5,
                                      bottom: 10,
                                    ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: dayHabits.length,
                                    itemBuilder: (context, index) {
                                      final lastCompleted =
                                          dayHabits[index]["lastCompleted"];
                                      bool alreadyDone =
                                          lastCompleted == null || !isToday
                                          ? false
                                          : isSameDay(
                                              (lastCompleted as Timestamp)
                                                  .toDate(),
                                              DateTime.now(),
                                            );

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        padding: EdgeInsets.all(5),
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.9,
                                        decoration: BoxDecoration(
                                          color: StandardData.backgroundColor1,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    dayHabits[index]["name"],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "Frequency: ${dayHabits[index]["frequency"]}",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final now = DateTime.now();
                                                final today = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                );

                                                if (!isToday) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin: EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                      ),
                                                      content: Text(
                                                        "Habits of future or past cannot be marked.",
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                final habitData =
                                                    dayHabits[index];
                                                final lastCompleted =
                                                    habitData["lastCompleted"]
                                                        as Timestamp?;
                                                int currentStreak =
                                                    dayHabits[index]["currentStreak"];
                                                int bestStreak =
                                                    dayHabits[index]["bestStreak"];

                                                if (lastCompleted != null) {
                                                  DateTime lastDate =
                                                      lastCompleted.toDate();
                                                  DateTime lastDateNormalized =
                                                      DateTime(
                                                        lastDate.year,
                                                        lastDate.month,
                                                        lastDate.day,
                                                      );

                                                  if (lastDateNormalized
                                                      .isAtSameMomentAs(
                                                        today,
                                                      )) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        content: Text(
                                                          "Already Done today!",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  DateTime yesterday = today
                                                      .subtract(
                                                        const Duration(days: 1),
                                                      );
                                                  if (lastDateNormalized
                                                      .isAtSameMomentAs(
                                                        yesterday,
                                                      )) {
                                                    currentStreak += 1;
                                                  } else {
                                                    currentStreak = 1;
                                                  }
                                                  if (currentStreak >
                                                      bestStreak) {
                                                    bestStreak = currentStreak;
                                                  }
                                                } else {
                                                  currentStreak = 1;
                                                  bestStreak = 1;
                                                }
                                                Navigator.pop(context);
                                                int i = habits.indexWhere(
                                                  (habit) =>
                                                      habit["id"] ==
                                                      habitData["id"],
                                                );

                                                if (i != -1) {
                                                  setState(() {
                                                    habits[i]["currentStreak"] =
                                                        currentStreak;
                                                    habits[i]["bestStreak"] =
                                                        bestStreak;
                                                    habits[i]["lastCompleted"] =
                                                        Timestamp.now();
                                                  });
                                                }
                                                print(
                                                  "Habit Id: ${habitData["id"]}",
                                                );
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("users")
                                                      .doc(user!.uid)
                                                      .collection("habits")
                                                      .doc(habitData["id"])
                                                      .update({
                                                        "lastCompleted":
                                                            FieldValue.serverTimestamp(),
                                                        "currentStreak":
                                                            currentStreak,
                                                        "bestStreak":
                                                            bestStreak,
                                                      });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Successfully Updated!",
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  StandardData.errorSnackbar(
                                                    context,
                                                  );
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    isToday && !alreadyDone
                                                    ? StandardData.primaryColor
                                                          .withAlpha(200)
                                                    : StandardData
                                                          .backgroundColor2,
                                                padding: EdgeInsets.only(
                                                  top: 0,
                                                  bottom: 0,
                                                  left: 5,
                                                  right: 5,
                                                ),
                                              ),
                                              child: Text(
                                                alreadyDone
                                                    ? "Done"
                                                    : "Mark as Done",
                                                style: TextStyle(fontSize: 12),
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
              ),
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
        child: Column(
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
                      style: const TextStyle(fontSize: 8, color: Colors.white),
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
      ),
    );
  }
}
