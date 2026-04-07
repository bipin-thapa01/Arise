import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodSearch extends StatefulWidget {
  const FoodSearch({super.key});

  @override
  State<FoodSearch> createState() => _FoodLogState();
}

class _FoodLogState extends State<FoodSearch> {
  bool isSearching = false;
  bool isSearchComplete = false;
  String key = "";
  List<Map<String, dynamic>> foods = [];

  Future<void> _fetchKey() async {
    final keyDoc = await FirebaseFirestore.instance
        .collection("key")
        .doc("food-api")
        .get();
    setState(() {
      key = keyDoc.data()!["key"];
    });
  }

  Future<void> _searchForFood(String value) async {
    setState(() {
      foods = [];
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
        foods = (data["foods"] as List<dynamic>).map<Map<String, dynamic>>((
          food,
        ) {
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
        }).toList();
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
  void initState() {
    super.initState();
    _fetchKey();
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
                  onFieldSubmitted: (value) {
                    _searchForFood(value);
                  },
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
          foods.isEmpty
              ? isSearchComplete
                    ? SliverToBoxAdapter(
                        child: Center(child: Text("No food found!")),
                      )
                    : isSearching
                    ? SliverToBoxAdapter(
                        child: Center(child: Text("Searching...")),
                      )
                    : SliverToBoxAdapter(
                        child: Center(child: Text("Search for Foods.")),
                      )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            saveFoodDetails(foods[index]);
                            return FoodDetails(food: foods[index]);
                          },
                        );
                      },
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foods[index]["description"],
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
                  }, childCount: foods.length),
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
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _checkFavourite();
  }

  Future<void> _checkFavourite() async {
    final favouriteFoodDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("favouriteFoods")
        .get();
    if (favouriteFoodDocs.docs.isNotEmpty) {
      final favFood = favouriteFoodDocs.docs.where((doc) {
        return doc.data()["name"] == widget.food["name"] &&
            doc.data()["brandName"] == widget.food["brandName"];
      });
      if (favFood.isNotEmpty) {
        setState(() {
          isFavourite = true;
        });
      }
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
      initialChildSize: 0.6,
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
