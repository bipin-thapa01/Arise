import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/Screens/FoodLog/customFoods.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodLog extends StatefulWidget {
  const FoodLog({super.key});

  @override
  State<FoodLog> createState() => _FoodLogState();
}

class _FoodLogState extends State<FoodLog> {
  bool isSearchingFavFoods = false;
  bool isSearching = false;
  bool isSearchComplete = false;
  String key = "";
  List<Map<String, dynamic>> favFoods = [];
  List<Map<String, dynamic>> searchFoods = [];

  @override
  void initState() {
    super.initState();
    _fetchKey();
    _fetchFavFoods();
  }

  Future<void> _fetchKey() async {
    final keyDoc = await FirebaseFirestore.instance
        .collection("key")
        .doc("food-api")
        .get();
    setState(() {
      key = keyDoc.data()!["key"];
    });
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

  Future<void> _searchFoods(String value) async {
    setState(() {
      searchFoods = [];
      isSearching = true;
      isSearchComplete = false;
    });
    final url = Uri.parse(
      'https://api.nal.usda.gov/fdc/v1/foods/search?query=$value&api_key=$key',
    );
    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        searchFoods = (data["foods"] as List<dynamic>)
            .map<Map<String, dynamic>>((food) {
              return {
                "name": food["description"].split(",")[0],
                "description": food["description"],
                "brandName": food["brandName"] ?? "",
                "ingredients": food["ingredients"] ?? "",
                "packageWeight": food["packageWeight"] ?? 0,
                "servingSize": food["servingSize"] ?? 0,
                "servingSizeUnit": food["servingSizeUnit"] ?? "",
                "foodNutrients": food["foodNutrients"] ?? [],
              };
            })
            .toList();
        isSearching = false;
        isSearchComplete = true;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
        isSearchComplete = true;
      });
      StandardData.normalSnackbar(context, "Error searching data");
    }
  }

  Future<void> saveFoodDetails(Map<String, dynamic> food) async {
    final foodsCollection = FirebaseFirestore.instance.collection("foods");
    final foodName = food["name"];
    final querySnapshot = await foodsCollection
        .where("name", isEqualTo: foodName)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      await foodsCollection.add(food);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Food Log",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          titleSpacing: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Favourites"),
              Tab(text: "Search"),
              Tab(text: "Custom Foods"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Favourite Foods",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                favFoods.isEmpty
                    ? isSearchingFavFoods
                          ? SliverToBoxAdapter(
                              child: Center(child: Text("Fetching...")),
                            )
                          : SliverToBoxAdapter(
                              child: Center(
                                child: Text("Empty Favourite List"),
                              ),
                            )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          return FoodDetails(
                                            food: favFoods[index],
                                            fetchFavFoods: _fetchFavFoods,
                                          );
                                        },
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(favFoods[index]["name"]),
                                        Text(
                                          "View Details>",
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
                                          food: favFoods[index],
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
                        }, childCount: favFoods.length),
                      ),
              ],
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Form(
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      height: 50,
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          _searchFoods(value);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: StandardData.backgroundColor2,
                          hintText: "Search Foods",
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      "Searched Foods",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                searchFoods.isEmpty
                    ? isSearchComplete
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Text(
                                  "No food found!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : isSearching
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Text(
                                  "Searching...",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : SliverToBoxAdapter(
                              child: Center(
                                child: Text(
                                  "Search for Foods",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) {
                                          saveFoodDetails(searchFoods[index]);
                                          return FoodDetails(
                                            food: searchFoods[index],
                                            fetchFavFoods: _fetchFavFoods,
                                          );
                                        },
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          searchFoods[index]["description"],
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
                                ),
                                TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return LogFoodForm(
                                          food: searchFoods[index],
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
                        }, childCount: searchFoods.length),
                      ),
              ],
            ),
            CustomFoods(),
          ],
        ),
      ),
    );
  }
}

