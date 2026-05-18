import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DailyFoodDetails extends StatefulWidget {
  const DailyFoodDetails({super.key});

  @override
  State<DailyFoodDetails> createState() => _DailyFoodDetailsState();
}

class _DailyFoodDetailsState extends State<DailyFoodDetails> {
  DateTime now = DateTime.now();
  double calorieLimit = 2000;
  double calorieConsumed = 0;
  double calorieRemaining = 2000;
  double waterConsumed = 0;
  double percentage = 0;
  List<Map<String, dynamic>> foodLog = [];
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      String todayDate = DateFormat("yyyy-MM-dd").format(now);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      final dailyDetail = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("dailyDetails")
          .doc(todayDate)
          .get();
      final todayFoodLogDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("foodLog")
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: todayDate)
          .where(FieldPath.documentId, isLessThan: todayDate + "\uf8ff")
          .get();
      setState(() {
        calorieLimit = double.parse(userData.data()?["calorieLimit"] ?? 2000);
        calorieConsumed = dailyDetail.data()?["consumed"] ?? 0;
        calorieRemaining = calorieLimit - calorieConsumed;
        waterConsumed = dailyDetail.data()?["water"] ?? 0;
        percentage = calorieConsumed / calorieLimit;
        foodLog = todayFoodLogDoc.docs
            .map(
              (doc) => {
                "name": doc.data()["name"],
                "brandName": doc.data()["brandName"],
                "calorieConsumed": doc.data()["calorieConsumed"],
                "quantity": doc.data()["quantity"],
                "unit": doc.data()["unit"],
                "id": doc.id,
              },
            )
            .toList();
        isFetching = false;
      });
    } catch (e) {
      StandardData.normalSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Today\'s Food Log",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: isFetching
          ? Center(
              child: SpinKitThreeBounce(
                color: StandardData.primaryColor,
                size: 24,
              ),
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  TopData(
                    percentage: percentage,
                    calorieConsumed: calorieConsumed,
                    calorieLimit: calorieLimit,
                    calorieRemaining: calorieRemaining,
                    waterConsumed: waterConsumed,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Meals",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: StandardData.backgroundColor2,
                        ),
                        child: Text(
                          "${foodLog.length.toString()} items",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: foodLog.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                "${foodLog[index]["id"].split(" ")[1].split(".")[0]}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: StandardData.backgroundColor1,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 1,
                                      color: StandardData.borderStrong,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0
                                              ? StandardData.purpleTint
                                              : StandardData.amberTint,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: index % 2 == 0
                                                ? StandardData.primaryColor
                                                : StandardData.amberColor,
                                          ),
                                        ),
                                        child:
                                            foodLog[index]["unit"]
                                                        .toLowerCase() !=
                                                    "ml" &&
                                                foodLog[index]["unit"] != "l"
                                            ? Icon(
                                                Icons.fastfood,
                                                color: index % 2 == 0
                                                    ? StandardData.primaryColor
                                                    : StandardData.amberColor,
                                              )
                                            : Icon(
                                                Icons.water_drop,
                                                color: index % 2 == 0
                                                    ? StandardData.primaryColor
                                                    : StandardData.amberColor,
                                              ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              foodLog[index]['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${foodLog[index]['quantity']} ${foodLog[index]['unit']}",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "${foodLog[index]["calorieConsumed"].ceil()} kcal",
                                        style: TextStyle(
                                          color: StandardData.tealColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
    );
  }
}

class TopData extends StatefulWidget {
  final double percentage;
  final double calorieConsumed;
  final double calorieLimit;
  final double calorieRemaining;
  final double waterConsumed;
  const TopData({
    super.key,
    required this.percentage,
    required this.calorieConsumed,
    required this.calorieLimit,
    required this.calorieRemaining,
    required this.waterConsumed,
  });

  @override
  State<TopData> createState() => _TopDataState();
}

class _TopDataState extends State<TopData> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: StandardData.backgroundColor1,
        border: Border.all(color: StandardData.borderStrong, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                CircularPercentIndicator(
                  radius: 35,
                  percent: widget.percentage,
                  progressColor: StandardData.primaryColor,
                  startAngle: 270,
                  lineWidth: 6,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: StandardData.mainColor,
                  animation: true,
                  animationDuration: 2000,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${(widget.percentage * 100).ceilToDouble()}%",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "done",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Consumed",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text("${widget.calorieConsumed.ceil()} kcal"),
                SizedBox(height: 10),
                Text(
                  "Daily Goal",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text("${widget.calorieLimit.ceil()} kcal"),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Remaining",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  "${widget.calorieRemaining.ceil()} kcal",
                  style: TextStyle(color: StandardData.tealColor),
                ),
                SizedBox(height: 10),
                Text(
                  "Hydration",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text("${widget.waterConsumed.ceil()} ml"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
