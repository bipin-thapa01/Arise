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
    habits = habitsDoc.docs.map((doc) => doc.data()).toList();
  }

  @override
  void initState() {
    super.initState();
    getHabits();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
      return SizedBox.shrink();
    }
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight =
        AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final double availableHeight = screenHeight - appBarHeight;
    const double headerHeight = 80.0;
    final double rowHeight = (availableHeight - headerHeight) / 6;
    return TableCalendar(
      focusedDay: selectedDay,
      firstDay: DateTime.utc(2026, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      rowHeight: rowHeight,
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
        defaultBuilder: (context, day, focusedDay) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSameDay(day, selectedDay)
                  ? StandardData.primaryColor
                  : StandardData.backgroundColor1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${day.day}"),
                SizedBox(height: 4),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: habits.map((habit) {
                //     DateTime today = normalize(DateTime.now());
                //     DateTime start = normalize(
                //       (habit["createdAt"] as Timestamp).toDate(),
                //     );
                //     if (habit["frequency"] == 'Weekly') {
                //       if (today != start) {
                //         return Container();
                //       }
                //     } else if (habit["frequency"] == "Monthly") {
                //       if (!(today.day == start.day &&
                //           !today.isBefore(start))) {
                //         return Container();
                //       }
                //     }
                //     return Container(
                //       child: Text(
                //         habit["name"],
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     );
                //   }).toList(),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