class LogFoodForm extends StatefulWidget {
  final Map<String, dynamic> food;
  const LogFoodForm({super.key, required this.food});

  @override
  State<LogFoodForm> createState() => _LogFoodFormState();
}

class _LogFoodFormState extends State<LogFoodForm> {
  final _key = GlobalKey<FormState>();
  final TextEditingController logQuantity = TextEditingController();
  double quantity = 100.0;
  String unit = "g";
  double energy = 0;
  bool isWater = false;
  double waterAmount = 0;

  double getEnergy(List<dynamic> nutrients) {
    for (var item in nutrients) {
      if (item["nutrientName"] == "Energy") {
        return (item["value"] as num).toDouble();
      }
    }
    return 0;
  }

  void setQuantityAndUnit() {
    if (widget.food.containsKey("by")) {
      setState(() {
        quantity = (widget.food["servingSize"] as num).toDouble();
        unit = widget.food["servingSizeUnit"] as String;
        energy = getEnergy(widget.food["foodNutrients"]);
      });
      if (unit.toLowerCase() == "ml") {
        setState(() {
          isWater = true;
          waterAmount = quantity;
        });
      }
      if (unit.toLowerCase() == "l") {
        setState(() {
          isWater = true;
          waterAmount = quantity * 1000;
        });
      }
    } else {
      setState(() {
        energy = getEnergy(widget.food["foodNutrients"]);
      });
      final packageWeight = widget.food["packageWeight"] != ""
          ? widget.food["packageWeight"]
          : 0;
      if (packageWeight != 0) {
        if (packageWeight is! int) {
          final data = packageWeight.split("/");
          final value = data[data.length - 1];
          setState(() {
            quantity = double.tryParse(value.split(" ")[0]) ?? 100;
            unit = value.split(" ")[1];
          });
        } else {
          setState(() {
            quantity = packageWeight as double;
            unit = "g";
          });
        }
        if (unit.toLowerCase() == "ml") {
          setState(() {
            isWater = true;
            waterAmount = quantity;
          });
        }
        if (unit.toLowerCase() == "l") {
          setState(() {
            isWater = true;
            waterAmount = quantity * 100;
          });
        }
        return;
      }
      final servingSize = widget.food["servingSize"] != 0
          ? widget.food["servingSize"]
          : 100.0;
      final servingSizeUnit = widget.food["servingSizeUnit"] != ""
          ? widget.food["servingSizeUnit"]
          : "g";
      if (unit.toLowerCase() == "ml") {
        setState(() {
          isWater = true;
          waterAmount = quantity;
        });
      }
      if (unit.toLowerCase() == "l") {
        setState(() {
          isWater = true;
          waterAmount = quantity * 1000;
        });
      }
      setState(() {
        quantity = servingSize as double;
        unit = servingSizeUnit;
      });
    }
  }

