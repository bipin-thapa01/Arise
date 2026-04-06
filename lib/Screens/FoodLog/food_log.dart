import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class FoodLog extends StatefulWidget {
  const FoodLog({super.key});

  @override
  State<FoodLog> createState() => _FoodLogState();
}

class _FoodLogState extends State<FoodLog> {
  List<Map<String, dynamic>> foods = [];

  Future<void> _fetchFood() async {
    try {
      final foodsDoc = await FirebaseFirestore.instance
          .collection("foods")
          .limit(20)
          .get();
      setState(() {
        foods = foodsDoc.docs.map((doc) {
          return doc.data();
        }).toList();
      });
    } catch (e) {
      StandardData.errorSnackbar(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Search"),
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Form(
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Search Food",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: foods.isEmpty
                ? Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Center(child: Text("Fetching...")),
                  )
                : Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: foods.length,
                        itemBuilder: (item, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.backgroundColor1,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return FoodDetails(food: foods[index]);
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foods[index]["name"],
                                    overflow: TextOverflow.ellipsis,
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
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class FoodDetails extends StatefulWidget {
  final Map<String, dynamic> food;
  const FoodDetails({super.key, required this.food});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
