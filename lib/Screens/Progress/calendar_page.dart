import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
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

  @override
  Widget build(BuildContext context) {
    return EasyDateTimeLinePicker.itemBuilder(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      },
    );
  }
}
