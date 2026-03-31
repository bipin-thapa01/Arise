import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/LoginPage/login_page.dart';
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
      habits = habitsDoc.docs.map((doc) => doc.data()).toList();
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

    return Container(
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
    );
  }
}
