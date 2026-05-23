import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/FoodLog/daily_food_details.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePageCalorie extends StatefulWidget {
  final Map<String, dynamic> dailyDetails;
  const HomePageCalorie({super.key, required this.dailyDetails});

  @override
  State<HomePageCalorie> createState() => _HomePageCalorieState();
}

class _HomePageCalorieState extends State<HomePageCalorie> {
  DateTime now = DateTime.now();
  double calorieLimit = 2000;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateTime.now().toIso8601String().split("T")[0];

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("dailyDetails")
          .snapshots(),
      builder: (context, snapshot1) {
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot2) {
            double consumed = 0;
            double water = 0;
            double burned =
                double.tryParse(widget.dailyDetails['expend'].toString()) ?? 0;

            if (snapshot1.hasData &&
                snapshot1.data!.docs.isNotEmpty &&
                snapshot2.hasData &&
                snapshot2.data!.data()!.isNotEmpty) {
              final docs = snapshot1.data!.docs;
              final todayDoc = docs.where((doc) => doc.id == today).isNotEmpty
                  ? docs.firstWhere((doc) => doc.id == today)
                  : docs.first;

              consumed = double.tryParse(todayDoc['consumed'].toString()) ?? 0;
              water = double.tryParse(todayDoc['water'].toString()) ?? 0;
              calorieLimit =
                  double.tryParse(snapshot2.data!.data()!["calorieLimit"]) ??
                  2000;
            }

            double percentRatio = (consumed - burned) / calorieLimit;
            percentRatio = (percentRatio * 100).round() / 100;

            Color progressColor = StandardData.primaryColor;
            if (percentRatio > 1) {
              percentRatio = 1;
              progressColor = Colors.red;
            } else if (percentRatio < 0) {
              percentRatio = 0;
              progressColor = Colors.white;
            }

            List<List<dynamic>> details = [
              [
                Icon(Icons.restaurant_menu, color: StandardData.iconColor2),
                "Consumed",
                consumed.toString(),
              ],
              [
                Icon(Icons.water_drop, color: StandardData.iconColor1),
                "Drank",
                water.toString(),
              ],
              [
                Icon(Icons.flag, color: Colors.green),
                "Daily Goal",
                calorieLimit.toString(),
              ],
            ];

            return Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DailyFoodDetails()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: StandardData.backgroundColor1,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: StandardData.borderStrong,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Net Calories",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  CircularPercentIndicator(
                                    startAngle: 270,
                                    radius: 55,
                                    lineWidth: 8,
                                    percent: percentRatio,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    backgroundColor: StandardData.mainColor,
                                    progressColor: progressColor,
                                    animation: true,
                                    animationDuration: 2000,
                                    center: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text:
                                            "${(percentRatio * 100).toStringAsFixed(0)}%\n",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: "done",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: details.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          item[0],
                                          const SizedBox(width: 5),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item[1],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '${item[2].split(".")[0]} ${item[1] == 'Drank' ? 'ml' : 'kcal'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
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
    );
  }
}
