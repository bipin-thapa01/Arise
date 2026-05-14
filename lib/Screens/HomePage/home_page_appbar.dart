import 'package:flutter/material.dart';
import 'package:fitness/standardData.dart';

class HomePageAppbar extends StatefulWidget {
  final data;

  const HomePageAppbar({super.key, required this.data});

  @override
  State<HomePageAppbar> createState() => _HomePageAppbarState();
}

class _HomePageAppbarState extends State<HomePageAppbar> {
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        spacing: 10,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: DecorationImage(
                image: AssetImage('assets/user.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${widget.data?['name']}",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "${months[now.month - 1]} ${now.day}, ${now.year}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),

      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: Icon(Icons.notifications_none),
      //     // style: IconButton.styleFrom(
      //     //   backgroundColor: StandardData.backgroundColor1,
      //     // ),
      //   ),
      // ],
    );
  }
}
