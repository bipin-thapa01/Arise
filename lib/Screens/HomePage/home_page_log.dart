import 'package:fitness/Screens/AddFood/add_food.dart';
import 'package:fitness/Screens/FoodLog/food_log.dart';
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
      margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodLog()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StandardData.backgroundColor1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1,
                    color: StandardData.borderStrong,
                  ),
                ),
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
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFood()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: StandardData.backgroundColor1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1,
                    color: StandardData.borderStrong,
                  ),
                ),
                child: Column(
                  spacing: 5,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.add),
                    ),
                    Text("Add Food"),
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