  Future<void> logFood() async {
    if (_key.currentState!.validate()) {
      try {
        final inputQuantity = logQuantity.text;
        double eatenQuantity = double.tryParse(inputQuantity) ?? 0;
        double calorieConsumed = (eatenQuantity / quantity) * energy;
        String today = DateTime.now().toString().split(" ")[0];
        final docRef = FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("dailyDetails")
            .doc(today);

        Map<String, dynamic> dataToUpdate = {
          "consumed": FieldValue.increment(calorieConsumed),
        };

        if (isWater) {
          if (unit.toLowerCase() == 'l') {
            eatenQuantity = eatenQuantity * 1000;
            unit = "mL";
          }
          dataToUpdate["water"] = FieldValue.increment(eatenQuantity);
        }

        await docRef.set(dataToUpdate, SetOptions(merge: true));

        final Map<String, dynamic> foodLog = {
          "name": widget.food["name"],
          "brandName": widget.food["brandName"] ?? "",
          "quantity": eatenQuantity,
          "unit": unit,
          "calorieConsumed": calorieConsumed,
        };

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("foodLog")
            .doc(DateTime.now().toString())
            .set(foodLog);

        Navigator.pop(context);

        StandardData.normalSnackbar(context, "Food Logged successfully");
      } catch (e) {
        StandardData.normalSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setQuantityAndUnit();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white24,
                ),
              ),
            ),
            Center(
              child: Text(
                "Log Food",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.food["brandName"] != "")
                    Container(
                      padding: EdgeInsets.only(
                        top: 2,
                        bottom: 3,
                        left: 5,
                        right: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFa78bfa).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.food["brandName"],
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFa78bfa),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    "${widget.food["name"] ?? "Unknown Food"}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    widget.food["description"] ?? "",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Divider(),
                  Row(
                    spacing: 20,
                    children: [
                      if (widget.food["packageWeight"] != "")
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.backgroundColor2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Package Weight",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${widget.food["packageWeight"] ?? "NaN"}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.food["servingSize"] != null)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: StandardData.backgroundColor2,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Serving Size",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${widget.food["servingSize"]} ${widget.food["servingSizeUnit"]}",
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Divider(),
                  Form(
                    key: _key,
                    child: TextFormField(
                      controller: logQuantity,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field cannot be empty";
                        }
                        double v = double.tryParse(value) ?? 0;
                        if (v == 0 || v < 0) {
                          return "Negative value is not accepted";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: StandardData.backgroundColor2,
                        hintText: "Eaten Quantity",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffix: Text(unit),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 10,
                      children: [
                        TextButton(
                          onPressed: () {
                            logFood();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: StandardData.primaryColor
                                .withAlpha(100),
                          ),
                          child: Text("Log"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: StandardData.backgroundColor2
                                .withAlpha(100),
                          ),
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetails extends StatefulWidget {
  final Map<String, dynamic> food;
  final Future<void> Function() fetchFavFoods;

  const FoodDetails({
    super.key,
    required this.food,
    required this.fetchFavFoods,
  });

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  bool isFavourite = false;
  String by = "";

  @override
  void initState() {
    super.initState();
    if (widget.food["by"] != "") {
      _checkCreator();
    }
    _checkFavourite();
  }

  Future<void> _checkCreator() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.food["by"])
        .get();
    setState(() {
      by = user.data()!["displayName"] ?? "UnknownUser";
    });
  }

  Future<void> _checkFavourite() async {
    final result = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("favouriteFoods")
        .where("name", isEqualTo: widget.food["name"])
        .where("brandName", isEqualTo: widget.food["brandName"] ?? "")
        .limit(1)
        .get();
    if (result.docs.isNotEmpty) {
      setState(() {
        isFavourite = true;
      });
    }
  }

  Future<void> setFavouriteFood() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favouriteFoods")
          .add(widget.food);
      setState(() {
        isFavourite = true;
      });
      widget.fetchFavFoods();
    } catch (e) {
      StandardData.normalSnackbar(context, "Error setting fav food");
    }
  }

  Future<void> removeFavouriteFood() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("favouriteFoods")
          .where("name", isEqualTo: widget.food["name"])
          .where("brandName", isEqualTo: widget.food["brandName"])
          .get()
          .then((value) {
            value.docs.forEach((element) {
              element.reference.delete();
            });
          });

      setState(() {
        isFavourite = false;
      });
      widget.fetchFavFoods();
    } catch (e) {
      StandardData.normalSnackbar(context, "Error removing fav food");
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.food['name'] ?? '';
    final description = widget.food['description'] ?? '';
    final brandName = widget.food['brandName'] ?? '';
    final ingredientsRaw = widget.food['ingredients'] ?? '';
    final packageWeight = widget.food['packageWeight'] ?? 0;
    final servingSize = widget.food['servingSize'] ?? 0;
    final servingSizeUnit = widget.food['servingSizeUnit'] ?? '';
    final foodNutrients = widget.food['foodNutrients'] as List? ?? [];

    final ingredients = ingredientsRaw.toString().isNotEmpty
        ? ingredientsRaw
              .toString()
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (brandName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFa78bfa).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              brandName,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFa78bfa),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          name.isNotEmpty ? name : 'Unknown Food',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF5F5F5),
                            height: 1.3,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                              height: 1.5,
                            ),
                          ),
                        ],
                        if (by.isNotEmpty) ...[
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(text: "By @"),
                                TextSpan(
                                  text: by.replaceAll(" ", ""),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: StandardData.primaryColor.withAlpha(
                                      200,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    isFavourite
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () {
                                removeFavouriteFood();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              style: IconButton.styleFrom(iconSize: 18),
                              icon: Icon(Icons.favorite),
                            ),
                          )
                        : Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () {
                                setFavouriteFood();
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              style: IconButton.styleFrom(iconSize: 18),
                              icon: Icon(Icons.favorite_border),
                            ),
                          ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFF2A2A2A), height: 1),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (packageWeight != 0 || servingSize != 0) ...[
                      _SectionTitle('Serving Info'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (packageWeight != 0)
                            Expanded(
                              child: _MetricCard(
                                label: 'Package weight',
                                value: '$packageWeight',
                                unit: 'g',
                              ),
                            ),
                          if (packageWeight != 0 && servingSize != 0)
                            const SizedBox(width: 10),
                          if (servingSize != 0)
                            Expanded(
                              child: _MetricCard(
                                label: 'Serving size',
                                value: '$servingSize',
                                unit: servingSizeUnit,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    _SectionTitle('Ingredients'),
                    const SizedBox(height: 10),
                    ingredients.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252525),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: ingredients
                                  .map((i) => _IngredientChip(label: i))
                                  .toList(),
                            ),
                          )
                        : _EmptyState('No ingredients listed'),

                    const SizedBox(height: 20),

                    _SectionTitle('Nutrition Facts'),
                    const SizedBox(height: 10),
                    foodNutrients.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF252525),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: List.generate(foodNutrients.length, (
                                i,
                              ) {
                                final nutrient =
                                    foodNutrients[i] as Map<String, dynamic>;
                                return _NutrientRow(
                                  nutrient: nutrient,
                                  isLast: i == foodNutrients.length - 1,
                                  colorIndex: i,
                                );
                              }),
                            ),
                          )
                        : _EmptyState('No nutrition data available'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: Color(0xFF666666),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF0F0F0),
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String label;
  const _IngredientChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFa78bfa).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFa78bfa).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFFc4b5fd)),
      ),
    );
  }
}

const _nutrientColors = [
  Color(0xFFa78bfa),
  Color(0xFF60a5fa),
  Color(0xFF34d399),
  Color(0xFFfb923c),
  Color(0xFFf472b6),
  Color(0xFFfbbf24),
];

class _NutrientRow extends StatelessWidget {
  final Map<String, dynamic> nutrient;
  final bool isLast;
  final int colorIndex;

  const _NutrientRow({
    required this.nutrient,
    required this.isLast,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        nutrient['nutrientName'] ??
        nutrient['name'] ??
        nutrient['nutrient']?['name'] ??
        'Unknown';
    final amount = nutrient['value'] ?? nutrient['amount'] ?? 0;
    final unit =
        nutrient['unitName'] ??
        nutrient['unit'] ??
        nutrient['nutrient']?['unitName'] ??
        '';

    final double barFill = (amount is num)
        ? (amount / 100).clamp(0.0, 1.0).toDouble()
        : 0.0;

    final color = _nutrientColors[colorIndex % _nutrientColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.toString(),
              style: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: barFill,
                backgroundColor: const Color(0xFF333333),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              '$amount${unit.isNotEmpty ? ' $unit' : ''}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
      ),
    );
  }
}
