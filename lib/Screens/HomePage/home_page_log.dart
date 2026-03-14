import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class HomePageLog extends StatefulWidget {
  const HomePageLog({super.key});

  @override
  State<HomePageLog> createState() => _HomePageLogState();
}

class _HomePageLogState extends State<HomePageLog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: StandardData.backgroundColor1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StandardData.backgroundColor2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  spacing: 5,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: StandardData.iconColor1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.fastfood),
                    ),
                    Text("Log Food"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StandardData.backgroundColor2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  spacing: 5,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.sports_baseball),
                    ),
                    Text("Log Workout"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
