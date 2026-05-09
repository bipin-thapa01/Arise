import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class CustomFoods extends StatefulWidget {
  const CustomFoods({super.key});

  @override
  State<CustomFoods> createState() => _CustomFoodsState();
}

class _CustomFoodsState extends State<CustomFoods> {
  bool isFetching = true;
  int count = 0;
  List<Map<String, dynamic>> customFoods = [];

  @override
  void initState() {
    super.initState();
    fetchCustomFoods();
  }

  Future<void> fetchCustomFoods() async {
    try {
      final countSnapshot = await FirebaseFirestore.instance
          .collection("customFood")
          .count()
          .get();
      count = countSnapshot.count ?? 0;
      final customFoodsSnapshot = await FirebaseFirestore.instance
          .collection("customFood")
          .limit(50)
          .get();
      setState(() {
        customFoods = customFoodsSnapshot.docs.map((doc) {
          return doc.data();
        }).toList();
        isFetching = false;
      });
    } catch (e) {
      StandardData.normalSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: StandardData.backgroundColor2,
                hintText: "Search Food",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Text("Custom Foods", style: TextStyle(color: Colors.grey)),
          isFetching
              ? Center(child: Text("Fetching Foods..."))
              : count == 0
              ? Center(child: Text("No Custom Foods"))
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customFoods.length < 50
                        ? customFoods.length
                        : 50,
                    padding: EdgeInsetsGeometry.all(0),
                    itemBuilder: (item, index) {
                      return Container(
                        padding: EdgeInsetsGeometry.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: StandardData.backgroundColor1,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return CustomFoodView();
                                    },
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customFoods[index]["description"],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      "View Details >",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: StandardData.primaryColor
                                    .withAlpha(200),
                              ),
                              child: Text("Log Food"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class CustomFoodView extends StatefulWidget {
  const CustomFoodView({super.key});

  @override
  State<CustomFoodView> createState() => _CustomFoodViewState();
}

class _CustomFoodViewState extends State<CustomFoodView> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return Container();
      },
    );
  }
}
