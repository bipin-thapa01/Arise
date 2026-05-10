import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class AddFood extends StatelessWidget {
  const AddFood({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Food",
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Add Custom Foods",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 20),
                  FoodForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodForm extends StatefulWidget {
  const FoodForm({super.key});

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final inputs = [
    {"name": "Food Name", "type": "Text"},
    {"name": "Serving Size", "type": "Number"},
    {"name": "Serving Unit", "type": "List"},
    {"name": "Calories", "type": "Number"},
  ];
  final units = ["gm", "kg", "ml", "L"];
  String selectedValue = "gm";

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var i in inputs) {
      _controllers[i["name"]!] = TextEditingController();
    }
  }

  Future<void> saveFood() async {
    if (!_formKey.currentState!.validate()) return;
    if (_controllers[inputs[0]["name"]]!.text.isEmpty ||
        _controllers[inputs[1]["name"]]!.text.isEmpty ||
        _controllers[inputs[3]["name"]]!.text.isEmpty) {
      StandardData.normalSnackbar(context, "All fields are required!");
      return;
    }

    try {
      FirebaseFirestore.instance.collection("customFood").add({
        "name": _controllers[inputs[0]["name"]]!.text,
        "brandName": "Custom",
        "servingSize": double.parse(_controllers[inputs[1]["name"]]!.text),
        "servingSizeUnit": selectedValue,
        "foodNutrients": [
          {
            "nutrientName": "Energy",
            "value": double.parse(_controllers[inputs[3]["name"]]!.text),
            "unitName": "KCAL",
          },
        ],
        "createdAt": FieldValue.serverTimestamp(),
        "by": FirebaseAuth.instance.currentUser!.uid,
      });
      StandardData.normalSnackbar(context, "Food Added Successfully!");
      Navigator.pop(context);
    } catch (e) {
      StandardData.normalSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _controllers[inputs[0]["name"]],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 1,
                  color: StandardData.primaryColor,
                ),
              ),
              filled: true,
              fillColor: StandardData.backgroundColor1,
              labelText: inputs[0]["name"],
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _controllers[inputs[1]["name"]],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 1,
                        color: StandardData.primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    labelText: inputs[1]["name"],
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField2(
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    fillColor: StandardData.backgroundColor1,
                    labelText: inputs[2]["name"],
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  hint: Text(
                    selectedValue,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value ?? "gm";
                    });
                  },
                  items: units.map((item) {
                    return DropdownItem(value: item, child: Text(item));
                  }).toList(),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _controllers[inputs[3]["name"]],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 1,
                  color: StandardData.primaryColor,
                ),
              ),
              filled: true,
              fillColor: StandardData.backgroundColor1,
              labelText: inputs[3]["name"],
              labelStyle: TextStyle(color: Colors.grey),
              suffixText: "kcal",
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              saveFood();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.only(left: 30, right: 30),
              backgroundColor: StandardData.primaryColor,
            ),
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
