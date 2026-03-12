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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor = StandardData.primaryColor;
    List<List<dynamic>> details = [
      [
        Icon(Icons.restaurant_menu, color: StandardData.iconColor1),
        "Consumed",
        widget.dailyDetails['consumed'].toString(),
      ],
      [
        Icon(Icons.local_fire_department, color: StandardData.iconColor2),
        "Burned",
        widget.dailyDetails['expend'].toString(),
      ],
      [Icon(Icons.flag, color: Colors.green), "Daily Goal", "2000"],
    ];
    double consumed =
        double.tryParse(widget.dailyDetails['consumed'].toString()) ?? 0.0;

    double burned =
        double.tryParse(widget.dailyDetails['expend'].toString()) ?? 0.0;

    double percentRatio = (consumed - burned) / 2000;

    percentRatio = (percentRatio * 100).round() / 100;

    if (percentRatio > 1) {
      percentRatio = 1;
      progressColor = Colors.red;
    }

    if (percentRatio < 0) {
      percentRatio = 0;
      progressColor = Colors.white;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5, left: 20, right: 20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${months[now.month - 1]} ${now.day}, ${now.year}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: StandardData.backgroundColor1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Text(
                          "Net Calories",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        CircularPercentIndicator(
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
                              text: "${(percentRatio * 100)}%\n",
                              children: [
                                TextSpan(
                                  text: "done",
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        spacing: 10,
                        children: [
                          ...details.map((item) {
                            return Row(
                              spacing: 5,
                              children: [
                                item[0],
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item[1],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${item[2]} cal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
