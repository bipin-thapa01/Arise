import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/standardData.dart';
import 'package:flutter/material.dart';

class EditDetails extends StatefulWidget {
  final int age;
  final String displayName;
  final String email;
  final String gender;
  final double goalWeight;
  final double height;
  final double weight;
  final String targetBody;
  const EditDetails({
    super.key,
    required this.age,
    required this.displayName,
    required this.email,
    required this.gender,
    required this.goalWeight,
    required this.height,
    required this.weight,
    required this.targetBody,
  });

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  String selectedType = "";
  String calorieLimit = "";
  final _key = GlobalKey<FormState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController goalWeightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  double calculateCalories({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String targetBody,
  }) {
    double bmr;
    if (gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    switch (targetBody) {
      case 'Lean':
        return (bmr * 1.2) - 300;

      case 'Normal':
        return bmr * 1.4;

      case 'Muscular':
        return (bmr * 1.6) + 200;

      case 'Bulky':
        return (bmr * 1.8) + 400;

      default:
        return bmr * 1.4;
    }
  }

  Future<void> updateData() async {
    if (_key.currentState!.validate()) {
      String displayName = displayNameController.text.trim();
      String gender = genderController.text.trim();
      String age = ageController.text.trim();
      String weight = weightController.text.trim();
      String goalWeight = goalWeightController.text.trim();
      String height = heightController.text.trim();
      String targetBody = selectedType;
      if (displayName == widget.displayName &&
          gender == widget.gender &&
          age == widget.age.toString() &&
          weight == widget.weight.toString() &&
          goalWeight == widget.goalWeight.toString() &&
          height == widget.height.toString() &&
          targetBody == widget.targetBody) {
        StandardData.normalSnackbar(context, "No changes found to update!");
        return;
      }
      try {
        if (targetBody != widget.targetBody ||
            gender != widget.gender ||
            age != widget.age.toString() ||
            weight != widget.weight.toString() ||
            goalWeight != widget.goalWeight.toString() ||
            height != widget.height.toString()) {
          calorieLimit = calculateCalories(
            weight: double.parse(weight),
            height: double.parse(height),
            age: int.parse(age),
            gender: gender,
            targetBody: targetBody,
          ).toString();
        }

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
              'displayName': displayName,
              'gender': gender,
              'age': age,
              'weight': weight,
              'goalWeight': goalWeight,
              'height': height,
              'targetBody': targetBody,
              if (calorieLimit.isNotEmpty) 'calorieLimit': calorieLimit,
            });

        StandardData.normalSnackbar(context, "Profile updated successfully!");
        Navigator.pop(context);
      } catch (e) {
        StandardData.normalSnackbar(context, e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    selectedType = widget.targetBody;
    displayNameController.text = widget.displayName;
    genderController.text = widget.gender;
    ageController.text = widget.age.toString();
    weightController.text = widget.weight.toString();
    goalWeightController.text = widget.goalWeight.toString();
    heightController.text = widget.height.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        titleSpacing: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
          child: Form(
            key: _key,
            child: Column(
              spacing: 20,
              children: [
                TextFormField(
                  controller: displayNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                TextFormField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText: "Gender",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Age",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Weight",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                TextFormField(
                  controller: goalWeightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "GoalWeight",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Height",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                DropdownButtonFormField2(
                  items: ['Lean', 'Normal', 'Muscular', 'Bulky']
                      .map(
                        (item) => DropdownItem(child: Text(item), value: item),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    hintText: selectedType,
                    labelText: "Target Body Type",
                    filled: true,
                    fillColor: StandardData.backgroundColor1,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? selectedType;
                    });
                  },
                ),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      updateData();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: StandardData.primaryColor,
                    ),
                    child: Text("Update Profile"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
