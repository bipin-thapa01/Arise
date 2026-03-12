import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePageAppbar extends StatefulWidget {
  final data;

  const HomePageAppbar({super.key, required this.data});

  @override
  State<HomePageAppbar> createState() => _HomePageAppbarState();
}

class _HomePageAppbarState extends State<HomePageAppbar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      title: Row(
        spacing: 10,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              image: DecorationImage(
                image: AssetImage('assets/user.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            "Welcome, ${widget.data?['name']}",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none),
          // style: IconButton.styleFrom(
          //   backgroundColor: StandardData.backgroundColor1,
          // ),
        ),
      ],
    );
  }
}
