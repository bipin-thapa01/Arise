import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool isFetching = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> eventsNTasks = [];
  List<Map<String, dynamic>> filteredEventsNTasks = [];
  final months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "June",
    "July",
    "Aug",
    "Sept",
    "Oct",
    "Nov",
    "Dec",
  ];
  final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  Future<void> fetchEventOrTask() async {
    final eventsNTasksDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("eventsNRemainders")
        .get();
    eventsNTasks = eventsNTasksDocs.docs.map((doc) => doc.data()).toList();
    filterEventOrTask(DateTime.now());
  }

  void filterEventOrTask(DateTime date) {
    setState(() {
      filteredEventsNTasks =
          eventsNTasks.where((event) {
            if (event["frequency"] == "Does not Repeat") {
              final eventDate = (event["eventDate"] as Timestamp)
                  .toDate()
                  .toString()
                  .split(" ")[0];
              final selectedDate = date.toString().split(" ")[0];
              return eventDate == selectedDate;
            } else if (event["frequency"] == "Daily") {
              return true;
            } else if (event["frequency"] == "Weekly") {
              final eventDay = (event["createdAt"] as Timestamp)
                  .toDate()
                  .weekday;
              final selectedDay = date.weekday;
              return eventDay == selectedDay;
            } else if (event["frequency"] == "Monthly") {
              final eventDay = (event["createdAt"] as Timestamp).toDate().day;
              final selectedDay = date.day;
              return eventDay == selectedDay;
            } else {
              final eventDay = (event["createdAt"] as Timestamp).toDate().day;
              final selectedDay = date.day;
              final eventMonth = (event["createdAt"] as Timestamp)
                  .toDate()
                  .month;
              final selectedMonth = date.month;
              return eventDay == selectedDay && eventMonth == selectedMonth;
            }
          }).toList()..sort((a, b) {
            final DateTime aDate = (a["eventDate"] as Timestamp).toDate();
            final DateTime bDate = (b["eventDate"] as Timestamp).toDate();

            final aMinutes = aDate.hour * 60 + aDate.minute;
            final bMinutes = bDate.hour * 60 + bDate.minute;
            return aMinutes.compareTo(bMinutes);
          });
      isFetching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEventOrTask();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EasyDateTimeLinePicker.itemBuilder(
          firstDate: DateTime(2025, 1, 1),
          lastDate: DateTime(2030, 3, 18),
          focusedDate: _selectedDate,
          itemExtent: 64.0,
          itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
            return InkResponse(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: isToday
                      ? Border.all(color: StandardData.iconColor1, width: 2)
                      : null,
                  color: isSelected
                      ? StandardData.primaryColor
                      : isToday
                      ? StandardData.primaryColor.withAlpha(100)
                      : StandardData.backgroundColor1,
                ),
                child: Column(
                  children: [
                    Text(months[date.month]),
                    SizedBox(height: 5),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(days[date.weekday - 1]),
                  ],
                ),
              ),
            );
          },
          onDateChange: (date) {
            setState(() {
              _selectedDate = date;
            });
            filterEventOrTask(date);
            print(date);
          },
        ),
        Container(
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.598,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: StandardData.backgroundColor1,
          ),
          child: isFetching
              ? SpinKitThreeBounce(color: StandardData.primaryColor, size: 26)
              : filteredEventsNTasks.isEmpty
              ? Center(
                  child: Image.asset(
                    "assets/no_events_empty_state.png",
                    opacity: const AlwaysStoppedAnimation<double>(2),
                  ),
                )
              : EventsAndTasksWidget(eventsAndTasks: filteredEventsNTasks),
        ),
      ],
    );
  }
}

class EventsAndTasksWidget extends StatefulWidget {
  final List<Map<String, dynamic>> eventsAndTasks;
  const EventsAndTasksWidget({super.key, required this.eventsAndTasks});

  @override
  State<EventsAndTasksWidget> createState() => _EventsAndTasksWidgetState();
}

class _EventsAndTasksWidgetState extends State<EventsAndTasksWidget> {
  @override
  Widget build(BuildContext context) {
    int totalEvents = widget.eventsAndTasks.length;
    int completedEvents = 0;
    int upcomingEvents = 0;

    void setComplete() {}

    void setUpcoming() {
      print(widget.eventsAndTasks);
      final DateTime now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;
      widget.eventsAndTasks.forEach((event) {
        final eventDate = (event["eventDate"] as Timestamp).toDate();
        final eventMinutes = eventDate.hour * 60 + eventDate.minute;
        if (eventMinutes > nowMinutes) {
          upcomingEvents++;
        }
      });
      print(widget.eventsAndTasks);
      print(widget.eventsAndTasks.length);
    }

    @override
    void initState() {
      super.initState();
      setUpcoming();
    }

    Future<void> markTaskComplete(String name) async {
      //   try{
      //
      //     await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("dailyDetails").update({
      //
      //     });
      //   }
    }

    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StandardData.backgroundColor2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      totalEvents.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "events/tasks today",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StandardData.backgroundColor2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upcoming",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      upcomingEvents.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "events/tasks today",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.eventsAndTasks.length,
            padding: EdgeInsets.all(0),
            itemBuilder: (context, index) {
              DateTime eventDateTime =
                  (widget.eventsAndTasks[index]["eventDate"] as Timestamp)
                      .toDate();
              String hour = eventDateTime.hour.toString().padLeft(2, '0');
              String minute = eventDateTime.minute.toString().padLeft(2, '0');

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  spacing: 10,
                  children: [
                    Text("$hour:$minute"),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String formatted = DateFormat(
                                "EEEE, MMM d ⋅ h:mma",
                              ).format(eventDateTime);
                              return AlertDialog(
                                titlePadding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 15,
                                  bottom: 0,
                                ),
                                contentPadding: EdgeInsets.all(10),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.eventsAndTasks[index]["name"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            widget.eventsAndTasks[index]["type"] ==
                                                "Task"
                                            ? Colors.lightBlueAccent.withAlpha(
                                                100,
                                              )
                                            : Colors.greenAccent.withAlpha(100),
                                      ),
                                      child: Text(
                                        widget.eventsAndTasks[index]["type"],
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatted,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "Frequency: ${widget.eventsAndTasks[index]["frequency"]}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            markTaskComplete(
                                              widget
                                                  .eventsAndTasks[index]["name"],
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: StandardData
                                                .primaryColor
                                                .withAlpha(100),
                                          ),
                                          child: Text(
                                            "Mark Completed",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: StandardData
                                                .primaryColor
                                                .withAlpha(100),
                                          ),
                                          child: Text("Close"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: StandardData.backgroundColor2,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.eventsAndTasks[index]["name"],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          widget.eventsAndTasks[index]["type"] ==
                                              "Task"
                                          ? Colors.lightBlueAccent.withAlpha(
                                              100,
                                            )
                                          : Colors.greenAccent.withAlpha(100),
                                    ),
                                    child: Text(
                                      widget.eventsAndTasks[index]["type"],
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
