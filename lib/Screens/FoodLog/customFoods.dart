import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/FoodLog/food_log.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class CustomFoods extends StatefulWidget {
  const CustomFoods({super.key});

  @override
  State<CustomFoods> createState() => _CustomFoodsState();
}

class _CustomFoodsState extends State<CustomFoods>
    with AutomaticKeepAliveClientMixin {
  bool isFetching = true;
  bool isSearchingFavFoods = false;
  int count = 0;
  List<Map<String, dynamic>> customFoods = [];
  List<Map<String, dynamic>> favFoods = [];

  @override
  void initState() {
    super.initState();
    fetchCustomFoods();
  }

  @override
  bool get wantKeepAlive => true;

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

  Future<void> _fetchFavFoods() async {
    setState(() {
      isSearchingFavFoods = true;
    });
    try {
      final favFoodsDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favouriteFoods")
          .get();
      setState(() {
        favFoods = favFoodsDoc.docs.map((doc) {
          return doc.data();
        }).toList();
        isSearchingFavFoods = false;
      });
    } catch (e) {
      setState(() {
        isSearchingFavFoods = false;
      });
      StandardData.normalSnackbar(context, "Error searching favourite foods");
    }
  }

  Future<void> searchFoods(String value) async {
    setState(() {
      count = 0;
      isSearchingFavFoods = true;
    });
    final customFoodsSnapshot = await FirebaseFirestore.instance
        .collection("customFood")
        .where("name", isEqualTo: value)
        .get();
    setState(() {
      isSearchingFavFoods = false;
      customFoods = customFoodsSnapshot.docs.map((doc) {
        return doc.data();
      }).toList();
      count = customFoods.length;
    });
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
              onFieldSubmitted: (value) {
                searchFoods(value);
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  fetchCustomFoods();
                }
              },
            ),
          ),
          Text("Custom Foods", style: TextStyle(color: Colors.grey)),
          isFetching
              ? Center(child: Text("Fetching Foods..."))
              : count == 0
              ? Center(child: Text("No Food Found"))
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
                        margin: EdgeInsets.only(bottom: 10),
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
                                      return FoodDetails(
                                        food: customFoods[index],
                                        fetchFavFoods: _fetchFavFoods,
                                      );
                                    },
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customFoods[index]["name"],
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
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return LogFoodForm(
                                      food: customFoods[index],
                                    );
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: StandardData.primaryColor
                                    .withAlpha(100),
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
