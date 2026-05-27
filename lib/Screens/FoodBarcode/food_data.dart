import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitness/standardData.dart';
import 'package:intl/intl.dart';

class FoodData extends StatefulWidget {
  final Map<String, dynamic> product;
  const FoodData({super.key, required this.product});

  @override
  State<FoodData> createState() => _FoodDataState();
}

class _FoodDataState extends State<FoodData> {
  String _formatNutrient(dynamic value) {
    final parsed = double.tryParse(value.toString());
    return parsed != null ? parsed.toStringAsFixed(1) : '0';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    print(product);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new),
            ),
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                product['image'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[600],
                  child: const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['brand'] ?? 'Unknown Brand',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Nutrition Facts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: StandardData.borderStrong),

                  Row(
                    children: [
                      _NutritionCard(
                        label: 'Protein',
                        value: _formatNutrient(product['protein']),
                        unit: 'g',
                        color: StandardData.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _NutritionCard(
                        label: 'Carbs',
                        value: _formatNutrient(product['carbs']),
                        unit: 'g',
                        color: StandardData.amberColor,
                      ),
                      const SizedBox(width: 12),
                      _NutritionCard(
                        label: 'Fat',
                        value: _formatNutrient(product['fat']),
                        unit: 'g',
                        color: StandardData.tealColor,
                      ),
                      const SizedBox(width: 12),
                      _NutritionCard(
                        label: 'Sugar',
                        value: _formatNutrient(product['sugar']),
                        unit: 'g',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _NutritionCard(
                        label: 'Calorie/100g',
                        value: _formatNutrient(product['calories']),
                        unit: ' kcal',
                        color: Colors.lightGreen,
                      ),
                      const SizedBox(width: 12),
                      _NutritionCard(
                        label: 'Calorie/Serving',
                        value: _formatNutrient(product['caloriesServingSize']),
                        unit: ' kcal',
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Serving Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: StandardData.borderStrong),
                  _InfoRow('Serving Size', product['serving_size']),
                  _InfoRow('Serving Quantity', product['serving_quantity']),
                  _InfoRow('Packet Quantity', product['quantity']),

                  SizedBox(height: 24),

                  (product['name'] == null || product['name'] == 'Unknown') ||
                          (product['brand'] == null ||
                              product['brand'] == 'Unknown')
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) =>
                                  FoodLogFromBarcode(product: product),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: StandardData.purpleTint,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1,
                                color: StandardData.primaryColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Log Food",
                                style: TextStyle(
                                  color: StandardData.primaryColor,
                                ),
                              ),
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

class FoodLogFromBarcode extends StatefulWidget {
  final Map<String, dynamic> product;
  const FoodLogFromBarcode({super.key, required this.product});

  @override
  State<FoodLogFromBarcode> createState() => _FoodLogFromBarcodeState();
}

class _FoodLogFromBarcodeState extends State<FoodLogFromBarcode> {
  bool isWater = false;
  final quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  String _formatNutrient(dynamic value) {
    final parsed = double.tryParse(value.toString());
    return parsed != null ? parsed.toStringAsFixed(1) : '0';
  }

  Future<void> logFood() async {
    double? caloriePerHundredGram = widget.product['calories'];

    if (quantityController.text == "") {
      Navigator.pop(context);
      StandardData.normalSnackbar(context, "Field cannot be empty!");
      return;
    }

    double consumedQuantity = double.parse(quantityController.text);

    if (caloriePerHundredGram == null || caloriePerHundredGram == 0) {
      Navigator.pop(context);
      StandardData.normalSnackbar(
        context,
        "The fetched food has incorrect data format so can\'t be logged!",
      );
    } else {
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("foodLog")
            .doc(DateFormat("yyyy-MM-dd HH:mm:ss.SSSS").format(DateTime.now()))
            .set({
              'brandName': widget.product['brand'],
              'name': widget.product['name'],
              'quantity': 100.0,
              'unit': isWater ? 'ml' : 'g',
              'calorieConsumed': caloriePerHundredGram / 100 * consumedQuantity,
            });
        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("dailyDetails")
            .doc(DateFormat("yyyy-MM-dd").format(DateTime.now()))
            .update({
              "consumed": FieldValue.increment(
                caloriePerHundredGram / 100 * consumedQuantity,
              ),
              if (isWater) "water": FieldValue.increment(consumedQuantity),
            });
        Navigator.pop(context);
        StandardData.normalSnackbar(context, "Food Logged successfully!");
      } catch (e) {
        StandardData.normalSnackbar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: StandardData.borderStrong,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.product["name"] ?? "Unknown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Colors.red),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Due to inconsistent data, food can only be logged with respect to Calorie/100g",
                      softWrap: true,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Nutrition Facts",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _NutritionCard(
                  label: 'Calorie/100g',
                  value: _formatNutrient(widget.product['calories']),
                  unit: ' kcal',
                  color: StandardData.primaryColor,
                ),
                const SizedBox(width: 12),
                _NutritionCard(
                  label: 'Calorie/Serving',
                  value: _formatNutrient(widget.product['caloriesServingSize']),
                  unit: ' kcal',
                  color: StandardData.amberColor,
                ),
              ],
            ),
            SizedBox(height: 20),
            const Text(
              'Serving Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(color: StandardData.borderStrong),
            _InfoRow('Serving Size', widget.product['serving_size']),
            _InfoRow('Serving Quantity', widget.product['serving_quantity']),
            _InfoRow('Packet Quantity', widget.product['quantity']),
            SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: quantityController,
              decoration: InputDecoration(
                filled: true,
                fillColor: StandardData.backgroundColor1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                labelText: "Quantity",
                suffixText: "g/ml",
              ),
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: isWater,
                    onChanged: (value) {
                      setState(() {
                        isWater = value ?? false;
                      });
                      print(isWater);
                    },
                  ),
                ),
                Text(
                  "Mark if the food is liquid.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    logFood();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: StandardData.primaryColor,
                  ),
                  child: Text("Log Food"),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: StandardData.backgroundColor2,
                  ),
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final String unit;
  final Color color;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$value$unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _InfoRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value?.toString() ?? 'Unknown',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
